unit CFacturacionCCB;

interface

uses CObrasSocialesCCB, CProfesionalCCB, CPacienteCCB, CNomeclaCCB, SysUtils, CListar,
     DB, DBTables, CBDT, CUtiles, CIDBFM, CUsuario, Forms, Unit1, WinProcs, CUtilidadesArchivos,
     Classes, CServers2000_Excel, CNBU, CNomeclatura_ObraSocial, CAgrupacionOSFact, CUnidadesNBU,
     CFirebird, IBTable, IBQuery, uLkJSON;

const
  elementos = 10;

type
 TTFacturacionCCB = class(TObject)
  periodo, idprof, codos, codpac, modelo, moneda, directorio, LaboratorioActual, attach, NProfesional: string; NroColumnas, LineasPag, lineas, lineas_audit, lineas_blanco: ShortInt;
  ExisteLiquidacion, ruptura, LaboratorioActivo: Boolean; copias, salto: ShortInt;
  ExportarTotalesProfInscriptosIVA, factglobal, omitir_ressql: Boolean;
  REGLA_EXPORTACION: integer; // 25/06/2018
  NRO_AUDITORIA, NRO_AFILIADO, NRO_AUTORIZACION, FECHA_ORDEN: string; // 25/06/2018
  FechaHoraImport, DirectorioImport, UsuarioImport, ModoImport, transfImport, idcFact, tipoFact, sucursalFact, numeroFact: String;
  _caran: Real;
  ExcluirLab, SC, DetMontoFijo, exporta_web, listtotalboleta, exporta_afip: Boolean;
  listlab: array[1..elementos+5] of String;
  cabfact, detfact, idordenes, parametrosInf, modeloc, cabfactos, liq, datosfact, datosfactdet, ctrlImpr, historico, totalesOS, totalesPROF, ordenes_audit, datosImport, cab_auditoria, det_auditoria, wtotalesprof: TTable;
  //cabfactIB, detfactIB, idordenesIB, ordenes_auditIB, cab_auditoriaIB, det_auditoriaIB: TIBTable;
  interbase: string;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   Grabar(xperiodo, xidprof, xcodos, xitems, xcodpac, xnombre, xcodanalisis, xorden, xperiodo1, xretiva, xmontocoseguro: string; modifica, guardar_orden_interna: boolean);
  procedure   GrabarIB(xperiodo, xidprof, xcodos, xitems, xcodpac, xnombre, xcodanalisis, xorden, xperiodo1, xretiva, xnroauditoria: string; modifica, guardar_orden_interna: boolean; xnroafiliado, xnroautorizacion, xfecha, xmontocoseguro: string);
  procedure   Borrar(xperiodo, xidprof, xcodos: String);
  procedure   BorrarMovimientosLaboratorio(xperiodo, xidprof: String; ProcesamientoIndividual: Boolean);
  procedure   BorrarPeriodo(xperiodo: String; ProcesamientoIndividual: Boolean);
  procedure   getDatos;
  function    Buscar(xperiodo, xidprof, xcodos: string): boolean;
  procedure   RenumerarOrdenesInternas(xperiodo, xidprof: String);
  procedure   BorrarOrden(xperiodo, xorden, xidprof: String);
  procedure   GuardarOrdenInterna(xperiodo, xidprof, xorden: string);
  procedure   VerificarOrdenInterna(xperiodo, xidprof: string);
  function    verificarMovimientosObraSocial(xperiodo, xidprof, xcodos: string): boolean;
  procedure   marcarOrdenesFactGlobal(xperiodo, xidprof, xcodos, xorden, xidproffact: string);
  procedure   iniciarFacturacionIB(xperiodo: string); overload;
  procedure   iniciarFacturacionIB(xperiodo, xcodos: string); overload;
  procedure   iniciarFacturacionIBOL(xperiodo, xcodos: string); overload;

  procedure   desconectarFacturacionIB;
  procedure   reconectarFacturacionIB;

  function    setItems: TQuery;
  function    setItemsIB: TIBQuery;
  function    setItemsIBAll(xperiodo, xidprof, xcodos: string): TIBQuery;
  function    NuevaOrdenInterna(xperiodo, xidprof, xcodos: string): string;
  function    NuevoItems(xperiodo, xidprof, xcodos: String): Integer;
  function    verificarSiLaObraSocialTieneMovimientos(xperiodo, xcodos: String): Boolean;
  procedure   InactivarLaboratorio;
  function    setUB: Real;
  function    setUG: Real;
  function    setTotCompensacion: Real;
  function    setTot9984: Real;
  function    set9984: Real;
  function    setCodigoMontoFijo: String;

  procedure   ListarResumenPrestacionesPorObraSocial(xperiodo, xtitulo, xcolumnas: String; ObrasSocSel: TStringList; salida: char);
  procedure   ListarResumenPorObraSocial(xperiodo, xtitulo: String; ObrasSocSel: TStringList; salida: char; xinf_com: Boolean);
  procedure   ListarResumenPorProfesional(xperiodo, xtitulo: String; profSel: TStringList; ObrasSocSel: TStringList; salida: char);
  procedure   ListarTotGralesObrasSociales(xperiodo, xtitulo: String; ObrasSocSel: TStringList; salida: Char);
  procedure   ListarResumenAProfesionales(xperiodo, xtitulo, xcolumnas: String; xruptura: Boolean; profSel, ObrasSocSel: TStringList; salida: char);
  procedure   ListarResumenAProfesionalesRI(xperiodo, xtitulo, xcolumnas: String; xruptura: Boolean; profSel, ObrasSocSel: TStringList; salida: char);
  procedure   ListarControlesFinales(xperiodo, xtitulo, xcolumnas: String; profSel, ObrasSocSel: TStringList; presentar_inf: Boolean; salida: char);
  procedure   ListarOrdenesAuditadas(xperiodo: String; profSel: TStringList; presentar_inf: Boolean; salida: char);
  procedure   ListarContorlesAuditoria(xperiodo: String; salida: Char);
  procedure   ListarOrdenesAuditoriaFacturadas(lista: TStringList; salida: char);
  procedure   ListarResumenRetencionesIVA(xperiodo, xtitulo: String; profSel: TStringList; ObrasSocSel: TStringList; salida: char; xinf_com: Boolean);
  procedure   ListarCosegurosFacturados(xperiodo: String; salida: Char);

  procedure   ExportarInforme(xarchivo: String);
  procedure   FinalizarExportacion;
  procedure   IniciarFacturacionWeb(xperiodo: string);

  procedure   GuardarModeloFact(xid, xmodelo: string);
  procedure   getDatosModeloFact(xid: string);

  function    setLiquidaciones: TQuery;
  function    setNumeroDeLiquidacion(xperiodo, xcodos: String): String;
  procedure   EstablecerNroLiquidacion(xperiodo, xnroliq: String);

  procedure   IniciarFacturacion(salida: char; ximpresora: integer);
  function    BuscarDatosFact(xperiodo, xcodos: String): Boolean;
  function    FacturarObraSociales(xperiodo, xcodos, xfecha, xvencimiento, xvto1, xvto2, xobservacion, xidcompr, xtipo, xsucursal, xnumero: String; xPorc1, xPorc2: Real; salida: char; agrupa: string): Boolean;
  function    FacturarObraSocialesFormBlanco(xperiodo, xcodos, xfecha, xvencimiento, xvto1, xvto2, xobservacion, xidcompr, xtipo, xsucursal, xnumero: String; xPorc1, xPorc2: Real; salida: char;
                                             xasociacion, xdireccion, xlocalidad, xtelefono, xcuit, xsuss, xibrutos, xiva: String): Boolean;
  procedure   ListarFacturacion(salida: Char);
  procedure   getDatosFact(xperiodo, xcodos: String);
  procedure   AjustarDatosFact(xperiodo, xcodos, xidcompr, xtipo, xsucursal, xnumero: String);

  function    BuscarDatosFactDet(xperiodo, xcodos, xitems: String): Boolean;

  procedure   Exportar(xperiodo, xidprof, xprofesional: String; listOS: TStringList; xtodoslospacientes: Boolean);
  procedure   CopiarDatosExportados(xdrive: String);
  function    setDatosExportados(xperiodo: String): TQuery;
  function    setDatosExport(xperiodo: String): TQuery;
  function    setDatosIngresados(xperiodo: String): TQuery;

  procedure   Importar(xperiodo, xidlab, xlaboratorio, xdrive: String);
  function    setDirectorioImportacion: String;
  function    setObrasSocialesImportadas(xidprof: String): TQuery;
  function    setObrasSocialesImportadasIB(xidprof: String): TIBQuery;
  procedure   TransferirDatosImportados(xperiodo, xidprof: String; listOS: TstringList);
  procedure   getDatosImportados(xperiodo, xidprof: String);

  function    setDatosImportados(xperiodo: String): TStringList;
  function    setLaboratoriosImportados(xperiodo: String): TStringList;
  function    setDatosIngresadosEnElDia: TQuery;

  procedure   PrepararDirectorio(xperiodo, xlaboratorio: String);
  function    DireccionarLaboratorio(xperiodo, xlaboratorio: String): Boolean;
  procedure   ProcesarDatosCentrales(xperiodo: String);
  procedure   CopiarEstructuras(xperiodo: String);
  procedure   ProcesarDatosHistoricos;

  function    ProcesarUnificados: Boolean;

  function    verificicarSiExisteLaboratorio(xperiodo, xlaboratorio: String): Boolean;

  procedure   Depurar(xperiodo: String);
  procedure   DepurarIB(xperiodo: String);
  function    VerificarPeriodoHistorico(xperiodo: String): Boolean;
  function    VerificarSiElPeriodoEstaDepurado(xperiodo: String): Boolean;
  procedure   BorrarDirectoriosDepurados;

  procedure   ConfigurarInforme(xreporte: String; xcopias, xsalto: ShortInt);
  procedure   getConfiguracionInforme(xreporte: String);

  procedure   FiltrarPeriodo(xperiodo: String);
  procedure   QuitarFiltro;

  procedure   SeleccionarLaboratorio(xdirectorio: String);

  procedure   Bloquear;
  function    verificarBloqueo: Boolean;
  procedure   QuitarBloqueo;
  procedure   ReiniciarProcesamientoCentral;
  procedure   ReiniciarProcesamientoIndividual;
  procedure   PrepararRegistrosTransferenciaFinalTodos(xperiodo: string); overload;
  procedure   PrepararRegistrosTransferenciaFinal(xperiodo, xidprof: String); overload;
  procedure   TransferenciaFinal(xperiodo, xidprof, xprofesional: String);
  procedure   TransferenciaFinalLaboratorios(xperiodo: String);
  procedure   CerrarTransferenciaFinal;

  procedure   UnificarPeriodosFacturados(xperiodos: TStringList);
  function    setPeriodoUnificacion: String;

  function    setTotalFactObraSocial(xperiodo, xcodos: String): Real;
  procedure   BorrarTotalFactObraSocial(xperiodo, xcodos: String);
  function    setTotalProfesional(xperiodo, xidprof, xcodos: String): Real; overload;
  function    setTotalProfesional(xperiodo, xcodos: String): Real; overload;
  function    setTotalProfesionalFacturaElectronica(xperiodo, xidprof: String): TQuery;
  procedure   registrarFacturaElectronica(xperiodo, xidprof, xcodos, xtipo, xsucursal, xnumero: String);
  function    setTotalUG: Real;
  function    setTotalUB: Real;
  function    setTotalCaran: Real;
  function    setTotalNeto: Real;
  function    setTotUBSin9984: Real;
  function    setTotUGSin9984: Real;
  function    setTotUB9984: Real;
  function    setTotUG9984: Real;
  function    setCaranSin9984: Real;
  function    setCaran9984: Real;
  procedure   IniciarTotalFacturado(xperiodo: String);
  procedure   IniciarTotalFacturadoObrasSociales(xperiodo: String);
  function    setTotalFacturado(xperiodo: String): Real; overload;
  function    setTotalFacturado(xperiodo, xcodos: String): Real; overload;
  function    setTotalFacturadoProfesionales(xperiodo: String): Real; overload;
  procedure   CalcularTotalFacturadoProfesionales(xperiodo: String; xinicializa_montos: Boolean);
  function    setTotalFacturadoProfesionales(xperiodo, xcodos: String): Real; overload;
  function    setTotalProfesionalesLiquidacion(xperiodo: String; listSel: TStringList; xincluirinscriptosiva: Boolean): TStringList;
  function    setRecalcularProfesionalesLiquidacion(xperiodo: String; listSel: TStringList; xincluirinscriptosiva: Boolean): Real;
  function    setDeterminacionesFacturadas(xperiodo: String): TQuery;
  function    setRangoPeriodos: String;
  function    setDeterminacionesFacturadasPorObraSocial(xperiodo, xcodos: String): TQuery;
  function    setDeterminacionesFacturadasPorObraSocialIB(xperiodo, xcodos: String): TIBQuery;
  function    setNominaProfesionalesQueFacturaronPorObraSocial(xperiodo, xcodos: String): TQuery;
  function    setCantidadPacientesFacturadosObraSocial(xperiodo, xcodos: String): Integer;
  procedure   CalcularMontosFacturacion(xperiodo: String);
  procedure   InformeTotalObrasSociales(xperiodo: String; listSel: TStringList; salida: Char);

  function    setNetoACobrarProfesional(xperiodo, xidprof, xcodos: String): Real; overload;
  function    setMontoACobrarProfesional(xperiodo, xidprof: String): Real;

  procedure   GuardarTotalProfesionalDistribucion(xperiodo, xidprof, xcodos: String; xmonto, xneto, xgrabado, xexento, xiva: Real);

  function    setItemsTotalFacturado(xperiodo: String): TQuery;
  function    setItemsTotalFacturadoProfesionales(xperiodo: String): TQuery; overload;
  function    setItemsTotalFacturadoProfesionales(xperiodo, xidprof: String): TQuery; overload;
  function    setListaTotalFacturadoProfesionales(xperiodo, xidprof: String): TStringList; overload;
  function    setListaTotalFacturadoProfesionalesExcluyendoObrasSocialesInscriptas(xperiodo, xidprof: String): TStringList;
  function    setListaTotalFacturadoProfesionalesIncluyendoObrasSocialesInscriptas(xperiodo, xidprof: String): TStringList;
  function    setNetoFacturado: TStringList;
  function    setUBFacturadas: TStringList;
  function    setListaTotalFacturadoProfesionales(xperiodo, xidprof, xcodos: String): TStringList; overload;
  function    setImporteAnalisis(xcodos, xcodanalisis: String): Real; overload;
  function    setImporteAnalisis(xcodos, xcodanalisis, xperiodo: String): Real; overload;
  function    setImporteAnalisis(xcodos, xcodanalisis: String; xosub, xosug, xosrieub, xosrieug: Real): Real; overload;
  function    setImporteAnalisis(xcodos, xcodanalisis, xperiodo: String; xnbu: real): Real; overload;
  function    setCodigoRecepcionToma: Boolean;

  procedure   IngresarMontoFacturadoObraSocial(xperiodo, xcodos, xnombre: String; ximporte: Real);
  procedure   IngresarMontoFacturadoProfesional(xperiodo, xidprof, xnombre, xcodos, xcodfact: String; xub, xug, xcaran, ximporte, xneto: Real);
  procedure   BorrarMontoFacturadoProfesional(xperiodo, xidprof, xcodos: String);
  procedure   RegistrarNetoACobrarProfesional(xperiodo, xidprof, xcodos: String; ximporte: Real);
  function    setNetoACobrarProfesional(xperiodo, xidprof: String): Real; overload;
  procedure   InformeTotalProfesionales(xperiodo: String; listSel: TStringList; salida: Char; xincluirinscriptosiva: Boolean);
  procedure   InformeResumenProfesionales(xperiodo: String; listSel: TStringList; salida: Char; xincluirinscriptosiva: Boolean);
  procedure   InformeResumenProfesionalesUnidadesHonorarios(xperiodo: String; listSel: TStringList; salida: Char; xincluirinscriptosiva: Boolean);
  function    setTotalesProfesionales(xperiodo, xcodos: String): TQuery;
  function    setPracticasFacturadas: TQuery;

  function    setCompensacionArancelaria: Real;
  function    setCompensacionArancelariaIndividual: Real;

  procedure   ConectarTotalesProf;
  procedure   DesconectarTotalesProf;
  function    ProcesandoDatosCentrales: Boolean;

  { Ordenes Auditadas }
  procedure   PrepararDirectorio_OrdenesAuditadas(xperiodo, xlaboratorio: String);
  function    verificarDirectorio_OrdenesAuditadas(xperiodo, xlaboratorio: String): Boolean;
  procedure   SeleccionarLaboratorio_Auditoria(xperiodo, xdirectorio: String);
  procedure   RegistrarOrdenes(xperiodo, xitems, xidprof, xnroauditoria, xestado: String; xcantidad_items: Integer);
  procedure   BorrarOrdenAuditoria(xperiodo, xitems, xidprof: String); overload;
  procedure   BorrarOrdenAuditoria(xperiodo, xidprof: String); overload;
  function    setOrdenesAuditoria(xperiodo, xidprof: String): TQuery;
  function    setOrdenesAuditoriaIB(xperiodo, xidprof: String): TIBQuery;
  function    verificarOrden(xidprof, xorden: String): Boolean;
  procedure   MarcarOrdenAuditoria(xperiodo, xitems, xidprof, xestado: String);
  procedure   BorrarOrdenesPorId(xid, xperiodo, xidprof: String);
  function    ObtenerUltimoId(xperiodo, xidprof: string): Integer;
  procedure   BorrarOrdenAuditoriaIB(xperiodo, xidprof: String);

  { Respaldar Laboratorios }
  function    setLaboratoriosBackup(xperiodo: String): TStringList;
  procedure   RealizarBackupLaboratorios(xperiodo: String);
  procedure   RealizarRestauracionLaboratorios(xperiodo, xidprof: String);
  function    ListaLaboratoriosActualizados: TStringList;

  function    getPeriodosFacturadosDepurar: TStringList;
  function    getPeriodosFacturadosDepurados: TStringList;
  procedure   DepurarPeriodosFacturadosIB(xperiodo: string);

  function    setDeterminacionesProfesional(xperiodo: String): TQuery;

  procedure   CambiarTipoTotalProfesional(xperiodo, xidprof, xcodos: string; xmodo: integer);

  procedure   vaciarBuffer;
  procedure   conectar;
  procedure   desconectar;
  procedure   CerrarConexiones;

  function    setValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;

  function   verificarEfector(xidprof: string): boolean;
  function   verificarObraSocial(xcodos: string): boolean;
  function   verificarDeterminacion(xcodigo: string): boolean;

  function   getTotalesInicidenciaPorDeterminacion_Detallada(xperiodo: string): TQuery;
  procedure  BorrarTotalesInicidenciaPorDeterminacion_Detallada(xperiodo, xcodos: string);

  procedure  vaciarLoteSecundario; overload;
  procedure  vaciarLoteSecundario(xlote: TStringList); overload;
  function   getDBConexion: string;

  function   getPracticasFacturadas(xdesde, xhasta: string): TIBQuery;
  function   getCantidadPracticasFacturadas(xdesde, xhasta, xcodigo: string): integer;
  procedure  ListarPracticasFacturadas(xdesde, xhasta: string; lista: TStringList; salida: char);

  function   getListPracticasFacturadas(xperiodo, xcodos: string): TIBQuery;
  function   getListItemsFacturados(xperiodo, xcodos: string): TIBQuery;
  function   getListItemsFacturadosSNF(xperiodo, xcodos: string): TIBQuery;

  procedure  recalcularMontosAnalisis(xperiodo, xcodos: string);
  procedure  recalcularMontosAnalisisRI(xperiodo, xcodos: string);
  function   getFacturas(xperiodo: string): TQuery;
  procedure  registrarCAE(xperiodo, xcodos, xcae, xtipo, xsucursal, xnumero, xfecha, xfechavto1, xfechavto2, xvtocae, xcodigocomprobante: string);
  procedure  generarFactura(xperiodo, xcodos, xinicioactividad, xcomprobante: string; xcopias: integer);

  procedure  exportarTotalesRI(xperiodo: string);
  procedure  exportarDetalleFacturacion(xperiodo: string);

  function   getLaboratoriosARefacturar(xperiodo: string): TIBQuery;
  function   getLaboratoriosARefacturarAll(xperiodo: string): TIBQuery;

  function   getLaboratoriosConCoseguro(xperiodo: string): TIBQuery;
  function   getCoseguroLaboratorios(xperiodo, xidprof: string): TIBQuery;
  function   getListObrasSocialesRegla(xperiodo, xregla: string): TIBQuery;

  procedure  exportarRegla(xperiodo, xregla: string);
  function   exportarReglaFacturasRI(xperiodo: string): TQuery;
  function   exportarReglaFacturasRM(xperiodo: string): TQuery;
  function   exportarReglaFacturasDetalle(xperiodo: string): TQuery;
  function   exportarReglaFacturasDetalleRM(xperiodo: string): TQuery;

  procedure  listarUBFacturadas(xperiodo: string; salida: char);

 private
  { Declaraciones Privadas }
  conexiones, pag: integer; lin, idanter, idanter1, ordenanter, codosanter, idprofanter, codftoma, titulo, columnas, npac, diractual, DBConexion, dir_lab, osretieneiva, pac_retiva, __c, __t: String;
  nrocol, espaciocol, distanciaImp: ShortInt; it, xf: Integer;
  cantidad, cantidadordenes, totprestaciones: Integer; subtotal, m9984, tot9984, totUG, totUB, canUG, canUB, total, ttotUB, caran, ivaret, ivaret9984, ivaretcaran, ivaexento, ivaexe9984, ivaexecaran, subtotalorden: real;
  ttotprestaciones, ccantidadordenes, tttotUB, ttotUG, ccanUB, ccanUG, ccaran, ttotal, compensacion, totcomp, canUB1, totUBSin9984, totUGSin9984, totUB9984, totUG9984, _ccaranSin9984, _ccaran9984, canUB9984, total_orden: Real;
  CHR18, CHR15, Caracter, msgImpresion, DBCentral, fx, codigomontofijo, perrem, labrem: String;
  ProcesamientoCentral, informe_ivaret, codigo_tomamuestra, datosListadosFact, u_h, nnbu, proceso_central, campo1, __laboratorios: Boolean;
  ar1, ar2: TextFile;
  __ordenint, _query, __periodo, __perfact, __maxperiodo, __peranter: string;

  codigos: array[1..elementos]   of String[6];
  montos : array[1..elementos]   of Real;
  totales: array[1..elementos+1] of Real;
  dirlab : array[1..elementos+5] of String;
  totiva : array[1..7] of Real;
  totivaol : array[1..7] of Real;
  datosListados, rp, listControl, ExportarDatos,llt, tibase, __historico, __ignorarcachemontos: Boolean;
  rsql, ressql: TQuery;

  directorio1, diractual1: String;
  listatrab, lNeto, lub, lote, lotesec: TStringList;

  ffirebird: TTFirebird;
  cabexptIB, detexptIB, idexptIB: TIBTable;
  rsqlIB: TIBQuery;

  __codigos, __montos: TStringList;

  procedure   InstanciarTablas(xdirectorio: String);

  function    ControlarSalto: Boolean;
  procedure   RealizarSalto;
  function    BuscarLiq(xperiodo, xcodos: String): Boolean;
  { Resumen de prestaciones por obras sociales }
  procedure   titulo1(xperiodo, xtitulo, xcolumnas: String);
  procedure   listLinea(xcolumnas: String; salida: char);
  procedure   RupturaObraSocial(salida: char; xperiodo, xtitulo, Color: string);
  procedure   SubtotalObraSocial(salida: char);
  procedure   RupturaPorProfesional(Color: String; salida: char);
  procedure   SubtotalProfesional(salida: char);
  { Listado Resumen por Obra Social }
  procedure   titulo2(xperiodo, xtitulo: String);
  procedure   ListarLineaDeAnalisis(xcolumnas: String; salida: char);
  procedure   RupturaObraSocial1(xperiodo, xtitulo: String; salida: char; xinf_com: Boolean);
  procedure   LineaLaboratorio(salida: char);
  procedure   SubtotalObraSocial1(xperiodo, xtitulo: String; salida: char);
  { Listado Resumen por Profesional }
  procedure   titulo3(xperiodo, xtitulo: String);
  procedure   RupturaPorProfesional2(xperiodo, xtitulo: String; salida: char);
  procedure   RupturaPorProfesional3(xperiodo, xtitulo: String; salida: char);
  procedure   LineaObraSocial(xperiodo: String; salida: char);
  procedure   SubtotalObraSocialResumenProf(xleyenda: String; salida: char);
  { Listado de Totales Generales por Obra Social }
  procedure   titulo4(xperiodo, xtitulo: String);
  procedure   LineaOS(xperiodo, codosanter, xtitulo: String; salida: Char);
  { Facturación Resumen a Profesionales }
  procedure   RupturaProf(salida: Char; xidprof, xperiodo: String; ruptura: Boolean);
  procedure   titulo5(xperiodo, xtitulo, xcolumnas: String);
  procedure   RupturaOS(salida: char; xperiodo, xtitulo: string);
  procedure   SubtotalObraSocial2(salida: char);
  { Depuración de Directorios }
  procedure   DepurarDirectorios(xperiodo, xidprof: String);
  procedure   GuardarPeriodoHistorico(xperiodo: String);
  { Totales Parciales }
  procedure   IniciarTotalObrasSociales(xperiodo: String);
  procedure   GuardarTotalObrasSociales(xperiodo, xcodos: String; xmonto: Real);
  procedure   IniciarTotalProfesional(xperiodo: String);
  procedure   GuardarTotalProfesional(xperiodo, xidprof, xcodos: String; xmonto, xUB, xUG, xCaran: Real);
  procedure   GuardarTotalProf(xperiodo, xidprof, xcodos: String);
  procedure   GuardarTotalProfIVA(xperiodo, xidprof, xcodos: String; xmonto, xneto: Real);
  procedure   GuardarTotalProfIVAExport(xperiodo, xidprof, xcodos: String; xneto, xiva, xexento, xtotal: Real; xcantidad, xprestaciones: integer);
  { Varios }
  procedure   GuardarRefDatosImportados(xperiodo, xidprof, xnombre, xdirectorio, xmodo: String);
  procedure   GuardarRefDatosExportados(xperiodo, xidprof, xnombre, xdirectorio, xmodo: String);
  procedure   TotalOS(xperiodo: String; salida: Char);
  procedure   LineaProfesional(xidanter, xperiodo: String; salida: char);
  procedure   FinalizarInforme(salida: Char);
  procedure   IniciarArreglos;
  { Ordenes Auditadas }
  procedure   InstanciarTablas_Auditoria(xdirectorio: String);
  procedure   Listar_Ordenes(id: String; la, lr, lr2: TStringList; salida: Char);
  procedure   titulo6(xperiodo: String);
  procedure   listOrd(l1: String; salida: Char);
  { Informe Retenciones de Iva }
  procedure   LineaObraSocialIvaRet(xperiodo: String; salida: char; xinf_com: Boolean);
  procedure   titulo7(xperiodo, xtitulo: String);
  { Varios }
  procedure   titulo8(xperiodo: String);
  procedure   titulo9(xperiodo: String);
  procedure   titulo10(xperiodo: String);
  procedure   testeartotalesprof;
  { Operaciones a Nivel Lista }
  function    listarLinea: Boolean;
  procedure   VerificarEstructuraDetFact;
end;

function facturacion: TTFacturacionCCB;

implementation

var
  xfacturacion: TTFacturacionCCB = nil;

constructor TTFacturacionCCB.Create;
begin
  inherited Create;

  if (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccb.exe') or
     (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbc.exe') or
     (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretivac.exe') or
     (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcretiva.exe') then Begin   // Motor de Persitencia para las versiones de Laboratorios
    if dbs.BaseClientServ = 'S' then dbs.NuevaBaseDeDatos('factcentro', 'sysdba', 'masterkey');
    if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.TDB1.DatabaseName;
    if dbs.BaseClientServ = 'N' then dbs.DatosHistoricos := dbs.DirSistema + '\historico' else dbs.DatosHistoricos := 'HISTORICOCENTROBIOQ';
    __laboratorios := true;
  end else Begin                                                                        // Motor de Persistencia para la Versión Full del Software
    if dbs.BaseClientServ = 'N' then DBConexion := dbs.DirSistema + '\archdat' else DBConexion := dbs.baseDat;
    if dbs.BaseClientServ = 'N' then dbs.DatosHistoricos := dbs.DirSistema + '\historico' else dbs.DatosHistoricos := 'HISTORICOCENTROBIOQ';
  end;

  wtotalesprof := nil;
  if ((LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcentrobioqcont.exe') or (LowerCase(ExtractFileName(Application.ExeName)) = 'shmsoftfccbcentrobioq.exe')) then begin
    wtotalesprof  := datosdb.openDB('wtotalesprof', 'periodo;codos;idprof', '', dbconexion);
    datosfactdet := datosdb.openDB('datosfactdet', 'Periodo;Codos;Items', '', DBConexion);
  end;

  modeloc      := datosdb.openDB('modcarta', 'Id', '', dbconexion);
  cabfactos    := datosdb.openDB('cabfactos', 'Nroliq;Codos', '', DBConexion);
  liq          := datosdb.openDB('liquidaciones', 'Codos;Periodo', '', DBConexion);
  datosfact    := datosdb.openDB('datosfact', 'Periodo;Nroliq;Codos', '', DBConexion);
  //datosfactdet := datosdb.openDB('datosfactdet', 'Periodo;Codos;Items', '', DBConexion);
  ctrlImpr     := datosdb.openDB('ctrlImp', 'Reporte', '', DBConexion);
  historico    := datosdb.openDB('historico', 'Periodo', '', DBConexion);
  datosImport  := datosdb.openDB('datosimportados', 'Periodo;Idprof', '', DBConexion);
  if usuario.usuario <> 'Administrador' then Begin  // Conecta en el directorio predeterminado
    //cabfact    := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\archdat');
    //detfact    := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', dbs.DirSistema + '\archdat');
    idordenes  := datosdb.openDB('idordenes', 'Periodo;Idprof', '', dbs.DirSistema + '\archdat');
    dir_lab    := dbs.DirSistema;
  end else Begin
    dir_lab   := dbs.DirSistema + '\fact_lab';
    InstanciarTablas(DBConexion);
  end;
  lineasPag := 65;
  CHR18     := CHR(18);
  CHR15     := CHR(15);
  Caracter  := '-';
  diractual := 'None';
  if (usuario.usuario <> 'Administrador') or (Length(Trim(laboratorioactual)) > 0)  then msgImpresion := 'No Existen Datos para Listar ...!' else msgImpresion := 'No Existen Datos para Listar,' + chr(13) + 'si ha Registrado Operaciones en este Período' + chr(13) + 'vuelva a Realizar la Transferencia Final de Datos ...!';

  listatrab := TStringList.Create;

  lote := TStringList.Create;
  lotesec := TStringList.Create;

  interbase := 'S';
end;

destructor TTFacturacionCCB.Destroy;
begin
  inherited Destroy;
end;

function TTFacturacionCCB.Buscar(xperiodo, xidprof, xcodos: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if (interbase = 'N') then begin
    QuitarFiltro;
    if cabfact.IndexFieldNames <> 'periodo;idprof;codos' then cabfact.IndexFieldNames := 'periodo;idprof;codos';
    if datosdb.Buscar(cabfact, 'periodo', 'idprof', 'codos', xperiodo, xidprof, xcodos) then Begin
      getDatos;
      Result  := True;
    end else Begin
      periodo := ''; idprof := ''; codos := '';
      Result := False;
    end;
  end;
  if (interbase = 'S') then begin
    rsqlIB := ffirebird.getTransacSQL('select * from cabfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and codos = ' + '''' + xcodos + '''');
    rsqlIB.open;
    if (rsqlIB.RecordCount > 0) then begin
      getDatos;
      result := true;
    end else begin
      periodo := ''; idprof := ''; codos := '';
      Result := False;
    end;
    rsqlIB.Close;
  end;
end;

procedure TTFacturacionCCB.Grabar(xperiodo, xidprof, xcodos, xitems, xcodpac, xnombre, xcodanalisis, xorden, xperiodo1, xretiva, xmontocoseguro: string; modifica, guardar_orden_interna: boolean);
// Objetivo...: Grabar Atributos del Objeto
var
  __c: string;
begin
  if (interbase = 'N') then begin
    if xitems = '001' then Begin
       if not detfact.active then detfact.Open;
      // Modificación de las Estructuras a partir del NBU (01/2007)
      if detfact.FieldByName('codanalisis').DataSize < 6 then Begin
        VerificarEstructuraDetFact;
        if not detfact.Active then detfact.Open;
      end;

      if not modifica then datosdb.tranSQL(directorio, 'DELETE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND orden = ' + '"' + xorden + '"' + ' AND codos = ' + '"' + xcodos + '"') else datosdb.tranSQL(directorio, 'DELETE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
      datosdb.closedb(detfact); detfact.Open;

      if not Buscar(xperiodo, xidprof, xcodos) then cabfact.Append else cabfact.Edit;
      cabfact.FieldByName('periodo').AsString := xperiodo;
      cabfact.FieldByName('idprof').AsString  := xidprof;
      cabfact.FieldByName('codos').AsString   := xcodos;
      if (guardar_orden_interna) then GuardarOrdenInterna(xperiodo, xidprof, xorden);
      try
        cabfact.Post
       except
        cabfact.Cancel
      end;
    end;

    detfact.Append;
    detfact.FieldByName('periodo').AsString     := xperiodo;
    detfact.FieldByName('idprof').AsString      := xidprof;
    detfact.FieldByName('codos').AsString       := xcodos;
    detfact.FieldByName('items').AsString       := xitems;
    detfact.FieldByName('orden').AsString       := xorden;
    detfact.FieldByName('codpac').AsString      := xcodpac;
    detfact.FieldByName('nombre').AsString      := xnombre;
    detfact.FieldByName('codanalisis').AsString := xcodanalisis;
    detfact.FieldByName('ref1').AsString        := xperiodo1;
    detfact.FieldByName('retiva').AsString      := xretiva;

    try
      detfact.Post
     except
      detfact.Cancel
    end;
  end;

  if (interbase = 'S') then begin

    // 25/06/2018 - para totales con I.V.A. Jerárquicos
    // 20/11/2019 - para todas las OS con reglas
    // antes del 16/06 if (REGLA_EXPORTACION >= 1) then begin

    if ((REGLA_EXPORTACION >= 1) or (length(trim(NRO_AUDITORIA)) > 0)) then begin
      GrabarIB(xperiodo, xidprof, xcodos, trim(xitems), trim(xcodpac), trimright(xnombre), xcodanalisis, xorden, xperiodo1, xretiva, NRO_AUDITORIA, modifica, guardar_orden_interna, NRO_AFILIADO, NRO_AUTORIZACION, FECHA_ORDEN, xmontocoseguro);
      exit;
    end;

    if (factglobal) then __t := 'detfact_gl' else __t := 'detfact';
    if (factglobal) then __c := 'cabfact_gl' else __c := 'cabfact';
    if (copy(xorden, 1, 1) = 'R') then __t := 'detfact';

    if xitems = '001' then Begin
      lote.Clear;
      if not modifica then begin
        lote.Add('DELETE FROM ' + __c + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
        lote.Add('DELETE FROM ' + __t + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND orden = ' + '"' + xorden + '"' + ' AND codos = ' + '"' + xcodos + '"');
      end else begin
        lote.Add('DELETE FROM ' + __c + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
        lote.Add('DELETE FROM ' + __t + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
      end;

      if (copy(xorden, 1, 1) = 'R') and (factglobal) then begin // Facturación Global, reescribimos - 15/08/2014
        lote.Clear;
        lote.Add('DELETE FROM  ' + __c + '  WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
        lote.Add('DELETE FROM  ' + __t + '  WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND orden = ' + '"' + xorden + '"' + ' AND codos = ' + '"' + xcodos + '"');
      end;

      ffirebird.TransacSQLBatch(lote);
      lote.Clear;

      lote.Add('insert into ' + __c + ' (periodo, idprof, codos) values (' +
        '''' + xperiodo + '''' + ', ' +
        '''' + xidprof + '''' + ', ' +
        '''' + xcodos + '''' + ')');

      if (copy(xorden, 1, 1) <> 'R') then begin
        //if not (modifica) then __ordenint := utiles.sLlenarIzquierda(NuevaOrdenInterna(xperiodo, xidprof, xcodos), 4, '0');
        if (guardar_orden_interna) then GuardarOrdenInterna(xperiodo, xidprof, xorden);
      end;

    end;

    if (factglobal) then __t := 'detfact_gl' else __t := 'detfact';
    if (copy(xorden, 1, 1) = 'R') then __t := 'detfact';
    lote.Add('insert into ' + __t + ' (periodo, idprof, codos, items, orden, codpac, nombre, codanalisis, ref1, retiva) values (' +
      '''' + xperiodo + '''' + ',' +
      '''' + xidprof + '''' + ',' +
      '''' + xcodos + '''' + ',' +
      '''' + xitems + '''' + ',' +
      '''' + xorden + '''' + ',' +
      '''' + xcodpac + '''' + ',' +
      QuotedStr(xnombre) + ',' +
      '''' + xcodanalisis + '''' + ',' +
      '''' + xperiodo1 + '''' + ',' +
      '''' + xretiva + ''''  + ')'
    );

  end;
end;

procedure TTFacturacionCCB.GrabarIB(xperiodo, xidprof, xcodos, xitems, xcodpac, xnombre, xcodanalisis, xorden, xperiodo1, xretiva, xnroauditoria: string; modifica, guardar_orden_interna: boolean; xnroafiliado, xnroautorizacion, xfecha, xmontocoseguro: string);
// Objetivo...: Grabar Atributos del Objeto
var
  __c: string;
  monto, iva, coseguro: double;
begin
  if (interbase = 'S') then begin

    if (length(trim(NRO_AFILIADO)) = 0) then begin
      utiles.msgError('Número de Afiliado Incorrecto ...!');
      exit;
    end;

    if (length(trim(xnroauditoria)) = 0) then begin
      utiles.msgError('Número de Auditoría Incorrecto ...!');
      exit;
    end;

    if (length(trim(FECHA_ORDEN)) = 0) then begin
      utiles.msgError('Fecha Orden Incorrecta ...!');
      exit;
    end;

    if (xmontocoseguro = '') then coseguro := 0 else coseguro := strtofloat(xmontocoseguro);

    if (factglobal) then __t := 'detfact_gl' else __t := 'detfact';
    if (factglobal) then __c := 'cabfact_gl' else __c := 'cabfact';
    if (copy(xorden, 1, 1) = 'R') then __t := 'detfact';

    if xitems = '001' then Begin
      lote.Clear;
      if not modifica then begin
        lote.Add('DELETE FROM ' + __c + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
        lote.Add('DELETE FROM ' + __t + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND orden = ' + '"' + xorden + '"' + ' AND codos = ' + '"' + xcodos + '"');
      end else begin
        lote.Add('DELETE FROM ' + __c + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
        lote.Add('DELETE FROM ' + __t + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
      end;

      if (copy(xorden, 1, 1) = 'R') and (factglobal) then begin // Facturación Global, reescribimos - 15/08/2014
        lote.Clear;
        lote.Add('DELETE FROM  ' + __c + '  WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
        lote.Add('DELETE FROM  ' + __t + '  WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND orden = ' + '"' + xorden + '"' + ' AND codos = ' + '"' + xcodos + '"');
      end;

      ffirebird.TransacSQLBatch(lote);
      lote.Clear;

      lote.Add('insert into ' + __c + ' (periodo, idprof, codos) values (' +
        '''' + xperiodo + '''' + ', ' +
        '''' + xidprof + '''' + ', ' +
        '''' + xcodos + '''' + ')');

      if (copy(xorden, 1, 1) <> 'R') then begin
        //if not (modifica) then __ordenint := utiles.sLlenarIzquierda(NuevaOrdenInterna(xperiodo, xidprof, xcodos), 4, '0');
        if (guardar_orden_interna) then GuardarOrdenInterna(xperiodo, xidprof, xorden);
      end;

    end;

    totiva[1] := 0;
    totiva[2] := 0;
    periodo := xperiodo;
    obsocial.SincronizarArancelNBU(xcodos, xperiodo);
    nbu.getDatos(xcodanalisis);
    __ignorarcachemontos := true;
    monto := setValorAnalisis(xcodos, xcodanalisis, 0, 0, 0, 0); // Valor de cada analisis
    __ignorarcachemontos := false;


    if (factglobal) then __t := 'detfact_gl' else __t := 'detfact';
    if (copy(xorden, 1, 1) = 'R') then __t := 'detfact';
    lote.Add('insert into ' + __t + ' (periodo, idprof, codos, items, orden, codpac, nroafiliado, nombre, codanalisis, ref1, monto, iva, exento, nroauditoria, nroautorizacion, fecha, coseguro, retiva) values (' +
      '''' + xperiodo + '''' + ',' +
      '''' + xidprof + '''' + ',' +
      '''' + xcodos + '''' + ',' +
      '''' + TrimRight(xitems) + '''' + ',' +
      '''' + xorden + '''' + ',' +
      '''' + xcodpac + '''' + ',' +
      QuotedStr(xnroafiliado) + ',' +
      TrimRight(QuotedStr(xnombre)) + ',' +
      '''' + xcodanalisis + '''' + ',' +
      '''' + xperiodo1 + '''' + ',' +
      utiles.StringRemplazarCaracteres(FloatToStr(monto), ',', '.') + ',' +
      utiles.StringRemplazarCaracteres(FloatToStr(totiva[1]), ',', '.') + ',' +
      utiles.StringRemplazarCaracteres(FloatToStr(totiva[2]), ',', '.') + ',' +
      '''' + xnroauditoria + '''' + ',' +
      '''' + NRO_AUTORIZACION + '''' + ',' +
      '''' + FECHA_ORDEN + '''' + ',' +
      utiles.StringRemplazarCaracteres(FloatToStr(coseguro), ',', '.') + ',' +
      '''' + xretiva + ''''  + ')'
    );
  end;
end;

procedure TTFacturacionCCB.recalcularMontosAnalisis(xperiodo, xcodos: string);
var
  rs: TIBQuery;
  monto: double;
  c: string;
begin
  periodo := xperiodo;
  obsocial.SincronizarArancelNBU(xcodos, xperiodo);

  lote.Clear;

  rs := ffirebird.getTransacSQL('select distinct(codanalisis) as codanalisis, periodo from detfact where periodo = ' + '''' + xperiodo + '''' +
    ' and codos = ' + '''' + xcodos + '''');
  rs.Open;
  while not rs.eof do begin
    totiva[1] := 0;
    totiva[2] := 0;
    c := rs.FieldByName('codanalisis').AsString;
    nbu.getDatos(c);
    monto := setValorAnalisis(xcodos, c, 0, 0, 0, 0); // Valor de cada analisis

    lote.Add('update detfact set monto = ' + utiles.StringRemplazarCaracteres(FloatToStr(monto), ',', '.') + ', ' +
             'iva = ' + utiles.StringRemplazarCaracteres(FloatToStr(totiva[1]), ',', '.') + ', ' +
             'exento = ' + utiles.StringRemplazarCaracteres(FloatToStr(totiva[2]), ',', '.') + ' ' +
             'where codos = ' + '''' + xcodos + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' ' +
             'and codanalisis = ' + '''' + c + '''');

    rs.Next;
  end;

  rs.Close; rs.free;

  ffirebird.TransacSQLBatch(lote);

  lote.Clear;
end;

procedure TTFacturacionCCB.recalcularMontosAnalisisRI(xperiodo, xcodos: string);
var
  rs: TIBQuery;
  monto, montoiva: double;
  c: string;
begin
  obsocial.SincronizarPosicionFiscal(xcodos, xperiodo);

  lote.Clear;

  rs := ffirebird.getTransacSQL('select periodo, codos, idprof, items, codanalisis, retiva, orden, ref1  from detfact where periodo = ' + '''' + xperiodo + '''' +
    ' and codos = ' + '''' + xcodos + '''');
  rs.Open;
  while not rs.eof do begin

    periodo := xperiodo;
    if (rs.FieldByName('ref1').AsString <> '') then periodo := rs.FieldByName('ref1').AsString;  // Si difiere del período imputado 26/11/2019
    obsocial.SincronizarArancelNBU(xcodos, periodo);

    c := rs.FieldByName('codanalisis').AsString;
    nbu.getDatos(c);
    monto := setValorAnalisis(xcodos, c, 0, 0, 0, 0); // Valor de cada analisis

    totiva[1] := 0; totiva[2] := 0;

    profesional.getDatos(rs.FieldByName('idprof').AsString);
    if (profesional.Retieneiva = 'S') then begin
      if (rs.FieldByName('retiva').AsString = 'S') then totiva[1] := monto;
      if (rs.FieldByName('retiva').AsString = 'N') then totiva[2] := monto;
    end;

    lote.Add('update detfact set monto = ' + utiles.StringRemplazarCaracteres(FloatToStr(monto), ',', '.') + ', ' +
             'iva = ' + utiles.StringRemplazarCaracteres(FloatToStr(totiva[1]), ',', '.') + ', ' +
             'exento = ' + utiles.StringRemplazarCaracteres(FloatToStr(totiva[2]), ',', '.') + ' ' +
             'where codos = ' + '''' + xcodos + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' ' +
             'and idprof = ' + '''' + rs.FieldByName('idprof').AsString + '''' + ' ' +
             'and orden = ' + '''' + rs.FieldByName('orden').AsString + '''' + ' ' +
             'and codanalisis = ' + '''' + c + '''' + ' and items = ' + '''' + rs.FieldByName('items').AsString + '''');

    rs.Next;

  end;

  rs.Close; rs.free;

  ffirebird.TransacSQLBatch(lote);

  lote.Clear;
end;

function  TTFacturacionCCB.getFacturas(xperiodo: string): TQuery;
begin
  result := datosdb.tranSQL(datosfact.DatabaseName, 'select * from datosfact where periodo = ' + '''' + xperiodo + '''');
end;

procedure TTFacturacionCCB.registrarCAE(xperiodo, xcodos, xcae, xtipo, xsucursal, xnumero, xfecha, xfechavto1, xfechavto2, xvtocae, xcodigocomprobante: string);
begin
  if BuscarDatosFact(xperiodo, xcodos) then begin
      datosfact.Edit;
      datosfact.FieldByName('tipo').AsString      := xtipo;
      datosfact.FieldByName('sucursal').AsString  := xsucursal;
      datosfact.FieldByName('numero').AsString    := xnumero;
      datosfact.FieldByName('cae').AsString       := xcae;
      datosfact.FieldByName('fecha').AsString     := xfecha;
      datosfact.FieldByName('fechavto1').AsString := xfechavto1;
      datosfact.FieldByName('fechavto2').AsString := xfechavto2;
      datosfact.FieldByName('vtocae').AsString    := xvtocae;
      datosfact.FieldByName('idcompr').AsString   := xcodigocomprobante;
      try
        datosfact.Post
       except
        datosfact.Cancel
      end;
      datosdb.refrescar(datosfact);
  end;
end;

procedure TTFacturacionCCB.generarFactura(xperiodo, xcodos, xinicioactividad, xcomprobante: string; xcopias: integer);
var
  r: TQuery;
  i, j: integer;
  c: array[1..3] of string;
  t: TTable;
  osdir, oscuit, oslocalidad, osiva, ostel, osloc, osnombre: string;
begin
  t := datosdb.openDB('datosfactreport', 'LINEA');
  t.open;
  datosdb.tranSQL('delete from datosfactreport');
  t.Refresh;

  if (obsocial.Buscar(xcodos)) then begin
    obsocial.getDatos(xcodos);
    osdir := obsocial.direccion;
    oscuit := obsocial.nrocuit;
    osiva := obsocial.codpfis;
    osloc := obsocial.localidad + ' (' + obsocial.codpost + ')';
    osnombre := obsocial.Nombrec;
  end else begin
    osagrupa.getobject(xcodos);
    osdir := osagrupa.Direccion;
    oscuit := osagrupa.Cuit;
    osiva := osagrupa.Codpfis;
    osloc := osagrupa.Localidad;
    osnombre := osagrupa.Nombre;
  end;                                                                           

  r := datosdb.tranSQL('select datosfact.periodo, datosfact.codos, datosfact.tipo, datosfact.sucursal, datosfact.numero, datosfact.fecha, datosfact.idcompr, datosfact.vtocae, ' +
    'datosfact.fechavto1, datosfact.fechavto2, datosfact.cae, datosfact.obrasocial, datosfact.cuit, datosfact.monto, datosfactdet.items, datosfactdet.descrip, ' +
    'datosfactdet.observacion, datosfactdet.monto as montoitem from datosfact, datosfactdet where datosfact.periodo = datosfactdet.periodo and datosfact.codos = datosfactdet.codos and datosfact.periodo = '
    + '''' + xperiodo + '''' + ' and datosfact.codos = ' + '''' + xcodos + '''');

  r.Open;

  c[1] := 'ORIGINAL'; c[2] := 'DUPLICADO'; c[3] := 'TRIPLICADO';

  j := 0;
  for i := 1 to xcopias do begin
    r.First;
    while not r.eof do begin
      inc(j);
      t.Append;
      t.FieldByName('linea').asinteger := j;
      t.FieldByName('copia').asstring := c[i];
      t.FieldByName('periodo').asstring :=  r.FieldByName('periodo').asstring;
      t.FieldByName('codos').asstring :=  r.FieldByName('codos').asstring;
      t.FieldByName('idcompr').asstring :=  r.FieldByName('idcompr').asstring;
      t.FieldByName('tipo').asstring :=  r.FieldByName('tipo').asstring;
      t.FieldByName('sucursal').asstring :=  r.FieldByName('sucursal').asstring;
      t.FieldByName('numero').asstring :=  r.FieldByName('numero').asstring;
      t.FieldByName('fechavto1').asstring :=  r.FieldByName('fechavto2').asstring;
      t.FieldByName('fechavto2').asstring :=  r.FieldByName('fechavto2').asstring;
      t.FieldByName('fecha').asstring :=  r.FieldByName('fecha').asstring;
      t.FieldByName('periodo').asstring :=  r.FieldByName('periodo').asstring;
      t.FieldByName('cae').asstring :=  r.FieldByName('cae').asstring;
      t.FieldByName('par3').asstring :=  copy(r.FieldByName('cae').asstring, 18, 14);
      t.FieldByName('obrasocial').asstring :=  osnombre; //r.FieldByName('obrasocial').asstring;
      t.FieldByName('cuit').asstring :=  r.FieldByName('cuit').asstring;
      t.FieldByName('monto').asstring :=  r.FieldByName('monto').asstring;
      t.FieldByName('items').asstring :=  r.FieldByName('items').asstring;
      t.FieldByName('descrip').asstring :=  r.FieldByName('descrip').asstring;
      t.FieldByName('montoitem').asstring :=  r.FieldByName('montoitem').asstring;
      t.FieldByName('observacion').asstring :=  r.FieldByName('observacion').asstring;
      t.FieldByName('orden').asinteger :=  i;
      t.FieldByName('comprobante').asstring := xcomprobante;
      t.FieldByName('vtocae').asstring :=  r.FieldByName('vtocae').asstring;
      t.FieldByName('p1').asstring := osdir;
      t.FieldByName('p2').asstring := oscuit;
      t.FieldByName('p3').asstring := osiva;
      t.FieldByName('p4').asstring := osloc;
      t.FieldByName('p5').asstring := xinicioactividad;
      try
        t.post
      except
        t.Cancel
      end;
      r.next;
    end;
  end;

  t.Refresh;
  t.Close;
  t.Free;

  r.Close; r.Free;
end;

procedure TTFacturacionCCB.exportarTotalesRI(xperiodo: string);
var
  r: TQuery;

  js:TlkJSONobject;
  ws: TlkJSONstring;
  s: String;
  i: Integer;
  result: TStringList;
begin
  r := datosdb.tranSQL(datosfact.DatabaseName, 'select * from wtotalesprof where periodo = ' + '''' + xperiodo + '''');
  r.Open;

  result := TStringList.Create;

  while not r.Eof do begin

    js := TlkJSONobject.Create;

    obsocial.getDatos(r.FieldByName('codos').AsString);
    profesional.getDatos(r.FieldByName('idprof').AsString);

    js.add('periodo', TlkJSONstring.Generate(r.FieldByName('periodo').AsString));
    js.add('codos', TlkJSONstring.Generate(r.FieldByName('codos').AsString));
    js.add('neto', TlkJSONnumber.Generate(r.FieldByName('neto').AsFloat));
    js.add('grabado', TlkJSONnumber.Generate(r.FieldByName('grabado').AsFloat));
    js.add('exento', TlkJSONnumber.Generate(r.FieldByName('exento').AsFloat));
    js.add('total', TlkJSONnumber.Generate(r.FieldByName('total').AsFloat));
    js.add('iva', TlkJSONnumber.Generate(r.FieldByName('iva').AsFloat));
    js.add('ordenes', TlkJSONnumber.Generate(r.FieldByName('ordenes').AsFloat));
    js.add('prestaciones', TlkJSONnumber.Generate(r.FieldByName('prestaciones').AsFloat));
    js.add('idprof', TlkJSONstring.Generate(r.FieldByName('idprof').AsString));
    js.add('obsocial', TlkJSONstring.Generate(r.FieldByName('obsocial').AsString));
    js.add('nombrec', TlkJSONstring.Generate(obsocial.Nombrec));
    js.add('cuit', TlkJSONstring.Generate(obsocial.nrocuit));
    js.add('direccion', TlkJSONstring.Generate(obsocial.direccion));
    js.add('localidad', TlkJSONstring.Generate(obsocial.localidad));
    js.add('codpfis', TlkJSONstring.Generate(obsocial.codpfis));
    js.add('profesional', TlkJSONstring.Generate(profesional.nombre));

    s := s + TlkJSON.GenerateText(js) + ',';

    r.Next;
  end;

  s := Copy(s, 1, Length(s) - 1);
  result.Add('[' + s +  ']');

  js.Free;

  r.Close; r := nil;

  ExportarDatos := false;

  result.SaveToFile(dbs.DirSistema + '\temp\totalesri.json');
end;

procedure TTFacturacionCCB.exportarDetalleFacturacion(xperiodo: string);
var
  r: TIBQuery;

  js:TlkJSONobject;
  ws: TlkJSONstring;
  s, c: String;
  i: Integer;
  result: TStringList;
  monto: double;
begin
  preparardirectorio(xperiodo, '000000');
  
  r := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '"' + xperiodo + '"' + ' order by periodo, idprof, codos, orden, items');
  r.Open;

  result := TStringList.Create;

  while not r.Eof do begin

    periodo := xperiodo;
    if (r.FieldByName('ref1').AsString <> '') then
      if (utiles.verificarPeriodo(r.FieldByName('ref1').AsString, '')) then  periodo := r.FieldByName('ref1').AsString;  // Si difiere del período imputado 26/11/2019
    obsocial.SincronizarArancelNBU(r.FieldByName('codos').AsString, periodo);

    c := r.FieldByName('codanalisis').AsString;
    nbu.getDatos(c);
    monto := setValorAnalisis(r.FieldByName('codos').AsString, c, 0, 0, 0, 0); // Valor de cada analisis

    totiva[1] := 0; totiva[2] := 0;

    js := TlkJSONobject.Create;

    obsocial.getDatos(r.FieldByName('codos').AsString);
    profesional.getDatos(r.FieldByName('idprof').AsString);

    js.add('periodo', TlkJSONstring.Generate(r.FieldByName('periodo').AsString));
    js.add('codos', TlkJSONstring.Generate(r.FieldByName('codos').AsString));
    js.add('idprof', TlkJSONstring.Generate(r.FieldByName('idprof').AsString));
    js.add('orden', TlkJSONstring.Generate(r.FieldByName('orden').AsString));
    js.add('items', TlkJSONstring.Generate(r.FieldByName('items').AsString));
    js.add('codpac', TlkJSONstring.Generate(r.FieldByName('codpac').AsString));
    js.add('nombre', TlkJSONstring.Generate(r.FieldByName('nombre').AsString));
    js.add('codanalisis', TlkJSONstring.Generate(r.FieldByName('codanalisis').AsString));
    js.add('profiva', TlkJSONstring.Generate(r.FieldByName('profiva').AsString));
    js.add('osiva', TlkJSONstring.Generate(r.FieldByName('osiva').AsString));
    js.add('ref1', TlkJSONstring.Generate(r.FieldByName('ref1').AsString));
    js.add('retiva', TlkJSONstring.Generate(r.FieldByName('retiva').AsString));

    js.add('monto', TlkJSONnumber.Generate(monto));
    js.add('iva', TlkJSONnumber.Generate(totiva[1]));
    js.add('exento', TlkJSONnumber.Generate(totiva[2]));

    js.add('nroauditoria', TlkJSONstring.Generate(r.FieldByName('nroauditoria').AsString));
    js.add('nroafiliado', TlkJSONstring.Generate(r.FieldByName('nroafiliado').AsString));
    js.add('nroautorizacion', TlkJSONstring.Generate(r.FieldByName('nroautorizacion').AsString));
    js.add('fecha', TlkJSONstring.Generate(r.FieldByName('fecha').AsString));
    js.add('obrasocial', TlkJSONstring.Generate(obsocial.Nombre));
    js.add('profesional', TlkJSONstring.Generate(profesional.nombre));

    s := s + TlkJSON.GenerateText(js) + ',';

    r.Next;
  end;

  s := Copy(s, 1, Length(s) - 1);
  result.Add('[' + s +  ']');

  js.Free;

  r.Close; r := nil;

  result.SaveToFile(dbs.DirSistema + '\temp\detalle_fact' + StringReplace(xperiodo, '/', '_', [rfReplaceAll, rfIgnoreCase]) + '.json');
end;

procedure TTFacturacionCCB.Borrar(xperiodo, xidprof, xcodos: String);
// Objetivo...: Eliminar un Objeto
begin
  if (interbase  = 'N') then begin
    if Buscar(xperiodo, xidprof, xcodos) then Begin
      cabfact.Delete;
      datosdb.tranSQL(directorio, 'DELETE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
      periodo := cabfact.FieldByName('periodo').AsString;
      idprof  := cabfact.FieldByName('idprof').AsString;
      codos   := cabfact.FieldByName('codos').AsString;
      ProcesarDatosCentrales(xperiodo);  // Ahora Eliminamos las Operaciones de la Facturación Central
      datosdb.tranSQL(directorio, 'DELETE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
      DireccionarLaboratorio(xperiodo, xidprof); // Restablecemos el Laboratorio
      getDatos;
    end;
  end;
  if (interbase  = 'S') then begin
    lote.Clear;
    lote.Add('delete from cabfact where periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
    lote.Add('delete from detfact where periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
    ffirebird.TransacSQLBatch(lote);
  end;
end;

procedure TTFacturacionCCB.BorrarPeriodo(xperiodo: String; ProcesamientoIndividual: Boolean);
// Objetivo...: Borrar el período completo
begin
  if (interbase = 'N') then begin
    if ProcesamientoIndividual then Begin
      if cabfact.Active then cabfact.Close; if detfact.Active then detfact.Close; if idordenes.Active then idordenes.Close;
      utilesarchivos.Deltree(dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4));
      datosdb.tranSQL('DELETE FROM datosExportados WHERE periodo = ' + '"' + xperiodo + '"');
    end else Begin
      datosdb.tranSQL(directorio, 'DELETE FROM cabfact   WHERE periodo = ' + '"' + xperiodo + '"');
      datosdb.tranSQL(directorio, 'DELETE FROM detfact   WHERE periodo = ' + '"' + xperiodo + '"');
      datosdb.tranSQL(directorio, 'DELETE FROM idordenes WHERE periodo = ' + '"' + xperiodo + '"');
    end;
  end;
  if (interbase = 'S') then begin
    lote.clear;
    if ProcesamientoIndividual then Begin
      lote.Add('DELETE FROM cabfact   WHERE periodo = ' + '"' + xperiodo + '"');
      lote.Add('DELETE FROM detfact   WHERE periodo = ' + '"' + xperiodo + '"');
      lote.Add('DELETE FROM idordenes WHERE periodo = ' + '"' + xperiodo + '"');
    end else Begin
      lote.Add('DELETE FROM cabfact   WHERE periodo = ' + '"' + xperiodo + '"');
      lote.Add('DELETE FROM detfact   WHERE periodo = ' + '"' + xperiodo + '"');
      lote.Add('DELETE FROM idordenes WHERE periodo = ' + '"' + xperiodo + '"');
    end;
    ffirebird.TransacSQLBatch(lote);
  end;
end;

procedure TTFacturacionCCB.BorrarMovimientosLaboratorio(xperiodo, xidprof: String; ProcesamientoIndividual: Boolean);
// Objetivo...: Borrar el los movimientos de un periodo para un Laboratorio dado
begin
  if (interbase = 'N') then begin
    if verificicarSiExisteLaboratorio(xperiodo, xidprof) then begin
      if ProcesamientoIndividual then Begin
        ProcesarDatosCentrales(xperiodo);  // Ahora Eliminamos las Operaciones de la Facturación Central
        datosdb.tranSQL(detfact.DatabaseName, 'DELETE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
        DireccionarLaboratorio(xperiodo, xidprof); // Restablecemos el Laboratorio
        if cabfact.Active then cabfact.Close; if detfact.Active then detfact.Close; if idordenes.Active then idordenes.Close;
        if ordenes_audit <> Nil then
          if ordenes_audit.Active then ordenes_audit.Close;
        utilesarchivos.Deltree(dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + xidprof);

        datosdb.tranSQL(DBConexion, 'DELETE FROM datosExportados WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
        datosdb.tranSQL(DBConexion, 'DELETE FROM datosImportados WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
        desconectar; diractual := ''; LaboratorioActual := '';
        // Estas clases necesitan conexion permanente
        paciente.conectar; obsocial.conectar; profesional.conectar;
      end else Begin
        datosdb.tranSQL(directorio, 'DELETE FROM cabfact   WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
        datosdb.tranSQL(directorio, 'DELETE FROM detfact   WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
        datosdb.tranSQL(directorio, 'DELETE FROM idordenes WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      end;
      facturacion.vaciarBuffer;
    end;
  end;

  if (interbase = 'S') then begin
    if ProcesamientoIndividual then Begin
      lote.clear;
      lote.add('DELETE FROM cabfact   WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      lote.add('DELETE FROM detfact   WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      lote.add('DELETE FROM idordenes WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      ffirebird.TransacSQLBatch(lote);

      datosdb.tranSQL(DBConexion, 'DELETE FROM datosExportados WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      datosdb.tranSQL(DBConexion, 'DELETE FROM datosImportados WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      desconectar; diractual := ''; LaboratorioActual := '';
      // Estas clases necesitan conexion permanente
      paciente.conectar; obsocial.conectar; profesional.conectar;
    end;
   end;
end;

procedure TTFacturacionCCB.getDatos;
// Objetivo...: Cargar una instancia de la clase
begin
  if (interbase = 'N') then begin
    periodo := cabfact.FieldByName('periodo').AsString;
    idprof  := cabfact.FieldByName('idprof').AsString;
    codos   := cabfact.FieldByName('codos').AsString;
  end;
end;

function TTFacturacionCCB.verificarMovimientosObraSocial(xperiodo, xidprof, xcodos: string): boolean;
// Objetivo...: Verificar Integridad en los Items
var
  resultado: TQuery;
  res: TIBQuery;
begin
  if (interbase = 'N') then begin
    resultado := datosdb.tranSQL(directorio, 'SELECT codos FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
    resultado.Open;
    if (resultado.RecordCount > 0) then begin
      if Buscar(xperiodo, xidprof, xcodos) then cabfact.Edit else cabfact.Append;
      cabfact.FieldByName('periodo').AsString := xperiodo;
      cabfact.FieldByName('codos').AsString   := xcodos;
      cabfact.FieldByName('idprof').AsString  := xidprof;
      try
        cabfact.Post
       except
        cabfact.Cancel
      end;
      datosdb.closeDB(cabfact); cabfact.Open;

      periodo := xperiodo;
      codos   := xcodos;
      idprof  := xidprof;

      result := true;
    end else
      result := false;
    resultado.Close; resultado.Free;
  end;

  if (interbase = 'S') then begin
    res := ffirebird.getTransacSQL('SELECT codos FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
    res.Open;
    if (res.RecordCount > 0) then begin
      rsqlIB := ffirebird.getTransacSQL('SELECT codos FROM cabfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"' + ' AND codos = ' + '"' + xcodos + '"');
      rsqlIB.Open;
      if (rsqlIB.RecordCount = 0) then begin
        lote.Clear;
        lote.Add('insert into cabfact(periodo, idprof, codos) values (' +
        '''' + xperiodo + '''' + ', ' +
        '''' + xidprof + '''' + ', ' +
        '''' + xcodos + '''' + ')');
        ffirebird.TransacSQLBatch(lote);
        lote.clear;
      end;
      rsqlIB.Close; rsqlIB := nil;

      periodo := xperiodo;
      codos   := xcodos;
      idprof  := xidprof;

      result := true;
    end else
      result := false;
    res.Close; res.Free;
  end;
end;

function TTFacturacionCCB.setItems;
// Objetivo...: devolver un set de items facturados
begin
  if (interbase = 'N') then begin
    Result := datosdb.tranSQL(directorio, 'SELECT periodo, retiva, items, codanalisis, idprof, codpac, nombre, orden, ref1 FROM detfact WHERE periodo = ' + '"' + periodo + '"' + ' AND idprof = ' + '"' + idprof + '"' + ' AND codos = ' + '"' + codos + '"' + ' ORDER BY orden, items');
  end;
end;

function TTFacturacionCCB.setItemsIB: TIBQuery;
// Objetivo...: devolver un set de items facturados
begin
  if (interbase = 'S') then begin
     if not (factglobal) then Result := ffirebird.getTransacSQL('SELECT * FROM detfact WHERE periodo = ' + '"' + periodo + '"' + ' AND idprof = ' + '"' + idprof + '"' + ' AND codos = ' + '"' + codos + '"' + ' ORDER BY orden, items') else
     Result := ffirebird.getTransacSQL('SELECT * FROM detfact_gl WHERE periodo = ' + '"' + periodo + '"' + ' AND idprof = ' + '"' + idprof + '"' + ' AND codos = ' + '"' + codos + '"' + ' ORDER BY orden, items');
  end;
end;

function TTFacturacionCCB.setItemsIBAll(xperiodo, xidprof, xcodos: string): TIBQuery;
// Objetivo...: devolver un set de items facturados
begin
  if (xcodos = '------') then Result := ffirebird.getTransacSQL('SELECT * FROM detfact_gl WHERE periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"' + ' ORDER BY codos, orden, items') else
    Result := ffirebird.getTransacSQL('SELECT * FROM detfact_gl WHERE periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"' + ' and codos = ' + '"' + xcodos + '"' + ' ORDER BY codos, orden, items');
end;

procedure TTFacturacionCCB.marcarOrdenesFactGlobal(xperiodo, xidprof, xcodos, xorden, xidproffact: string);
begin
  ffirebird.TransacSQL('update detfact_gl set idproffact = ' + '''' + xidproffact + '''' + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and orden = ' + '''' + xorden + '''');
end;

procedure TTFacturacionCCB.iniciarFacturacionIB(xperiodo: string);
var
  r: TIBQuery;
begin
  lote.clear;
  r := ffirebird.getTransacSQL('select distinct(codos) from detfact where periodo = ' + '"' + xperiodo + '"' + ' and orden < ' + '"' + '5000' + '"');
  r.open;
  while not r.eof do begin
    lote.Add('delete from cabfact where periodo = ' + '''' + xperiodo + '''');
    r.Next;
  end;

  // Solamente borramos las ordenes que se generan desde la facturación global
  lote.Add('delete from detfact where periodo = ' + '''' + xperiodo + '''' + ' and  orden >= ' + '''' + 'R001' + '''');

  ffirebird.TransacSQLBatch(lote);
  lote.Clear;

  // Habilitamos las tablas de trabajo
  {ffirebird.closeDB(cabfactIB);
  ffirebird.closeDB(detfactIB);
  ffirebird.closeDB(ordenes_auditIB);

  cabfactIB       := ffirebird.InstanciarTabla('cabfact');
  detfactIB       := ffirebird.InstanciarTabla('detfact');
  idordenesIB     := ffirebird.InstanciarTabla('idordenes');
  cab_auditoriaIB := ffirebird.InstanciarTabla('cab_auditoria');
  det_auditoriaIB := ffirebird.InstanciarTabla('det_auditoria');

  {cabfactIB.Open;
  detfactIB.Open;
  idordenesIB.Open;}
end;

procedure TTFacturacionCCB.iniciarFacturacionIB(xperiodo, xcodos: string);
begin
  ffirebird.TransacSQL('delete from detfact where codos = ' + '''' + xcodos + '''' + ' and periodo = ' + '''' + xperiodo + '''');
  ffirebird.TransacSQL('delete from cabfact where codos = ' + '''' + xcodos + '''' + ' and periodo = ' + '''' + xperiodo + '''');

  // Habilitamos las tablas de trabajo
  {ffirebird.closeDB(cabfactIB);
  ffirebird.closeDB(detfactIB);
  ffirebird.closeDB(ordenes_auditIB);

  cabfactIB       := ffirebird.InstanciarTabla('cabfact');
  detfactIB       := ffirebird.InstanciarTabla('detfact');
  idordenesIB     := ffirebird.InstanciarTabla('idordenes');
  cab_auditoriaIB := ffirebird.InstanciarTabla('cab_auditoria');
  det_auditoriaIB := ffirebird.InstanciarTabla('det_auditoria');}

  {cabfactIB.Open;
  detfactIB.Open;
  idordenesIB.Open;}
end;

procedure TTFacturacionCCB.iniciarFacturacionIBOL(xperiodo, xcodos: string);
begin
  ffirebird.TransacSQL('delete from detfact where codos = ' + '''' + xcodos + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' and orden >= ' + '''' + 'O001' + '''' + ' and orden <= ' + '''' + 'O999' + '''');
end;


procedure TTFacturacionCCB.desconectarFacturacionIB;
begin
  // Habilitamos las tablas de trabajo
  {ffirebird.closeDB(cabfactIB);
  ffirebird.closeDB(detfactIB);
  ffirebird.closeDB(ordenes_auditIB);

  cabfactIB       := ffirebird.InstanciarTabla('cabfact_gl');
  detfactIB       := ffirebird.InstanciarTabla('detfact_gl');
  idordenesIB     := ffirebird.InstanciarTabla('idordenes_gl');

  cabfactIB.Open;
  detfactIB.Open;
  idordenesIB.Open;}
end;

procedure TTFacturacionCCB.reconectarFacturacionIB;
begin
  exit;  //25/08/2014

  // Habilitamos las tablas de trabajo
  {if (cabfactIB <> nil) then begin
    ffirebird.closeDB(cabfactIB);
    cabfactIB       := ffirebird.InstanciarTabla('cabfact');
    //cabfactIB.Open;
  end;

  if (detfactIB <> nil) then begin
    ffirebird.closeDB(detfactIB);
    detfactIB       := ffirebird.InstanciarTabla('detfact');
    //detfactIB.Open;
  end;

  if (ordenes_auditIB <> nil) then begin
    ffirebird.closeDB(ordenes_auditIB);
    idordenesIB     := ffirebird.InstanciarTabla('idordenes');
    //idordenesIB.Open;
  end;}

  factglobal := false;
end;

function TTFacturacionCCB.NuevaOrdenInterna(xperiodo, xidprof, xcodos: string): string;
// Objetivo...: Devolver el nuevo número de orden
var
  periodoanter, idprofanter, ordenanter, s, p: string;
  r: TIBQuery;
begin
  ordenanter := '0';

  if (interbase = 'N') then begin
    if DirectoryExists(diractual) then Begin
      if datosdb.Buscar(idordenes, 'periodo', 'idprof', xperiodo, xidprof) then Begin
        periodoanter := idordenes.FieldByName('periodo').AsString;
        idprofanter  := idordenes.FieldByName('idprof').AsString;
        ordenanter   := idordenes.FieldByName('orden').AsString;
        while not idordenes.EOF do Begin
          if (idordenes.FieldByName('periodo').AsString <> periodoanter) or (idordenes.FieldByName('idprof').AsString <> idprofanter) then Break;
          periodoanter := idordenes.FieldByName('periodo').AsString;
          idprofanter  := idordenes.FieldByName('idprof').AsString;
          ordenanter   := idordenes.FieldByName('orden').AsString;
          idordenes.Next;
        end;
      end;
    end;
  end;

  if (interbase = 'S') then begin
      if (factglobal) then __t := 'idordenes_gl' else __t := 'idordenes';
      r := ffirebird.getTransacSQL('select max(orden) from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      r.open; r.first;
      while not r.eof do begin
        ordenanter   := r.Fields[0].AsString;
        r.next;
      end;
      r.close; r.free;

      if (ordenanter = '') then ordenanter := '0'

      {ffirebird.Filtrar(idordenesIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      if ffirebird.Buscar(idordenesIB, 'PERIODO;IDPROF', xperiodo, xidprof) then Begin
        periodoanter := idordenesIB.FieldByName('periodo').AsString;
        idprofanter  := idordenesIB.FieldByName('idprof').AsString;
        ordenanter   := idordenesIB.FieldByName('orden').AsString;
        while not idordenesIB.EOF do Begin
          if (idordenesIB.FieldByName('periodo').AsString <> periodoanter) or (idordenesIB.FieldByName('idprof').AsString <> idprofanter) then Break;
          periodoanter := idordenesIB.FieldByName('periodo').AsString;
          idprofanter  := idordenesIB.FieldByName('idprof').AsString;
          ordenanter   := idordenesIB.FieldByName('orden').AsString;
          idordenesIB.Next;
        end;
      end;
      ffirebird.QuitarFiltro(idordenesIB);}
  end;

  Result := IntToStr(StrToInt(ordenanter) + 1);
end;

function TTFacturacionCCB.getPeriodosFacturadosDepurar: TStringList;
var
  l: TStringList;
  r: TIBQuery;
  s, a, m, t: string;
  __i: boolean;
begin

  __i := true;
  if (ffirebird <> nil) then
    if (pos('FACTLABWORK.GDB', ffirebird.IBDatabase.DatabaseName) > 0) then __i := false;

  if (__i) then begin
    firebird.getModulo('facturacion');
    ffirebird := TTFirebird.Create;
    ffirebird.Conectar(firebird.Host +  'FACTLABWORK.GDB', firebird.Usuario , firebird.Password);
  end;

  s := utiles.sExprFecha2000(utiles.setFechaActual);
  a := inttostr( strtoint( copy(s, 1, 4) ) - 1 );
  m := copy(s, 5, 2);

  l := TStringList.Create;
  r := ffirebird.getTransacSQL('select distinct(periodo) from cabfact order by substring(periodo from 4 for 4) desc, substring(periodo from 1 for 2) desc');
  r.open;
  while not r.eof do begin
    t := r.Fields[0].asstring;
    if (copy(t, 1, 2) <= m) and (copy(t, 4, 4) <= a)  then l.Add(t);
    r.next;
  end;
  r.close; r.free;
  result := l;

  ffirebird.Desconectar;
  ffirebird.free;
end;

function TTFacturacionCCB.getPeriodosFacturadosDepurados: TStringList;
var
  l: TStringList;
  r: TIBQuery;
  t: string;
begin
  l := TStringList.Create;
  r := ffirebird.getTransacSQL('select distinct(periodo) from detfact_hist order by substring(periodo from 4 for 4) desc, substring(periodo from 1 for 2) desc');
  r.open;
  while not r.eof do begin
    t := r.Fields[0].asstring;
    l.Add(t);
    r.next;
  end;
  r.close; r.free;
  result := l;
end;

procedure TTFacturacionCCB.DepurarPeriodosFacturadosIB(xperiodo: string);

procedure procesar(xperiodo: string);
begin
  lote.Add('DELETE FROM cabfact_hist WHERE periodo = ' + '''' + xperiodo + '''');

  rsqlIB := ffirebird.getTransacSQL('select * from cabfact where periodo = ' + '''' + xperiodo + '''');
  rsqlIB.Open;
  while not rsqlIB.eof do begin
    lote.Add('insert into cabfact_hist (periodo, idprof, codos, fecha) values (' +
             '''' + xperiodo + '''' + ', ' +
             '''' + rsqlIB.FieldByName('idprof').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('codos').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('fecha').AsString + '''' + ')');
    rsqlIB.Next;
  end;
  rsqlIB.Close; rsqlIB.Free;

  lote.Add('DELETE FROM detfact_hist WHERE periodo = ' + '''' + xperiodo + '''');

  rsqlIB := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''');
  rsqlIB.Open;
  while not rsqlIB.eof do begin
    lote.Add('insert into detfact_hist (periodo, idprof, codos, items, orden, codpac, nombre, codanalisis, ref1, osiva, retiva, profiva, monto, iva, exento, ' +
             'nroauditoria, nroafiliado, nroautorizacion, fecha, coseguro) values (' +
             '''' + xperiodo + '''' + ', ' +
             '''' + rsqlIB.FieldByName('idprof').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('codos').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('items').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('orden').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('codpac').AsString + '''' + ', ' +
             QuotedStr(rsqlIB.FieldByName('nombre').AsString) + ', ' +
             '''' + rsqlIB.FieldByName('codanalisis').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('ref1').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('osiva').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('retiva').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('profiva').AsString + '''' + ', ' +
             utiles.StringRemplazarCaracteres(FloatToStr(rsqlIB.FieldByName('monto').AsFloat), ',', '.') + ',' +
             utiles.StringRemplazarCaracteres(FloatToStr(rsqlIB.FieldByName('iva').AsFloat), ',', '.') + ',' +
             utiles.StringRemplazarCaracteres(FloatToStr(rsqlIB.FieldByName('exento').AsFloat), ',', '.') + ',' +
             '''' + rsqlIB.FieldByName('nroauditoria').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('nroafiliado').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('nroautorizacion').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('fecha').AsString + '''' + ', ' +
             utiles.StringRemplazarCaracteres(FloatToStr(rsqlIB.FieldByName('coseguro').AsFloat), ',', '.') +
             ')'
            );
    rsqlIB.Next;
  end;
  rsqlIB.Close; rsqlIB.Free;

  lote.Add('DELETE FROM idordenes_hist WHERE periodo = ' + '''' + xperiodo + '''');

  rsqlIB := ffirebird.getTransacSQL('select * from idordenes where periodo = ' + '''' + xperiodo + '''');
  rsqlIB.Open;
  while not rsqlIB.eof do begin
    lote.Add('insert into idordenes_hist (periodo,idprof, orden) values (' +
             '''' + xperiodo + '''' + ', ' +
             '''' + rsqlIB.FieldByName('idprof').AsString + '''' + ', ' +
             '''' + rsqlIB.FieldByName('orden').AsString + '''' + ')');
    rsqlIB.Next;
  end;
  rsqlIB.Close; rsqlIB.Free;
end;

begin
  firebird.getModulo('facturacion');
  ffirebird := TTFirebird.Create;
  ffirebird.Conectar(firebird.Host +  'FACTLABWORK.GDB', firebird.Usuario , firebird.Password);

  lote.Clear;
  procesar(xperiodo);
  lote.add('delete from detfact where periodo = ' + '''' + xperiodo + '''');
  lote.add('delete from cabfact where periodo = ' + '''' + xperiodo + '''');
  lote.add('delete from idordenes where periodo = ' + '''' + xperiodo + '''');

  ffirebird.TransacSQLBatch(lote);

  ffirebird.Desconectar;
  ffirebird.free;

  ffirebird := TTFirebird.Create;
  ffirebird.Conectar(firebird.Host +  'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);

  lote.clear;
  procesar(xperiodo);
  lote.add('delete from detfact where periodo = ' + '''' + xperiodo + '''');
  lote.add('delete from cabfact where periodo = ' + '''' + xperiodo + '''');
  lote.add('delete from idordenes where periodo = ' + '''' + xperiodo + '''');

  ffirebird.TransacSQLBatch(lote);

  ffirebird.Desconectar;
  ffirebird.free;

  ffirebird := TTFirebird.Create;
  ffirebird.Conectar(firebird.Host +  'FACTLABWORK.GDB', firebird.Usuario , firebird.Password);
end;

function TTFacturacionCCB.NuevoItems(xperiodo, xidprof, xcodos: String): Integer;
// Objetivo...: Recuperar el ultimo Items Facturado
var
  r: TQuery; s: TIBQuery;
Begin
  if (interbase = 'N') then begin
    Result := 1;
    r := datosdb.tranSQL(directorio, 'select * from detfact where Periodo = ' + '''' + xperiodo + '''' + ' and Idprof = ' + '''' + xidprof + '''' + ' and Codos = ' + '''' + xcodos + '''' + ' and Items < ' + '''' + '5000' + '''');
    r.Open;
    if r.RecordCount > 0 then Begin
      r.Last;
      Result := StrToInt(r.FieldByName('items').AsString) + 1;
    end;
    r.Close; r.Free;
  end;

  if (interbase = 'S') then begin
    Result := 1;
    s := ffirebird.getTransacSQL('select * from detfact where Periodo = ' + '''' + xperiodo + '''' + ' and Idprof = ' + '''' + xidprof + '''' + ' and Codos = ' + '''' + xcodos + '''' + ' and Items < ' + '''' + '5000' + '''');
    s.Open;
    if s.RecordCount > 0 then Begin
      s.Last;
      Result := StrToInt(s.FieldByName('items').AsString) + 1;
    end;
    s.Close; s.Free;
  end;
end;

procedure TTFacturacionCCB.RenumerarOrdenesInternas(xperiodo, xidprof: String);
// Objetivo...: Renumerar las ordenes internas en una Obra Social
var
  i, j: Integer;
Begin
  if (interbase = 'N') then begin
    detfact.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';

    detfact.First; i := 0; j := 0;
    while not detfact.EOF do Begin
      if detfact.FieldByName('orden').AsString <> idanter then Begin
        Inc(i); j := 0;
        idanter  := detfact.FieldByName('orden').AsString;
      end;
      Inc(j);
      detfact.Edit;
      detfact.FieldByName('orden').AsString := utiles.sLlenarIzquierda(IntToStr(i), 4, '0');
      try
        detfact.Post
       except
        detfact.Cancel
      end;
      detfact.Next;
    end;

    detfact.IndexFieldNames := 'Periodo;Idprof;Codos;Items;Orden';

    if datosdb.Buscar(idordenes, 'periodo', 'idprof', xperiodo, xidprof) then Begin      // Guardamos la ultima como Orden Interna
      idordenes.Edit;
      idordenes.FieldByName('orden').AsString := utiles.sLlenarIzquierda(IntToStr(i), 4, '0');
      try
        idordenes.Post
       except
        idordenes.Cancel
      end;
    end;

    datosdb.refrescar(idordenes);
  end;

  if (interbase = 'S') then begin
    {if not (detfactIB.Active) then detfactIB.Open;
    detfactIB.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';

    detfactIB.First; i := 0; j := 0;
    while not detfact.EOF do Begin
      if detfactIB.FieldByName('orden').AsString <> idanter then Begin
        Inc(i); j := 0;
        idanter  := detfactIB.FieldByName('orden').AsString;
      end;
      Inc(j);
      detfactIB.Edit;
      detfactIB.FieldByName('orden').AsString := utiles.sLlenarIzquierda(IntToStr(i), 4, '0');
      try
        detfactIB.Post
       except
        detfactIB.Cancel
      end;
      ffirebird.RegistrarTransaccion(detfactIB);
      detfactIB.Next;
    end;

    if not (detfactIB.Active) then detfactIB.Open;
    detfactIB.IndexFieldNames := 'Periodo;Idprof;Codos;Items;Orden';

    if ffirebird.Buscar(idordenesIB, 'periodo;idprof', xperiodo, xidprof) then Begin      // Guardamos la ultima como Orden Interna
      idordenesIB.Edit;
      idordenesIB.FieldByName('orden').AsString := utiles.sLlenarIzquierda(IntToStr(i), 4, '0');
      try
        idordenesIB.Post
       except
        idordenesIB.Cancel
      end;
    end;

    ffirebird.RegistrarTransaccion(idordenesIB);}
  end;
end;

procedure TTFacturacionCCB.BorrarOrden(xperiodo, xorden, xidprof: String);
// Objetivo...: Borrar un items en una determinación
begin
  if (interbase = 'N') then begin
    datosdb.tranSQL(directorio, 'DELETE FROM detfact WHERE Periodo = ' + '"' + xperiodo + '"' + ' and orden = ' + '"' + xorden + '"');
  end;
  if (interbase = 'S') then begin
    ffirebird.TransacSQL('DELETE FROM detfact WHERE Periodo = ' + '"' + xperiodo + '"' + ' and orden = ' + '"' + xorden + '"' + ' and idprof = ' + '"' + xidprof + '"');
  end;
end;

function TTFacturacionCCB.verificarSiLaObraSocialTieneMovimientos(xperiodo, xcodos: String): Boolean;
Begin
  if (interbase = 'N') then begin
    Result := False;
    datosdb.Filtrar(detfact, 'Periodo = ' + '''' + xperiodo + '''' + ' and Codos = ' + '''' + xcodos + '''');
    if detfact.RecordCount > 0 then Result := True;
    datosdb.QuitarFiltro(detfact);
  end;
  if (interbase = 'S') then begin
    Result := False;
    rsqlIB := ffirebird.getTransacSQL('select * from detfact where Periodo = ' + '''' + xperiodo + '''' + ' and Codos = ' + '''' + xcodos + '''');
    rsqlIB.Open;
    if rsqlIB.RecordCount > 0 then Result := True;
    rsqlIB.close;
  end;
end;

procedure TTFacturacionCCB.InactivarLaboratorio;
// Objetivo...: Quitarle al Laboratorio la categoria de Activo
Begin
  LaboratorioActivo := False;
  directorio        := '';
  diractual         := 'ninguno';

  if (interbase = 'N') then begin
    if cabfact   <> nil then if cabfact.Active   then datosdb.closeDB(cabfact);
    if detfact   <> nil then if detfact.Active   then datosdb.closeDB(detfact);
    if idordenes <> nil then if idordenes.Active then datosdb.closeDB(idordenes);
    cabfact := nil; detfact := nil; idordenes := nil;
  end;

  if (interbase = 'S') then begin
    {if cabfactIB   <> nil then if cabfactIB.Active   then ffirebird.closeDB(cabfactIB);
    if detfactIB   <> nil then if detfactIB.Active   then ffirebird.closeDB(detfactIB);
    if idordenesIB <> nil then if idordenesIB.Active then ffirebird.closeDB(idordenesIB);
    cabfactIB := nil; detfactIB := nil; idordenesIB := nil;}
  end;
end;

procedure TTFacturacionCCB.GuardarOrdenInterna(xperiodo, xidprof, xorden: string);
// Objetivo...: Guardar ultimo número de orden
var
  norden: Boolean;
  r: TIBQuery;
begin
  norden := False;
  if (interbase = 'N') then begin
    if xorden < '5000' then Begin
      if not datosdb.Buscar(idordenes, 'periodo', 'idprof', xperiodo, xidprof) then Begin
        idordenes.Append;
        norden := True;
      end else idordenes.Edit;
      idordenes.FieldByName('periodo').AsString := xperiodo;
      idordenes.FieldByName('idprof').AsString  := xidprof;
      if  norden then idordenes.FieldByName('orden').AsString := '0001' else
        if xorden > idordenes.FieldByName('orden').AsString then idordenes.FieldByName('orden').AsString := xorden;  // Solo remplazamos si es mayor
      try
        idordenes.Post
       except
        idordenes.Cancel
      end;
      datosdb.refrescar(idordenes);
    end;
  end;

  if (interbase = 'S') then begin
    if xorden < '5000' then Begin
      if (factglobal) then __t := 'idordenes_gl' else __t := 'idordenes';

      r := ffirebird.getTransacSQL('select * from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      r.open;

      if (r.RecordCount = 0) then begin
        lote.Add('delete from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
        lote.Add('insert into ' + __t + ' (periodo, idprof, orden) values (' + '''' + xperiodo + '''' + ', ' + '''' + xidprof + '''' + ', ' + '''' + '0001' + '''' + ')');
      end else begin
        if xorden > r.FieldByName('orden').AsString then lote.Add('update ' + __t + ' set orden = ' + '''' + xorden + '''' + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      end;

      r.close; r.free;

      {if not ffirebird.Buscar(idordenesIB, 'PERIODO;IDPROF', xperiodo, xidprof) then Begin
        idordenesIB.Append;
        norden := True;
      end else
        idordenesIB.Edit;
      idordenesIB.FieldByName('periodo').AsString := xperiodo;
      idordenesIB.FieldByName('idprof').AsString  := xidprof;
      if norden then idordenesIB.FieldByName('orden').AsString := '0001' else
        if xorden > idordenesIB.FieldByName('orden').AsString then idordenesIB.FieldByName('orden').AsString := xorden;  // Solo remplazamos si es mayor
      try
        idordenesIB.Post
       except
        idordenesIB.Cancel
      end;
      ffirebird.RegistrarTransaccion(idordenesIB);
      ffirebird.closeDB(idordenesIB); idordenesIB.Open;}
    end;
  end;

end;

procedure TTFacturacionCCB.VerificarOrdenInterna(xperiodo, xidprof: string);
// Objetivo...: Verificar el ultimo nro de orden, para evitar que se superpongan ordenes
var
  r: TQuery;
  s: TIBQuery;
Begin
  if (interbase = 'N') then begin
    r := datosdb.tranSQL(detfact.DatabaseName, 'select max(orden) from detfact');
    r.Open;
    GuardarOrdenInterna(xperiodo, xidprof, r.Fields[0].AsString);
    r.Close; r.Free;
  end;
  if (interbase = 'S') then begin
    if (factglobal) then __t := 'detfact_gl' else __t := 'detfact';
    s := ffirebird.getTransacSQL('select max(orden) from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
    s.Open;
    if (length(trim(s.Fields[0].AsString)) > 0) then GuardarOrdenInterna(xperiodo, xidprof, s.Fields[0].AsString);
    s.Close; s.Free;
  end;
end;

function TTFacturacionCCB.setValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
var
  i, j, v, v9984, porcentOS: real; montoFijo, mf9984: Boolean;
  _totUB, _canUB, unidadNBU, unidad_NBU, __montocache, __un: Real;
  rie: String;

  function getMontoAnalisis(xcodos, xperiodo, xcodigo: string): real;
  var
    i: integer;
    m: real;
  begin
    m := 0;
    if (__codigos = nil) then begin
      __codigos := TStringList.Create;
      __montos := TStringList.Create;
      result := m;
      exit;
    end;

    for i:= 1 to __codigos.Count do begin
      if (__codigos[i-1] = xcodos+xperiodo+xcodigo) then begin
        m := StrToFloat(__montos[i-1]);
        break;
      end;
    end;

    result := m;
  end;

  procedure addMonto(xcodos, xperiodo, xcodigo: string; xmonto: real);
  begin
    if (not __ignorarcachemontos) then begin
      __codigos.Add(xcodos+xperiodo+xcodigo);
      __montos.Add(FloatToStr(xmonto));
    end;
    //utiles.msgError((xcodos+xperiodo+xcodigo) + '   ' + FloatToStr(xmonto));
  end;

begin
  compensacion := 0;

  if (obsocial.FactNBU = 'N') or (Length(trim(xcodanalisis)) = 4) then Begin

    // _caran: deducir la compensación determinacion a determinacion
    // Verificamos el porcentaje que paga la Obra Social
    if obsocial.porcentaje > 0 then porcentOS := (obsocial.porcentaje * 0.01) else porcentOS := (100 * 0.01);

    i := 0; j := 0; v9984 := 0; totUG9984 := 0; totUB9984 := 0;

    // 1º Verificamos que el analisis no tenga monto Fijo - Teniendo en cuenta períodos
    i := obsocial.setMontoFijo(xcodos, xcodanalisis, periodo);
    // 2º Verificamos que el analisis no tenga monto Fijo
    if i = 0 then i := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis);
    // Retenemos el código de Monto Fijo
    if i = 0 then codigomontofijo := '' else codigomontofijo := xcodanalisis;
    // Flag que indica si la determinación tiene o no Monto Fijo
    if i > 0 then DetMontoFijo := True else DetMontoFijo := False;
    // Si tiene Monto Fijo y es cero abortamos Abortamos
    if (obsocial.MontoFijo) and (i = 0) then exit;

    if i = 0 then Begin
      // Cálculamos el valor del análisis
      i := (xOSUB * xNOUB) + (xOSUG * xNOUG);
      if obsocial.tope <> 'S' then Begin   // Acumulamos para las Obras Sociales sin Topes
        totUG  := totUG + ((xNOUG * xOSUG) * porcentOS);
        totUB  := totUB + ((xNOUB * xOSUB) * porcentOS);
        _totUB := _totUB + ((xNOUB * xOSUB) * porcentOS);
      end;
      canUG  := canUG + xOSUG;
      canUB  := canUB + xOSUB;
      _canUB := _canUB + xOSUB;

      if obsocial.categoria = 'S' then Begin
        caran          := caran + (((xNOUB * xOSUB) * porcentOS) * (profesional.porcUB * 0.01));
        compensacion   := (((xNOUB * xOSUB) * porcentOS) * (profesional.porcUB * 0.01));
        _ccaranSin9984 := (((xNOUB * xOSUB) * porcentOS) * (profesional.porcUB * 0.01));
      end;
      montoFijo := False;
    end else montoFijo := True;

    // Unidades Gastos y Unidades Honorarios sin 9984
    totUBSin9984 := totUB;
    totUGSin9984 := totUG;

    // Calculamos el valor del codigo de toma y recepción
    rie := nomeclatura.RIE;
    codigo_tomamuestra := False;
    if Length(Trim(nomeclatura.cftoma)) > 0 then Begin
      codigo_tomamuestra := True;
      codftoma := nomeclatura.cftoma;  // Capturamos el código fijo de toma y recepcion
      nomeclatura.getDatos(codftoma);
      //j := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, codftoma);   // Verificamos si el 9984 tiene Monto Fijo

      if j = 0 then
        j := obsocial.setMontoFijo(xcodos, codftoma, periodo);   // Rastrea el Monto Fijo por Período

      if j = 0 then Begin      // Deducimos en Forma Normal el 9984
        v9984   := ((obsocial.UG * nomeclatura.ub) + (obsocial.UB * nomeclatura.gastos));

        if (obsocial.tope = 'S') and (rie <> '*') then Begin
          v := v9984;
          if v < obsocial.topemin then Begin
            v9984 := v * 2;   // Si monto menor a topemin entonces se multiplica por 2
            if obsocial.categoria = 'S' then Begin
              caran        := caran + (v * (profesional.porcUB * 0.01));   // Recalculamos la compensacion porque va por dos
              compensacion := v * (profesional.porcUB * 0.01);
            end;
          end;
          if (v > obsocial.topemin) and (v < obsocial.topemax) then v9984 := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
        end;
        tot9984 := tot9984 + (v9984 * porcentOS);
      end else Begin               // Monto Fijo del 9984
        tot9984 := tot9984 + j;
        v9984   := j;
      end;

      if obsocial.tope <> 'S' then Begin
        if not montoFijo then Begin
          totUG  := totUG  + ((obsocial.UG * nomeclatura.gastos) * porcentOS);
          totUB  := totUB  + ((obsocial.UB * nomeclatura.UB) * porcentOS);
          _totUB := _totUB + ((obsocial.UB * nomeclatura.UB) * porcentOS);

          totUG9984 := totUG9984 + ((obsocial.UG * nomeclatura.gastos) * porcentOS);
          totUB9984 := totUB9984 + ((obsocial.UB * nomeclatura.UB) * porcentOS);
        end;
      end;
      if not montoFijo then Begin
        canUG     := canUG     + nomeclatura.gastos;
        canUB     := canUB     + nomeclatura.UB;
        _canUB    := _canUB    + nomeclatura.UB;
        canUB9984 := canUB9984 + nomeclatura.UB;
      end;
    end;

    if not montoFijo then Begin          // Obras sociales que trabajan con topes
      if (obsocial.tope = 'S') and (rie <> '*') then Begin
        if v < obsocial.topemin then i := i * 2;   // Si monto menor a topemin entonces se multiplica por 2
        if (v > obsocial.topemin) and (v < obsocial.topemax) then i := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
      end;
    end;

    // Verificamos si el 9984 es de monto fijo
    if obsocial.setMontoFijo(xcodos, codftoma, periodo) > 0 then mf9984 := True else mf9984 := False;

    if (obsocial.categoria = 'S') and not (mf9984) then Begin
      if obsocial.tope <> 'S' then
        caran := totUB * (profesional.porcUB * 0.01) else
          if rie <> '*' then caran := (canUB * obsocial.UB) * (profesional.porcUB * 0.01);   // Compensación Arancelaria

      if obsocial.tope <> 'S' then        // Compensación Arancelaria del 9984
        _ccaran9984 := totUB9984 * (profesional.porcUB * 0.01) else
         if rie <> '*' then _ccaran9984 := (canUB9984 * obsocial.UB) * (profesional.porcUB * 0.01);

      if obsocial.tope <> 'S' then   // Compesación individual, determinación a determinación
        _caran := _totUB * (profesional.porcUB * 0.01) else
          if rie <> '*' then _caran := (_canUB * obsocial.UB) * (profesional.porcUB * 0.01);   // Compensación Arancelaria

      //--------- Anulado 29/05/2008
      {if obsocial.tope <> 'S' then
        compensacion := profesional.porcUB * 0.01 else
          if rie <> '*' then compensacion := (canUB * obsocial.UB) * (profesional.porcUB * 0.01);   // Compensación Arancelaria}

      //--------- Activado 29/05/2008
      if obsocial.tope <> 'S' then   // Compesación individual, determinación a determinación
        compensacion := _totUB * (profesional.porcUB * 0.01) else
          if rie <> '*' then compensacion := (_canUB * obsocial.UB) * (profesional.porcUB * 0.01);   // Compensación Arancelaria

    end;

    i := i * porcentOS;

    totcomp := totcomp + caran;

    //if not (ExcluirLab) then begin   // agregado el 29/01/2010
    if paciente.Gravadoiva = 'S' then Begin
      ivaret      := ivaret      + i;
      ivaret9984  := ivaret9984  + (v9984 * porcentOS); //StrToFloat(utiles.FormatearNumero(FloatToStr((v9984 * porcentOS))));
      ivaretcaran := ivaretcaran + compensacion; //_caran;
      if obsocial.retencioniva > 0 then Begin
        totiva[1] := totiva[1] + (i + (v9984 * porcentOS) + compensacion {_caran});  ///StrToFloat(utiles.FormatearNumero(FloatToStr((i + (v9984 * porcentOS) + _caran))));
        totiva[3] := totiva[1] * (obsocial.retencioniva * 0.01); ///StrToFloat(utiles.FormatearNumero(FloatToStr((obsocial.retencioniva * 0.01))));
      end;
    end else Begin
      ivaexento   := ivaexento   + i;
      ivaexe9984  := ivaexe9984  + (v9984 * porcentOS); ///StrToFloat(utiles.FormatearNumero(FloatToStr((v9984 * porcentOS))));
      ivaexecaran := ivaexecaran + compensacion; // _caran; //StrToFloat(utiles.FormatearNumero(FloatToStr(_caran)));
      if obsocial.retencioniva > 0 then totiva[2] := totiva[2] + (i + (v9984 * porcentOS) + compensacion); // {_caran}); ///StrToFloat(utiles.FormatearNumero(FloatToStr((i + (v9984 * porcentOS) + _caran))));
    end;
    //end;

    totiva[4] := totiva[1]; totiva[5] := totiva[2]; totiva[6] := totiva[3];
    m9984 := v9984;
  end;

  if (obsocial.FactNBU = 'S') and (Length(trim(xcodanalisis)) = 6) then Begin
    totUG := 0; totUB := 0; caran := 0; tot9984 := 0;

    __montocache := getMontoAnalisis(xcodos, periodo, xcodanalisis);

    if (__montocache = 0) then begin // implementamos sistema de cache 09/02/2014

      nbu.getDatos(xcodanalisis);
      // Verificamos si tiene Monto Fijo
      i := obsocial.setMontoFijoNBU(xcodos, xcodanalisis, periodo);

      if (i = -1) then begin
        result := 0;
        exit;
      end;

      // Verificamos si tiene unidad diferencial
      unidadNBU := obsocial.setUnidadNBU(xcodos, xcodanalisis, periodo);
      if unidadNBU > 0 then i := {nbu.unidad} obsocial.valorNBU * unidadNBU;  //utiles.msgError(floattostr(nbu.unidad) + '   ' + floattostr(unidadNBU) + '   ' + floattostr(i));

      // Verificamos si la OS tiene nomenclador propio
      if (nomeclaturaos.Buscar(xcodos, xcodanalisis)) then begin
        nomeclaturaos.getDatos(xcodos, xcodanalisis);
        if (nomeclaturaos.Especial <> '*') then begin
          if i = 0 then i := nomeclaturaos.unidad * obsocial.valorNBU;
        end else begin
          if i = 0 then i := nomeclaturaos.unidades * obsocial.valorNBU;
        end;
      end;

      // 12/07/2010 -> NBU unidades por periodo
      unidad_NBU := nbu.unidad;
      __un := unidadesNBU.getUnidad(xcodanalisis, periodo);
      //if (unidadesNBU.getUnidades > 0) then
      if (__un > 0) then

        unidad_NBU := __un; //unidadesNBU.getUnidades;

      if (nbu.Especial <> '*') then begin
        if i = 0 then i := unidad_NBU * obsocial.valorNBU;
      end else begin
        if i = 0 then i := unidad_NBU * obsocial.valorNBUDif;
      end;

      //if not (ExcluirLab) then begin   // agregado el 29/01/2010
      {if paciente.Gravadoiva = 'S' then Begin
        ivaret      := ivaret      + i;
        ivaret9984  := 0;
        ivaretcaran := 0;
        if obsocial.retencioniva > 0 then Begin
          totiva[1] := totiva[1] + i;
          totiva[3] := totiva[1] * (obsocial.retencioniva * 0.01);
        end;
      end else Begin
        ivaexento   := ivaexento   + i;
        ivaexe9984  := 0;
        ivaexecaran := 0;
        if obsocial.retencioniva > 0 then totiva[2] := totiva[2] + i;
      end;}
      //end;

      if obsocial.porcentaje > 0 then porcentOS := (obsocial.porcentaje * 0.01) else porcentOS := (100 * 0.01);

      i := i * porcentOS;

      addMonto(xcodos, periodo, xcodanalisis, i);

    end else

      i := __montocache;

    if paciente.Gravadoiva = 'S' then Begin
      ivaret      := ivaret      + i;
      ivaret9984  := 0;
      ivaretcaran := 0;
      if obsocial.retencioniva > 0 then Begin
        totiva[1] := totiva[1] + i;
        totiva[3] := totiva[1] * (obsocial.retencioniva * 0.01);
      end;
    end else Begin
      ivaexento   := ivaexento   + i;
      ivaexe9984  := 0;
      ivaexecaran := 0;
      if obsocial.retencioniva > 0 then totiva[2] := totiva[2] + i;
    end;


    totiva[4] := totiva[1]; totiva[5] := totiva[2]; totiva[6] := totiva[3];
  end;

  Result := i;
end;

function TTFacturacionCCB.setUB: Real;
// Objetivo...: retornar UB
Begin
  Result := totUB;
  totUB  := 0;
end;

function TTFacturacionCCB.setUG: Real;
// Objetivo...: retornar UG
Begin
  Result := totUG;
  totUG  := 0;
end;

function TTFacturacionCCB.setTotCompensacion: Real;
// Objetivo...: retornar total compensacion arancelaria
Begin
  Result  := totcomp;
  totcomp := 0;
  caran   := 0;
end;

function TTFacturacionCCB.setTot9984: Real;
// Objetivo...: Obtener total Facturado de códigos 9984
Begin
  Result  := tot9984;
  tot9984 := 0;
end;

function TTFacturacionCCB.set9984: Real;
// Objetivo...: Obtener total Facturado de códigos 9984
Begin
  Result  := m9984;
  m9984 := 0;
end;

function TTFacturacionCCB.setCodigoMontoFijo: String;
// Objetivo...: Devolver determinación con código de monto fijo
Begin
  Result := codigomontofijo;
end;

function TTFacturacionCCB.setTotUBSin9984: Real;
// Objetivo...: Obtener total Facturado sin códigos 9984
Begin
  Result       := totUBSin9984;
  totUBSin9984 := 0; totUB := 0;
end;

function TTFacturacionCCB.setTotUGSin9984: Real;
// Objetivo...: Obtener total Facturado sin códigos 9984
Begin
  Result       := totUGSin9984;
  totUGSin9984 := 0; totUG := 0;
end;

function TTFacturacionCCB.setTotUB9984: Real;
// Objetivo...: Obtener total Facturado sin códigos 9984
Begin
  Result    := totUB9984;
  totUB9984 := 0; totUB := 0;
end;

function TTFacturacionCCB.setTotUG9984: Real;
// Objetivo...: Obtener total Facturado sin códigos 9984
Begin
  Result       := totUG9984;
  totUG9984 := 0; totUG := 0;
end;

function  TTFacturacionCCB.setCaranSin9984: Real;
// Objetivo...: Devolver Compensacion sin 9984
Begin
  Result         := _ccaranSin9984;
  _ccaranSin9984 := 0;
end;

function  TTFacturacionCCB.setCaran9984: Real;
// Objetivo...: Devolver Compensacion de los 9984
Begin
  Result      := _ccaran9984;
  _ccaran9984 := 0;
end;

procedure TTFacturacionCCB.FiltrarPeriodo(xperiodo: String);
// Objetivo...: Filtrar Período
begin
  firebird.getModulo('facturacion');
  if (length(trim(firebird.Host)) = 0) then interbase := 'N';

  if (interbase = 'N') then begin
    if (cabfact <> nil) then
      if not cabfact.Filtered then datosdb.Filtrar(cabfact, 'periodo = ' + '''' + xperiodo + '''');
  end;
  if (interbase = 'S') then begin
    //if (cabfactIB <> nil) then
      //if not cabfactIB.Filtered then ffirebird.Filtrar(cabfactIB, 'periodo = ' + '''' + xperiodo + '''');
  end;
end;

procedure TTFacturacionCCB.QuitarFiltro;
// Objetivo...: Quitar Filtrar Período
begin
  if (interbase = 'N') then begin
    if (cabfact <> nil) then
      if cabfact.Filtered then datosdb.QuitarFiltro(cabfact);
  end;
  if (interbase = 'S') then begin
    //if (cabfactIB <> nil) then begin
      //if cabfactIB.Filtered then ffirebird.QuitarFiltro(cabfactIB);
    //end;
  end;
end;

{ *****************************************************************************
 Informes
 ***************************************************************************** }

function TTFacturacionCCB.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if not ExportarDatos then Begin
    if lineas >= LineasPag then Begin
      //list.lineatxt(inttostr(lineas), True);
      if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else
        for k := 1 to lineas_blanco do list.LineaTxt('', True);
      Result := True;
    end;
  end;
end;

procedure TTFacturacionCCB.RealizarSalto;
// Objetivo...: imprimir lineas en blanco hasta realizar salto de página
var
  k: Integer;
begin
  if not ExportarDatos then Begin
    if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else Begin
      for k := lineas + 1 to LineasPag do list.LineaTxt('', True);
      lineas := LineasPag + 5;
      ControlarSalto;
    end;
  end;
end;

{------------------------------------------------------------------------------}

procedure TTFacturacionCCB.ListarResumenPrestacionesPorObraSocial(xperiodo, xtitulo, xcolumnas: String; ObrasSocSel: TStringList; salida: char);
// Objetivo...: Listar Resumen de Prestaciones por Obra Social
var
  i, j, e: ShortInt;
begin
  IniciarArreglos;

  if (interbase = 'N') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    if not (detfact.Active) then detfact.Open;
    detfact.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';
    if listControl then e := 36 else e := 6; pag := 0;
    Periodo := xperiodo;

    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación a Obras Sociales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, cursiva, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div StrToInt(xcolumnas);
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo((espaciocol * i) + e, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo((((espaciocol * i) + e) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo1(xperiodo, xtitulo, xcolumnas);
    end;

    if ProcesamientoCentral then totalesOS.Open;

    detfact.First;

    codosanter  := ''; idprofanter := ''; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; montos[1] := 0; total := 0; totales[1] := 0; datosListados := False;
    ccanUB := 0; ccanUG := 0; ttotUB := 0; ttotUG := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; totiva[1] := 0; totiva[2] := 0; totiva[3] := 0; _caran := 0; caran := 0;

    ordenanter  := detfact.FieldByName('orden').AsString;
    idprofanter := 't';
    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;
        nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);
        if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        if detfact.FieldByName('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaObraSocial(salida, xperiodo, xtitulo, 'clNavy'); // Ruptura por Obra Social
          idprofanter := ''; cantidad := 0; subtotal := 0; total := 0; //tot9984 := 0;
        end;
        if detfact.FieldByName('idprof').AsString <> idprofanter then Begin   // Ruptura por Profesional
          profesional.SincronizarListaRetIVA(xperiodo, detfact.FieldByname('idprof').AsString);
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaPorProfesional('clNavy', salida);
        end;

        if (i >= StrToInt(xcolumnas)) or (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if detfact.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        paciente.getDatos(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
        if (length(trim(detfact.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfact.FieldByName('retiva').AsString;
        pac_retiva := paciente.Gravadoiva;
        Inc(i);

        if (length(trim(detfact.FieldByName('ref1').AsString)) = 7) then periodo := detfact.FieldByName('ref1').AsString else periodo := xperiodo;

        if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfact.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfact.FieldByName('codanalisis').AsString);
          codigos[i] := detfact.FieldByName('codanalisis').AsString;
          montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0); // Valor de cada analisis
          nnbu       := True;
        end;

        it := i;

        subtotal := subtotal + montos[i];

        if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfact.FieldByName('codos').AsString;
        idprofanter := detfact.FieldByName('idprof').AsString;
        idanter     := detfact.FieldByName('codpac').AsString;
        ordenanter  := detfact.FieldByName('orden').AsString;
        npac        := detfact.FieldByName('nombre').AsString;
      end;
      detfact.Next;
    end;
    it := i;
    ListarLineaDeAnalisis(xcolumnas, salida);

    if cantidad > 0 then SubtotalProfesional(salida);
    if not listControl then SubtotalObraSocial(salida);

    if ProcesamientoCentral then totalesOS.Close;

    if not ExportarDatos then Begin
      if not datosListados then utiles.msgError(msgImpresion) else
        if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
    end else FinalizarExportacion;
    rp := False;
  end;

  if (interbase = 'S') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    //if not (detfactIB.Active) then detfactIB.Open;
    //if not (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''') else ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');
    //detfactIB.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';
    //detfactIB.First;

    {rsqlIB :=  ffirebird.getTransacSQL('select count(*) from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''');
    rsqlIB.Open;
    utiles.msgError(rsqlIB.fields[0].asstring + '  ' + 'select count(*) from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''');
    rsqlIB.close;}

    if (factglobal) then __t := 'detfact_gl' else __t := 'detfact';

    {if not (ProcesamientoCentral) then
      UTILES.msgError('select * from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, codos, idprof, orden, items')
    else
      utiles.msgError('select * from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, codos, idprof, orden, items');}

    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, codos, idprof, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, codos, idprof, orden, items');

    {if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, codos, idprof, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact' + __c + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, codos, idprof, orden, items');}

    rsqlIB.Open; rsqlIB.First;
    //utiles.msgError(inttostr(rsqlIB.RecordCount));
    if listControl then e := 36 else e := 6; pag := 0;
    Periodo := xperiodo;

    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación a Obras Sociales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, cursiva, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div StrToInt(xcolumnas);
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo((espaciocol * i) + e, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo((((espaciocol * i) + e) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo1(xperiodo, xtitulo, xcolumnas);
    end;

    if ProcesamientoCentral then totalesOS.Open;

    codosanter  := ''; idprofanter := ''; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; montos[1] := 0; total := 0; totales[1] := 0; datosListados := False;
    ccanUB := 0; ccanUG := 0; ttotUB := 0; ttotUG := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; totiva[1] := 0; totiva[2] := 0; totiva[3] := 0; _caran := 0; caran := 0;
    __peranter := '';

    ordenanter  := rsqlIB.FieldByName('orden').AsString;
    idprofanter := 't';
    while not rsqlIB.EOF do Begin
      if (rsqlIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (rsqlIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;
        nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
        if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        if rsqlIB.FieldByName('codos').AsString <> codosanter then Begin
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaObraSocial(salida, xperiodo, xtitulo, 'clNavy'); // Ruptura por Obra Social
          idprofanter := ''; cantidad := 0; subtotal := 0; total := 0; //tot9984 := 0;
        end;
        if rsqlIB.FieldByName('idprof').AsString <> idprofanter then Begin   // Ruptura por Profesional
          profesional.SincronizarListaRetIVA(xperiodo, rsqlIB.FieldByname('idprof').AsString);
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaPorProfesional('clNavy', salida);
        end;

        if (i >= StrToInt(xcolumnas)) or (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if rsqlIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

         if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then begin
          paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
          paciente.Nombre := rsqlIB.FieldByName('nombre').AsString;
        end else
          paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);

        //paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);
        Inc(i);
        //if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
        pac_retiva := paciente.Gravadoiva;

        if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
        __peranter := utiles.getPeriodoAAAAMM(periodo);

        if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := rsqlIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
          //nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
          codigos[i] := rsqlIB.FieldByName('codanalisis').AsString;
          montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0); // Valor de cada analisis
          nnbu       := True;
        end;

        it := i;

        subtotal := subtotal + montos[i];

        if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := rsqlIB.FieldByName('codos').AsString;
        idprofanter := rsqlIB.FieldByName('idprof').AsString;
        idanter     := rsqlIB.FieldByName('codpac').AsString;
        ordenanter  := rsqlIB.FieldByName('orden').AsString;
        npac        := rsqlIB.FieldByName('nombre').AsString;
        __perfact   := rsqlIB.FieldByName('ref1').AsString;
      end;
      rsqlIB.Next;
    end;
    it := i;
    ListarLineaDeAnalisis(xcolumnas, salida);

    if cantidad > 0 then SubtotalProfesional(salida);
    if not listControl then SubtotalObraSocial(salida);

    if ProcesamientoCentral then totalesOS.Close;

    if not ExportarDatos then Begin
      if not datosListados then utiles.msgError(msgImpresion) else
        if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
    end else FinalizarExportacion;
    rp := False;

    rsqlIB.Close; rsqlIB.free;

    {
    if listControl then e := 36 else e := 6; pag := 0;
    Periodo := xperiodo;

    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación a Obras Sociales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, cursiva, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div StrToInt(xcolumnas);
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo((espaciocol * i) + e, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo((((espaciocol * i) + e) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo1(xperiodo, xtitulo, xcolumnas);
    end;

    if ProcesamientoCentral then totalesOS.Open;

    codosanter  := ''; idprofanter := ''; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; montos[1] := 0; total := 0; totales[1] := 0; datosListados := False;
    ccanUB := 0; ccanUG := 0; ttotUB := 0; ttotUG := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; totiva[1] := 0; totiva[2] := 0; totiva[3] := 0; _caran := 0; caran := 0;

    ordenanter  := detfactIB.FieldByName('orden').AsString;
    idprofanter := 't';
    while not detfactIB.EOF do Begin
      if (detfactIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (detfactIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, detfactIB.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;
        nomeclatura.getDatos(detfactIB.FieldByName('codanalisis').AsString);
        if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        if detfactIB.FieldByName('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaObraSocial(salida, xperiodo, xtitulo, 'clNavy'); // Ruptura por Obra Social
          idprofanter := ''; cantidad := 0; subtotal := 0; total := 0; //tot9984 := 0;
        end;
        if detfactIB.FieldByName('idprof').AsString <> idprofanter then Begin   // Ruptura por Profesional
          profesional.SincronizarListaRetIVA(xperiodo, detfactIB.FieldByname('idprof').AsString);
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaPorProfesional('clNavy', salida);
        end;

        if (i >= StrToInt(xcolumnas)) or (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if detfactIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        paciente.getDatos(detfactIB.FieldByName('idprof').AsString, detfactIB.FieldByName('codpac').AsString);
        Inc(i);
        if (length(trim(detfactIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfactIB.FieldByName('retiva').AsString;
        pac_retiva := paciente.Gravadoiva;

        if (length(trim(detfactIB.FieldByName('ref1').AsString)) = 7) then periodo := detfactIB.FieldByName('ref1').AsString else periodo := xperiodo;

        if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfactIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);
          codigos[i] := detfactIB.FieldByName('codanalisis').AsString;
          montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0); // Valor de cada analisis
          nnbu       := True;
        end;

        it := i;

        subtotal := subtotal + montos[i];

        if detfactIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfactIB.FieldByName('codos').AsString;
        idprofanter := detfactIB.FieldByName('idprof').AsString;
        idanter     := detfactIB.FieldByName('codpac').AsString;
        ordenanter  := detfactIB.FieldByName('orden').AsString;
        npac        := detfactIB.FieldByName('nombre').AsString
      end;
      detfactIB.Next;
    end;
    it := i;
    ListarLineaDeAnalisis(xcolumnas, salida);

    if cantidad > 0 then SubtotalProfesional(salida);
    if not listControl then SubtotalObraSocial(salida);

    if ProcesamientoCentral then totalesOS.Close;

    if not ExportarDatos then Begin
      if not datosListados then utiles.msgError(msgImpresion) else
        if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
    end else FinalizarExportacion;
    rp := False;
    }
  end;

  //ffirebird.QuitarFiltro(detfactIB);

end;

procedure TTFacturacionCCB.titulo1(xperiodo, xtitulo, xcolumnas: String);
// Objetivo...: Titulo para impresion en modo texto
var
  i: ShortInt;
begin
  if rp then titulo5(xperiodo, xtitulo, xcolumnas) else Begin
    Inc(pag);
    list.LineaTxt(CHR18 + '  ', true);
    list.LineaTxt(xtitulo, true);
    if not listControl then list.LineaTxt('Facturacion a Obras Sociales', true) else list.LineaTxt('Control de Ordenes Ingresadas', true);
    list.LineaTxt('Periodo de Facturacion: ' + xperiodo + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
    list.LineaTxt(' ', true);
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
    espaciocol := 60 div StrToInt(xcolumnas);
    nrocol     := 60 div espaciocol;
    distanciaImp := (nrocol * 6) div StrToInt(xcolumnas);
    list.LineaTxt('Paciente      ', false);
    For i := 1 to nrocol do
      if not listControl then list.LineaTxt(' Cod.' + utiles.espacios((distanciaImp-1)) + 'Aran.', False) else list.LineaTxt(' Cod.' + utiles.espacios((distanciaImp-1)), False);
    list.LineaTxt(CHR18 + '  ', true);
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
    lineas := 9;
  end;
end;

procedure TTFacturacionCCB.listLinea(xcolumnas: string; salida: char);
// Objetivo...: Listar una Linea para el detalle de la liquidación por obra social
// Nota.......: listControl -> bandera
var
  i, j, e: ShortInt;
  torden: real;
begin
  if (Length(Trim(npac)) = 0) then paciente.getDatos(idprofanter, idanter);
  if listControl then j := 2  else j := 1;
  if listControl then e := 18 else e := 6;
  if salida <> 'T' then Begin
    //if not listControl then distanciaImp := (nrocol * 12) div StrToInt(xcolumnas) else distanciaImp := (nrocol * 12) div StrToInt(xcolumnas);
    if not listControl then distanciaImp := (nrocol * 14) div StrToInt(xcolumnas) else distanciaImp := (nrocol * 14) div StrToInt(xcolumnas);
    if idanter <> idanter1 then Begin
      if (osretieneiva <> 'S') then begin
        if Length(Trim(npac)) = 0 then list.Linea(0, 0, Copy(paciente.nombre, 1, 15), 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, Copy(npac, 1, 15), 1, 'Arial, normal, 8', salida, 'N')
      end else begin
        paciente.getDatos(idprofanter, idanter);
        if Length(Trim(npac)) = 0 then list.Linea(0, 0, Copy(paciente.nombre, 1, 11) + ' [' + pac_retiva {paciente.Gravadoiva} + ']', 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, Copy(npac, 1, 11) + ' [' + pac_retiva {paciente.Gravadoiva} + ']', 1, 'Arial, normal, 8', salida, 'N');
      end;
      if listControl then list.Linea(17, list.Lineactual, '[' + ordenanter + ']', 2, 'Arial, normal, 8', salida, 'N');
    end else list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');

    For i := 1 to nrocol do Begin
      if Length(Trim(codigos[i])) = 0 then Break;
      list.Linea((espaciocol * i) + e, list.Lineactual, codigos[i], j+1, 'Arial, normal, 8', salida, 'N');
      if not listControl then list.importe((((espaciocol * i) + e) + distanciaImp) - (2), list.Lineactual, '', montos[i], j+2, 'Arial, normal, 8');
      j := j + 2;
    end;
    //list.Linea(97, list.Lineactual, ' ', j+3, 'Arial, normal, 8', salida, 'S');
    list.Linea(101, list.Lineactual, '', j+3, 'Arial, normal, 8', salida, 'S');
  end else Begin
    if idanter <> idanter1 then Begin
      if (osretieneiva <> 'S') then begin
        if Length(Trim(npac)) = 0 then list.LineaTxt(Copy(paciente.nombre, 1, 15) + utiles.espacios(15 - Length(Copy(paciente.nombre, 1, 15))), False) else list.LineaTxt(Copy(npac, 1, 15) + utiles.espacios(15 - Length(Copy(npac, 1, 15))), False)
      end else begin
        paciente.getDatos(idprofanter, idanter);
        if Length(Trim(npac)) = 0 then list.LineaTxt(Copy(paciente.nombre, 1, 11) + ' [' + pac_retiva {paciente.Gravadoiva} + ']' + utiles.espacios(15 - Length(Copy(paciente.nombre, 1, 11) + ' [' + pac_retiva {paciente.Gravadoiva} + ']')), False)
        else
        list.LineaTxt(Copy(npac, 1, 11) + ' [' + pac_retiva {paciente.Gravadoiva} + ']' + utiles.espacios(15 - Length(Copy(npac, 1, 11) + ' [' + paciente.Gravadoiva + ']')), False);
      end;
    end else list.LineaTxt('               ', False);

    For i := 1 to nrocol do Begin
      distanciaImp := ((nrocol * 6) div StrToInt(xcolumnas));
      if Length(Trim(codigos[i])) = 0 then Break;
      list.LineaTxt(' ' + codigos[i] + utiles.espacios(distanciaImp-1), False);
      if not listControl then list.ImporteTxt(montos[i], 5, 2, False);
    end;
    list.LineaTxt(' ', True); Inc(lineas); if ControlarSalto then titulo1(periodo, titulo, xcolumnas);
  end;
  idanter1 := idanter;

  For i := 1 to elementos do Begin
    subtotalorden := subtotalorden + montos[i];
    total_orden := total_orden + montos[i];
    torden := torden + montos[i];
    codigos[i] := ''; montos[i] := 0;
  end;

  {if (listtotalboleta) and not (l_linea) then begin
    if (salida = 'P') or (salida = 'I') then begin
      list.Linea(0, 0, 'Total Orden:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(45,list.Lineactual, '', torden, 2, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;
  end;}

  torden := 0;
end;

procedure TTFacturacionCCB.ListarLineaDeAnalisis(xcolumnas: String; salida: char);
// Objetivo...: Listar Línea de detalle para análisis
var
  no_pass: Boolean;
begin
  no_pass := False;
  if it >= StrToInt(xcolumnas) then Begin  // Si estamos al maximo emitimos la linea de detalle
    ListLinea(xcolumnas, salida);
    it := 1000;  // Indicador (1)
  end;

  if ((tot9984 > 0) or (Length(Trim(codftoma)) > 0) or (nnbu)) and (it > 0) then Begin
    if tot9984 > 0 then Begin
      if it = 1000 then it := 0;  // Toma (1)
      Inc(it);
      codigos[it] := codftoma;             // Anexamos el código fijo de toma y recepcion
      montos [it] := tot9984;
    end;

    ListLinea(xcolumnas, salida);          // Emitimos Linea ...
    subtotal := subtotal + tot9984;
    tot9984  := 0;
    idanter  := ''; idanter1 := ''; ordenanter := ''; nnbu := False;
    no_pass  := True;
  end;

  if not (no_pass) and (it > 0) then Begin  // Para los casos en que ninguna determinación tiene 9984
    ListLinea(xcolumnas, salida);           // Emitimos Linea ...
    tot9984  := 0;
    idanter  := ''; idanter1 := ''; ordenanter := ''; nnbu := False;
  end;

  // Ruptura de totales por Orden de Obra Social
  if (((obsocial.Corteorden = 'S') or (listtotalboleta) or (obsocial.Rupturaorden) ) and (total_orden <> 0) and not (listControl)) or ((listtotalboleta) and (total_orden <> 0)) then begin
    if (salida = 'P') or (salida = 'I') then begin
      if (length(trim(__perfact)) = 0) then
        list.Linea(0, 0, 'Total Orden: ', 1, 'Arial, negrita, 8', salida, 'N')
      else
        list.Linea(0, 0, 'Total Orden / Per. ' + __perfact + ' : ', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', total_orden, 2, 'Arial, negrita, 8');
      list.Linea(95, list.lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina('..', salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    end;
    if (salida = 'T') then begin
      //list.LineaTxt(CHR15 + '  ', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      if (length(trim(__perfact)) = 0) then
        list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Total Orden / Per. ' + __perfact + ' : ' + utiles.FormatearNumero(floattostr(total_orden)), True)
      else
        list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Total Orden: ' + utiles.FormatearNumero(floattostr(total_orden)), True);
      Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(utiles.sLlenarIzquierda(CHR18 + lin, 80, Caracter) + CHR15, True);
      Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      //list.LineaTxt(' ', True); Inc(lineas); if ControlarSalto then titulo1(periodo, titulo, xcolumnas);
    end;

    total_orden := 0;
  end;

  total_orden := 0;
end;

procedure TTFacturacionCCB.RupturaObraSocial(salida: char; xperiodo, xtitulo, Color: string);
var
  nLiq, ColorLinea: String;
begin
  if Length(Trim(Color)) > 0 then ColorLinea := ', ' + Color else ColorLinea := '';
  if not listControl then Begin
    SubtotalObraSocial(salida);
    totales[1] := 0;
  end;
  if (interbase = 'N') then
    nLiq := setNumeroDeLiquidacion(xperiodo, detfact.FieldByName('codos').AsString)
  else
    nLiq := setNumeroDeLiquidacion(xperiodo, rsqlIB.FieldByName('codos').AsString);
  if salida <> 'T' then Begin
    if (ruptura) and (Length(Trim(codosanter)) > 0) then Begin
      pag := 0;
      list.IniciarNuevaPagina;
      list.pagina := 0;
    end;
    if not listControl then list.Linea(0, 0, 'Obra Social: ' + Copy(obsocial.nombre, 1, 38), 1, 'Arial, negrita, 9, clNavy', salida, 'N') else list.Linea(0, 0, 'Obra Social: ' + Copy(obsocial.nombre, 1, 38), 1, 'Arial, negrita, 8' + ColorLinea, salida, 'N');
    if not listControl then list.Linea(55, list.Lineactual, obsocial.codos, 2, 'Arial, negrita, 9, clNavy', salida, 'N') else list.Linea(60, list.Lineactual, obsocial.codos, 2, 'Arial, negrita, 8' + ColorLinea, salida, 'N');
    if not listControl then list.Linea(64, list.Lineactual, 'Período: ' + xperiodo, 3, 'Arial, negrita, 9' + ColorLinea, salida, 'N') else list.Linea(70, list.Lineactual, 'Período: ' + xperiodo, 3, 'Arial, negrita, 9' + ColorLinea, salida, 'N');
    if not listControl then list.Linea(80, list.Lineactual, 'Nro.Liq.: ' + nLiq, 4, 'Arial, negrita, 9' + ColorLinea, salida, 'S') else list.Linea(70, list.Lineactual, '' , 4, 'Arial, negrita, 9' + ColorLinea, salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    if (ruptura) and (Length(Trim(codosanter)) > 0) then Begin
      RealizarSalto;
      pag := 0;
      titulo1(periodo, titulo, columnas);
    end;
    if not listControl then Begin
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Obra Social: ' + Copy(obsocial.nombre, 1, 38) + utiles.espacios(30 - (Length(Trim(obsocial.nombre)))) + ' ' + obsocial.codos + ' ' + 'Per.: ' + xperiodo + ' Liq.: ' + nLiq + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    end;
    if listControl then Begin
      list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Obra Social: ' + Copy(obsocial.nombre, 1, 38) + utiles.espacios(30 - (Length(Trim(obsocial.nombre)))) + ' ' + obsocial.codos + list.modo_resaltado_cancelar, True);
      Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    end;
    list.LineaTxt(CHR15, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
  end;
end;

procedure TTFacturacionCCB.SubtotalObraSocial(salida: char);
// Objetivo...: Subtotal OS parea liq. por OS
var
  cos: String;
begin
  cos := obsocial.codos;
  obsocial.getDatos(codosanter);
  obsocial.SincronizarArancel(codosanter, Periodo);
  profesional.SincronizarListaRetIVA(Periodo, profesional.Codigo);
  if (length(trim(__maxperiodo)) > 0) then profesional.SincronizarListaRetIVA(__maxperiodo, profesional.Codigo);

  if totales[1] > 0 then Begin
   if not rp then Begin
     if salida <> 'T' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(40, list.Lineactual, 'Total de Ordenes: ', 2, 'Arial, normal, 9', salida, 'N');
      list.importe(79, list.Lineactual, '#####', cantidadordenes, 3, 'Arial, normal, 9');
      list.Linea(85, list.Lineactual, ' ', 4, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(40, list.Lineactual, 'Total de Prestaciones: ', 2, 'Arial, normal, 9', salida, 'S');
      list.importe(79, list.Lineactual, '#####', totprestaciones, 3, 'Arial, normal, 9');
      list.Linea(85, list.Lineactual, ' ', 4, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(40, list.Lineactual, 'Unidades Gasto: ', 2, 'Arial, normal, 9', salida, 'N');
      list.importe(79, list.Lineactual, '', canUG, 3, 'Arial, normal, 9');
      list.Linea(80, list.Lineactual, moneda, 4, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totUG, 5, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, ' ', 6, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(40, list.Lineactual, 'Unidades Honorarios: ', 2, 'Arial, normal, 9', salida, 'N');
      list.importe(79, list.Lineactual, '', canUB, 3, 'Arial, normal, 9');
      list.Linea(80, list.Lineactual, moneda, 4, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', ttotUB, 5, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, ' ', 6, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(40, list.Lineactual, 'Compensación Arancelaria: ', 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', total, 4, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(95, list.Lineactual, '######################', '-----------------------', 2, 'Arial, normal, 9');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');

      if (obsocial.retencioniva = 0) or (profesional.Retieneiva = 'N') then list.Linea(40, list.Lineactual, 'Total Facturado: ', 2, 'Arial, normal, 9', salida, 'N') else
        list.Linea(40, list.Lineactual, 'Subtotal Facturado: ', 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[1], 4, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

      if (obsocial.retencioniva > 0) and (profesional.Retieneiva = 'S') then Begin                                   // Obras Sociales con I.V.A.
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
        list.Linea(40, list.Lineactual, 'Subtotal Grabado: ', 2, 'Arial, normal, 9', salida, 'N');
        list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
        list.importe(95, list.Lineactual, '', totiva[1], 4, 'Arial, normal, 9');
        list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
        list.Linea(40, list.Lineactual, 'Subtotal Exento: ', 2, 'Arial, normal, 9', salida, 'N');
        list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
        list.importe(95, list.Lineactual, '', totiva[2], 4, 'Arial, normal, 9');
        list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
        list.Linea(40, list.Lineactual, 'I.V.A.:', 2, 'Arial, normal, 9', salida, 'N');
        list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
        list.importe(95, list.Lineactual, '', totiva[3], 4, 'Arial, normal, 9');
        list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
        list.derecha(95, list.Lineactual, '######################', '-----------------------', 2, 'Arial, normal, 9');
        list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
        list.Linea(40, list.Lineactual, 'Total Facturado:', 2, 'Arial, normal, 9', salida, 'N');
        list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
        list.importe(95, list.Lineactual, '', StrToFloat(utiles.FormatearNumero(FloatToStr((totiva[3])))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaexento + ivaexe9984 + ivaexecaran)))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaret + ivaret9984 + ivaretcaran)))), 4, 'Arial, normal, 9');
        list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
      end;
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
    end else Begin
      list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + utiles.espacios(26) + 'Total de Ordenes        : ', False);
      list.ImporteTxt(cantidadordenes, 12, 0, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Total de Prestaciones   : ', False);
      list.ImporteTxt(totprestaciones, 12, 0, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Unidades Gasto          : ', False);
      list.ImporteTxt(canUG, 12, 2, False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(totUG, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Unidades Honorario      : ', False);
      list.ImporteTxt(canUB, 12, 2, False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(ttotUB, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Compensacion Arancelaria:             ', False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(total, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(Length(Trim(moneda))) + utiles.espacios(26) + '                                      -------------', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Subtotal Facturado      :             ', False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(totales[1], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt('', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      if (obsocial.retencioniva > 0) and (profesional.Retieneiva = 'S') then Begin                                   // Obras Sociales con I.V.A.
        list.LineaTxt(CHR18 + utiles.espacios(26) + 'Subtotal Grabado        :             ', False);
        list.LineaTxt(' ' + moneda, False);
        list.ImporteTxt(ivaret + ivaret9984 + ivaretcaran, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        list.LineaTxt(CHR18 + utiles.espacios(26) + 'Subtotal Exento         :             ', False);
        list.LineaTxt(' ' + moneda, False);
        list.ImporteTxt(ivaexento + ivaexe9984 + ivaexecaran, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        list.LineaTxt(CHR18 + utiles.espacios(26) + 'I.V.A.                  :             ', False);
        list.LineaTxt(' ' + moneda, False);
        list.ImporteTxt(totiva[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      end;
      list.LineaTxt(CHR18 + utiles.espacios(Length(Trim(moneda))) + utiles.espacios(26) + '                                      -------------', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Total Facturado         :             ', False);
      list.LineaTxt(' ' + moneda, False);
      if (obsocial.retencioniva > 0) and (profesional.Retieneiva = 'S') then Begin
        list.ImporteTxt(StrToFloat(utiles.FormatearNumero(FloatToStr((totiva[3])))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaexento + ivaexe9984 + ivaexecaran)))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaret + ivaret9984 + ivaretcaran)))), 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      end else Begin
        list.ImporteTxt(totales[1], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      end;
      list.LineaTxt(CHR18 + list.modo_resaltado_cancelar + utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    end;
  end;

  // Guardamos Total Obra Social para Facturar si se trata del procesamiento central
  if (ProcesamientoCentral) then GuardarTotalObrasSociales(Periodo, codosanter, totales[1]);

  // Subtotalizamos para la ruptura por obra social
  ttotprestaciones := ttotprestaciones + totprestaciones;
  ccantidadordenes := ccantidadordenes + cantidadordenes;
  tttotUB := tttotUB + ttotUB;
  ttotUG  := ttotUG  + totUG;
  ccanUB  := ccanUB  + canUB;
  ccanUG  := ccanUG  + canUG;
  ttotal  := ttotal  + total;
  cantidadordenes := 0; totprestaciones := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; ttotUB := 0; total := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0;
  totiva[1] := 0; totiva[2] := 0; totiva[3] := 0; _caran := 0;
 end;
 obsocial.getDatos(cos);
end;

procedure TTFacturacionCCB.RupturaPorProfesional(Color: String; salida: char);
var
  ColorLinea: String;
begin
  if Length(Trim(Color)) > 0 then ColorLinea := ', ' + Color else ColorLinea := '';
  if (interbase = 'N') then begin
    profesional.getDatos(detfact.FieldByName('idprof').AsString);
    profesional.SincronizarCategoria(detfact.FieldByName('idprof').AsString, detfact.FieldByName('periodo').AsString);
  end;
  if (interbase = 'S') then begin
    profesional.getDatos(rsqlIB.FieldByName('idprof').AsString);
    profesional.SincronizarCategoria(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('periodo').AsString);
  end;
  if salida <> 'T' then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    if not listControl then list.Linea(0, 0, profesional.codigo + '  ' + profesional.nombre, 1, 'Arial, negrita, 8', salida, 'N') else list.Linea(0, 0, profesional.codigo + '  ' + profesional.nombre, 1, 'Arial, negrita, 9' + ColorLinea, salida, 'N');
    if not listControl then list.Linea(70, list.Lineactual, 'Categoría: ' + '"' + profesional.idcategoria + '"', 2, 'Arial, negrita, 8', salida, 'S') else list.Linea(70, list.Lineactual, 'Categoría: ' + '"' + profesional.idcategoria + '"', 2, 'Arial, negrita, 9' + ColorLinea, salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  end else Begin
    if Length(Trim(idprofanter)) > 0 then Begin
      list.LineaTxt(CHR18, True);
      Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    end;
    list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + profesional.codigo + '  ' + profesional.nombre + utiles.espacios(7), False);
    list.LineaTxt('Categoria: ' + profesional.idcategoria + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    if not listControl then list.LineaTxt(CHR15, True) else list.LineaTxt('  ', True);
    Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
  end;
  codosanter  := ''; idprofanter := ''; idanter := ''; ordenanter := '';
end;

procedure TTFacturacionCCB.SubtotalProfesional(salida: char);
begin
 if subtotal + cantidad <> 0 then Begin
   ttotUB := ttotUB + totUB;
   total  := total  + caran;
   canUB1 := canUB1 + canUB;
   if salida <> 'T' then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Nro. de Ordenes: ', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(25, list.Lineactual, '####', cantidad, 2, 'Arial, negrita, 8');
    if usuario.usuario <> 'Laboratorio' then Begin
      list.Linea(30, list.Lineactual, 'Comp. Arancelaria: ', 3, 'Arial, negrita, 8', salida, 'N');
      list.importe(58, list.Lineactual, '', utiles.setNro2Dec(caran), 4, 'Arial, negrita, 8');
      list.Linea(65, list.Lineactual, 'Subtotal Facturado: ', 5, 'Arial, negrita, 8', salida, 'N');
      list.importe(96, list.Lineactual, '', utiles.setNro2Dec(subtotal) + utiles.setNro2Dec(caran), 6, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, ' ', 7, 'Arial, negrita, 8', salida, 'S');
    end else
      list.Linea(95, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
   end else Begin
    Inc(lineas); list.LineaTxt(CHR18, True); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Nro. de Ordenes: ', False);
    if usuario.usuario <> 'Laboratorio' then Begin
      list.importeTxt(cantidad, 4, 0, False);
      list.LineaTxt(' Comp. Arancelaria: ', False);
      list.importeTxt(utiles.setNro2Dec(caran), 7, 2, False);
      list.LineaTxt(' Subtotal Facturado: ', False);
      list.importeTxt(utiles.setNro2Dec(subtotal) + utiles.setNro2Dec(caran), 10, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    end else Begin
      list.importeTxt(cantidad, 4, 0, True);
      Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    end;
    list.LineaTxt(CHR18 + list.modo_resaltado_cancelar + utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
   end;
   cantidadordenes := cantidadordenes + cantidad;
   totales[1] := totales[1] + (utiles.setNro2Dec(subtotal) + utiles.setNro2Dec(caran));
 end;
 tot9984 := 0; subtotal := 0; cantidad := 0; caran := 0; ordenanter := '';
 totUB := 0; canUB := 0; canUG := 0;  // Reactivado
end;

{*******************************************************************************}

procedure TTFacturacionCCB.ListarResumenPorObraSocial(xperiodo, xtitulo: String; ObrasSocSel: TStringList; salida: char; xinf_com: Boolean);
begin
  if (interbase = 'N') then begin
    if not (detfact.Active) then detfact.Open;
    detfact.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';

    IniciarArreglos;
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Resumen por Obra Social', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Apellido y Nom. del Profesional           Código', 1, 'Arial, cursiva, 8');
      list.Titulo(34, list.Lineactual, 'Cant.Ord.', 2, 'Arial, cursiva, 8');
      list.Titulo(48, list.Lineactual, 'U.G.', 3, 'Arial, cursiva, 8');
      list.Titulo(57, list.Lineactual, 'U.H.', 4, 'Arial, cursiva, 8');
      list.Titulo(65, list.Lineactual, '$ U.G.', 5, 'Arial, cursiva, 8');
      list.Titulo(74, list.Lineactual, '$ U.B.', 6, 'Arial, cursiva, 8');
      list.Titulo(83, list.Lineactual, '$ Cat.', 7, 'Arial, cursiva, 8');
      list.Titulo(94, list.Lineactual, 'Total', 8, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo2(xperiodo, xtitulo);
    end;
    if salida = 'X' then Begin
      excel.FijarAnchoColumna('a1', 'a1', 30);
      excel.FijarAnchoColumna('b1', 'b1', 7);
      excel.FijarAnchoColumna('c1', 'c1', 4);
      excel.FijarAnchoColumna('d1', 'd1', 8);
      excel.FijarAnchoColumna('e1', 'e1', 8);
      excel.FijarAnchoColumna('f1', 'f1', 8);
      excel.FijarAnchoColumna('g1', 'g1', 8);
      excel.FijarAnchoColumna('h1', 'h1', 8);
      excel.FijarAnchoColumna('i1', 'i1', 8);
      excel.setString('a1', 'a1', xtitulo, 'Arial, negrita, 12');
      excel.setString('a2', 'a2', 'Resumen por Obra Social', 'Arial, negrita, 14');
      excel.setString('d2', 'd2', 'Período: ' + xperiodo, 'Arial, normal, 12');
      excel.setString('a4', 'a4', 'Profesional', 'Arial, negrita, 8');
      excel.Alinear('b4', 'b4', 'D');
      excel.setString('b4', 'b4', 'Código', 'Arial, negrita, 8');
      excel.Alinear('c4', 'c4', 'D');
      excel.setString('c4', 'c4', 'Cant.', 'Arial, negrita, 8');
      excel.Alinear('d4', 'd4', 'D');
      excel.setString('d4', 'd4', 'U.G.', 'Arial, negrita, 8');
      excel.Alinear('e4', 'e4', 'D');
      excel.setString('e4', 'e4', 'U.H.', 'Arial, negrita, 8');
      excel.Alinear('f4', 'f4', 'D');
      excel.setString('f4', 'f4', '$ U.G.', 'Arial, negrita, 8');
      excel.Alinear('g4', 'g4', 'D');
      excel.setString('g4', 'g4', '$ U.B.', 'Arial, negrita, 8');
      excel.Alinear('h4', 'h4', 'D');
      excel.setString('h4', 'h4', '$ Cat.', 'Arial, negrita, 8');
      excel.Alinear('i4', 'i4', 'D');
      excel.setString('i4', 'i4', 'Total', 'Arial, negrita, 8');
    end;

    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; ordenanter := ''; codosanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ccaran := 0; ttotal := 0; xf := 4; caran := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; codosanter := '';
    detfact.First;
    idprofanter := detfact.FieldByName('idprof').AsString;
    profesional.getDatos(idprofanter);
    profesional.SincronizarCategoria(idprofanter, xperiodo);
    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) and (listarLinea) then Begin
        datosListados := True;

        if (obsocial.FactNBU = 'N') or (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
          nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);
        End;
        if (obsocial.FactNBU = 'S') and (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, xperiodo);
          nbu.getDatos(detfact.FieldByName('codanalisis').AsString);
        End;

        if detfact.FieldByName('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          if (obsocial.FactNBU = 'N') or (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
            obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
          End;
          if (obsocial.FactNBU = 'S') and (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
            obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
          End;

          if cantidad > 0 then LineaLaboratorio(salida);
          RupturaObraSocial1(xperiodo, xtitulo, salida, xinf_com);
        end else
          if detfact.FieldByName('idprof').AsString <> idprofanter then LineaLaboratorio(salida);
        if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if detfact.FieldByName('idprof').AsString <> idprofanter then Begin
          profesional.getDatos(detfact.FieldByName('idprof').AsString);
          profesional.SincronizarCategoria(detfact.FieldByName('idprof').AsString, xperiodo);
        end;

        paciente.getDatos(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
        if (length(trim(detfact.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfact.FieldByName('retiva').AsString; // 08/2013

        if (length(trim(detfact.FieldByName('ref1').AsString)) = 7) then periodo := detfact.FieldByName('ref1').AsString else periodo := xperiodo;

        if (obsocial.FactNBU = 'N') or (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
          subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada análisis
        end;

        codosanter  := detfact.FieldByName('codos').AsString;
        idprofanter := detfact.FieldByName('idprof').AsString;
        ordenanter  := detfact.FieldByName('orden').AsString;
      end;
      detfact.Next;
    end;

    LineaLaboratorio(salida);
    SubtotalObraSocial1(xperiodo, xtitulo, salida);
    FinalizarInforme(salida);
  end;

  if (interbase = 'S') then begin
    //if not (detfactIB.Active) then detfactIB.Open;
    //if not (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''') else ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');
    //detfactIB.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';
    //ffirebird.buscar(detfactIB, 'periodo', xperiodo);
    //detfactIB.First;

    {
    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, codos, idprof, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact' + __c + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, codos, idprof, orden, items');
    rsqlIB.Open; rsqlIB.First;
    }

    IniciarArreglos;
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Resumen por Obra Social', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Apellido y Nom. del Profesional           Código', 1, 'Arial, cursiva, 8');
      list.Titulo(34, list.Lineactual, 'Cant.Ord.', 2, 'Arial, cursiva, 8');
      list.Titulo(48, list.Lineactual, 'U.G.', 3, 'Arial, cursiva, 8');
      list.Titulo(57, list.Lineactual, 'U.H.', 4, 'Arial, cursiva, 8');
      list.Titulo(65, list.Lineactual, '$ U.G.', 5, 'Arial, cursiva, 8');
      list.Titulo(74, list.Lineactual, '$ U.B.', 6, 'Arial, cursiva, 8');
      list.Titulo(83, list.Lineactual, '$ Cat.', 7, 'Arial, cursiva, 8');
      list.Titulo(94, list.Lineactual, 'Total', 8, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo2(xperiodo, xtitulo);
    end;
    if salida = 'X' then Begin
      excel.FijarAnchoColumna('a1', 'a1', 30);
      excel.FijarAnchoColumna('b1', 'b1', 7);
      excel.FijarAnchoColumna('c1', 'c1', 4);
      excel.FijarAnchoColumna('d1', 'd1', 8);
      excel.FijarAnchoColumna('e1', 'e1', 8);
      excel.FijarAnchoColumna('f1', 'f1', 8);
      excel.FijarAnchoColumna('g1', 'g1', 8);
      excel.FijarAnchoColumna('h1', 'h1', 8);
      excel.FijarAnchoColumna('i1', 'i1', 8);
      excel.setString('a1', 'a1', xtitulo, 'Arial, negrita, 12');
      excel.setString('a2', 'a2', 'Resumen por Obra Social', 'Arial, negrita, 14');
      excel.setString('d2', 'd2', 'Período: ' + xperiodo, 'Arial, normal, 12');
      excel.setString('a4', 'a4', 'Profesional', 'Arial, negrita, 8');
      excel.Alinear('b4', 'b4', 'D');
      excel.setString('b4', 'b4', 'Código', 'Arial, negrita, 8');
      excel.Alinear('c4', 'c4', 'D');
      excel.setString('c4', 'c4', 'Cant.', 'Arial, negrita, 8');
      excel.Alinear('d4', 'd4', 'D');
      excel.setString('d4', 'd4', 'U.G.', 'Arial, negrita, 8');
      excel.Alinear('e4', 'e4', 'D');
      excel.setString('e4', 'e4', 'U.H.', 'Arial, negrita, 8');
      excel.Alinear('f4', 'f4', 'D');
      excel.setString('f4', 'f4', '$ U.G.', 'Arial, negrita, 8');
      excel.Alinear('g4', 'g4', 'D');
      excel.setString('g4', 'g4', '$ U.B.', 'Arial, negrita, 8');
      excel.Alinear('h4', 'h4', 'D');
      excel.setString('h4', 'h4', '$ Cat.', 'Arial, negrita, 8');
      excel.Alinear('i4', 'i4', 'D');
      excel.setString('i4', 'i4', 'Total', 'Arial, negrita, 8');
    end;

    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; ordenanter := ''; codosanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ccaran := 0; ttotal := 0; xf := 4; caran := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; codosanter := '';   __peranter := '';

    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, codos, idprof, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact' + __c + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, codos, idprof, orden, items');
    rsqlIB.Open; rsqlIB.First;

    idprofanter := rsqlIB.FieldByName('idprof').AsString;
    profesional.getDatos(idprofanter);

    profesional.SincronizarCategoria(idprofanter, xperiodo);
    while not rsqlIB.EOF do Begin
      if (rsqlIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (rsqlIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) and (listarLinea) then Begin
        datosListados := True;

        if (obsocial.FactNBU = 'N') or (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
          nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
        End;
        if (obsocial.FactNBU = 'S') and (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, xperiodo);
          nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
        End;

        if rsqlIB.FieldByName('codos').AsString <> codosanter then Begin
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
          if (obsocial.FactNBU = 'N') or (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
            obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
          End;
          if (obsocial.FactNBU = 'S') and (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
            obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
          End;

          if cantidad > 0 then LineaLaboratorio(salida);
          RupturaObraSocial1(xperiodo, xtitulo, salida, xinf_com);
        end else
          if rsqlIB.FieldByName('idprof').AsString <> idprofanter then LineaLaboratorio(salida);
        if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if rsqlIB.FieldByName('idprof').AsString <> idprofanter then Begin
          profesional.getDatos(rsqlIB.FieldByName('idprof').AsString);
          profesional.SincronizarCategoria(rsqlIB.FieldByName('idprof').AsString, xperiodo);
        end;

         if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then begin
          paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
          paciente.Nombre := rsqlIB.FieldByName('nombre').AsString;
        end else
          paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);

        //paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);
        //if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString; // 08/2013

        if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
        __peranter := utiles.getPeriodoAAAAMM(periodo);

        if (obsocial.FactNBU = 'N') or (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
          subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada análisis
        end;

        codosanter  := rsqlIB.FieldByName('codos').AsString;
        idprofanter := rsqlIB.FieldByName('idprof').AsString;
        ordenanter  := rsqlIB.FieldByName('orden').AsString;
      end;
      rsqlIB.Next;
    end;

    rsqlIB.Close; rsqlIB.free;

    {IniciarArreglos;
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Resumen por Obra Social', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Apellido y Nom. del Profesional           Código', 1, 'Arial, cursiva, 8');
      list.Titulo(34, list.Lineactual, 'Cant.Ord.', 2, 'Arial, cursiva, 8');
      list.Titulo(48, list.Lineactual, 'U.G.', 3, 'Arial, cursiva, 8');
      list.Titulo(57, list.Lineactual, 'U.H.', 4, 'Arial, cursiva, 8');
      list.Titulo(65, list.Lineactual, '$ U.G.', 5, 'Arial, cursiva, 8');
      list.Titulo(74, list.Lineactual, '$ U.B.', 6, 'Arial, cursiva, 8');
      list.Titulo(83, list.Lineactual, '$ Cat.', 7, 'Arial, cursiva, 8');
      list.Titulo(94, list.Lineactual, 'Total', 8, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo2(xperiodo, xtitulo);
    end;
    if salida = 'X' then Begin
      excel.FijarAnchoColumna('a1', 'a1', 30);
      excel.FijarAnchoColumna('b1', 'b1', 7);
      excel.FijarAnchoColumna('c1', 'c1', 4);
      excel.FijarAnchoColumna('d1', 'd1', 8);
      excel.FijarAnchoColumna('e1', 'e1', 8);
      excel.FijarAnchoColumna('f1', 'f1', 8);
      excel.FijarAnchoColumna('g1', 'g1', 8);
      excel.FijarAnchoColumna('h1', 'h1', 8);
      excel.FijarAnchoColumna('i1', 'i1', 8);
      excel.setString('a1', 'a1', xtitulo, 'Arial, negrita, 12');
      excel.setString('a2', 'a2', 'Resumen por Obra Social', 'Arial, negrita, 14');
      excel.setString('d2', 'd2', 'Período: ' + xperiodo, 'Arial, normal, 12');
      excel.setString('a4', 'a4', 'Profesional', 'Arial, negrita, 8');
      excel.Alinear('b4', 'b4', 'D');
      excel.setString('b4', 'b4', 'Código', 'Arial, negrita, 8');
      excel.Alinear('c4', 'c4', 'D');
      excel.setString('c4', 'c4', 'Cant.', 'Arial, negrita, 8');
      excel.Alinear('d4', 'd4', 'D');
      excel.setString('d4', 'd4', 'U.G.', 'Arial, negrita, 8');
      excel.Alinear('e4', 'e4', 'D');
      excel.setString('e4', 'e4', 'U.H.', 'Arial, negrita, 8');
      excel.Alinear('f4', 'f4', 'D');
      excel.setString('f4', 'f4', '$ U.G.', 'Arial, negrita, 8');
      excel.Alinear('g4', 'g4', 'D');
      excel.setString('g4', 'g4', '$ U.B.', 'Arial, negrita, 8');
      excel.Alinear('h4', 'h4', 'D');
      excel.setString('h4', 'h4', '$ Cat.', 'Arial, negrita, 8');
      excel.Alinear('i4', 'i4', 'D');
      excel.setString('i4', 'i4', 'Total', 'Arial, negrita, 8');
    end;

    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; ordenanter := ''; codosanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ccaran := 0; ttotal := 0; xf := 4; caran := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; codosanter := '';

    idprofanter := detfactIB.FieldByName('idprof').AsString;
    profesional.getDatos(idprofanter);
    profesional.SincronizarCategoria(idprofanter, xperiodo);
    while not detfactIB.EOF do Begin
      if (detfactIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (detfactIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, detfactIB.FieldByName('codos').AsString)) and (listarLinea) then Begin
        datosListados := True;

        if (obsocial.FactNBU = 'N') or (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, xperiodo);
          nomeclatura.getDatos(detfactIB.FieldByName('codanalisis').AsString);
        End;
        if (obsocial.FactNBU = 'S') and (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, xperiodo);
          nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);
        End;

        if detfactIB.FieldByName('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
          if (obsocial.FactNBU = 'N') or (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
            obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, xperiodo);
          End;
          if (obsocial.FactNBU = 'S') and (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
            obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, xperiodo);
          End;

          if cantidad > 0 then LineaLaboratorio(salida);
          RupturaObraSocial1(xperiodo, xtitulo, salida, xinf_com);
        end else
          if detfactIB.FieldByName('idprof').AsString <> idprofanter then LineaLaboratorio(salida);
        if detfactIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if detfactIB.FieldByName('idprof').AsString <> idprofanter then Begin
          profesional.getDatos(detfactIB.FieldByName('idprof').AsString);
          profesional.SincronizarCategoria(detfactIB.FieldByName('idprof').AsString, xperiodo);
        end;

        paciente.getDatos(detfactIB.FieldByName('idprof').AsString, detfactIB.FieldByName('codpac').AsString);
        if (length(trim(detfactIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfactIB.FieldByName('retiva').AsString; // 08/2013

        if (length(trim(detfactIB.FieldByName('ref1').AsString)) = 7) then periodo := detfactIB.FieldByName('ref1').AsString else periodo := xperiodo;

        if (obsocial.FactNBU = 'N') or (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
          subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada análisis
        end;

        codosanter  := detfactIB.FieldByName('codos').AsString;
        idprofanter := detfactIB.FieldByName('idprof').AsString;
        ordenanter  := detfactIB.FieldByName('orden').AsString;
      end;
      detfactIB.Next;
    end;

    ffirebird.QuitarFiltro(detfactIB);}

    LineaLaboratorio(salida);
    SubtotalObraSocial1(xperiodo, xtitulo, salida);
    FinalizarInforme(salida);
  end;

end;

procedure TTFacturacionCCB.titulo2(xperiodo, xtitulo: String);
// Objetivo...: Titulo para impresion en modo texto
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt(xtitulo, true);
  list.LineaTxt('Resumen por Obra Social', true);
  list.LineaTxt('Periodo de Facturacion: ' + xperiodo + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('Apellido y Nom. del Profesional             Codigo Nro.Ord.  U.G.     U.H.   ' + moneda + ' U.G.   ' + moneda + ' U.B.  ' + moneda + '   Cat.     Total' + CHR18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  lineas := 9;
end;

procedure TTFacturacionCCB.RupturaObraSocial1(xperiodo, xtitulo: String; salida: char; xinf_com: Boolean);
// Objetivo...: Ruptura por obra social
var
  nLiq: String; s: Boolean;
begin
  if (interbase = 'N') then
    nLiq := setNumeroDeLiquidacion(xperiodo, detfact.FieldByName('codos').AsString);  // Obtenemoe en número de Liquidación
  if (interbase = 'S') then
    nLiq := setNumeroDeLiquidacion(xperiodo, rsqlIB.FieldByName('codos').AsString);  // Obtenemoe en número de Liquidación

  if ccantidadordenes > 0 then s := True else s := False;
  if ccantidadordenes > 0 then SubtotalObraSocial1(xperiodo, xtitulo, salida);
  if (interbase = 'N') then begin
    obsocial.getDatos(detfact.FieldByName('codos').AsString);
    obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
  end;
  if (interbase = 'S') then begin
    obsocial.getDatos(rsqlIB.FieldByName('codos').AsString);
    obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
  end;
  if not llt then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      if (ruptura) and (s) then Begin
        pag := 0;
        list.IniciarNuevaPagina;
      end;
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Obra Social: ' + obsocial.codos + '  ' + Copy(obsocial.Nombre, 1, 38), 1, 'Arial, negrita, 8, clNavy', salida, 'N');
      list.Linea(80, list.Lineactual, 'Nro.Liq.: ' + nLiq, 2, 'Arial, negrita, 8, clNavy', salida, 'S');
      if xinf_com then Begin
        list.Linea(0, 0, obsocial.Nombrec, 1, 'Arial, normal, 7', salida, 'N');
        list.Linea(40, list.Lineactual, obsocial.direccion, 2, 'Arial, normal, 7', salida, 'N');
        list.Linea(70, list.Lineactual, obsocial.localidad, 3, 'Arial, normal, 7', salida, 'N');
        list.Linea(90, list.Lineactual, obsocial.nrocuit, 4, 'Arial, normal, 7', salida, 'S');
      end;
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if salida = 'T' then Begin
      if (ruptura) and (s) then Begin
        pag := 0;
        RealizarSalto;
        titulo2(xperiodo, xtitulo);
      end;
      list.LineaTxt(list.modo_resaltado_seleccionar + 'Obra Social: ' + TrimRight(obsocial.codos + ' ' + Copy(obsocial.Nombre, 1, 38)) + utiles.espacios(40 - Length(TrimRight(obsocial.codos + ' ' + Copy(obsocial.Nombre, 1, 38)))), False);
      list.LineaTxt('        Nro.Liq.: ' + nLiq + list.modo_resaltado_cancelar + CHR15, True); Inc(lineas); if controlarSalto then titulo2(xperiodo, xtitulo);
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo2(xperiodo, xtitulo);
      if xinf_com then Begin
        list.LineaTxt(Copy(obsocial.Nombrec, 1, 45) + utiles.espacios(46 - Length(TrimRight(Copy(obsocial.Nombrec, 1, 45)))), False);
        list.LineaTxt(Copy(obsocial.direccion, 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(obsocial.direccion, 1, 30)))), False);
        list.LineaTxt(Copy(obsocial.localidad, 1, 20) + utiles.espacios(21 - Length(TrimRight(Copy(obsocial.localidad, 1, 20)))), False);
        list.LineaTxt(obsocial.nrocuit, True); Inc(lineas); if controlarSalto then titulo2(xperiodo, xtitulo);
      end;
    end;
    if salida = 'X' then Begin
      Inc(xf); fx := IntToStr(xf);
      excel.setString('a' + fx, 'a' + fx, 'Obra Social: ' + obsocial.codos + ' ' + obsocial.Nombre, 'Arial, negrita, 9');
    end;
  end;
end;

procedure TTFacturacionCCB.LineaLaboratorio(salida: char);
// Objetivo...: Listar Linea
begin
  //subtotal := subtotal + StrToFloat(utiles.FormatearNumero(FloatToStr(tot9984))) + StrToFloat(utiles.FormatearNumero(FloatToStr(caran)));    // Acumulamos el total de los 9984
  subtotal := subtotal + utiles.setNro2Dec(tot9984) + utiles.setNro2Dec(caran);
  if not llt then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, profesional.nombre, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(28, list.Lineactual, profesional.codigo, 2, 'Arial, normal, 8', salida, 'N');
      list.importe(40, list.Lineactual, '###', cantidad, 3, 'Arial, normal, 8');
      list.importe(51, list.Lineactual, '', canUG, 4, 'Arial, normal, 8');
      list.importe(60, list.Lineactual, '', canUB, 5, 'Arial, normal, 8');
      list.importe(69, list.Lineactual, '', totUG, 6, 'Arial, normal, 8');
      list.importe(78, list.Lineactual, '', totUB, 7, 'Arial, normal, 8');
      list.importe(87, list.Lineactual, '', caran, 8, 'Arial, normal, 8');
      list.importe(99, list.Lineactual, '', subtotal, 9, 'Arial, normal, 8');
      list.Linea(99, list.Lineactual, ' ', 10, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(CHR15 + TrimRight(profesional.nombre) + utiles.espacios(42 - Length(TrimRight(profesional.nombre)))  + '  ' + profesional.codigo, False);
      list.ImporteTxt(cantidad, 7, 0, False);
      list.ImporteTxt(canUG, 9, 2, False);
      list.ImporteTxt(canUB, 9, 2, False);
      list.ImporteTxt(totUG, 9, 2, False);
      list.ImporteTxt(totUB, 9, 2, False);
      list.ImporteTxt(caran, 9, 2, False);
      list.ImporteTxt(subtotal, 11, 2, True); Inc(lineas); if controlarSalto then titulo2(periodo, titulo);
    end;
    if salida = 'X' then Begin
      Inc(xf); fx := IntToStr(xf);
      excel.setString('a' + fx, 'a' + fx, profesional.nombre, 'Arial, normal, 8');
      excel.setString('b' + fx, 'b' + fx, profesional.codigo, 'Arial, normal, 8');
      excel.setInteger('c' + fx, 'c' + fx, cantidad, 'Arial, normal, 8');
      excel.setReal('d' + fx, 'd' + fx, canUG, 'Arial, normal, 8');
      excel.setReal('e' + fx, 'e' + fx, canUB, 'Arial, normal, 8');
      excel.setReal('f' + fx, 'f' + fx, totUG, 'Arial, normal, 8');
      excel.setReal('g' + fx, 'g' + fx, totUB, 'Arial, normal, 8');
      excel.setReal('h' + fx, 'h' + fx, caran, 'Arial, normal, 8');
      excel.setReal('i' + fx, 'i' + fx, subtotal, 'Arial, normal, 8');
    end;
  end;
  ccantidadordenes := ccantidadordenes + cantidad;
  tttotUB          := tttotUB + totUB;
  ttotUG           := ttotUG  + totUG;
  ccanUB           := ccanUB  + canUB;
  ccanUG           := ccanUG  + canUG;
  ccaran           := ccaran  + utiles.setNro2Dec(caran);
  ttotal           := ttotal  + subtotal;
  tot9984 := 0; subtotal := 0; cantidad := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; caran := 0; ordenanter := '';
end;

procedure TTFacturacionCCB.SubtotalObraSocial1(xperiodo, xtitulo: String; salida: char);
// Objetivo...: Subtotal por Obra Social en listado resumen por determinaciones
begin
  if not llt then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0,0, 'Totales:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(40, list.Lineactual, '###', ccantidadordenes, 2, 'Arial, negrita, 8');
      list.importe(51, list.Lineactual, '', ccanUG, 3, 'Arial, negrita, 8');
      list.importe(60, list.Lineactual, '', ccanUB, 4, 'Arial, negrita, 8');
      list.importe(69, list.Lineactual, '', ttotUG, 5, 'Arial, negrita, 8');
      list.importe(78, list.Lineactual, '', tttotUB, 6, 'Arial, negrita, 8');
      list.importe(87, list.Lineactual, '', ccaran, 7, 'Arial, negrita, 9');
      list.importe(99, list.Lineactual, '', ttotal, 8, 'Arial, negrita, 8');
      list.Linea(99, list.Lineactual, ' ', 9, 'Arial, negrita, 8', salida, 'S');
      if (totiva[1] + totiva[2] > 0) and not (ExcluirLab) then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0,0, 'Gravado / Exento / I.V.A. / Total:', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(69, list.Lineactual, '', totiva[1], 2, 'Arial, negrita, 8');
        list.importe(78, list.Lineactual, '', totiva[2], 3, 'Arial, negrita, 8');
        list.importe(87, list.Lineactual, '', totiva[3], 4, 'Arial, negrita, 8');
        list.importe(99, list.Lineactual, '', (StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[1]))) + StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[2]))) + StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[3])))), 5, 'Arial, negrita, 8');
        list.Linea(99, list.Lineactual, ' ', 6, 'Arial, negrita, 8', salida, 'S');
      end;
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo2(periodo, titulo);
      list.LineaTxt(CHR15 + 'Totales:                                          ', False);
      list.ImporteTxt(ccantidadordenes, 7, 0, False);
      list.ImporteTxt(ccanUG, 9, 2, False);
      list.ImporteTxt(ccanUB, 9, 2, False);
      list.ImporteTxt(ttotUG, 9, 2, False);
      list.ImporteTxt(tttotUB, 9, 2, False);
      list.ImporteTxt(ccaran, 9, 2, False);
      list.ImporteTxt(ttotal, 11, 2, True); Inc(lineas); if controlarSalto then titulo2(periodo, titulo);
      if (totiva[1] + totiva[2] > 0) and not (ExcluirLab) then Begin
        list.LineaTxt(CHR15 + 'Gravado / Exento / I.V.A. / Total:              ', False);
        list.ImporteTxt(totiva[1], 9, 2, False);
        list.ImporteTxt(totiva[2], 9, 2, False);
        list.ImporteTxt(totiva[3], 9, 2, False);
        list.ImporteTxt((StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[1]))) + StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[2]))) + StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[3])))), 9, 2, True); Inc(lineas); if controlarSalto then titulo2(periodo, titulo);
      end;
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas); if controlarSalto then titulo2(periodo, titulo);
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo2(periodo, titulo);
    end;
    if salida = 'X' then Begin
      Inc(xf); fx := IntToStr(xf);
      excel.setString('a' + fx, 'a' + fx, 'Totales:', 'Arial, negrita, 9');
      excel.setInteger('c' + fx, 'c' + fx, StrToInt(FloatToStr(ccantidadordenes)), 'Arial, negrita, 9');
      excel.setReal('d' + fx, 'd' + fx, ccanUG, 'Arial, negrita, 9');
      excel.setReal('e' + fx, 'e' + fx, ccanUB, 'Arial, negrita, 9');
      excel.setReal('f' + fx, 'f' + fx, ttotUG, 'Arial, negrita, 9');
      excel.setReal('g' + fx, 'g' + fx, tttotUB, 'Arial, negrita, 9');
      excel.setReal('h' + fx, 'h' + fx, ccaran, 'Arial, negrita, 9');
      excel.setReal('i' + fx, 'i' + fx, ttotal, 'Arial, negrita, 9');
      Inc(xf); fx := IntToStr(xf);
      excel.setString('a3', 'a3', '');
    end;
  end;
  ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ccaran := 0; ttotal := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0;
  totiva[1] := 0; totiva[2] := 0; totiva[3] := 0; _caran := 0;
end;

{*******************************************************************************}

procedure TTFacturacionCCB.ListarResumenPorProfesional(xperiodo, xtitulo: String; profSel: TStringList; ObrasSocSel: TStringList; salida: char);
// Objetivo...: Listado resumen por profesional
var
  id_prof: string;
  cant: integer;

begin

  if (exporta_web) then begin
    utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_resfacturacion', '*.txt');
    list.AnularCaracteresTexto;
    salida := 'T';
    ExportarDatos := true;
    list.IniciarImpresionModoTexto(10000);
    list.exportar_rep := true;
  end;

  if (interbase = 'N') then begin

    if not (detfact.Active) then detfact.Open;
    detfact.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';

    IniciarArreglos;
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Resúmen por Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Código   Obra Social', 1, 'Arial, cursiva, 8');
      list.Titulo(35, list.Lineactual, 'Ord.', 2, 'Arial, cursiva, 8');
      list.Titulo(40, list.Lineactual, 'Det.', 3, 'Arial, cursiva, 8');
      list.Titulo(48, list.Lineactual, 'U.G.', 4, 'Arial, cursiva, 8');
      list.Titulo(57, list.Lineactual, 'U.H.', 5, 'Arial, cursiva, 8');
      list.Titulo(65, list.Lineactual, '$ U.G.', 6, 'Arial, cursiva, 8');
      list.Titulo(74, list.Lineactual, '$ U.B.', 7, 'Arial, cursiva, 8');
      list.Titulo(82, list.Lineactual, '$ Cat.', 8, 'Arial, cursiva, 8');
      list.Titulo(93, list.Lineactual, 'Total', 9, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo3(xperiodo, xtitulo);
      titulo := xtitulo;
    end;

    if Length(Trim(laboratorioactual)) = 0 then Begin
      totalesPROF.Open; // Guardamos totales para liquidar, si se estan procesando los datos centrales
      testeartotalesprof;
    end;
    detfact.First;
    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; montos[3] := 0; montos[4] := 0; ordenanter := ''; codosanter := ''; idprofanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0;
    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, detfact.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) and (listarLinea) then Begin
         if not datosListados then Begin
           obsocial.getDatos(detfact.FieldByname('codos').AsString);
           obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
           codosanter := detfact.FieldByName('codos').AsString;
           datosListados := True;
         end;

         if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
           nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);
           if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
         end;

         if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Inc(totprestaciones);
         if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

         if detfact.FieldByName('idprof').AsString <> idprofanter then RupturaPorProfesional2(xperiodo, xtitulo, salida);
         if (detfact.FieldByName('codos').AsString <> codosanter) and (totprestaciones > 0) {and (cantidad > 0)} then LineaObraSocial(xperiodo, salida);

         if detfact.FieldByname('codos').AsString <> codosanter then Begin
           obsocial.getDatos(detfact.FieldByname('codos').AsString);
         end;

         profesional.SincronizarCategoria(detfact.FieldByName('idprof').AsString, xperiodo);

         if (length(trim(detfact.FieldByName('ref1').AsString)) = 7) then periodo := detfact.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
         if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then begin
          __maxperiodo := periodo;
          __peranter := periodo;
         end;

         if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
           obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
           if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
           if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
         end;
         if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
           obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
           nbu.getDatos(detfact.FieldByName('codanalisis').AsString);
           subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
         end;

         codosanter  := detfact.FieldByName('codos').AsString;
         idprofanter := detfact.FieldByName('idprof').AsString;
         id_prof := detfact.FieldByName('idprof').AsString;
         ordenanter  := detfact.FieldByName('orden').AsString;
      end;
      detfact.Next;
    end;

    LineaObraSocial(xperiodo, salida);

    if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social

    if Length(Trim(laboratorioactual)) = 0 then Begin
      CalcularMontosFacturacion(xperiodo);  // Unificar Montos para Facturación
      totalesPROF.Close;
    end;
  end;

  if (interbase = 'S') then begin
    {if not (detfactIB.Active) then detfactIB.Open;
    if not (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''') else ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');
    detfactIB.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';
    detfactIB.First;}

    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, idprof, codos, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact' + __c + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, idprof, codos, orden, items');
    rsqlIB.Open; rsqlIB.First;
    
    IniciarArreglos;
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Resúmen por Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Código   Obra Social', 1, 'Arial, cursiva, 8');
      list.Titulo(35, list.Lineactual, 'Ord.', 2, 'Arial, cursiva, 8');
      list.Titulo(40, list.Lineactual, 'Det.', 3, 'Arial, cursiva, 8');
      list.Titulo(48, list.Lineactual, 'U.G.', 4, 'Arial, cursiva, 8');
      list.Titulo(57, list.Lineactual, 'U.H.', 5, 'Arial, cursiva, 8');
      list.Titulo(65, list.Lineactual, '$ U.G.', 6, 'Arial, cursiva, 8');
      list.Titulo(74, list.Lineactual, '$ U.B.', 7, 'Arial, cursiva, 8');
      list.Titulo(82, list.Lineactual, '$ Cat.', 8, 'Arial, cursiva, 8');
      list.Titulo(93, list.Lineactual, 'Total', 9, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo3(xperiodo, xtitulo);
      titulo := xtitulo;
    end;

    if Length(Trim(laboratorioactual)) = 0 then Begin
      totalesPROF.Open; // Guardamos totales para liquidar, si se estan procesando los datos centrales
      testeartotalesprof;
    end;

    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; montos[3] := 0; montos[4] := 0; ordenanter := ''; codosanter := ''; idprofanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; idprofanter := ''; codosanter := ''; __peranter := '';
    while not rsqlIB.EOF do Begin
      if (rsqlIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, rsqlIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) and (listarLinea) then Begin

         if not datosListados then Begin
           obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
           obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
           codosanter := rsqlIB.FieldByName('codos').AsString;
           datosListados := True;
         end;

         if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
           nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
           if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
         end;

         if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Inc(totprestaciones);
         if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

         if rsqlIB.FieldByName('idprof').AsString <> idprofanter then RupturaPorProfesional2(xperiodo, xtitulo, salida);
         if (rsqlIB.FieldByName('codos').AsString <> codosanter) and (totprestaciones > 0) {and (cantidad > 0)} then LineaObraSocial(xperiodo, salida);

         if rsqlIB.FieldByname('codos').AsString <> codosanter then Begin
           obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
         end;

         profesional.SincronizarCategoria(rsqlIB.FieldByName('idprof').AsString, xperiodo);

         if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

          // 21/03/2022
         if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
         __peranter := utiles.getPeriodoAAAAMM(periodo);

         if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
           obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
           if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
           if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
         end;
         if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
           obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
           //nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
           subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
         end;

         codosanter  := rsqlIB.FieldByName('codos').AsString;
         idprofanter := rsqlIB.FieldByName('idprof').AsString;
         id_prof := rsqlIB.FieldByName('idprof').AsString;
         ordenanter  := rsqlIB.FieldByName('orden').AsString;
      end;
      rsqlIB.Next;
    end;

    LineaObraSocial(xperiodo, salida);

    if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social

    if Length(Trim(laboratorioactual)) = 0 then Begin
      CalcularMontosFacturacion(xperiodo);  // Unificar Montos para Facturación
      totalesPROF.Close;
    end;

    rsqlIB.close; rsqlIB.Free;

    {IniciarArreglos;
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Resúmen por Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Código   Obra Social', 1, 'Arial, cursiva, 8');
      list.Titulo(35, list.Lineactual, 'Ord.', 2, 'Arial, cursiva, 8');
      list.Titulo(40, list.Lineactual, 'Det.', 3, 'Arial, cursiva, 8');
      list.Titulo(48, list.Lineactual, 'U.G.', 4, 'Arial, cursiva, 8');
      list.Titulo(57, list.Lineactual, 'U.H.', 5, 'Arial, cursiva, 8');
      list.Titulo(65, list.Lineactual, '$ U.G.', 6, 'Arial, cursiva, 8');
      list.Titulo(74, list.Lineactual, '$ U.B.', 7, 'Arial, cursiva, 8');
      list.Titulo(82, list.Lineactual, '$ Cat.', 8, 'Arial, cursiva, 8');
      list.Titulo(93, list.Lineactual, 'Total', 9, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo3(xperiodo, xtitulo);
      titulo := xtitulo;
    end;

    if Length(Trim(laboratorioactual)) = 0 then Begin
      totalesPROF.Open; // Guardamos totales para liquidar, si se estan procesando los datos centrales
      testeartotalesprof;
    end;

    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; montos[3] := 0; montos[4] := 0; ordenanter := ''; codosanter := ''; idprofanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; idprofanter := ''; codosanter := '';
    while not detfactIB.EOF do Begin
      if (detfactIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, detfactIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfactIB.FieldByName('codos').AsString)) and (listarLinea) then Begin

         if not datosListados then Begin
           obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
           obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, xperiodo);
           codosanter := detfactIB.FieldByName('codos').AsString;
           datosListados := True;
         end;

         if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
           nomeclatura.getDatos(detfactIB.FieldByName('codanalisis').AsString);
           if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
         end;

         if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Inc(totprestaciones);
         if detfactIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

         if detfactIB.FieldByName('idprof').AsString <> idprofanter then RupturaPorProfesional2(xperiodo, xtitulo, salida);
         if (detfactIB.FieldByName('codos').AsString <> codosanter) and (totprestaciones > 0) then LineaObraSocial(xperiodo, salida);

         if detfactIB.FieldByname('codos').AsString <> codosanter then Begin
           obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
         end;

         profesional.SincronizarCategoria(detfactIB.FieldByName('idprof').AsString, xperiodo);

         if (length(trim(detfactIB.FieldByName('ref1').AsString)) = 7) then periodo := detfactIB.FieldByName('ref1').AsString else periodo := xperiodo;

         if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
           obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, periodo);
           if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
           if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
         end;
         if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
           obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
           nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);
           subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
         end;

         codosanter  := detfactIB.FieldByName('codos').AsString;
         idprofanter := detfactIB.FieldByName('idprof').AsString;
         id_prof := detfactIB.FieldByName('idprof').AsString;
         ordenanter  := detfactIB.FieldByName('orden').AsString;
      end;
      detfactIB.Next;
    end;

    LineaObraSocial(xperiodo, salida);

    if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social

    if Length(Trim(laboratorioactual)) = 0 then Begin
      CalcularMontosFacturacion(xperiodo);  // Unificar Montos para Facturación
      totalesPROF.Close;
    end;

    ffirebird.QuitarFiltro(detfactIB);}

  end;

  if (exporta_web) and (salida = 'T') then begin
    list.FinalizarExportacion;
    CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_resfacturacion\' + copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + id_prof + '_RE' + '.txt'), false);
  end else begin
    if salida <> 'N' then FinalizarInforme(salida);
  end;

  exporta_web := false;

end;

procedure TTFacturacionCCB.titulo3(xperiodo, xtitulo: String);
// Objetivo...: Titulo para impresion en modo texto
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt(xtitulo, true);
  list.LineaTxt('Resumen por Profesionales', true);
  list.LineaTxt('Periodo de Facturacion: ' + xperiodo + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('Codigo  Obra Social                               Nro.Ord. Cant.Det.   U.G.     U.H.   ' + moneda + ' U.G.   ' + moneda + ' U.B.   ' + moneda + ' Cat.      Total' + CHR18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  lineas := 9;
end;

procedure TTFacturacionCCB.RupturaPorProfesional2(xperiodo, xtitulo: String; salida: char);
// Objetivo...: Ruptura por profesional
var
  archdest: string;
begin
  if (Length(Trim(idprofanter)) > 0) and (totprestaciones > 0) then Begin
    LineaObraSocial(xperiodo, salida);
    if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '  ', 1, 'Arial, negrita, 5', salida, 'S');
  end;

  if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social

  if (interbase = 'N') then begin
    profesional.getDatos(detfact.FieldByName('idprof').AsString);
    profesional.SincronizarCategoria(detfact.FieldByName('idprof').AsString, xperiodo);
  end;
  if (interbase = 'S') then begin
    profesional.getDatos(rsqlIB.FieldByName('idprof').AsString);
    profesional.SincronizarCategoria(rsqlIB.FieldByName('idprof').AsString, xperiodo);
  end;
  if (salida = 'P') or (salida = 'I') then Begin
      if (ruptura) and (Length(Trim(idprofanter)) > 0) then Begin
        pag := 0;
        list.IniciarNuevaPagina;
      end;
      list.Linea(0, 0, 'Profesional:  ' + profesional.codigo + '  ' + profesional.nombre, 1, 'Arial, negrita, 8, clNavy', salida, 'S');
  end;
  if (salida = 'T') then Begin
    if (ruptura) and (Length(Trim(idprofanter)) > 0) then Begin
      pag := 0;
      if not (exporta_web) then RealizarSalto else begin
        list.FinalizarExportacion;
        archdest := copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + idprofanter + '_RE' + '.txt';
        CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_resfacturacion\' + archdest), false);
        list.IniciarImpresionModoTexto(10000);
        list.exportar_rep := true;
      end;
      titulo3(xperiodo, xtitulo);
    end;
    if (Length(Trim(idprofanter)) > 0) then Begin
      list.LineaTxt(CHR18 + ' ', True); Inc(lineas); if controlarSalto then titulo3(periodo, xtitulo);
    end;
    list.LineaTxt(list.modo_resaltado_seleccionar + 'Profesional:  ' + profesional.codigo + '  ' + profesional.nombre + list.modo_resaltado_cancelar + CHR15, True); Inc(lineas); if controlarSalto then titulo3(periodo, xtitulo);
  end;
end;

procedure TTFacturacionCCB.RupturaPorProfesional3(xperiodo, xtitulo: String; salida: char);
// Objetivo...: Ruptura por profesional
var
  archdest: string;
begin
  if (Length(Trim(idprofanter)) > 0) and (totprestaciones > 0) then Begin
    LineaObraSocial(xperiodo, salida);
    if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '  ', 1, 'Arial, negrita, 5', salida, 'S');
  end;

  if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social

  if (interbase = 'N') then begin
    profesional.getDatos(detfact.FieldByName('idprof').AsString);
    profesional.SincronizarCategoria(detfact.FieldByName('idprof').AsString, xperiodo);
  end;
  if (interbase = 'S') then begin
    profesional.getDatos(rsqlIB.FieldByName('idprof').AsString);
    profesional.SincronizarCategoria(rsqlIB.FieldByName('idprof').AsString, xperiodo);
  end;
  if (salida = 'P') or (salida = 'I') then Begin
      if (ruptura) and (Length(Trim(idprofanter)) > 0) then Begin
        pag := 0;
        list.IniciarNuevaPagina;
      end;
      list.Linea(0, 0, 'Profesional:  ' + profesional.codigo + '  ' + profesional.nombre, 1, 'Arial, negrita, 8, clNavy', salida, 'S');
  end;
  if (salida = 'T') then Begin
    if (Length(Trim(idprofanter)) > 0) then Begin
      pag := 0;
      if not (exporta_web) then RealizarSalto else begin
        list.FinalizarExportacion;
        archdest := copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + idprofanter + '_REIN' + '.txt';
        CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_totalesri\' + archdest), false);
        list.IniciarImpresionModoTexto(10000);
        list.exportar_rep := true;
      end;
      titulo3(xperiodo, xtitulo);
    end;
    if (Length(Trim(idprofanter)) > 0) then Begin
      list.LineaTxt(CHR18 + ' ', True); Inc(lineas); if controlarSalto then titulo3(periodo, xtitulo);
    end;
    list.LineaTxt(list.modo_resaltado_seleccionar + 'Profesional:  ' + profesional.codigo + '  ' + profesional.nombre + list.modo_resaltado_cancelar + CHR15, True); Inc(lineas); if controlarSalto then titulo3(periodo, xtitulo);
  end;
end;

procedure TTFacturacionCCB.LineaObraSocial(xperiodo: String; salida: char);
begin
  subtotal := subtotal + utiles.setNro2Dec(tot9984) + utiles.setNro2Dec(caran);
  obsocial.getDatos(codosanter);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, ' ' + obsocial.codos + '  ' + Copy(obsocial.Nombre, 1, 30), 1, 'Arial, normal, 8', salida, 'N');
    list.importe(37, list.Lineactual, '####', cantidad, 2, 'Arial, normal, 8');
    list.importe(42, list.Lineactual, '####', totprestaciones, 3, 'Arial, normal, 8');
    list.importe(51, list.Lineactual, '', canUG, 4, 'Arial, normal, 8');
    list.importe(60, list.Lineactual, '', canUB, 5, 'Arial, normal, 8');
    list.importe(69, list.Lineactual, '', totUG, 6, 'Arial, normal, 8');
    list.importe(78, list.Lineactual, '', totUB, 7, 'Arial, normal, 8');
    list.importe(87, list.Lineactual, '', caran, 8, 'Arial, normal, 9');
    list.importe(99, list.Lineactual, '', subtotal, 9, 'Arial, normal, 8');
    list.Linea(99, list.Lineactual, '  ', 10, 'Arial, normal, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    if (exporta_web) then begin   // 01/04/2019
      list.LineaTxt(Copy(obsocial.Nombrec, 1, 45) + utiles.espacios(46 - Length(TrimRight(Copy(obsocial.Nombrec, 1, 45)))), False);
      list.LineaTxt(Copy(obsocial.direccion, 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(obsocial.direccion, 1, 30)))), False);
      list.LineaTxt(Copy(obsocial.localidad, 1, 20) + utiles.espacios(21 - Length(TrimRight(Copy(obsocial.localidad, 1, 20)))), False);
      list.LineaTxt(obsocial.nrocuit, True);
      Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
    end;
    list.LineaTxt('  ' + CHR15 + obsocial.codos + ' ' + Copy(obsocial.Nombre, 1, 38) + utiles.espacios(45 - Length(TrimRight(Copy(obsocial.Nombre, 1, 38)))), False);
    list.ImporteTxt(cantidad, 4, 0, False);
    list.ImporteTxt(totprestaciones, 8, 0, False);
    list.importeTxt(canUG, 9, 2, False);
    list.importeTxt(canUB, 9, 2, False);
    list.importeTxt(totUG, 9, 2, False);
    list.importeTxt(totUB, 9, 2, False);
    list.importeTxt(caran, 9, 2, False);
    list.importeTxt(subtotal, 11, 2, True); Inc(lineas); if controlarSalto then titulo3(periodo, titulo);
  end;

  totales[1] := totales[1] + cantidad;
  totales[2] := totales[2] + totprestaciones;
  ttotUB := ttotUB + totUB;
  ttotUG := ttotUG + totUG;
  ccanUB := ccanUB + canUB;
  ccanUG := ccanUG + canUG;
  totales[3]  := totales[3] + caran;
  totales[4]  := totales[4] + utiles.setNro2Dec(subtotal);
  // Totales Finales
  totales[5]  := totales[5] + cantidad;
  totales[6]  := totales[6] + totprestaciones;
  totales[7]  := totales[7] + totUB;
  totales[8]  := totales[8] + totUG;
  totales[9]  := totales[9] + canUB;
  totales[10] := totales[10]+ canUG;
  montos [3]  := montos[3]  + caran;
  montos [4]  := montos[4]  + utiles.setNro2Dec(subtotal);

  if Length(Trim(obsocial.Codosdif)) = 0 then GuardarTotalProfesional(xperiodo, idprofanter, codosanter, utiles.setNro2Dec(subtotal), totUB, totUG, caran);
  if Length(Trim(obsocial.Codosdif)) > 0 then GuardarTotalProfesional(xperiodo, idprofanter, obsocial.codosdif, utiles.setNro2Dec(subtotal), totUB, totUG, caran);

  totales[11] := totales[11] + subtotal;

  cantidad := 0; totprestaciones := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; caran := 0; subtotal := 0; tot9984 := 0; ordenanter := '';
end;

procedure TTFacturacionCCB.SubtotalObraSocialResumenProf(xleyenda: String; salida: char);
begin
  if not informe_ivaret then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 11', salida, 'N');
      list.derecha(99, list.Lineactual, '', '------------------------------------------------------------------------------------------', 2, 'Arial, normal, 11');
      list.Linea(99, 0, ' ', 3, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, xleyenda, 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(37, list.Lineactual, '####', totales[1], 2, 'Arial, negrita, 8');
      list.importe(42, list.Lineactual, '####', totales[2], 3, 'Arial, negrita, 8');
      list.importe(51, list.Lineactual, '', ccanUG, 4, 'Arial, negrita, 8');
      list.importe(60, list.Lineactual, '', ccanUB, 5, 'Arial, negrita, 8');
      list.importe(69, list.Lineactual, '', ttotUG, 6, 'Arial, negrita, 8');
      list.importe(78, list.Lineactual, '', ttotUB, 7, 'Arial, negrita, 8');
      list.importe(87, list.Lineactual, '', totales[3], 8, 'Arial, negrita, 9');
      list.importe(99, list.Lineactual, '', totales[4], 9, 'Arial, negrita, 8');
      list.Linea(99, list.Lineactual, '  ', 10, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas); if controlarSalto then titulo3(periodo, titulo);
      list.LineaTxt(CHR15 + xleyenda + '                                             ', False);
      list.ImporteTxt(totales[1], 4, 0, False);
      list.ImporteTxt(totales[2], 8, 0, False);
      list.importeTxt(ccanUG, 9, 2, False);
      list.importeTxt(ccanUB, 9, 2, False);
      list.importeTxt(ttotUG, 9, 2, False);
      list.importeTxt(ttotUB, 9, 2, False);
      list.importeTxt(totales[3], 9, 2, False);
      list.importeTxt(totales[4], 11, 2, True); Inc(lineas); if controlarSalto then titulo3(periodo, titulo);
    end;
  end;

  if informe_ivaret then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 11', salida, 'N');
      list.derecha(99, list.Lineactual, '', '------------------------------------------------------------------------------------------', 2, 'Arial, normal, 11');
      list.Linea(99, 0, ' ', 3, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, xleyenda, 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(38, list.Lineactual, '####', totales[1], 2, 'Arial, negrita, 8');
      list.importe(45, list.Lineactual, '####', totales[2], 3, 'Arial, negrita, 8');
      list.importe(60, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 8');
      list.importe(71, list.Lineactual, '', totales[9], 5, 'Arial, negrita, 8');
      list.importe(82, list.Lineactual, '', totales[4], 6, 'Arial, negrita, 8');
      list.importe(93, list.Lineactual, '', totales[3] + totales[4] + totales[9], 7, 'Arial, negrita, 8');
      list.Linea(99, list.Lineactual, ' ', 8, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
    end;
    if salida = 'T' then Begin
      if controlarSalto then titulo7(periodo, titulo);
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
      list.LineaTxt(CHR15 + xleyenda + '                                            ', False);
      list.ImporteTxt(totales[1], 4, 0, False);
      list.ImporteTxt(totales[2], 8, 0, False);
      list.LineaTxt('      ', False);
      list.importeTxt(totales[3], 10, 2, False);
      list.importeTxt(totales[9], 10, 2, False);
      list.importeTxt(totales[4], 10, 2, False);
      list.importeTxt(totales[3] + totales[4], 10, 2, True);
      Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
      list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
    end;
  end;

  totales[3] := 0; totales[4] := 0; ccanUG := 0; ccanUB := 0; ttotUB := 0; ttotUG := 0;
  totales[1] := 0; totales[2] := 0; totales[9] := 0;
end;

{ ***************************************************************************** }

procedure TTFacturacionCCB.ListarTotGralesObrasSociales(xperiodo, xtitulo: String; ObrasSocSel: TStringList; salida: Char);
// Objetivo...: Totales generales por obra social
begin
  IniciarArreglos;
  if (interbase = 'N') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Totales Generales por Obra Social', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Código   Obra Social', 1, 'Arial, cursiva, 8');
      list.Titulo(26, list.Lineactual, 'Nro.Liq.', 2, 'Arial, cursiva, 8');
      list.Titulo(34, list.Lineactual, 'Nro. Factura', 3, 'Arial, cursiva, 8');
      list.Titulo(50, list.Lineactual, 'U.G.', 4, 'Arial, cursiva, 8');
      list.Titulo(59, list.Lineactual, 'U.H.', 5, 'Arial, cursiva, 8');
      list.Titulo(67, list.Lineactual, '$ U.G.', 6, 'Arial, cursiva, 8');
      list.Titulo(77, list.Lineactual, '$ U.B.', 7, 'Arial, cursiva, 8');
      list.Titulo(86, list.Lineactual, '$ Cat.', 8, 'Arial, cursiva, 8');
      list.Titulo(94, list.Lineactual, 'Total', 9, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo4(xperiodo, xtitulo);
    end;

    if not (detfact.Active) then detfact.Open;
    detfact.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';
    subtotal := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; idprofanter := ''; datosListados := False; ordenanter := ''; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0;  ccaran := 0; llt := True;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0;
    if Length(Trim(laboratorioactual)) = 0 then totalesOS.Open;   // Instancia para Guardar los totales por Obra Social, si se trata de procesamiento central
    detfact.First;
    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; ordenanter := ''; codosanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ccaran := 0; ttotal := 0;
    idprofanter := detfact.FieldByName('idprof').AsString;
    profesional.getDatos(idprofanter);
    profesional.SincronizarCategoria(idprofanter, xperiodo);
    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString = xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) and (listarLinea) then Begin
        datosListados := True;
        nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);
        if detfact.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then LineaLaboratorio(salida);
          if ttotal > 0 then LineaOS(xperiodo, codosanter, xtitulo, salida);
          RupturaObraSocial1(xperiodo, xtitulo, salida, False);
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
        end else
          if detfact.FieldByName('idprof').AsString <> idprofanter then LineaLaboratorio(salida);
        if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if detfact.FieldByName('idprof').AsString <> idprofanter then Begin
          profesional.getDatos(detfact.FieldByName('idprof').AsString);
          profesional.SincronizarCategoria(detfact.FieldByName('idprof').AsString, xperiodo);
        end;

        if (length(trim(detfact.FieldByName('ref1').AsString)) = 7) then periodo := detfact.FieldByName('ref1').AsString else periodo := xperiodo;

        if (obsocial.FactNBU = 'N') or (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (Length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
          subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
        end;

        codosanter  := detfact.FieldByName('codos').AsString;
        idprofanter := detfact.FieldByName('idprof').AsString;
        ordenanter  := detfact.FieldByName('orden').AsString;
      end;
      detfact.Next;
    end;

    if cantidad > 0 then LineaLaboratorio(salida);
    if ttotal > 0 then LineaOS(xperiodo, codosanter, xtitulo, salida);

    if Length(Trim(laboratorioactual)) = 0 then totalesOS.Close;

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(48, list.Lineactual, '---------------------------------------------------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(54, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
      list.importe(62, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
      list.importe(72, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 8');
      list.importe(81, list.Lineactual, '', totales[4], 5, 'Arial, negrita, 8');
      list.importe(90, list.Lineactual, '', totales[5], 6, 'Arial, negrita, 9');
      list.importe(99, list.Lineactual, '', totales[6], 7, 'Arial, negrita, 8');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(utiles.espacios(54) + '---------------------------------------------------------', True); Inc(lineas); if controlarSalto then titulo4(periodo, titulo);
      list.LineaTxt('Subtotal:  ' + utiles.espacios(52 - Length(TrimRight('Subtotal:'))), False);
      list.importeTxt(totales[1], 9, 2, False);
      list.importeTxt(totales[2], 9, 2, False);
      list.importeTxt(totales[3], 9, 2, False);
      list.importeTxt(totales[4], 9, 2, False);
      list.importeTxt(totales[5], 9, 2, False);
      list.importeTxt(totales[6], 11, 2, True); Inc(lineas); if controlarSalto then titulo4(periodo, titulo);
    end;
    if salida <> 'N' then FinalizarInforme(salida);
    llt := False;
  end;

  if (interbase = 'S') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    pag := 0; datosListados := False;
    Periodo := xperiodo;
    if (salida = 'P') or (salida = 'I') then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Totales Generales por Obra Social', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
      list.Titulo(0, 0, 'Código   Obra Social', 1, 'Arial, cursiva, 8');
      list.Titulo(26, list.Lineactual, 'Nro.Liq.', 2, 'Arial, cursiva, 8');
      list.Titulo(34, list.Lineactual, 'Nro. Factura', 3, 'Arial, cursiva, 8');
      list.Titulo(50, list.Lineactual, 'U.G.', 4, 'Arial, cursiva, 8');
      list.Titulo(59, list.Lineactual, 'U.H.', 5, 'Arial, cursiva, 8');
      list.Titulo(67, list.Lineactual, '$ U.G.', 6, 'Arial, cursiva, 8');
      list.Titulo(77, list.Lineactual, '$ U.B.', 7, 'Arial, cursiva, 8');
      list.Titulo(86, list.Lineactual, '$ Cat.', 8, 'Arial, cursiva, 8');
      list.Titulo(94, list.Lineactual, 'Total', 9, 'Arial, cursiva, 8');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end;
    if salida = 'T' then Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo4(xperiodo, xtitulo);
    end;

    {if not (detfactIB.Active) then detfactIB.Open;
    if not (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''') else ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');
    detfactIB.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';
    detfactIB.First;}

    //osagrupa.conectar;
    //ressql := osagrupa.getListaObrasSocialesAgrupadas;
    //ressql.Open;

    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, codos, idprof, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact' + __c + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, codos, idprof, orden, items');
    rsqlIB.Open; rsqlIB.First;

     subtotal := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; idprofanter := ''; datosListados := False; ordenanter := ''; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0;  ccaran := 0; llt := True;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; __peranter := '';
    if Length(Trim(laboratorioactual)) = 0 then totalesOS.Open;   // Instancia para Guardar los totales por Obra Social, si se trata de procesamiento central
    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; ordenanter := ''; codosanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ccaran := 0; ttotal := 0;
    idprofanter := rsqlIB.FieldByName('idprof').AsString;
    profesional.getDatos(idprofanter);
    profesional.SincronizarCategoria(idprofanter, xperiodo);
    while not rsqlIB.EOF do Begin
      if (rsqlIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (rsqlIB.FieldByName('periodo').AsString = xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) and (listarLinea) then Begin
        datosListados := True;
        nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
        if rsqlIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then LineaLaboratorio(salida);
          if ttotal > 0 then LineaOS(xperiodo, codosanter, xtitulo, salida);
          RupturaObraSocial1(xperiodo, xtitulo, salida, False);
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
        end else
          if rsqlIB.FieldByName('idprof').AsString <> idprofanter then LineaLaboratorio(salida);
        if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if rsqlIB.FieldByName('idprof').AsString <> idprofanter then Begin
          profesional.getDatos(rsqlIB.FieldByName('idprof').AsString);
          profesional.SincronizarCategoria(rsqlIB.FieldByName('idprof').AsString, xperiodo);
        end;

        if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
        __peranter := utiles.getPeriodoAAAAMM(periodo);

        if (obsocial.FactNBU = 'N') or (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (Length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
          subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
        end;

        codosanter  := rsqlIB.FieldByName('codos').AsString;
        idprofanter := rsqlIB.FieldByName('idprof').AsString;
        ordenanter  := rsqlIB.FieldByName('orden').AsString;
      end;
      rsqlIB.Next;
    end;

    if cantidad > 0 then LineaLaboratorio(salida);
    if ttotal > 0 then LineaOS(xperiodo, codosanter, xtitulo, salida);

    rsqlIB.close; rsqlIB.Free;

    //ressql.Close; ressql.Free;
    //osagrupa.desconectar;

    {subtotal := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; idprofanter := ''; datosListados := False; ordenanter := ''; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0;  ccaran := 0; llt := True;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0;
    if Length(Trim(laboratorioactual)) = 0 then totalesOS.Open;   // Instancia para Guardar los totales por Obra Social, si se trata de procesamiento central
    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; ordenanter := ''; codosanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ccaran := 0; ttotal := 0;
    idprofanter := detfactIB.FieldByName('idprof').AsString;
    profesional.getDatos(idprofanter);
    profesional.SincronizarCategoria(idprofanter, xperiodo);
    while not detfactIB.EOF do Begin
      if (detfactIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (detfactIB.FieldByName('periodo').AsString = xperiodo) and (utiles.verificarItemsLista(ObrasSocSel, detfactIB.FieldByName('codos').AsString)) and (listarLinea) then Begin
        datosListados := True;
        nomeclatura.getDatos(detfactIB.FieldByName('codanalisis').AsString);
        if detfactIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then LineaLaboratorio(salida);
          if ttotal > 0 then LineaOS(xperiodo, codosanter, xtitulo, salida);
          RupturaObraSocial1(xperiodo, xtitulo, salida, False);
          obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, xperiodo);
        end else
          if detfactIB.FieldByName('idprof').AsString <> idprofanter then LineaLaboratorio(salida);
        if detfactIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if detfactIB.FieldByName('idprof').AsString <> idprofanter then Begin
          profesional.getDatos(detfactIB.FieldByName('idprof').AsString);
          profesional.SincronizarCategoria(detfactIB.FieldByName('idprof').AsString, xperiodo);
        end;

        if (length(trim(detfactIB.FieldByName('ref1').AsString)) = 7) then periodo := detfactIB.FieldByName('ref1').AsString else periodo := xperiodo;

        if (obsocial.FactNBU = 'N') or (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (Length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
          subtotal := subtotal + setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
        end;

        codosanter  := detfactIB.FieldByName('codos').AsString;
        idprofanter := detfactIB.FieldByName('idprof').AsString;
        ordenanter  := detfactIB.FieldByName('orden').AsString;
      end;
      detfactIB.Next;
    end;

    if cantidad > 0 then LineaLaboratorio(salida);
    if ttotal > 0 then LineaOS(xperiodo, codosanter, xtitulo, salida);

    ffirebird.QuitarFiltro(detfactIB);}

    if Length(Trim(laboratorioactual)) = 0 then totalesOS.Close;

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(48, list.Lineactual, '---------------------------------------------------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(54, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
      list.importe(62, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
      list.importe(72, list.Lineactual, '', totales[3], 4, 'Arial, negrita, 8');
      list.importe(81, list.Lineactual, '', totales[4], 5, 'Arial, negrita, 8');
      list.importe(90, list.Lineactual, '', totales[5], 6, 'Arial, negrita, 9');
      list.importe(99, list.Lineactual, '', totales[6], 7, 'Arial, negrita, 8');
    end;
    if salida = 'T' then Begin
      list.LineaTxt(utiles.espacios(54) + '---------------------------------------------------------', True); Inc(lineas); if controlarSalto then titulo4(periodo, titulo);
      list.LineaTxt('Subtotal:  ' + utiles.espacios(52 - Length(TrimRight('Subtotal:'))), False);
      list.importeTxt(totales[1], 9, 2, False);
      list.importeTxt(totales[2], 9, 2, False);
      list.importeTxt(totales[3], 9, 2, False);
      list.importeTxt(totales[4], 9, 2, False);
      list.importeTxt(totales[5], 9, 2, False);
      list.importeTxt(totales[6], 11, 2, True); Inc(lineas); if controlarSalto then titulo4(periodo, titulo);
    end;
    if salida <> 'N' then FinalizarInforme(salida);
    llt := False;
  end;

end;

procedure TTFacturacionCCB.titulo4(xperiodo, xtitulo: String);
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt(xtitulo, true);
  list.LineaTxt('Totales Generales por Obra Social', True);
  list.LineaTxt('Periodo de Facturacion: ' + xperiodo + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('Codigo  Obra Social           Nro.Liq. Nro.Factura         U.G.     U.H.   ' + moneda + ' U.G.   ' + moneda + ' U.B.   ' + moneda + ' Cat.      Total' + CHR18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  lineas := 8;
end;

procedure TTFacturacionCCB.LineaOS(xperiodo, codosanter, xtitulo: String; salida: Char);
// Objetivo...: Listar Linea de detalle
var
  nrofact: String;
begin
  if BuscarDatosFact(xperiodo, codosanter) then nrofact := datosfact.FieldByName('tipo').AsString + ' ' + datosfact.FieldByName('sucursal').AsString + '-' + datosfact.FieldByName('numero').AsString else nrofact := '               ';
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, codosanter + '  ' + Copy(obsocial.Nombre, 1, 20), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(26, list.Lineactual, setNumeroDeLiquidacion(xperiodo, codosanter), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(34, list.Lineactual, nrofact, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(54, list.Lineactual, '', ccanUG, 4, 'Arial, normal, 8');
    list.importe(62, list.Lineactual, '', ccanUB, 5, 'Arial, normal, 8');
    list.importe(72, list.Lineactual, '', ttotUG, 6, 'Arial, normal, 8');
    list.importe(81, list.Lineactual, '', tttotUB, 7, 'Arial, normal, 8');
    list.importe(90, list.Lineactual, '', ccaran, 8, 'Arial, normal, 9');
    list.importe(99, list.Lineactual, '', ttotal, 9, 'Arial, normal, 8');
    list.Linea(99, list.Lineactual, '', 10, 'Arial, normal, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(codosanter + '  ' + Copy(obsocial.Nombre, 1, 20) + utiles.espacios(21 - Length(TrimRight(Copy(obsocial.nombre, 1, 20)))) + ' ' + setNumeroDeLiquidacion(xperiodo, codosanter) + ' ' + nrofact, False);
    list.importeTxt(ccanUG, 9, 2, False);
    list.importeTxt(ccanUB, 9, 2, False);
    list.importeTxt(ttotUG, 9, 2, False);
    list.importeTxt(tttotUB, 9, 2, False);
    list.importeTxt(ccaran, 9, 2, False);
    list.importeTxt(ttotal, 11, 2, True); Inc(lineas); if controlarSalto then titulo4(periodo, titulo);
  end;

  totales[1] := totales[1] + ccanUG;
  totales[2] := totales[2] + ccanUB;
  totales[3] := totales[3] + ttotUG;
  totales[4] := totales[4] + tttotUB;
  totales[5] := totales[5] + ccaran;
  totales[6] := totales[6] + utiles.setNro2Dec(ttotal);

  GuardarTotalObrasSociales(xperiodo, codosanter, ttotal);
  ccaran := 0; ttotUB := 0; ttotUG := 0; ccanUG := 0; ccanUB := 0; ttotal := 0; tot9984 := 0; caran := 0; ccaran := 0;
end;

{ ***************************************************************************** }

procedure TTFacturacionCCB.ListarResumenAProfesionales(xperiodo, xtitulo, xcolumnas: String; xruptura: Boolean; profSel: TStringList; ObrasSocSel: TStringList; salida: char);
// Objetivo...: Listar Resumen de Prestaciones por Obra Social
var
  i, j: ShortInt;
  ord: array[1..2] of Integer;
  archdest: string;

  procedure Terminar(fin: boolean);
  begin
    if (length(trim(idprofanter)) < 5) then exit;
    if (salida = 'T') and (exporta_web) then begin
      if not (exporta_web) then RealizarSalto else list.FinalizarExportacion;
      archdest := copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + idprofanter + '_FA' + '.txt';
      CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_facturacion\' + archdest), false);
      if not (fin) then begin
        pag := 0;
        list.IniciarImpresionModoTexto(10000);
        list.exportar_rep := true;
        titulo5(xperiodo, xtitulo, xcolumnas);
      end;
      //utiles.msgError('0');
    end;

    if (salida = 'T') and not (exporta_web) then begin
      //utiles.msgError('3' + ' ' + salida);
      //if salida <> 'N' then FinalizarInforme(salida); // 26/11/2019
    end;
  end;

begin
  IniciarArreglos;
  if (interbase = 'N') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);

    if (exporta_web) then begin
      utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_facturacion', '*.txt');
      list.AnularCaracteresTexto;
      salida := 'T';
      ExportarDatos := true;
      list.IniciarImpresionModoTexto(10000);
      list.exportar_rep := true;
    end;

    if not (detfact.Active) then detfact.Open;
    detfact.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';
    pag := 0; rp := True; datosListados := False;
    ruptura := xruptura;
    Periodo := xperiodo;
    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación Resumen a Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, normal, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div 5;
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo(espaciocol * i, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo(((espaciocol * i) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo5(xperiodo, xtitulo, xcolumnas);
    end;

    detfact.First;
    codosanter  := ''; idprofanter := 't'; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; datosListados := False; __maxperiodo := '';
    ttotprestaciones := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ttotal := 0; tot9984 := 0; totales[1] := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; canUB1 := 0;

    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, detfact.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;

        if (length(trim(codosanter)) = 0) then obsocial.getDatos(detfact.FieldByname('codos').AsString);

        if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then
          nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);

        if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then
          nbu.getDatos(detfact.FieldByName('codanalisis').AsString);

        if (length(trim(detfact.FieldByName('ref1').AsString)) = 7) then periodo := detfact.FieldByName('ref1').AsString else periodo := xperiodo;

        // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then begin
          __maxperiodo := periodo;
          __peranter := periodo;
        end;
        periodo := __maxperiodo;

        if detfact.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then
            obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then
            obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
        end;

        if detfact.FieldByName('idprof').AsString <> idprofanter then Begin  // Ruptura por Profesional
          ListarLineaDeAnalisis(xcolumnas, salida);
          SubtotalProfesional(salida);
          ord[1] := cantidadordenes; ord[2] := totprestaciones;
          SubtotalObraSocial(salida);
          cantidadordenes := ord[1]; totprestaciones := ord[2];
          SubtotalObraSocial2(salida);

          Terminar(false);

          if not (exporta_web) then RupturaProf(salida, detfact.FieldByName('idprof').AsString, xperiodo, ruptura);
          cantidad := 0; subtotal := 0; total := 0; codosanter := ''; caran := 0; canUB := 0; totUB := 0;
        end;
        if detfact.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaOS(salida, xperiodo, xtitulo); // Ruptura por Obra Social
          subtotal := 0; idprofanter := ''; idanter := ''; cantidad := 0; caran := 0; canUB := 0; totUB := 0;
        end;

        if (i >= StrToInt(xcolumnas)) or (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if detfact.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        Inc(i);
        paciente.getDatos(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
        if (length(trim(detfact.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfact.FieldByName('retiva').AsString;
        pac_retiva := paciente.Gravadoiva;

        if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfact.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos[i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
          if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfact.FieldByName('codanalisis').AsString);
          codigos[i] := detfact.FieldByName('codanalisis').AsString;
          montos[i]  := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
          Inc(totprestaciones);
          nnbu       := True;
        end;

        it := i;

        subtotal   := subtotal + montos[i];

        if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfact.FieldByName('codos').AsString;
        idprofanter := detfact.FieldByName('idprof').AsString;
        idanter     := detfact.FieldByName('codpac').AsString;
        ordenanter  := detfact.FieldByName('orden').AsString;
        npac        := detfact.FieldByName('nombre').AsString;
       end;
       detfact.Next;
    end;

    it := i;

    ListarLineaDeAnalisis(xcolumnas, salida);
    SubtotalProfesional(salida);
    ord[1] := cantidadordenes; ord[2] := totprestaciones;
    cantidadordenes := ord[1]; totprestaciones := ord[2];
    SubtotalObraSocial2(salida);   // 08/2013

    it := 0;
    if not (ExportarDatos) and (salida <> 'T') then FinalizarInforme(salida);
    rp := False;

    Terminar(true);
   end;

  if (interbase = 'S') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);

    if (exporta_web) then begin
      utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_facturacion', '*.txt');
      list.AnularCaracteresTexto;
      salida := 'T';
      ExportarDatos := true;
      list.IniciarImpresionModoTexto(10000);
      list.exportar_rep := true;
    end;

    {if not (detfactIB.Active) then detfactIB.Open;
    if not (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''') else ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');
    detfactIB.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';
    detfactIB.First;}

    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, idprof, codos, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact' + __c + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, idprof, codos, orden, items');
    rsqlIB.Open; rsqlIB.First;

    pag := 0; rp := True; datosListados := False;
    ruptura := xruptura;
    Periodo := xperiodo;
    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación Resumen a Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, normal, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div 5;
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo(espaciocol * i, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo(((espaciocol * i) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo5(xperiodo, xtitulo, xcolumnas);
    end;

    codosanter  := ''; idprofanter := 't'; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; datosListados := False;
    ttotprestaciones := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ttotal := 0; tot9984 := 0; totales[1] := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; canUB1 := 0;
    __peranter := '';

    while not rsqlIB.EOF do Begin
      if (rsqlIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (rsqlIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, rsqlIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;

        if (length(trim(codosanter)) = 0) then obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);

        if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then
          nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);

        if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then
          nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);

        if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
        __peranter := utiles.getPeriodoAAAAMM(periodo);

        if rsqlIB.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then
            obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
          if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then
            obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
        end;

        if rsqlIB.FieldByName('idprof').AsString <> idprofanter then Begin  // Ruptura por Profesional
          ListarLineaDeAnalisis(xcolumnas, salida);
          SubtotalProfesional(salida);
          ord[1] := cantidadordenes; ord[2] := totprestaciones;
          SubtotalObraSocial(salida);
          cantidadordenes := ord[1]; totprestaciones := ord[2];
          SubtotalObraSocial2(salida);

          Terminar(false);

          RupturaProf(salida, rsqlIB.FieldByName('idprof').AsString, xperiodo, ruptura);
          cantidad := 0; subtotal := 0; total := 0; codosanter := ''; caran := 0; canUB := 0; totUB := 0;
        end;
        if rsqlIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            obsocial.getDatos(codosanter);
            ListarLineaDeAnalisis(xcolumnas, salida);
            obsocial.getDatos(rsqlIB.FieldByName('codos').AsString);
            SubtotalProfesional(salida);
          end;
          RupturaOS(salida, xperiodo, xtitulo); // Ruptura por Obra Social
          subtotal := 0; idprofanter := ''; idanter := ''; cantidad := 0; caran := 0; canUB := 0; totUB := 0;
        end;

        if (i >= StrToInt(xcolumnas)) or (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if rsqlIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        Inc(i);

        //paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);
        //if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
        if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then begin
          paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
          paciente.Nombre := rsqlIB.FieldByName('nombre').AsString;
        end else
          paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);

        pac_retiva := paciente.Gravadoiva;

        if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := rsqlIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos[i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
          if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
          nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
          codigos[i] := rsqlIB.FieldByName('codanalisis').AsString;
          montos[i]  := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
          Inc(totprestaciones);
          nnbu       := True;
        end;

        it := i;

        subtotal   := subtotal + montos[i];

        if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := rsqlIB.FieldByName('codos').AsString;
        idprofanter := rsqlIB.FieldByName('idprof').AsString;
        idanter     := rsqlIB.FieldByName('codpac').AsString;
        ordenanter  := rsqlIB.FieldByName('orden').AsString;
        npac        := rsqlIB.FieldByName('nombre').AsString;
        __perfact   := rsqlIB.FieldByName('ref1').AsString;
       end;
       rsqlIB.Next;
    end;

    it := i;

    rsqlIB.close; rsql.Free;

    {pag := 0; rp := True; datosListados := False;
    ruptura := xruptura;
    Periodo := xperiodo;
    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación Resumen a Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, normal, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div 5;
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo(espaciocol * i, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo(((espaciocol * i) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo5(xperiodo, xtitulo, xcolumnas);
    end;

    codosanter  := ''; idprofanter := 't'; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; datosListados := False;
    ttotprestaciones := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ttotal := 0; tot9984 := 0; totales[1] := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; canUB1 := 0;
    while not detfactIB.EOF do Begin
      if (detfactIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (detfactIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, detfactIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfactIB.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;

        if (length(trim(codosanter)) = 0) then obsocial.getDatos(detfactIB.FieldByname('codos').AsString);

        if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then
          nomeclatura.getDatos(detfactIB.FieldByName('codanalisis').AsString);

        if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then
          nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);

        if (length(trim(detfactIB.FieldByName('ref1').AsString)) = 7) then periodo := detfactIB.FieldByName('ref1').AsString else periodo := xperiodo;

        if detfactIB.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then
            obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, periodo);
          if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then
            obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
        end;

        if detfactIB.FieldByName('idprof').AsString <> idprofanter then Begin  // Ruptura por Profesional
          ListarLineaDeAnalisis(xcolumnas, salida);
          SubtotalProfesional(salida);
          ord[1] := cantidadordenes; ord[2] := totprestaciones;
          SubtotalObraSocial(salida);
          cantidadordenes := ord[1]; totprestaciones := ord[2];
          SubtotalObraSocial2(salida);

          Terminar(false);

          RupturaProf(salida, detfactIB.FieldByName('idprof').AsString, xperiodo, ruptura);
          cantidad := 0; subtotal := 0; total := 0; codosanter := ''; caran := 0; canUB := 0; totUB := 0;
        end;
        if detfactIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaOS(salida, xperiodo, xtitulo); // Ruptura por Obra Social
          subtotal := 0; idprofanter := ''; idanter := ''; cantidad := 0; caran := 0; canUB := 0; totUB := 0;
        end;

        if (i >= StrToInt(xcolumnas)) or (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if detfactIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        Inc(i);
        paciente.getDatos(detfactIB.FieldByName('idprof').AsString, detfactIB.FieldByName('codpac').AsString);
        if (length(trim(detfactIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfactIB.FieldByName('retiva').AsString;
        pac_retiva := paciente.Gravadoiva;

        if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, xperiodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfactIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos[i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
          if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);
          codigos[i] := detfactIB.FieldByName('codanalisis').AsString;
          montos[i]  := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
          Inc(totprestaciones);
          nnbu       := True;
        end;

        it := i;

        subtotal   := subtotal + montos[i];

        if detfactIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfactIB.FieldByName('codos').AsString;
        idprofanter := detfactIB.FieldByName('idprof').AsString;
        idanter     := detfactIB.FieldByName('codpac').AsString;
        ordenanter  := detfactIB.FieldByName('orden').AsString;
        npac        := detfactIB.FieldByName('nombre').AsString
       end;
       detfactIB.Next;
    end;

    it := i;

    ffirebird.QuitarFiltro(detfactIB);}

    ListarLineaDeAnalisis(xcolumnas, salida);
    SubtotalProfesional(salida);
    ord[1] := cantidadordenes; ord[2] := totprestaciones;
    SubtotalObraSocial(salida);
    cantidadordenes := ord[1]; totprestaciones := ord[2];
    //SubtotalObraSocial2(salida);   // 08/2013

    it := 0;
    SubtotalObraSocial2(salida);
    if not (ExportarDatos) then FinalizarInforme(salida);
    rp := False;

    Terminar(true);
   end;

end;

//------------------------------------------------------------------------------

procedure TTFacturacionCCB.IniciarFacturacionWeb(xperiodo: string);
begin
  datosdb.tranSQL(cabfactos.DatabaseName, 'delete from wtotalesprof where periodo = ' + '''' + xperiodo + '''');
  utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_totalesri', '*.txt');
end;

procedure TTFacturacionCCB.ListarResumenAProfesionalesRI(xperiodo, xtitulo, xcolumnas: String; xruptura: Boolean; profSel: TStringList; ObrasSocSel: TStringList; salida: char);
// Objetivo...: Listar Resumen de Prestaciones por Obra Social
var
  i, j: ShortInt;
  ord: array[1..2] of Integer;
  archdest: string;

  procedure Terminar(fin: boolean; xcodos: string);
  begin
    if (length(trim(idprofanter)) < 5) then exit;
    if (salida = 'T') and (exporta_web) then begin
      if not (exporta_web) then RealizarSalto else list.FinalizarExportacion;
      archdest := copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + idprofanter + '_' + xcodos + '_REIN' + '.txt';
      CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_totalesri\' + archdest), false);

      if not (fin) then begin
        pag := 0;
        list.IniciarImpresionModoTexto(10000);
        list.exportar_rep := true;
        titulo5(xperiodo, xtitulo, xcolumnas);
      end;
    end;
    if (salida = 'T') and not (exporta_web) then begin
      if salida <> 'N' then FinalizarInforme(salida);
    end;
  end;

begin
  IniciarArreglos;
  __periodo := xperiodo;

  if (interbase = 'N') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);

    if (exporta_web) then begin
      utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_totoalesri', '*.txt');
      list.AnularCaracteresTexto;
      salida := 'T';
      ExportarDatos := true;
      list.IniciarImpresionModoTexto(10000);
      list.exportar_rep := true;
    end;

    if not (detfact.Active) then detfact.Open;
    detfact.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';
    pag := 0; rp := True; datosListados := False;
    ruptura := xruptura;
    Periodo := xperiodo;
    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación Resumen a Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, normal, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div 5;
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo(espaciocol * i, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo(((espaciocol * i) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo5(xperiodo, xtitulo, xcolumnas);
    end;

    detfact.First;
    codosanter  := ''; idprofanter := 't'; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; datosListados := False;
    ttotprestaciones := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ttotal := 0; tot9984 := 0; totales[1] := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; canUB1 := 0;
    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, detfact.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;

        if (length(trim(codosanter)) = 0) then obsocial.getDatos(detfact.FieldByname('codos').AsString);

        if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then
          nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);

        if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then
          nbu.getDatos(detfact.FieldByName('codanalisis').AsString);

        if (length(trim(detfact.FieldByName('ref1').AsString)) = 7) then periodo := detfact.FieldByName('ref1').AsString else periodo := xperiodo;

        if detfact.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then
            obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then
            obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
        end;

        if detfact.FieldByName('idprof').AsString <> idprofanter then Begin  // Ruptura por Profesional
          ListarLineaDeAnalisis(xcolumnas, salida);
          SubtotalProfesional(salida);
          ord[1] := cantidadordenes; ord[2] := totprestaciones;
          //SubtotalObraSocial2(salida);  // 22/04/2019
          cantidadordenes := ord[1]; totprestaciones := ord[2];
          SubtotalObraSocial2(salida);

          Terminar(false, codosanter);

          if not (exporta_web) then RupturaProf(salida, detfact.FieldByName('idprof').AsString, xperiodo, ruptura);
          cantidad := 0; subtotal := 0; total := 0; codosanter := ''; caran := 0; canUB := 0; totUB := 0;
        end;
        if detfact.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaOS(salida, xperiodo, xtitulo); // Ruptura por Obra Social
          subtotal := 0; idprofanter := ''; idanter := ''; cantidad := 0; caran := 0; canUB := 0; totUB := 0;
        end;

        if (i >= StrToInt(xcolumnas)) or (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if detfact.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        Inc(i);
        paciente.getDatos(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
        if (length(trim(detfact.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfact.FieldByName('retiva').AsString;
        pac_retiva := paciente.Gravadoiva;

        if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfact.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos[i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
          if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfact.FieldByName('codanalisis').AsString);
          codigos[i] := detfact.FieldByName('codanalisis').AsString;
          montos[i]  := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
          Inc(totprestaciones);
          nnbu       := True;
        end;

        it := i;

        subtotal   := subtotal + montos[i];

        if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfact.FieldByName('codos').AsString;
        idprofanter := detfact.FieldByName('idprof').AsString;
        idanter     := detfact.FieldByName('codpac').AsString;
        ordenanter  := detfact.FieldByName('orden').AsString;
        npac        := detfact.FieldByName('nombre').AsString
       end;
       detfact.Next;
    end;

    it := i;

    ListarLineaDeAnalisis(xcolumnas, salida);
    SubtotalProfesional(salida);
    ord[1] := cantidadordenes; ord[2] := totprestaciones;
    cantidadordenes := ord[1]; totprestaciones := ord[2];
    SubtotalObraSocial2(salida);   // 08/2013

    it := 0;
    if not (ExportarDatos) and (salida <> 'T') then FinalizarInforme(salida);
    rp := False;

    Terminar(true, codosanter);
   end;

  if (interbase = 'S') then begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);

    if (exporta_web) then begin
      utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_totoalesri', '*.txt');
      list.AnularCaracteresTexto;
      salida := 'T';
      ExportarDatos := true;
      list.IniciarImpresionModoTexto(10000);
      list.exportar_rep := true;
    end;

    {if not (detfactIB.Active) then detfactIB.Open;
    if not (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''') else ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');
    detfactIB.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';
    detfactIB.First;}

    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, idprof, codos, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from detfact' + __c + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, idprof, codos, orden, items');
    rsqlIB.Open; rsqlIB.First;

    pag := 0; rp := True; datosListados := False;
    ruptura := xruptura;
    Periodo := xperiodo;
    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación Resumen a Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, normal, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div 5;
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo(espaciocol * i, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo(((espaciocol * i) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo5(xperiodo, xtitulo, xcolumnas);
    end;

    codosanter  := ''; idprofanter := 't'; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; datosListados := False;
    ttotprestaciones := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ttotal := 0; tot9984 := 0; totales[1] := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; canUB1 := 0;
    __peranter := '';
    while not rsqlIB.EOF do Begin
      if (rsqlIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (rsqlIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, rsqlIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;

        if (length(trim(codosanter)) = 0) then obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);

        if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then
          nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);

        if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then
          nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);

        if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
        __peranter := utiles.getPeriodoAAAAMM(periodo);

        if rsqlIB.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then
            obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
          if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then
            obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
        end;

        if rsqlIB.FieldByName('idprof').AsString <> idprofanter then Begin  // Ruptura por Profesional
          ListarLineaDeAnalisis(xcolumnas, salida);
          SubtotalProfesional(salida);
          ord[1] := cantidadordenes; ord[2] := totprestaciones;
          SubtotalObraSocial(salida);
          cantidadordenes := ord[1]; totprestaciones := ord[2];
          SubtotalObraSocial2(salida);

          Terminar(false, codosanter);

          RupturaProf(salida, rsqlIB.FieldByName('idprof').AsString, xperiodo, ruptura);
          cantidad := 0; subtotal := 0; total := 0; codosanter := ''; caran := 0; canUB := 0; totUB := 0;
        end;
        if rsqlIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaOS(salida, xperiodo, xtitulo); // Ruptura por Obra Social
          subtotal := 0; idprofanter := ''; idanter := ''; cantidad := 0; caran := 0; canUB := 0; totUB := 0;
        end;

        if (i >= StrToInt(xcolumnas)) or (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if rsqlIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        Inc(i);

        //paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);
        //if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
        //****************
        if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then begin
          paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
          paciente.Nombre := rsqlIB.FieldByName('nombre').AsString;
        end else
          paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);

        pac_retiva := paciente.Gravadoiva;

        //****************************

        if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := rsqlIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos[i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
          if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
          nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
          codigos[i] := rsqlIB.FieldByName('codanalisis').AsString;
          montos[i]  := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
          Inc(totprestaciones);
          nnbu       := True;
        end;

        it := i;

        subtotal   := subtotal + montos[i];

        if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := rsqlIB.FieldByName('codos').AsString;
        idprofanter := rsqlIB.FieldByName('idprof').AsString;
        idanter     := rsqlIB.FieldByName('codpac').AsString;
        ordenanter  := rsqlIB.FieldByName('orden').AsString;
        npac        := rsqlIB.FieldByName('nombre').AsString;
        __perfact   := rsqlIB.FieldByName('ref1').AsString;
       end;
       rsqlIB.Next;
    end;

    it := i;

    rsqlIB.close; rsql.Free;

    {pag := 0; rp := True; datosListados := False;
    ruptura := xruptura;
    Periodo := xperiodo;
    if salida <> 'T' then Begin
      list.altopag := 0; list.m := 0;
      list.IniciarTitulos;
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
      list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
      list.Titulo(0, 0, 'Facturación Resumen a Profesionales', 1, 'Arial, negrita, 12');
      list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
      list.Titulo(0, 0, 'Paciente', 1, 'Arial, normal, 8');
      espaciocol   := 80 div StrToInt(xcolumnas);
      nrocol       := 80 div espaciocol;
      distanciaImp := (nrocol * 12) div 5;
      j := 1;
      For i := 1 to nrocol do Begin
        list.Titulo(espaciocol * i, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
        list.Titulo(((espaciocol * i) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8');
        j := j + 2;
      end;
      list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    end else Begin
      if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
      titulo5(xperiodo, xtitulo, xcolumnas);
    end;

    codosanter  := ''; idprofanter := 't'; idanter := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; datosListados := False;
    ttotprestaciones := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ttotal := 0; tot9984 := 0; totales[1] := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; canUB1 := 0;
    while not detfactIB.EOF do Begin
      if (detfactIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (detfactIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, detfactIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfactIB.FieldByName('codos').AsString)) and (listarLinea) then Begin   // Filtro general - Período
        datosListados := True;

        if (length(trim(codosanter)) = 0) then obsocial.getDatos(detfactIB.FieldByname('codos').AsString);

        if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then
          nomeclatura.getDatos(detfactIB.FieldByName('codanalisis').AsString);

        if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then
          nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);

        if (length(trim(detfactIB.FieldByName('ref1').AsString)) = 7) then periodo := detfactIB.FieldByName('ref1').AsString else periodo := xperiodo;

        if detfactIB.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
          if (obsocial.retencioniva <> 0) then osretieneiva := 'S' else osretieneiva := 'N';
          if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then
            obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, periodo);
          if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then
            obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
        end;

        if detfactIB.FieldByName('idprof').AsString <> idprofanter then Begin  // Ruptura por Profesional
          ListarLineaDeAnalisis(xcolumnas, salida);
          SubtotalProfesional(salida);
          ord[1] := cantidadordenes; ord[2] := totprestaciones;
          SubtotalObraSocial(salida);
          cantidadordenes := ord[1]; totprestaciones := ord[2];
          SubtotalObraSocial2(salida);

          Terminar(false);

          RupturaProf(salida, detfactIB.FieldByName('idprof').AsString, xperiodo, ruptura);
          cantidad := 0; subtotal := 0; total := 0; codosanter := ''; caran := 0; canUB := 0; totUB := 0;
        end;
        if detfactIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(xcolumnas, salida);
            SubtotalProfesional(salida);
          end;
          RupturaOS(salida, xperiodo, xtitulo); // Ruptura por Obra Social
          subtotal := 0; idprofanter := ''; idanter := ''; cantidad := 0; caran := 0; canUB := 0; totUB := 0;
        end;

        if (i >= StrToInt(xcolumnas)) or (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(xcolumnas, salida) else ListLinea(xcolumnas, salida);
          i := 0;
          if detfactIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        Inc(i);
        paciente.getDatos(detfactIB.FieldByName('idprof').AsString, detfactIB.FieldByName('codpac').AsString);
        if (length(trim(detfactIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfactIB.FieldByName('retiva').AsString;
        pac_retiva := paciente.Gravadoiva;

        if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, xperiodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfactIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos[i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
          if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);
          codigos[i] := detfactIB.FieldByName('codanalisis').AsString;
          montos[i]  := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
          Inc(totprestaciones);
          nnbu       := True;
        end;

        it := i;

        subtotal   := subtotal + montos[i];

        if detfactIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfactIB.FieldByName('codos').AsString;
        idprofanter := detfactIB.FieldByName('idprof').AsString;
        idanter     := detfactIB.FieldByName('codpac').AsString;
        ordenanter  := detfactIB.FieldByName('orden').AsString;
        npac        := detfactIB.FieldByName('nombre').AsString
       end;
       detfactIB.Next;
    end;

    it := i;

    ffirebird.QuitarFiltro(detfactIB);}

    ListarLineaDeAnalisis(xcolumnas, salida);
    SubtotalProfesional(salida);
    ord[1] := cantidadordenes; ord[2] := totprestaciones;
    SubtotalObraSocial(salida);
    cantidadordenes := ord[1]; totprestaciones := ord[2];
    SubtotalObraSocial2(salida);   // 08/2013

    it := 0;
    SubtotalObraSocial2(salida);
    if not (ExportarDatos) then FinalizarInforme(salida);
    rp := False;

    Terminar(true, codosanter);
   end;

   exporta_web := false;

   list.Setear('P');
   list.altopag := 0; list.m := 0;

end;


procedure TTFacturacionCCB.titulo5(xperiodo, xtitulo, xcolumnas: String);
// Objetivo...: Titulo para impresion en modo texto
var
  i: ShortInt;
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt(xtitulo, true);
  list.LineaTxt('Facturacion Resumen a Profesionales', true);
  list.LineaTxt('Periodo de Facturacion: ' + xperiodo + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  espaciocol := 60 div StrToInt(xcolumnas);
  nrocol     := 60 div espaciocol;
  distanciaImp := (nrocol * 6) div StrToInt(xcolumnas);
  list.LineaTxt('Paciente       ', false);
  For i := 1 to nrocol do
    list.LineaTxt('Cod.' + utiles.espacios((distanciaImp) - 3) + 'Arancel ', False);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  lineas := 9;
end;

procedure TTFacturacionCCB.RupturaProf(salida: char; xidprof, xperiodo: string; ruptura: Boolean);
begin
  profesional.getDatos(xidprof);
  profesional.SincronizarCategoria(xidprof, xperiodo);
  if salida <> 'T' then Begin
    list.Linea(0, 0, 'Profesional: ' + profesional.Nombre, 1, 'Arial, negrita, 10, clNavy', salida, 'N');
    list.Linea(45, list.Lineactual, profesional.codigo, 2, 'Arial, negrita, 10, clNavy', salida, 'N');
    list.Linea(70, 0, 'Período: ' + xperiodo, 3, 'Arial, negrita, 10, clNavy', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    list.LineaTxt(CHR18, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Profesional: ' + profesional.nombre + utiles.espacios(32 - (Length(Trim(profesional.nombre)))) + ' ' + profesional.codigo + '   ' + 'Periodo: ' + xperiodo + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
  end;
end;

procedure TTFacturacionCCB.RupturaOS(salida: char; xperiodo, xtitulo: string);
begin
  if salida <> 'T' then Begin
    list.Linea(0, 0, 'Obra Social: ' + Copy(obsocial.nombre, 1, 38), 1, 'Arial, negrita, 8', salida, 'N');
    list.Linea(60, list.Lineactual, obsocial.codos, 2, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Obra Social: ' + Copy(obsocial.nombre, 1, 38) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 38))))) + ' ' + obsocial.codos + list.modo_resaltado_cancelar, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR15 + ' ', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
  end;
end;

procedure TTFacturacionCCB.SubtotalObraSocial2(salida: char);
// Objetivo...: Subtotal OS parea liq. por OS
var
  cos: String;
begin
  cos := obsocial.codos;
  obsocial.getDatos(codosanter);
  obsocial.SincronizarPosicionFiscal(codosanter, Periodo);
  profesional.SincronizarListaRetIVA(Periodo, profesional.codigo);
  profesional.SincronizarListaRetIVA(__maxperiodo, profesional.codigo);
  //utiles.msgError(__maxperiodo);


  //24/12/2019
  if (profesional.Retieneiva <> 'S') then
    if ExcluirLab then totiva[4] := 0;   // Excluir laboratorios del I.V.A.

  if cantidadordenes > 0 then Begin

   // Exportamos totales a la Web - 22/05/2019
   if (exporta_web) then begin
     GuardarTotalProfIVAExport(__periodo, idprofanter, codosanter, totiva[4], totiva[6], totiva[5], (totales[1] + totiva[6]), cantidadordenes, totprestaciones);
     // 30/12
     IngresarMontoFacturadoProfesional(__periodo, idprofanter, profesional.nombre, codosanter, codosanter, 0, 0, 0, totales[1] + totiva[6], totales[1] + totiva[6]);
   end;

   if salida <> 'T' then Begin
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(40, list.Lineactual, 'Total de Ordenes: ', 2, 'Arial, normal, 9', salida, 'N');
    list.importe(79, list.Lineactual, '#####', cantidadordenes, 3, 'Arial, normal, 9');
    list.Linea(85, list.Lineactual, ' ', 4, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(40, list.Lineactual, 'Total de Prestaciones: ', 2, 'Arial, normal, 9', salida, 'S');
    list.importe(79, list.Lineactual, '#####', totprestaciones, 3, 'Arial, normal, 9');
    list.Linea(85, list.Lineactual, ' ', 4, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
    list.Linea(40, list.Lineactual, 'Unidades Gasto: ', 2, 'Arial, normal, 9', salida, 'N');
    list.importe(79, list.Lineactual, '', ccanUG, 3, 'Arial, normal, 9');
    list.Linea(80, list.Lineactual, moneda, 4, 'Arial, normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', ttotUG, 5, 'Arial, normal, 9');
    list.Linea(96, list.Lineactual, ' ', 6, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
    list.Linea(40, list.Lineactual, 'Unidades Honorarios: ', 2, 'Arial, normal, 9', salida, 'N');
    list.importe(79, list.Lineactual, '', canUB1, 3, 'Arial, normal, 9');
    list.Linea(80, list.Lineactual, moneda, 4, 'Arial, normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', tttotUB, 5, 'Arial, normal, 9');
    list.Linea(96, list.Lineactual, ' ', 6, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'S');
    list.Linea(40, list.Lineactual, 'Compensación Arancelaria: ', 2, 'Arial, normal, 9', salida, 'N');
    list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', ttotal, 4, 'Arial, normal, 9');
    list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
    list.derecha(95, list.Lineactual, '######################', '-----------------------', 2, 'Arial, normal, 9');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
    if (totiva[4] > 0) or (profesional.Retieneiva = 'N') then list.Linea(40, list.Lineactual, 'Subtotal Facturado: ', 2, 'Arial, normal, 9', salida, 'N') else
      list.Linea(40, list.Lineactual, 'Total Facturado: ', 2, 'Arial, normal, 9', salida, 'N');
    list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 4, 'Arial, normal, 9');
    list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
    if (totiva[4] + totiva[5] + totiva[6] >= 0) and (profesional.Retieneiva = 'S') then Begin                                   // Obras Sociales con I.V.A.
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(40, list.Lineactual, 'Subtotal Grabado: ', 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totiva[4], 4, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(40, list.Lineactual, 'Subtotal Exento: ', 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totiva[5] {totiva[5] 09/2013}, 4, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(40, list.Lineactual, 'I.V.A.:', 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totiva[6], 4, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(40, list.Lineactual, 'Total Facturado:', 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(80, list.Lineactual, moneda, 3, 'Arial, normal, 9', salida, 'N');
      //list.importe(95, list.Lineactual, '', StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[4]))) + StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[5]))) + StrToFloat(utiles.FormatearNumero(FloatToStr(totiva[6]))), 4, 'Arial, normal, 9');
      list.importe(95, list.Lineactual, '', StrToFloat(utiles.FormatearNumero(FloatToStr(totales[1] + totiva[6]))), 4, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
    end;
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
    if (ruptura) and (it > 0) then Begin
      pag := 0;
      list.IniciarNuevaPagina;
      list.pagina := 0;
    end;
  end else Begin
    list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + utiles.espacios(26) + 'Total de Ordenes        : ', False);
    list.ImporteTxt(ccantidadordenes, 12, 0, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR18 + utiles.espacios(26) + 'Total de Prestaciones   : ', False);
    list.ImporteTxt(ttotprestaciones, 12, 0, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR18 + utiles.espacios(26) + 'Unidades Gasto          : ', False);
    list.ImporteTxt(ccanUG, 12, 2, False);
    list.LineaTxt(' ' + moneda, False);
    list.ImporteTxt(ttotUG, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR18 + utiles.espacios(26) + 'Unidades Honorario      : ', False);
    list.ImporteTxt(canUB1, 12, 2, False);
    list.LineaTxt(' ' + moneda, False);
    list.ImporteTxt(tttotUB, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR18 + utiles.espacios(26) + 'Compensacion Arancelaria:             ', False);
    list.LineaTxt(' ' + moneda, False);
    list.ImporteTxt(ttotal, 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    list.LineaTxt(CHR18 + utiles.espacios(Length(Trim(moneda))) + utiles.espacios(26) + '                                       ------------', True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    if (totiva[4] > 0) and (profesional.Retieneiva = 'S') then list.LineaTxt(CHR18 + utiles.espacios(26) + 'Subtotal Facturado      :             ', False) else
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Total Facturado         :             ', False);

    list.LineaTxt(' ' + moneda, False);
    list.ImporteTxt(totales[1], 12, 2, False);
    list.LineaTxt(list.modo_resaltado_cancelar, True);
    Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    //if totiva[4] > 0 then Begin                                   // Obras Sociales con I.V.A.
    if (totiva[4] + totiva[5] + totiva[6] >= 0) and (profesional.Retieneiva = 'S') then Begin
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Subtotal Grabado        :             ', False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(totiva[4], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Subtotal Exento         :             ', False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(totiva[5], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'I.V.A.                  :             ', False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(totiva[6], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + utiles.espacios(26) + 'Total Facturado         :             ', False);
      list.LineaTxt(' ' + moneda, False);
      list.ImporteTxt(StrToFloat(utiles.FormatearNumero(FloatToStr(totales[1] + totiva[6]))), 12, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
      list.LineaTxt(CHR18 + list.modo_resaltado_cancelar + utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
    end;
    if (ruptura) and (it > 0) and not (exporta_web) then Begin
      pag := 0;
      RealizarSalto;
      titulo1(periodo, titulo, columnas);
    end;
  end;
 end;

 obsocial.getDatos(cos);
 cantidadordenes := 0; totprestaciones := 0; ttotprestaciones := 0; ccantidadordenes := 0; tttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; ttotal := 0; totales[1] := 0; canUB1 := 0;
 totiva[1] := 0; totiva[2] := 0; totiva[3] := 0; totiva[4] := 0; totiva[5] := 0; totiva[6] := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; _caran := 0;
end;

//------------------------------------------------------------------------------

procedure TTFacturacionCCB.GuardarModeloFact(xid, xmodelo: string);
// Objetivo...: Guardar Modelo Facturado
begin
  if not modeloc.FindKey([xid]) then modeloc.Append else modeloc.Edit;
  modeloc.FieldByName('id').AsString     := xid;
  modeloc.FieldByName('modelo').AsString := xmodelo;
  try
    modeloc.Post
   except
    modeloc.Cancel
  end;
  datosdb.refrescar(modeloc);
end;

procedure TTFacturacionCCB.getDatosModeloFact(xid: string);
// Objetivo...: Obtener modelo de factura
begin
  if not (modeloc.Active) then modeloc.Open;
  if modeloc.FindKey([xid]) then modelo := modeloc.FieldByName('modelo').AsString else modelo := '';
end;

function  TTFacturacionCCB.setLiquidaciones: TQuery;
// Objetivo...: devolver un set con las facturas del período
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + liq.TableName + ' WHERE codos = ' + '"' + obsocial.tabla.FieldByName('codos').AsString + '"');
end;

function  TTFacturacionCCB.setNumeroDeLiquidacion(xperiodo, xcodos: String): String;
// Objetivo...: Establecer el número de liquidación
var
  nliq: String;
begin
  if BuscarLiq(xperiodo, xcodos) then nliq := liq.FieldByName('nroliq').AsString else Begin
    // Determinamos el numero de liquidacion
    liq.First; nLiq := '0';
    while not liq.EOF do Begin
      if liq.FieldByName('nroliq').AsString > nliq then nliq := liq.FieldByName('nroliq').AsString;
      liq.Next;
    end;
    nLiq := utiles.sLlenarIzquierda(IntToStr(StrToInt(nLiq) + 1), 8, '0');
    //if BuscarLiq(utiles.PeriodoAnterior(xperiodo), xcodos) then nliq := utiles.sLlenarIzquierda(IntToStr(StrToInt(liq.FieldByName('nroliq').AsString) + 1), 8, '0') else nliq := '00000001';
    if BuscarLiq(xperiodo, xcodos) then liq.Edit else liq.Append;
    liq.FieldByName('periodo').AsString := xperiodo;
    liq.FieldByName('codos').AsString   := xcodos;
    liq.FieldByName('nroliq').AsString  := nliq;
    try
      liq.Post
     except
      liq.Cancel
    end;
    datosdb.refrescar(liq);
  end;
  Result := nliq;
end;

function TTFacturacionCCB.BuscarLiq(xperiodo, xcodos: String): Boolean;
// Objetivo...: Buscar una Liquidacion para un periodo dado
begin
  Result := datosdb.Buscar(liq, 'periodo', 'codos', xperiodo, xcodos);
end;

procedure TTFacturacionCCB.EstablecerNroLiquidacion(xperiodo, xnroliq: String);
// Objetivo...: Establecer/Ajustar el número de liquidación
begin
  if BuscarLiq(xperiodo, obsocial.tabla.FieldByName('codos').AsString) then liq.Edit else liq.Append;
  liq.FieldByName('periodo').AsString := xperiodo;
  liq.FieldByName('codos').AsString   := obsocial.tabla.FieldByName('codos').AsString;
  liq.FieldByName('nroliq').AsString  := xnroliq;
  try
    liq.Post
   except
    liq.Cancel
  end;
  datosdb.refrescar(liq);
end;

procedure TTFacturacionCCB.IniciarFacturacion(salida: char; ximpresora: integer);
// Objetivo...: Iniciar Facturación para las Obras Sociales
begin
  if salida <> 'T' then Begin
    if (salida = 'I') then list.SeleccionarImpresora(ximpresora, ''); 
    list.Setear(salida);
    list.altopag := 0; list.m := 0;
    list.NoImprimirPieDePagina;
    list.IniciarTitulos;
  end;
  if salida = 'T' then list.IniciarImpresionModoTexto;
  datosListadosFact := False;
end;

function TTFacturacionCCB.FacturarObraSociales(xperiodo, xcodos, xfecha, xvencimiento, xvto1, xvto2, xobservacion, xidcompr, xtipo, xsucursal, xnumero: String; xPorc1, xPorc2: Real; salida: char; agrupa: string): Boolean;
// Objetivo...: Facturar para las obras sociales en Formularios Preimpresos
var
  i, xi, item: Integer; il: String;
  nLiq, it: String;
  l, st: TStringList;

  procedure ListarOSAgrupadas(xperiodo, xcodos: string);
  var
    rs: TQuery;
    s: real;
    i, j: integer;
  begin
    i  := 0;
    rs := osagrupa.getObrasAgrupadas(xcodos);
    rs.Open;
    while not rs.eof do begin
      BorrarTotalFactObraSocial(xperiodo, rs.FieldByName('codos').AsString);   // Borramos la Instancia para Regenerarla
      l := TStringList.Create;
      l.Add(rs.FieldByName('codos').AsString);
      ListarTotGralesObrasSociales(xperiodo, '', l, 'N');
      s := setTotalFactObraSocial(xperiodo, rs.FieldByName('codos').AsString);
      subtotal := subtotal + s;

      obsocial.getDatos(rs.FieldByName('codos').AsString);
      st.Add(utiles.FormatearNumero(FloatToStr(s)));

      inc(i);
      list.RemplazarEtiquetasEnMemo('#obsocial' + inttostr(i), utiles.StringLongitudFija(obsocial.Nombre, 30));
      list.RemplazarEtiquetasEnMemo('#tos' + inttostr(i), utiles.FormatearNumero(FloatToStr(s)));

      item := item + 1;
      it := utiles.sLlenarIzquierda(inttostr(item), 2, '0');
      if (buscardatosfactdet(xperiodo, xcodos, it)) then  datosfactdet.Edit else datosfactdet.Append;
      datosfactdet.FieldByName('periodo').AsString  := xperiodo;
      datosfactdet.FieldByName('codos').AsString    := xcodos;
      datosfactdet.FieldByName('items').AsString    := it;
      datosfactdet.FieldByName('descrip').AsString  := utiles.StringLongitudFija(obsocial.Nombre, 30);
      datosfactdet.FieldByName('monto').AsFloat     := s;
      try
        datosfactdet.Post
       except
        datosfactdet.Cancel
      end;
      datosdb.refrescar(datosfactdet);

      rs.Next;
    end;
    rs.Close; rs.Free;

    for j := i to 8 do begin
      list.RemplazarEtiquetasEnMemo('#obsocial' + inttostr(j), '');
      list.RemplazarEtiquetasEnMemo('#tos' + inttostr(j), '');
    end;
  end;

begin

  if not (modeloc.Active) then modeloc.Open;
  omitir_ressql := true;     // 29/05/2014 para que no prorratee

  datosdb.tranSQL('delete from datosfactdet where periodo = ' + '''' + xperiodo + '''' + ' and codos = ' + '''' + xcodos + '''');

  if (agrupa <> 'S') then begin
    item := 0;
    nLiq := setNumeroDeLiquidacion(xperiodo, xcodos);  // Obtenemos el número de Liquidación
    obsocial.getDatos(xcodos);  // Sincronizamos la Obra Social

    l := TStringList.Create; l.Add(xcodos);

    BorrarTotalFactObraSocial(xperiodo, xcodos);   // Borramos la Instancia para Regenerarla
    ListarTotGralesObrasSociales(xperiodo, '', l, 'N');
    if (salida <> 'T') then list.NoImprimirPieDePagina;
    subtotal := 0;
    subtotal := setTotalFactObraSocial(xperiodo, xcodos);

    if subtotal > 0 then Begin
      modeloc.FindKey(['facturacion']);
      list.IniciarMemoImpresiones(modeloc, 'modelo', 500);
      list.RemplazarEtiquetasEnMemo('#fecha', xfecha);
      list.RemplazarEtiquetasEnMemo('#obsocial', Copy(obsocial.Nombrec, 1, 48));
      list.RemplazarEtiquetasEnMemo('#vencimiento', Copy(xvencimiento, 1, 2) + ' de ' + utiles.setMes(StrToInt(Copy(xvencimiento, 4, 2))) + ' del ' + Copy(utiles.sExprFecha2000(xvencimiento), 1, 4));
      list.RemplazarEtiquetasEnMemo('#direccion', obsocial.direccion);
      list.RemplazarEtiquetasEnMemo('#codigopost', obsocial.codpost);
      list.RemplazarEtiquetasEnMemo('#liquidacion', nLiq);
      list.RemplazarEtiquetasEnMemo('#localidad', obsocial.localidad);
      list.RemplazarEtiquetasEnMemo('#condicioniva', obsocial.codpfis);
      list.RemplazarEtiquetasEnMemo('#cuit', obsocial.nrocuit);
      list.RemplazarEtiquetasEnMemo('#mes', utiles.setMes(StrToInt(Copy(xfecha, 4, 2))));
      list.RemplazarEtiquetasEnMemo('#anio', Copy(utiles.sExprFecha2000(xfecha), 1, 4));
      list.RemplazarEtiquetasEnMemo('#totalfact1', utiles.FormatearNumero(FloatToStr(subtotal)));
      list.RemplazarEtiquetasEnMemo('#totalfact2', utiles.FormatearNumero(FloatToStr(subtotal)));
      list.RemplazarEtiquetasEnMemo('#fechavencimiento1', xvto1);
      list.RemplazarEtiquetasEnMemo('#fechavencimiento2', xvto2);
      list.RemplazarEtiquetasEnMemo('#importevencimiento1', utiles.FormatearNumero(FloatToStr(subtotal + ((subtotal * xPorc1) / 100))));
      list.RemplazarEtiquetasEnMemo('#importevencimiento2', utiles.FormatearNumero(FloatToStr(subtotal + ((subtotal * xPorc2) / 100))));
      il := utiles.FormatearNumero(FloatToStr(subtotal));
      xi := StrToInt(Copy(il, 1, Length(Trim(il)) - 3));
      list.RemplazarEtiquetasEnMemo('#importeenletras', LowerCase(utiles.xIntToLletras(xi) + ' C/ ' + Copy(il, Length(Trim(il)) - 1, 2)));
      list.RemplazarEtiquetasEnMemo('#observacion', trimright(xobservacion));
      list.RemplazarEtiquetasEnMemo('#nombre-obra-social', Copy(obsocial.Nombre, 1, 35));
      list.RemplazarEtiquetasEnMemo('#obsocial1', ''); list.RemplazarEtiquetasEnMemo('#tos1', '');
      list.RemplazarEtiquetasEnMemo('#obsocial2', ''); list.RemplazarEtiquetasEnMemo('#tos2', '');
      list.RemplazarEtiquetasEnMemo('#obsocial3', ''); list.RemplazarEtiquetasEnMemo('#tos3', '');
      list.RemplazarEtiquetasEnMemo('#obsocial4', ''); list.RemplazarEtiquetasEnMemo('#tos4', '');
      list.RemplazarEtiquetasEnMemo('#obsocial5', ''); list.RemplazarEtiquetasEnMemo('#tos5', '');
      list.RemplazarEtiquetasEnMemo('#obsocial6', ''); list.RemplazarEtiquetasEnMemo('#tos6', '');
      list.RemplazarEtiquetasEnMemo('#obsocial7', ''); list.RemplazarEtiquetasEnMemo('#tos7', '');
      list.RemplazarEtiquetasEnMemo('#obsocial8', ''); list.RemplazarEtiquetasEnMemo('#tos8', '');
      list.RemplazarEtiquetasEnMemo('#obsocial9', ''); list.RemplazarEtiquetasEnMemo('#tos9', '');
      list.RemplazarEtiquetasEnMemo('#obsocial10', ''); list.RemplazarEtiquetasEnMemo('#tos10', '');

      if salida <> 'T' then Begin
        For i := 1 to list.NumeroLineasMemo do Begin   // Vamos imprimiendo en un archivo las lineas del memo
          list.Linea(0, 0, TrimRight(list.ExtraerItemsMemoImp(i-1)), 1, 'Courier New, normal, 11', salida, 'S');
        end;
        list.IniciarNuevaPagina;
      end else Begin
        lineas := 0;
        For i := 1 to list.NumeroLineasMemo do Begin   // Vamos imprimiendo en un archivo las lineas del memo
          if i = 1 then list.LineaTxt(CHR18, False);
          list.LineaTxt(TrimRight(list.ExtraerItemsMemoImp(i-1)), true);
          Inc(lineas);
        end;
        RealizarSalto;
      end;

      // Actualizamos los datos de la facturación
      if BuscarDatosFact(xperiodo, xcodos) then datosfact.Edit else datosfact.Append;
      datosfact.FieldByName('periodo').AsString  := xperiodo;
      datosfact.FieldByName('codos').AsString    := xcodos;
      datosfact.FieldByName('nroliq').AsString   := nLiq;
      datosfact.FieldByName('idcompr').AsString  := xidcompr;
      if (not exporta_afip) then datosfact.FieldByName('fecha').AsString := xfecha else begin
        if (datosfact.FieldByName('cae').AsString = '') then datosfact.FieldByName('fecha').Clear;
      end;
      datosfact.FieldByName('obrasocial').AsString := obsocial.Nombre;
      datosfact.FieldByName('cuit').AsString     := obsocial.nrocuit;
      datosfact.FieldByName('monto').AsFloat     := subtotal;
      try
        datosfact.Post
       except
        datosfact.Cancel
      end;
      datosdb.refrescar(datosfact);
      // Actualizamos los datos de la facturación emitida

      // Detalle de la factura 11/12/2018

      item := item + 1;
      it := utiles.sLlenarIzquierda(inttostr(item), 2, '0');
      if (buscardatosfactdet(xperiodo, xcodos, it)) then  datosfactdet.Edit else datosfactdet.Append;
      datosfactdet.FieldByName('periodo').AsString  := xperiodo;
      datosfactdet.FieldByName('codos').AsString    := xcodos;
      datosfactdet.FieldByName('items').AsString    := it;
      datosfactdet.FieldByName('descrip').AsString := 'Prestaciones correspondientes al mes de ' +
        utiles.setMes(StrToInt(Copy(xfecha, 4, 2))) + ' de ' + Copy(utiles.sExprFecha2000(xfecha), 1, 4);
      datosfactdet.FieldByName('monto').AsFloat    := subtotal;
      try
        datosfactdet.Post
       except
        datosfactdet.Cancel
      end;
      datosdb.refrescar(datosfactdet);

      if datosdb.Buscar(cabfactos, 'nroliq', 'codos', nLiq, xcodos) then cabfactos.Edit else cabfactos.Append;
      cabfactos.FieldByName('nroliq').AsString      := nLiq;
      cabfactos.FieldByName('codos').AsString       := xcodos;
      cabfactos.FieldByName('periodo').AsString     := xperiodo;
      cabfactos.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
      cabfactos.FieldByName('vencimiento').AsString := xvencimiento;
      cabfactos.FieldByName('concepto').AsString    := utiles.setMes(StrToInt(Copy(xfecha, 4, 2))) + ',' + Copy(utiles.sExprFecha2000(xfecha), 1, 4);
      cabfactos.FieldByName('ultimovenc').AsString  := utiles.sExprFecha2000(xvto2);
      cabfactos.FieldByName('importevto1').AsFloat  := (subtotal * xPorc1) / 100;
      cabfactos.FieldByName('importevto2').AsFloat  := (subtotal * xPorc2) / 100;
      cabfactos.FieldByName('total').AsFloat        := Montos[1];
      try
        cabfactos.Post
       except
        cabfactos.Cancel
      end;
      datosdb.refrescar(cabfactos);
    end;
    nLiq := '';

    if subtotal <> 0 then Begin
      Result := True;
      datosListadosFact := True;
    end else
      Result := False;
  end;

  if (agrupa = 'S') then begin
    nLiq     := setNumeroDeLiquidacion(xperiodo, xcodos);  // Obtenemos el número de Liquidación

    //osagrupa.conectar;

    modeloc.FindKey(['facturacion']);
    list.IniciarMemoImpresiones(modeloc, 'modelo', 500);
    st := TStringList.Create;

    ListarOSAgrupadas(xperiodo, xcodos);

    subtotal := 0;
    for i := 1 to st.Count do
      subtotal := subtotal + StrToFloat(st.Strings[i-1]);

    if (salida <> 'T') then list.NoImprimirPieDePagina;

    osagrupa.getobject(xcodos);

    if subtotal > 0 then Begin
      list.RemplazarEtiquetasEnMemo('#fecha', xfecha);
      list.RemplazarEtiquetasEnMemo('#obsocial', Copy(osagrupa.Nombre, 1, 48));
      list.RemplazarEtiquetasEnMemo('#vencimiento', Copy(xvencimiento, 1, 2) + ' de ' + utiles.setMes(StrToInt(Copy(xvencimiento, 4, 2))) + ' del ' + Copy(utiles.sExprFecha2000(xvencimiento), 1, 4));
      list.RemplazarEtiquetasEnMemo('#direccion', osagrupa.Direccion);
      list.RemplazarEtiquetasEnMemo('#codigopost', '');
      list.RemplazarEtiquetasEnMemo('#liquidacion', nLiq);
      list.RemplazarEtiquetasEnMemo('#localidad', osagrupa.Localidad);
      list.RemplazarEtiquetasEnMemo('#condicioniva', osagrupa.Codpfis);
      list.RemplazarEtiquetasEnMemo('#cuit', osagrupa.Cuit);
      list.RemplazarEtiquetasEnMemo('#mes', utiles.setMes(StrToInt(Copy(xfecha, 4, 2))));
      list.RemplazarEtiquetasEnMemo('#anio', Copy(utiles.sExprFecha2000(xfecha), 1, 4));
      list.RemplazarEtiquetasEnMemo('#totalfact1', utiles.FormatearNumero(FloatToStr(subtotal)));
      list.RemplazarEtiquetasEnMemo('#totalfact2', utiles.FormatearNumero(FloatToStr(subtotal)));
      list.RemplazarEtiquetasEnMemo('#fechavencimiento1', xvto1);
      list.RemplazarEtiquetasEnMemo('#fechavencimiento2', xvto2);
      list.RemplazarEtiquetasEnMemo('#importevencimiento1', utiles.FormatearNumero(FloatToStr(subtotal + ((subtotal * xPorc1) / 100))));
      list.RemplazarEtiquetasEnMemo('#importevencimiento2', utiles.FormatearNumero(FloatToStr(subtotal + ((subtotal * xPorc2) / 100))));
      il := utiles.FormatearNumero(FloatToStr(subtotal));
      xi := StrToInt(Copy(il, 1, Length(Trim(il)) - 3));
      list.RemplazarEtiquetasEnMemo('#importeenletras', LowerCase(utiles.xIntToLletras(xi) + ' C/ ' + Copy(il, Length(Trim(il)) - 1, 2)));
      list.RemplazarEtiquetasEnMemo('#observacion', xobservacion);
      list.RemplazarEtiquetasEnMemo('#nombre-obra-social', Copy(osagrupa.Nombre, 1, 35));

      if salida <> 'T' then Begin
        For i := 1 to list.NumeroLineasMemo do Begin   // Vamos imprimiendo en un archivo las lineas del memo
          list.Linea(0, 0, TrimRight(list.ExtraerItemsMemoImp(i-1)), 1, 'Courier New, normal, 11', salida, 'S');
        end;
        list.IniciarNuevaPagina;
      end else Begin
        lineas := 0;
        For i := 1 to list.NumeroLineasMemo do Begin   // Vamos imprimiendo en un archivo las lineas del memo
          if i = 1 then list.LineaTxt(CHR18, False);
          list.LineaTxt(TrimRight(list.ExtraerItemsMemoImp(i-1)), true);
          Inc(lineas);
        end;
        RealizarSalto;
      end;

      // Actualizamos los datos de la facturación
      if BuscarDatosFact(xperiodo, xcodos) then datosfact.Edit else datosfact.Append;
      datosfact.FieldByName('periodo').AsString  := xperiodo;
      datosfact.FieldByName('codos').AsString    := xcodos;
      datosfact.FieldByName('nroliq').AsString   := nLiq;
      //datosfact.FieldByName('idcompr').AsString  := xidcompr;
      //datosfact.FieldByName('tipo').AsString     := xtipo;
      //datosfact.FieldByName('sucursal').AsString := xsucursal;
      //datosfact.FieldByName('numero').AsString   := xnumero;
      if (not exporta_afip) then datosfact.FieldByName('fecha').AsString    := xfecha else begin
        if (datosfact.FieldByName('cae').AsString = '') then datosfact.FieldByName('fecha').Clear;
      end;
      datosfact.FieldByName('obrasocial').AsString := osagrupa.Nombre;
      datosfact.FieldByName('cuit').AsString     := osagrupa.Cuit;
      datosfact.FieldByName('monto').AsFloat     := subtotal;
      try
        datosfact.Post
       except
        datosfact.Cancel
      end;
      datosdb.refrescar(datosfact);
      // Actualizamos los datos de la facturación emitida
      if datosdb.Buscar(cabfactos, 'nroliq', 'codos', nLiq, xcodos) then cabfactos.Edit else cabfactos.Append;
      cabfactos.FieldByName('nroliq').AsString      := nLiq;
      cabfactos.FieldByName('codos').AsString       := xcodos;
      cabfactos.FieldByName('periodo').AsString     := xperiodo;
      cabfactos.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
      cabfactos.FieldByName('vencimiento').AsString := xvencimiento;
      cabfactos.FieldByName('concepto').AsString    := utiles.setMes(StrToInt(Copy(xfecha, 4, 2))) + ',' + Copy(utiles.sExprFecha2000(xfecha), 1, 4);
      cabfactos.FieldByName('ultimovenc').AsString  := utiles.sExprFecha2000(xvto2);
      cabfactos.FieldByName('importevto1').AsFloat  := (subtotal * xPorc1) / 100;
      cabfactos.FieldByName('importevto2').AsFloat  := (subtotal * xPorc2) / 100;
      cabfactos.FieldByName('total').AsFloat        := Montos[1];
      try
        cabfactos.Post
       except
        cabfactos.Cancel
      end;
      datosdb.refrescar(cabfactos);
    end;
    nLiq := '';

    //osagrupa.desconectar;

    omitir_ressql := false;

    if subtotal <> 0 then Begin
      Result := True;
      datosListadosFact := True;
    end else
      Result := False;
  end;
end;

function TTFacturacionCCB.FacturarObraSocialesFormBlanco(xperiodo, xcodos, xfecha, xvencimiento, xvto1, xvto2, xobservacion, xidcompr, xtipo, xsucursal, xnumero: String; xPorc1, xPorc2: Real; salida: char;
                                                         xasociacion, xdireccion, xlocalidad, xtelefono, xcuit, xsuss, xibrutos, xiva: String): Boolean;
// Objetivo...: Facturar para las obras sociales en Formularios en Blanco
var
  i, xi: Integer; il: String;
  nLiq: String;
  l: TStringList;
begin
  nLiq := setNumeroDeLiquidacion(xperiodo, xcodos);  // Obtenemos el número de Liquidación
  obsocial.getDatos(xcodos);  // Sincronizamos la Obra Social

  l := TStringList.Create; l.Add(xcodos);
  ListarTotGralesObrasSociales(xperiodo, '', l, 'N');
  subtotal := 0;
  subtotal := setTotalFactObraSocial(xperiodo, xcodos);

  if subtotal > 0 then Begin
    if (salida = 'I') or (salida = 'P') then Begin
      list.NoImprimirPieDePagina;
      list.Linea(0, 0, xasociacion, 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(50, list.Lineactual, xtipo, 2, 'Arial, normal, 10', salida, 'N');
      list.Linea(70, list.Lineactual, 'Nº  ' + xsucursal + ' - ' + xnumero, 3, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, xdireccion + ' Tel.: ' + xtelefono, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.Lineactual, 'Fecha: ' + xfecha, 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, xdireccion + ' Localidad: ' + xlocalidad, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.Lineactual, 'C.U.I.T.: ' + xcuit, 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.Lineactual, 'S.U.S.S.: ' + xsuss, 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'I.V.A.: ' + xiva, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.Lineactual, 'I.Brutos: ' + xibrutos, 2, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'O. Social: ' + Copy(obsocial.Nombrec, 1, 48), 1, 'Arial, negrita, 10', salida, 'N');
      list.Linea(75, list.Lineactual, 'Cód.: ' + xcodos, 2, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, 'Domicilio: ' + obsocial.direccion, 1, 'Arial, negrita, 10', salida, 'N');
      list.Linea(60, list.Lineactual, 'C.P.: ' + obsocial.codpost + '   ' + obsocial.localidad, 2, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, 'C.U.I.T.: ' + obsocial.nrocuit, 1, 'Arial, negrita, 10', salida, 'N');
      list.Linea(60, list.Lineactual, 'I.V.A.: ' + obsocial.codpfis, 2, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

      list.Linea(0, 0, 'Por la asistencia profesional prestada por medio de profesionales y/o instituciones', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'sanatoriales, a los afiliados de esta Obra Social del período ' + xperiodo + ',', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'según detalle del RESUMEN DE RENDICION Nro. ' + xnumero + ' adjunto.', 1, 'Arial, normal, 10', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'N');
      list.Linea(15, list.Lineactual, 'Total', 2, 'Arial, negrita, 10', salida, 'N');
      list.Linea(35, list.Lineactual, '$', 3, 'Arial, negrita, 10', salida, 'N');
      list.importe(55, list.Lineactual, '', subtotal, 4, 'Arial, negrita, 10');
      list.Linea(60, list.Lineactual, '', 5, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'N');
      list.Linea(15, list.Lineactual, '1º Vto. ' + xvto1, 2, 'Arial, negrita, 10', salida, 'N');
      list.Linea(35, list.Lineactual, '$', 3, 'Arial, negrita, 10', salida, 'N');
      list.importe(55, list.Lineactual, '', (subtotal + ((subtotal * xPorc1) / 100)), 4, 'Arial, negrita, 10');
      list.Linea(60, list.Lineactual, '', 5, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, noegrita, 10', salida, 'N');
      list.Linea(15, list.Lineactual, '2º Vto. ' + xvto1, 2, 'Arial, negrita, 10', salida, 'N');
      list.Linea(35, list.Lineactual, '$', 3, 'Arial, negrita, 10', salida, 'N');
      list.importe(55, list.Lineactual, '', (subtotal + ((subtotal * xPorc2) / 100)), 4, 'Arial, negrita, 10');
      list.Linea(60, list.Lineactual, '', 5, 'Arial, negrita, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');

      il := utiles.FormatearNumero(FloatToStr(subtotal));
      xi := StrToInt(Copy(il, 1, Length(Trim(il)) - 3));
      list.Linea(0, 0, 'Son Pesos:  ' + LowerCase(utiles.xIntToLletras(xi) + ' C/ ' + Copy(il, Length(Trim(il)) - 1, 2)), 1, 'Arial, negritra, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, xobservacion, 1, 'Arial, negritra, 10', salida, 'S');

      list.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'S');
      list.Linea(0, 0, 'EL PRESENTE COMPROBANTE DEBERA ABONARSE ANTES DEL ', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, xvencimiento + ', VENCIDO DICHO TERMINO SU IMPORTE DEVENGARA' , 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'EL INTERES QUE FIJE EL BANCO DE LA NACIÓN ARGENTINA ', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'PARA EL DESCUENTO DE DOCUMENTOS VIGENTE, EMITIENDOSE RECIBO OFICIAL AL', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'MOMENTO DEL PAGO.', 1, 'Arial, normal, 10', salida, 'S');


      list.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'S');

      list.Linea(0, 0, '.........................................', 1, 'Arial, normal, 10', salida, 'N');
      list.Linea(70, list.Lineactual, '..........................................', 2, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, 'Firma y Sello Ente Facturador', 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(70, list.Lineactual, 'Firma y Sello Ente Facturador', 2, 'Arial, normal, 9', salida, 'S');
    end;

    if (salida = 'T') then Begin
      Lineas := 0;
      list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + xasociacion, True); Inc(lineas);
      list.LineaTxt(utiles.espacios(39) +  xtipo + '           ' + xsucursal + ' - ' + xnumero, True); Inc(lineas);
      list.LineaTxt('', True); Inc(lineas);
      list.LineaTxt(CHR15 + xdireccion + ' Tel.: ' + xtelefono + utiles.espacios(55 - Length(TrimRight(xdireccion + 'Tel.: ' + xtelefono))), False);
      list.LineaTxt(CHR18 + ' Fecha: ' + xfecha, True); Inc(lineas);
      list.LineaTxt(CHR15 + xdireccion + 'Localidad: ' + xlocalidad + utiles.espacios(55 - Length(TrimRight(xdireccion + 'Localidad: ' + xlocalidad))), False);
      list.LineaTxt(CHR18 + 'S.U.S.S.: ' + xcuit, True); Inc(lineas);
      list.LineaTxt(CHR15 + 'I.V.A.: ' + xiva + utiles.espacios(55 - Length(TrimRight('I.V.A.: ' + xiva))), False);
      list.LineaTxt(CHR18 + 'I.Brutos: ' + xibrutos + list.modo_resaltado_cancelar, True); Inc(lineas);

      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas);
      list.LineaTxt(list.modo_resaltado_seleccionar + 'O. Social: ' + Copy(obsocial.Nombrec, 1, 48) + utiles.espacios(63 - Length(TrimRight('O. Social: ' + Copy(obsocial.Nombrec, 1, 48)))), False);
      list.LineaTxt('Cód.: ' + xcodos, True); Inc(lineas);
      list.LineaTxt('Domicilio: ' + obsocial.direccion + ' C.P.: ' + obsocial.codpost + ' ' + Copy(obsocial.localidad, 1, 15), True); Inc(lineas);
      list.LineaTxt('C.U.I.T.: ' + obsocial.nrocuit + utiles.espacios(40 - Length(TrimRight('C.U.I.T.: ' + obsocial.nrocuit))), False);
      list.LineaTxt('I.V.A.: ' + obsocial.codpfis, True); Inc(lineas);
      list.LineaTxt(list.modo_resaltado_cancelar + CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas);

      list.LineaTxt(CHR18 + '', True); Inc(lineas);

      list.LineaTxt('Por la asistencia profesional prestada por medio de profesionales y/o', True); Inc(lineas);
      list.LineaTxt('periodo ' + xperiodo + ', instituciones sanatoriales, a los afiliados', True); Inc(lineas);
      list.LineaTxt('de esta Obra Social del según detalle del RESUMEN DE RENDICION', True); Inc(lineas);
      list.LineaTxt('Nro. ' + xnumero + ' adjunto.', True); Inc(lineas);

      list.LineaTxt(list.modo_resaltado_seleccionar, True); Inc(lineas);
      list.LineaTxt('     Total                     $', False);
      list.importeTxt(subtotal, 12, 2, True); Inc(lineas);

      list.LineaTxt('     1º Vto. ' + xvto1 + '         $', False);
      list.importeTxt((subtotal + ((subtotal * xPorc1) / 100)), 12, 2, True); Inc(lineas);

      list.LineaTxt('     2º Vto. ' + xvto2 + '         $', False);
      list.importeTxt((subtotal + ((subtotal * xPorc2) / 100)), 12, 2, True); Inc(lineas);
      list.LineaTxt('', True); Inc(lineas);

      il := utiles.FormatearNumero(FloatToStr(subtotal));
      xi := StrToInt(Copy(il, 1, Length(Trim(il)) - 3));
      list.LineaTxt('Son Pesos:  ' + LowerCase(utiles.xIntToLletras(xi) + ' C/ ' + Copy(il, Length(Trim(il)) - 1, 2)), True); Inc(lineas);

      list.LineaTxt('', True); Inc(lineas);
      list.LineaTxt(xobservacion, True); Inc(lineas);

      list.LineaTxt('' + list.modo_resaltado_cancelar, True); Inc(lineas);
      list.LineaTxt('EL PRESENTE COMPROBANTE DEBERA ABONARSE ANTES DEL ', True); Inc(lineas);
      list.LineaTxt(xvencimiento + ', VENCIDO DICHO TERMINO SU IMPORTE DEVENGARA', True); Inc(lineas);
      list.LineaTxt('EL INTERES QUE FIJE EL BANCO DE LA NACIÓN ARGENTINA ', True); Inc(lineas);
      list.LineaTxt('PARA EL DESCUENTO DE DOCUMENTOS VIGENTE, EMITIENDOSE', True); Inc(lineas);
      list.LineaTxt('RECIBO OFICIAL AL MOMENTO DEL PAGO.', True); Inc(lineas);

      list.LineaTxt('', True); Inc(lineas);
      list.LineaTxt('', True); Inc(lineas);
      list.LineaTxt('', True); Inc(lineas);
      list.LineaTxt('', True); Inc(lineas);


      list.LineaTxt('....................................      ....................................', True); Inc(lineas);
      list.LineaTxt('   Firma y Sello Ente Facturador             Firma y Sello Ente Facturador', True); Inc(lineas);
    end;

    if salida <> 'T' then Begin
      list.CompletarPagina;
    end else Begin
      RealizarSalto;
    end;

    // Actualizamos los datos de la facturación
    if BuscarDatosFact(xperiodo, xcodos) then datosfact.Edit else datosfact.Append;
    datosfact.FieldByName('periodo').AsString  := xperiodo;
    datosfact.FieldByName('codos').AsString    := xcodos;
    datosfact.FieldByName('nroliq').AsString   := nLiq;
    datosfact.FieldByName('idcompr').AsString  := xidcompr;
    datosfact.FieldByName('tipo').AsString     := xtipo;
    datosfact.FieldByName('sucursal').AsString := xsucursal;
    datosfact.FieldByName('numero').AsString   := xnumero;
    datosfact.FieldByName('fecha').AsString    := xfecha;
    try
      datosfact.Post
     except
      datosfact.Cancel
    end;
    datosdb.refrescar(datosfact);
    // Actualizamos los datos de la facturación emitida
    if datosdb.Buscar(cabfactos, 'nroliq', 'codos', nLiq, xcodos) then cabfactos.Edit else cabfactos.Append;
    cabfactos.FieldByName('nroliq').AsString      := nLiq;
    cabfactos.FieldByName('codos').AsString       := xcodos;
    cabfactos.FieldByName('periodo').AsString     := xperiodo;
    cabfactos.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
    cabfactos.FieldByName('vencimiento').AsString := xvencimiento;
    cabfactos.FieldByName('concepto').AsString    := utiles.setMes(StrToInt(Copy(xfecha, 4, 2))) + ',' + Copy(utiles.sExprFecha2000(xfecha), 1, 4);
    cabfactos.FieldByName('ultimovenc').AsString  := utiles.sExprFecha2000(xvto2);
    cabfactos.FieldByName('importevto1').AsFloat  := (subtotal * xPorc1) / 100;
    cabfactos.FieldByName('importevto2').AsFloat  := (subtotal * xPorc2) / 100;
    cabfactos.FieldByName('total').AsFloat        := Montos[1];
    try
      cabfactos.Post
     except
      cabfactos.Cancel
    end;
    datosdb.refrescar(cabfactos);
  end;
  nLiq := '';

  if subtotal <> 0 then Begin
    Result := True;
    datosListadosFact := True;
  end else
    Result := False;
end;

procedure TTFacturacionCCB.ListarFacturacion(salida: Char);
// Objetivo...: Listar Facturación
begin

  if (salida = 'A') then begin
    list.m := 0;
    exit;
  end;

  if not datosListadosFact then Begin
    utiles.msgError(msgImpresion);
    if salida <> 'T' then list.Setear(salida);
  end else
    if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
end;

procedure TTFacturacionCCB.Exportar(xperiodo, xidprof, xprofesional: String; listOS: TStringList; xtodoslospacientes: Boolean);
// Objetivo...: Exportar datos para facturacion
var
  cabexpt, detexpt, idexpt, auditexpt, datosExport: TTable;
  lista1, lista2: TStringList;
begin
  attach := '';
  lista2 := TStringList.Create;
  if DireccionarLaboratorio(xperiodo, xidprof) then Begin // Activamos el directorio a Exportar
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work', '*.*', dbs.DirSistema + '\exportar');
    if DirectoryExists(dbs.DirSistema + '\work\factNBU') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\factNBU', '*.*', dbs.DirSistema + '\exportar');
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\auditoria', '*.*', dbs.DirSistema + '\exportar');
    if ExportarTotalesProfInscriptosIVA then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\totalesFactRI', '*.*', dbs.DirSistema + '\exportar');
    // Instanciamos las tablas a usar
    cabexpt := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\exportar');
    idexpt  := datosdb.openDB('idordenes', 'Periodo;Idprof', '', dbs.DirSistema + '\exportar');
    detexpt := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', dbs.DirSistema + '\exportar');
    if ExportarTotalesProfInscriptosIVA then totalesPROF := datosdb.openDB('totalesprof', '', '', dbs.DirSistema + '\exportar');
    // Vaciamos el contenido
    datosdb.tranSQL(dbs.DirSistema + '\exportar', 'DELETE FROM cabfact');
    datosdb.tranSQL(dbs.DirSistema + '\exportar', 'DELETE FROM detfact');
    datosdb.tranSQL(dbs.DirSistema + '\exportar', 'DELETE FROM idordenes');
    if ExportarTotalesProfInscriptosIVA then datosdb.tranSQL(dbs.DirSistema + '\exportar', 'DELETE FROM totalesPROF');
    // Iniciamos Nómina de Pacientes a Exportar
    paciente.IniciarExportacion(xidprof);
    // Copiamos los datos a exportar

    if (interbase = 'N') then begin

      cabfact.First; cabexpt.Open;
      while not cabfact.EOF do Begin
        if (cabfact.FieldByName('periodo').AsString = xperiodo) and (cabfact.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, cabfact.FieldByName('codos').AsString)) then Begin
          cabexpt.Append;
          cabexpt.FieldByName('periodo').AsString := cabfact.FieldByName('periodo').AsString;
          cabexpt.FieldByName('idprof').AsString  := cabfact.FieldByName('idprof').AsString;
          cabexpt.FieldByName('codos').AsString   := cabfact.FieldByName('codos').AsString;
          cabexpt.FieldByName('fecha').AsString   := cabfact.FieldByName('fecha').AsString;
          try
            cabexpt.Post
           except
            cabexpt.Cancel
          end;
        end;
        cabfact.Next;
      end;
      cabexpt.Close;

      detfact.First; detexpt.Open;
      while not detfact.EOF do Begin
        if (detfact.FieldByName('periodo').AsString = xperiodo) {and (detfact.FieldByName('orden').AsString < '5000')} and (detfact.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, detfact.FieldByName('codos').AsString)) then Begin
          nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);
          detexpt.Append;
          detexpt.FieldByName('periodo').AsString     := detfact.FieldByName('periodo').AsString;
          detexpt.FieldByName('idprof').AsString      := detfact.FieldByName('idprof').AsString;
          detexpt.FieldByName('codos').AsString       := detfact.FieldByName('codos').AsString;
          detexpt.FieldByName('items').AsString       := detfact.FieldByName('items').AsString;
          detexpt.FieldByName('orden').AsString       := detfact.FieldByName('orden').AsString;
          detexpt.FieldByName('codpac').AsString      := detfact.FieldByName('codpac').AsString;
          detexpt.FieldByName('nombre').AsString      := detfact.FieldByName('nombre').AsString;
          detexpt.FieldByName('ref1').AsString        := detfact.FieldByName('ref1').AsString;
          if Length(Trim(nomeclatura.codfact)) = 0 then detexpt.FieldByName('codanalisis').AsString := detfact.FieldByName('codanalisis').AsString else detexpt.FieldByName('codanalisis').AsString := nomeclatura.codfact;
          try
            detexpt.Post
           except
            detexpt.Cancel
          end;
          // Seleccionamos los Pacientes que tuvieron movimiento para Darlos de Alta
          if not utiles.verificarItemsLista(lista2, detfact.FieldByName('idprof').AsString + detfact.FieldByName('codpac').AsString) then Begin
            paciente.MarcarPacienteAExportar(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
            lista2.Add(detfact.FieldByName('idprof').AsString + detfact.FieldByName('codpac').AsString);
          end;
        end;
        detfact.Next;
      end;
      detexpt.Close;
      lista2.Destroy;

      idordenes.First; idexpt.Open;
      while not idordenes.EOF do Begin
        if (idordenes.FieldByName('periodo').AsString = xperiodo) and (idordenes.FieldByName('idprof').AsString = xidprof) then Begin
          idexpt.Append;
          idexpt.FieldByName('periodo').AsString := idordenes.FieldByName('periodo').AsString;
          idexpt.FieldByName('idprof').AsString  := idordenes.FieldByName('idprof').AsString;
          idexpt.FieldByName('orden').AsString   := idordenes.FieldByName('orden').AsString;
          try
            idexpt.Post
           except
            idexpt.Cancel
          end;
        end;
        idordenes.Next;
      end;
      idexpt.Close;

      // Exportamos los totales facturados Inscriptos en I.V.A.
      if ExportarTotalesProfInscriptosIVA then Begin
        lista1 := TStringList.Create;
        lista1.Add(xidprof);
        ListarResumenRetencionesIVA(xperiodo, '', lista1, listOS, 'N', True);
        datosdb.closeDB(totalesPROF);
        lista1.Destroy;
      end;

      cabexpt.Free; detexpt.Free; idexpt.Free;

      paciente.Exportar(xperiodo, xtodoslospacientes);

      // Exportamos Ordenes Auditadas
      directorio1 := dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + xidprof;
      if DirectoryExists(directorio1) then Begin
        SeleccionarLaboratorio_Auditoria(xperiodo, directorio1);
        if ordenes_audit <> Nil then Begin
          // Instanciamos las tablas a usar
          auditexpt := datosdb.openDB('ordenes_audit', '', '', dbs.DirSistema + '\exportar');
          // Vaciamos el contenido
          datosdb.tranSQL(dbs.DirSistema + '\exportar', 'DELETE FROM ordenes_audit');
          // Copiamos los datos a exportar
          ordenes_audit.First;
          while not ordenes_audit.Eof do Begin
            if datosdb.Buscar(auditexpt, 'periodo', 'items', 'idprof', ordenes_audit.FieldByName('periodo').AsString, ordenes_audit.FieldByName('items').AsString, ordenes_audit.FieldByName('idprof').AsString) then auditexpt.Edit else auditexpt.Append;
            auditexpt.FieldByName('periodo').AsString      := ordenes_audit.FieldByName('periodo').AsString;
            auditexpt.FieldByName('items').AsString        := ordenes_audit.FieldByName('items').AsString;
            auditexpt.FieldByName('idprof').AsString       := ordenes_audit.FieldByName('idprof').AsString;
            auditexpt.FieldByName('nroauditoria').AsString := ordenes_audit.FieldByName('nroauditoria').AsString;
            try
              auditexpt.Post
             except
              auditexpt.Cancel
            end;
            ordenes_audit.Next;
          end;

          auditexpt.Close; auditexpt.Free;
        end;
      end;

    end;

    if (interbase = 'S') then begin
      rsqlIB := ffirebird.getTransacSQL('select * from cabfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof =  ' + '''' + xidprof + '''');

      rsqlIB.Open; rsqlIB.First; cabexpt.open;
      while not rsqlIB.EOF do Begin
        if (rsqlIB.FieldByName('periodo').AsString = xperiodo) and (rsqlIB.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, rsqlIB.FieldByName('codos').AsString)) then Begin
          cabexpt.Append;
          cabexpt.FieldByName('periodo').AsString := rsqlIB.FieldByName('periodo').AsString;
          cabexpt.FieldByName('idprof').AsString  := rsqlIB.FieldByName('idprof').AsString;
          cabexpt.FieldByName('codos').AsString   := rsqlIB.FieldByName('codos').AsString;
          cabexpt.FieldByName('fecha').AsString   := rsqlIB.FieldByName('fecha').AsString;
          try
            cabexpt.Post
           except
            cabexpt.Cancel
          end;
        end;
        rsqlIB.Next;
      end;
      cabexpt.Close;

      rsqlIB.Close; rsqlIB.Free;

      rsqlIB := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof =  ' + '''' + xidprof + '''');

      rsqlIB.Open; rsqlIB.First; detexpt.open;
      while not rsqlIB.EOF do Begin
        if (rsqlIB.FieldByName('periodo').AsString = xperiodo) and ((rsqlIB.FieldByName('orden').AsString < '5000') or (copy(rsqlIB.FieldByName('orden').AsString,1,1) = 'R')) and (rsqlIB.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, rsqlIB.FieldByName('codos').AsString)) then Begin
          nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
          detexpt.Append;
          detexpt.FieldByName('periodo').AsString     := rsqlIB.FieldByName('periodo').AsString;
          detexpt.FieldByName('idprof').AsString      := rsqlIB.FieldByName('idprof').AsString;
          detexpt.FieldByName('codos').AsString       := rsqlIB.FieldByName('codos').AsString;
          detexpt.FieldByName('items').AsString       := rsqlIB.FieldByName('items').AsString;
          detexpt.FieldByName('orden').AsString       := rsqlIB.FieldByName('orden').AsString;
          detexpt.FieldByName('codpac').AsString      := rsqlIB.FieldByName('codpac').AsString;
          detexpt.FieldByName('nombre').AsString      := rsqlIB.FieldByName('nombre').AsString;
          detexpt.FieldByName('ref1').AsString        := rsqlIB.FieldByName('ref1').AsString;
          detexpt.FieldByName('osiva').AsString       := rsqlIB.FieldByName('osiva').AsString;
          detexpt.FieldByName('profiva').AsString     := rsqlIB.FieldByName('profiva').AsString;
          detexpt.FieldByName('retiva').AsString      := rsqlIB.FieldByName('retiva').AsString;
          if Length(Trim(nomeclatura.codfact)) = 0 then detexpt.FieldByName('codanalisis').AsString := rsqlIB.FieldByName('codanalisis').AsString else detexpt.FieldByName('codanalisis').AsString := nomeclatura.codfact;
          try
            detexpt.Post
           except
            detexpt.Cancel
          end;
          // Seleccionamos los Pacientes que tuvieron movimiento para Darlos de Alta
          if not utiles.verificarItemsLista(lista2, rsqlIB.FieldByName('idprof').AsString + rsqlIB.FieldByName('codpac').AsString) then Begin
            paciente.MarcarPacienteAExportar(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);
            lista2.Add(rsqlIB.FieldByName('idprof').AsString + rsqlIB.FieldByName('codpac').AsString);
          end;
        end;
        rsqlIB.Next;
      end;
      detexpt.Close;
      lista2.Destroy;

      rsqlIB.close; rsqlIB.free;

      rsqlIB := ffirebird.getTransacSQL('select * from idordenes where periodo = ' + '''' + xperiodo + '''' + ' and idprof =  ' + '''' + xidprof + '''');

      rsqlIB.Open; rsqlIB.First; idexpt.Open;
      while not rsqlIB.EOF do Begin
        if (rsqlIB.FieldByName('periodo').AsString = xperiodo) and (rsqlIB.FieldByName('idprof').AsString = xidprof) then Begin
          idexpt.Append;
          idexpt.FieldByName('periodo').AsString := rsqlIB.FieldByName('periodo').AsString;
          idexpt.FieldByName('idprof').AsString  := rsqlIB.FieldByName('idprof').AsString;
          idexpt.FieldByName('orden').AsString   := rsqlIB.FieldByName('orden').AsString;
          try
            idexpt.Post
           except
            idexpt.Cancel
          end;
        end;
        rsqlIB.Next;
      end;
      idexpt.Close;

      rsqlIB.Close; rsqlIB.Free;

      // Exportamos los totales facturados Inscriptos en I.V.A.
      if ExportarTotalesProfInscriptosIVA then Begin
        lista1 := TStringList.Create;
        lista1.Add(xidprof);
        ListarResumenRetencionesIVA(xperiodo, '', lista1, listOS, 'N', True);
        datosdb.closeDB(totalesPROF);
        lista1.Destroy;

        // Exportamos totales
        // 29/04/2014
        totalesPROF := datosdb.openDB('totalesprof', '', '', dbs.DirSistema + '\exportar');
        totalesPROF.Open;
        datosdb.tranSQL(dbs.DirSistema + '\exportar', 'delete from totalesprof where periodo = ' + '''' + xperiodo + '''' + ' and idprof =  ' + '''' + xidprof + '''');
        rsql := datosdb.tranSQL(DBConexion, 'select * from totalesprof where periodo = ' + '''' + xperiodo + '''' + ' and idprof =  ' + '''' + xidprof + '''');
        rsql.Open;
        while not rsql.eof do begin
          totalesPROF.Append;
          totalesPROF.FieldByName('periodo').AsString := rsql.FieldByName('periodo').AsString;
          totalesPROF.FieldByName('idprof').AsString := rsql.FieldByName('idprof').AsString;
          totalesPROF.FieldByName('nombre').AsString := rsql.FieldByName('nombre').AsString;
          totalesPROF.FieldByName('codos').AsString := rsql.FieldByName('codos').AsString;
          totalesPROF.FieldByName('monto').AsString := rsql.FieldByName('monto').AsString;
          totalesPROF.FieldByName('neto').AsString := rsql.FieldByName('neto').AsString;
          totalesPROF.FieldByName('retencion').AsString := rsql.FieldByName('retencion').AsString;
          totalesPROF.FieldByName('ug').AsString := rsql.FieldByName('ug').AsString;
          totalesPROF.FieldByName('ub').AsString := rsql.FieldByName('ub').AsString;
          totalesPROF.FieldByName('caran').AsString := rsql.FieldByName('caran').AsString;
          totalesPROF.FieldByName('gravado').AsString := rsql.FieldByName('gravado').AsString;
          totalesPROF.FieldByName('iva').AsString := rsql.FieldByName('iva').AsString;
          totalesPROF.FieldByName('exento').AsString := rsql.FieldByName('exento').AsString;
          try
            totalesPROF.Post
          except
            totalesPROF.Cancel
          end;
          rsql.Next;
        end;
        rsql.Close; rsql.Free;
        datosdb.closeDB(totalesPROF);
      end;

      cabexpt.Free; detexpt.Free; idexpt.Free;

      paciente.Exportar(xperiodo, xtodoslospacientes);

      // Exportamos Ordenes Auditadas
      directorio1 := dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + xidprof;
      if DirectoryExists(directorio1) then Begin
        SeleccionarLaboratorio_Auditoria(xperiodo, directorio1);
        if ordenes_audit <> Nil then Begin
          // Instanciamos las tablas a usar
          auditexpt := datosdb.openDB('ordenes_audit', '', '', dbs.DirSistema + '\exportar');
          // Vaciamos el contenido
          datosdb.tranSQL(dbs.DirSistema + '\exportar', 'DELETE FROM ordenes_audit');
          // Copiamos los datos a exportar

          rsqlIB := ffirebird.getTransacSQL('select * from ordenes_audit where periodo = ' + '''' + xperiodo + '''');

          rsqlIB.open; rsqlIB.First;
          while not rsqlIB.Eof do Begin
            if datosdb.Buscar(auditexpt, 'periodo', 'items', 'idprof', rsqlIB.FieldByName('periodo').AsString, rsqlIB.FieldByName('items').AsString, rsqlIB.FieldByName('idprof').AsString) then auditexpt.Edit else auditexpt.Append;
            auditexpt.FieldByName('periodo').AsString      := rsqlIB.FieldByName('periodo').AsString;
            auditexpt.FieldByName('items').AsString        := rsqlIB.FieldByName('items').AsString;
            auditexpt.FieldByName('idprof').AsString       := rsqlIB.FieldByName('idprof').AsString;
            auditexpt.FieldByName('nroauditoria').AsString := rsqlIB.FieldByName('nroauditoria').AsString;
            try
              auditexpt.Post
             except
              auditexpt.Cancel
            end;
            rsqlIB.Next;
          end;

          auditexpt.Close; auditexpt.Free;

          rsqlIB.close; rsqlIB.free;
        end;
      end;

    end;

    // Compactamos los datos
    utilesarchivos.BorrarArchivo(dbs.DirSistema + '\exportar\attach\' + xidprof + '.bck');
    utilesarchivos.CompactarArchivos(dbs.DirSistema + '\exportar\*.*', dbs.dirSistema + '\exportar\attach\' + xidprof + '.bck');
    attach := dbs.DirSistema + '\exportar\attach\' + xidprof + '.bck';

    // Guardamos la referencia
    datosExport := datosdb.openDB('datosexportados', '', '', DBConexion);
    datosExport.Open;
    if not datosdb.Buscar(datosExport, 'periodo', 'idprof', xperiodo, xidprof) then datosExport.Append else datosExport.Edit;
    datosExport.FieldByName('periodo').AsString    := xperiodo;
    datosExport.FieldByName('idprof').AsString     := xidprof;
    datosExport.FieldByName('nombre').AsString     := xprofesional;
    datosExport.FieldByName('fechahora').AsString  := FormatDateTime('dd/mm/yy hh:mm:ss', Now);
    datosExport.FieldByName('directorio').AsString := diractual;
    datosExport.FieldByName('modo').AsString       := 'E';
    datosExport.FieldByName('usuario').AsString    := usuario.alias;
    try
      datosExport.Post
     except
      datosExport.Cancel
    end;
    datosdb.closeDB(datosExport);
  end else
    utiles.msgError('El Laboratorio ' + xprofesional + ',' + CHR(13) + 'No tiene Operaciones Registradas ...!');
end;

procedure TTFacturacionCCB.CopiarDatosExportados(xdrive: String);
// Objetivo...: Copiar Datos Exportados
begin
  if xdrive <> '0' then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar\attach', '*.bck', xdrive);
  utilesarchivos.BorrarArchivos(dbs.DirSistema + '\exportar\attach', '*.bck');
end;

function TTFacturacionCCB.setDatosExportados(xperiodo: String): TQuery;
// Objetivo...: devolver un set con los registros exportados
begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM datosexportados WHERE periodo = ' + '"' + xperiodo + '"');
end;

function TTFacturacionCCB.setDatosExport(xperiodo: String): TQuery;
// Objetivo...: devolver un set con los registros exportados, marcados como exportar
begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM datosexportados WHERE periodo = ' + '"' + xperiodo + '"' + ' AND modo = ' + '"' + 'E' + '"');
end;

function TTFacturacionCCB.setDatosIngresados(xperiodo: String): TQuery;
// Objetivo...: devolver un set con los registros ingresados manualmente
begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM datosexportados WHERE periodo = ' + '"' + xperiodo + '"' + ' AND modo = ' + '"' + 'M' + '"');
end;

procedure TTFacturacionCCB.Importar(xperiodo, xidlab, xlaboratorio, xdrive: String);
// Objetivos...: Importar datos de Laboratorios, descompactamos los datos en el disco
var
  directorio, p, l: String;
  DirInfo: TSearchRec; r: Integer; t, j, z: Integer;
begin
  For j := 1 to elementos+5 do Begin
    dirlab[j] := ''; listlab[j] := '';
  end;
  cantidad := 0; j := 0;
  r := FindFirst(xdrive + '\*.bck', FaAnyfile, DirInfo);
  while r = 0 do  begin   // Restauramos todos los buckups
    Inc(cantidad);
    t := pos('.', pChar(DirInfo.Name));
    l := Copy(pChar(DirInfo.Name), 1, t-1);
    // Creamos Via de trabajo
    p := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);

    repeat
      directorio := dbs.DirSistema + '\temp\' + p + '\import_' + Trim(IntToStr(Random(999999)));
    until not DirectoryExists(directorio);

    if directorio = diractual then utiles.msgError('El Laboratorio ' + Copy(pChar(DirInfo.Name), 1, t-1) + ' esta en uso, la Operación fue Rechazada ...!') else Begin
      utilesarchivos.CrearDirectorio(dbs.DirSistema + '\temp\' + p);
      utilesarchivos.CrearDirectorio(directorio);
      utilesarchivos.CrearDirectorio(directorio + '\compact');
      utilesarchivos.CopiarArchivos(xdrive, l + '.bck', directorio + '\compact');
      // Descompactamos los datos
      Application.CreateForm(TfmBackup, fmBackup);
      fmBackup.DirectoryListBox1.Directory := directorio + '\compact';
      fmBackup.FileListBox1.ItemIndex := 0;
      fmBackup.FileListBox1Click(nil);   // Cargamos los datos del archivo
      fmBackup.rbOtherPath.Checked := True;
      fmBackup.EdPath.Text         := directorio;
      fmBackup.OcultarMensaje      := True;
      fmBackup.Button3Click(Self);
      fmBackup.Release; fmBackup := nil;
      Application.CreateForm(TfmBackup, fmBackup);
      fmBackup.DirectoryListBox1.Directory := directorio + '\compact';
      fmBackup.FileListBox1.ItemIndex := 0;
      fmBackup.FileListBox1Click(nil);   // Cargamos los datos del archivo
      fmBackup.rbOtherPath.Checked := True;
      fmBackup.EdPath.Text         := directorio;
      fmBackup.OcultarMensaje      := True;
      fmBackup.Button3Click(Self);
      fmBackup.Release; fmBackup := nil;
      Inc(j);
      listlab[j] := l; dirlab[j] := directorio;
    end;
    r := FindNext(DirInfo);
  end;
end;

function TTFacturacionCCB.setDirectorioImportacion: String;
// Objetivo... Devolver via de exportacion
Begin
  Result := dbs.DirSistema + '\attach\';
end;

function TTFacturacionCCB.setObrasSocialesImportadas(xidprof: String): TQuery;
// Objetivo...: Devolver la Nómina de Obras Sociales Importadas por cada laboratorio
var
  i: Integer;
Begin
  i := utiles.ObtenerItemsEnLista(listLab, xidprof);
  if i > -1 then Result := datosdb.tranSQL(dirlab[i], 'SELECT codos, idprof FROM cabfact ORDER BY codos') else Result := nil;
end;

function TTFacturacionCCB.setObrasSocialesImportadasIB(xidprof: String): TIBQuery;
// Objetivo...: Devolver la Nómina de Obras Sociales Importadas por cada laboratorio
Begin
  if (ffirebird <> Nil) then Result := ffirebird.getTransacSQL('SELECT codos, idprof FROM cabfact ORDER BY codos') else Result := nil;
end;

procedure TTFacturacionCCB.TransferirDatosImportados(xperiodo, xidprof: String; listOS: TStringList);
// Objetivo...: Transferir los Movimientos de las Obras Sociales y los profesionales Seleccionados

var
  i, j, k: Integer; no_importar, totpr, transnbu, _noimport, fieldref1, __iniciar, fieldretiva: Boolean;
  cabexpt, detexpt, idexpt, auditexpt, totprof: TTable;
  codnbu, ordenanter, ref1, retiva: String;
  r, t, rs, rss: TQuery;
  rsql: TIBQuery;
  m: array[1..5000, 1..10] of String;
  lista1: TStringList;

  //----------------------------------------------------------------------------
  procedure InsertarCodigo(xitems: Integer);
  var
    cons: TQuery;
    it: Integer;
  Begin
    if (interbase = 'N') then begin
      cons := nbu.setCodigos('I');
      cons.Open;
      it   := xitems;
      while not cons.Eof do Begin
        Inc(it);
        detfact.Append;
        detfact.FieldByName('periodo').AsString     := m[1, 1];
        detfact.FieldByName('idprof').AsString      := m[1, 2];
        detfact.FieldByName('codos').AsString       := m[1, 3];
        detfact.FieldByName('items').AsString       := utiles.sLlenarIzquierda(IntToStr(it), 3, '0');
        detfact.FieldByName('orden').AsString       := m[1, 5];
        detfact.FieldByName('codpac').AsString      := m[1, 6];
        detfact.FieldByName('nombre').AsString      := m[1, 7];
        detfact.FieldByName('codanalisis').AsString := cons.FieldByName('codigo').AsString;
        try
          detfact.Post
         except
          detfact.Cancel
        end;

        cons.Next;
      end;
      cons.Close; cons.Free;
    end;

    if (interbase = 'S') then begin
      cons := nbu.setCodigos('I');
      cons.Open;
      it   := xitems;
      while not cons.Eof do Begin
        Inc(it);
        lote.Add('delete from detfact where periodo = ' + '''' + m[1, 1] + '''' + ' and idprof = ' + '''' + m[1, 2] + '''' + ' and codos = ' + '''' + m[1, 3] + '''' + ' and items = ' + '''' + utiles.sLlenarIzquierda(IntToStr(it), 3, '0') + '''');
        lote.Add('insert into detfact (periodo, idprof, codos, items, orden, codpac, nombre, codanalisis, ref1, osiva, retiva, profiva) values (' +
                '''' + m[1, 1] + '''' + ', ' +
                '''' + m[1, 2] + '''' + ', ' +
                '''' + m[1, 3] + '''' + ', ' +
                '''' + utiles.sLlenarIzquierda(IntToStr(it), 3, '0') + '''' + ', ' +
                '''' + m[1, 5] + '''' + ', ' +
                '''' + m[1, 6] + '''' + ', ' +
                QuotedStr(m[1, 7]) + ', ' +
                '''' + cons.FieldByName('codigo').AsString + '''' + ', ' +
                '''' + ref1 + '''' + ', ' +
                '''' + obsocial.Retieneiva + '''' + ', ' +
                '''' + retiva + '''' + ', ' +
                '''' + profesional.Retieneiva + '''' + ')'
                );

        cons.Next;
      end;
      cons.Close; cons.Free;
    end;
  end;
  //----------------------------------------------------------------------------

Begin
  firebird.getModulo('facturacion');
  if (length(trim(firebird.Dir_Remoto)) = 0) then interbase := 'N';

  if profesional.Buscar(xidprof) and (interbase = 'N') then Begin
    i := utiles.ObtenerItemsEnLista(listLab, xidprof);
    if i < 1 then utiles.msgError('El Laboratorio No está dado de Alta, Operación Rechazada ...!') else Begin
    LaboratorioActual := ''; codosanter := ''; no_importar := True;
    PrepararDirectorio(xperiodo, xidprof);  // Activamos el directorio a Importar
    PrepararDirectorio_OrdenesAuditadas(xperiodo, xidprof);  // Directorio a Importar Ordenes Auditoria
    // Instanciamos las tablas a usar
    cabexpt := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', dirlab[i]);
    idexpt  := datosdb.openDB('idordenes', 'Periodo;Idprof', '', dirlab[i]);
    detexpt := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', dirlab[i]);
    if FileExists(dirlab[i] + '\totalesprof.db') then Begin
      totprof := datosdb.openDB('totalesprof', '', '', dirlab[i]);
      totpr   := True;
    end;

    lista1 := TStringList.Create;

    datosdb.tranSQL(directorio, 'DELETE FROM cabfact');
    cabexpt.Open;
    while not cabexpt.EOF do Begin
      _noimport := False;
      if (obsocial.Buscar(cabexpt.FieldByName('codos').AsString)) then begin
        obsocial.getDatos(cabexpt.FieldByName('codos').AsString); // Excluimos las Obras Sociales Capitadas que no se Importan
        if obsocial.NoImporta = 'N' then no_importar := False;    // Flag para Determinar si se Incorporan las ordenes de Auditoria
        if (cabexpt.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, cabexpt.FieldByName('codos').AsString)) and (obsocial.NoImporta <> 'N') then Begin          if Buscar(xperiodo, cabexpt.FieldByName('idprof').AsString, cabexpt.FieldByName('codos').AsString) then cabfact.Edit else Begin
            datosdb.tranSQL(directorio, 'DELETE FROM detfact WHERE codos = ' + '"' + cabexpt.FieldByName('codos').AsString + '"' + ' and orden < ' + '"' + '5000' + '"');
            cabfact.Append;
          end;
          cabfact.FieldByName('periodo').AsString := xperiodo; // cabexpt.FieldByName('periodo').AsString;
          cabfact.FieldByName('idprof').AsString  := cabexpt.FieldByName('idprof').AsString;
          cabfact.FieldByName('codos').AsString   := cabexpt.FieldByName('codos').AsString;
          cabfact.FieldByName('fecha').AsString   := cabexpt.FieldByName('fecha').AsString;
          try
            cabfact.Post
           except
            cabfact.Cancel
          end;
          _noimport := True;
        end;
      end;
      cabexpt.Next;
    end;
    cabexpt.Close; cabexpt.Free;
    datosdb.refrescar(cabfact);

    detexpt.Open; idanter := '';
    fieldref1 := datosdb.verificarSiExisteCampo(detexpt, 'ref1');
    while not detexpt.EOF do Begin
      if detexpt.FieldByName('codos').AsString <> idanter then Begin    // Excluimos las Obras Sociales Capitadas que no se Importan
        obsocial.getDatos(detexpt.FieldByName('codos').AsString);
        idanter := detexpt.FieldByName('codos').AsString;
      end;
      if (obsocial.Buscar(detexpt.FieldByName('codos').AsString)) then begin
        if (detexpt.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, detexpt.FieldByName('codos').AsString)) and (obsocial.NoImporta <> 'N') then Begin
          if datosdb.Buscar(detfact, 'periodo', 'idprof', 'codos', 'items', 'orden', xperiodo, detexpt.FieldByName('idprof').AsString, detexpt.FieldByName('codos').AsString, detexpt.FieldByName('items').AsString, detexpt.FieldByName('orden').AsString) then detfact.Edit else detfact.Append;
          detfact.FieldByName('periodo').AsString     := xperiodo; // detexpt.FieldByName('periodo').AsString;
          detfact.FieldByName('idprof').AsString      := detexpt.FieldByName('idprof').AsString;
          detfact.FieldByName('codos').AsString       := detexpt.FieldByName('codos').AsString;
          detfact.FieldByName('items').AsString       := detexpt.FieldByName('items').AsString;
          detfact.FieldByName('orden').AsString       := detexpt.FieldByName('orden').AsString;
          detfact.FieldByName('codpac').AsString      := detexpt.FieldByName('codpac').AsString;
          detfact.FieldByName('nombre').AsString      := detexpt.FieldByName('nombre').AsString;
          detfact.FieldByName('codanalisis').AsString := detexpt.FieldByName('codanalisis').AsString;
          if (fieldref1) then
            detfact.FieldByName('ref1').AsString        := detexpt.FieldByName('ref1').AsString;
          try
            detfact.Post
           except
            detfact.Cancel
          end;
        end;

        // Aislamos los pacientes con movimientos para Importarlos
        if (not utiles.verificarItemsLista(lista1, detexpt.FieldByName('idprof').AsString + detexpt.FieldByName('codpac').AsString)) or (lista1.Count = 0) then lista1.Add(detexpt.FieldByName('idprof').AsString + detexpt.FieldByName('codpac').AsString);
      end;
      detexpt.Next;
    end;

    //--------------------------------------------------------------------------
    // Transferencia/Conversión de Datos al Sistema NBU

    if not (cabfact.Active) then cabfact.Open;
    cabfact.First;
    while not cabfact.Eof do Begin
      obsocial.getDatos(cabfact.FieldByName('codos').AsString);
      obsocial.SincronizarArancelNBU(cabfact.FieldByName('codos').AsString, cabfact.FieldByName('periodo').AsString);
      if obsocial.FactNBU = 'S' then Begin

        transnbu := False;
        datosdb.Filtrar(detfact, 'codos = ' + '''' + cabfact.FieldByName('codos').AsString + '''');
        detfact.First;
        while not detfact.Eof do Begin
          if Length(Trim(detfact.FieldByName('codanalisis').AsString)) < 6 then Begin
            transnbu := True;
            if nbu.BuscarCodigoNNN(detfact.FieldByName('codanalisis').AsString) then codnbu := nbu.setCodigoNBU(detfact.FieldByName('codanalisis').AsString) else
              codnbu := detfact.FieldByName('codanalisis').AsString;
            detfact.Edit;
            detfact.FieldByName('codanalisis').AsString := codnbu;
            try
              detfact.Post
             except
              detfact.Cancel
            end;
          end;
          detfact.Next;
        end;

        // Ahora borramos los códigos excluidos
        r := nbu.setCodigos('E');
        r.Open;
        while not r.Eof do Begin
          datosdb.tranSQL(detfact.DatabaseName, 'delete from detfact where codanalisis = ' + '''' + r.FieldByName('codigo').AsString + '''' + ' and codos = ' + '''' + cabfact.FieldByName('codos').AsString + '''');
          r.Next;
        end;
        r.Close; r.Free;

        r := datosdb.tranSQL(detfact.DatabaseName, 'select * from detfact where codos = ' + '''' + cabfact.FieldByName('codos').AsString + '''' + ' order by orden, items');
        r.Open; j := 0;
        while not r.Eof do Begin
          if r.FieldByName('orden').AsString <> ordenanter then Begin
            k := 0;
            ordenanter := r.FieldByName('orden').AsString;
          end;

          Inc(j);
          Inc(k);
          m[j, 1] := xperiodo; //r.FieldByName('periodo').AsString;
          m[j, 2] := r.FieldByName('idprof').AsString;
          m[j, 3] := r.FieldByName('codos').AsString;
          m[j, 4] := utiles.sLlenarIzquierda(IntToStr(k), 3, '0');
          m[j, 5] := r.FieldByName('orden').AsString;
          m[j, 6] := r.FieldByName('codpac').AsString;
          m[j, 7] := r.FieldByName('nombre').AsString;
          m[j, 8] := r.FieldByName('codanalisis').AsString;

          r.Next;
        end;
        r.Close; r.Free;

        datosdb.tranSQL(detfact.DatabaseName, 'delete from detfact where codos = ' + '''' + cabfact.FieldByName('codos').AsString + '''');
        datosdb.QuitarFiltro(detfact);

        For k := 1 to j do Begin
          detfact.Append;
          detfact.FieldByName('periodo').AsString     := m[k, 1];
          detfact.FieldByName('idprof').AsString      := m[k, 2];
          detfact.FieldByName('codos').AsString       := m[k, 3];
          detfact.FieldByName('items').AsString       := m[k, 4];
          detfact.FieldByName('orden').AsString       := m[k, 5];
          detfact.FieldByName('codpac').AsString      := m[k, 6];
          detfact.FieldByName('nombre').AsString      := m[k, 7];
          detfact.FieldByName('codanalisis').AsString := m[k, 8];
          try
            detfact.Post
           except
            detfact.Cancel
          end;
        end;

        // Incorporamos los códigos incluidos
        if transnbu then Begin
          t := datosdb.tranSQL(detfact.DatabaseName, 'select * from detfact where codos = ' + '''' + cabfact.FieldByName('codos').AsString + '''' + ' order by codos, orden, items');
          t.Open;
          ordenanter := t.FieldByName('orden').AsString;
          while not t.Eof do Begin
            if t.FieldByName('orden').AsString <> ordenanter then Begin
              InsertarCodigo(k);
              ordenanter := t.FieldByName('orden').AsString;
            end;
            k       := t.FieldByName('items').AsInteger;
            m[1, 1] := xperiodo; //t.FieldByName('periodo').AsString;
            m[1, 2] := t.FieldByName('idprof').AsString;
            m[1, 3] := t.FieldByName('codos').AsString;
            m[1, 4] := '';
            m[1, 5] := t.FieldByName('orden').AsString;
            m[1, 6] := t.FieldByName('codpac').AsString;
            m[1, 7] := t.FieldByName('nombre').AsString;
            m[1, 8] := t.FieldByName('codanalisis').AsString;
            t.Next;
          end;

          InsertarCodigo(k);
          t.Close; t.Free;

        end;

      end;
      cabfact.Next;
    end;

    //--------------------------------------------------------------------------

    detexpt.Close; detexpt.Free;
    datosdb.refrescar(detfact);

    idexpt.Open;
    while not idexpt.EOF do Begin
      if (idexpt.FieldByName('idprof').AsString = xidprof) and (_noimport) then Begin
        if datosdb.Buscar(idordenes, 'Periodo', 'Idprof', xperiodo, idexpt.FieldByName('idprof').AsString) then idordenes.Edit else idordenes.Append;
        idordenes.FieldByName('periodo').AsString := xperiodo; //idexpt.FieldByName('periodo').AsString;
        idordenes.FieldByName('idprof').AsString  := idexpt.FieldByName('idprof').AsString;
        idordenes.FieldByName('orden').AsString   := idexpt.FieldByName('orden').AsString;
        try
          idordenes.Post
         except
          idordenes.Cancel
        end;
      end;
      idexpt.Next;
    end;
    idexpt.Close; idexpt.Free;
    datosdb.refrescar(idordenes);

    datosdb.closeDB(cabfact);  datosdb.closeDB(detfact);  datosdb.closeDB(idordenes);

    paciente.Importar(xidprof, dirlab[i], lista1);
    lista1.Clear;

    profesional.getDatos(xidprof);
    profesional.SincronizarCategoria(xidprof, xperiodo);
    GuardarRefDatosImportados(xperiodo, xidprof, profesional.nombre, directorio, 'I');

    // Transferimos ordenes Auditadas
    if FileExists(dirlab[i] + '\ordenes_audit.db') then Begin    // Si el modulo incluye Facturación de Ordenes Auditadas
      if no_importar then Begin
        auditexpt := datosdb.openDB('ordenes_audit', '', '', dirlab[i]);
        auditexpt.Open;
        while not auditexpt.Eof do Begin
          if datosdb.Buscar(ordenes_audit, 'periodo', 'items', 'idprof', xperiodo, auditexpt.FieldByName('items').AsString, auditexpt.FieldByName('idprof').AsString) then ordenes_audit.Edit else ordenes_audit.Append;
          ordenes_audit.FieldByName('periodo').AsString      := xperiodo; // auditexpt.FieldByName('periodo').AsString;
          ordenes_audit.FieldByName('idprof').AsString       := auditexpt.FieldByName('idprof').AsString;
          ordenes_audit.FieldByName('items').AsString        := auditexpt.FieldByName('items').AsString;
          ordenes_audit.FieldByName('nroauditoria').AsString := auditexpt.FieldByName('nroauditoria').AsString;
          try
            ordenes_audit.Post
           except
            ordenes_audit.Cancel
          end;
          auditexpt.Next;
        end;
        auditexpt.Close; auditexpt.Free;
        datosdb.refrescar(auditexpt);
      end;
    end;

    // Transferimos totales profesionales responsables inscriptos
    profesional.getDatos(xidprof);
    profesional.SincronizarListaRetIVA(xperiodo, xidprof);

    if profesional.Retieneiva = 'S' then Begin
      if totpr then Begin
        if dbs.BaseClientServ = 'S' then totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.baseDat) else totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\archdat');
        totalesPROF.Open;
        testeartotalesprof;
        totprof.Open;
        while not totprof.Eof do Begin
          if (obsocial.Buscar(totalesprof.FieldByName('codos').AsString)) then begin
            if datosdb.Buscar(totalesprof, 'periodo', 'idprof', 'codos', xperiodo, totprof.FieldByName('idprof').AsString, totprof.FieldByName('codos').AsString) then totalesprof.Edit else totalesprof.Append;
            totalesprof.FieldByName('periodo').AsString  := xperiodo; // totprof.FieldByName('periodo').AsString;
            totalesprof.FieldByName('idprof').AsString   := totprof.FieldByName('idprof').AsString;
            totalesprof.FieldByName('codos').AsString    := totprof.FieldByName('codos').AsString;
            totalesprof.FieldByName('nombre').AsString   := totprof.FieldByName('nombre').AsString;
            totalesprof.FieldByName('monto').AsFloat     := totprof.FieldByName('monto').AsFloat;
            totalesprof.FieldByName('neto').AsFloat      := totprof.FieldByName('neto').AsFloat;
            totalesprof.FieldByName('retencion').AsFloat := totprof.FieldByName('retencion').AsFloat;
            totalesprof.FieldByName('ug').AsFloat        := totprof.FieldByName('ug').AsFloat;
            totalesprof.FieldByName('ub').AsFloat        := totprof.FieldByName('ub').AsFloat;
            totalesprof.FieldByName('caran').AsFloat     := totprof.FieldByName('caran').AsFloat;
            totalesprof.FieldByName('codfact').AsString  := totprof.FieldByName('codfact').AsString;
            totalesprof.FieldByName('tipoing').AsInteger := 2;
            try
              totalesprof.Post
             except
              totalesprof.Cancel
            end;
          end;
          totprof.Next;
        end;

        datosdb.closeDB(totprof); datosdb.closeDB(totalesPROF);
      end;
     end;
    end;

    LaboratorioActual := '';
  End;

  if (profesional.Buscar(xidprof)) and (interbase = 'S') then Begin
    InstanciarTablas('S');
    i := utiles.ObtenerItemsEnLista(listLab, xidprof);
    if i < 1 then utiles.msgError('El Laboratorio No está dado de Alta, Operación Rechazada ...!') else Begin
    LaboratorioActual := ''; codosanter := ''; no_importar := True;
    // Instanciamos las tablas a usar

    cabexpt := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', dirlab[i]);
    idexpt  := datosdb.openDB('idordenes', 'Periodo;Idprof', '', dirlab[i]);
    detexpt := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', dirlab[i]);
    if FileExists(dirlab[i] + '\totalesprof.db') then Begin
      totprof := datosdb.openDB('totalesprof', '', '', dirlab[i]);
      totpr   := True;
    end;

    profesional.getDatos(xidprof);

    lista1 := TStringList.Create;

    {cabexpt.Open;
    while not cabexpt.EOF do Begin
      _noimport := False;
      if (utiles.verificarItemsLista(listOS, cabexpt.FieldByName('codos').AsString)) then begin
        if (obsocial.Buscar(cabexpt.FieldByName('codos').AsString)) then begin
          obsocial.getDatos(cabexpt.FieldByName('codos').AsString); // Excluimos las Obras Sociales Capitadas que no se Importan
          if obsocial.NoImporta = 'N' then no_importar := False;    // Flag para Determinar si se Incorporan las ordenes de Auditoria
          if (cabexpt.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, cabexpt.FieldByName('codos').AsString)) and (obsocial.NoImporta <> 'N') then Begin
            if Buscar(xperiodo, cabexpt.FieldByName('idprof').AsString, cabexpt.FieldByName('codos').AsString) then cabfactIB.Edit else Begin
              ffirebird.TransacSQL('DELETE FROM detfact WHERE codos = ' + '''' + cabexpt.FieldByName('codos').AsString + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and orden < ' + '''' + '5000' + '''' + ' AND periodo = ' + '''' + xperiodo + '''');
              cabfactIB.Append;
            end;
            cabfactIB.FieldByName('periodo').AsString := xperiodo; // cabexpt.FieldByName('periodo').AsString;
            cabfactIB.FieldByName('idprof').AsString  := cabexpt.FieldByName('idprof').AsString;
            cabfactIB.FieldByName('codos').AsString   := cabexpt.FieldByName('codos').AsString;
            cabfactIB.FieldByName('fecha').AsString   := cabexpt.FieldByName('fecha').AsString;
            try
              cabfactIB.Post
             except
              cabfactIB.Cancel
            end;
            _noimport := True;

          end;
        end;
      end;
      cabexpt.Next;
    end;

    ffirebird.RegistrarTransaccion(cabfactIB);
    cabfactIB.Close; cabfactIB.Open;
    cabexpt.Close; cabexpt.Free;

    detexpt.Open; idanter := '';
    fieldref1 := datosdb.verificarSiExisteCampo(detexpt, 'ref1');
    while not detexpt.EOF do Begin
      if (utiles.verificarItemsLista(listOS, detexpt.FieldByName('codos').AsString)) then begin
      if detexpt.FieldByName('codos').AsString <> idanter then Begin    // Excluimos las Obras Sociales Capitadas que no se Importan
        obsocial.getDatos(detexpt.FieldByName('codos').AsString);
        idanter := detexpt.FieldByName('codos').AsString;
      end;
      if (obsocial.Buscar(detexpt.FieldByName('codos').AsString)) then begin
        if (detexpt.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, detexpt.FieldByName('codos').AsString)) and (obsocial.NoImporta <> 'N') then Begin
          if not (detfactIB.Active) then detfactIB.Open;
          //if ffirebird.Buscar(detfactIB, 'periodo;idprof;codos;items;orden', xperiodo, detexpt.FieldByName('idprof').AsString, detexpt.FieldByName('codos').AsString, detexpt.FieldByName('items').AsString, detexpt.FieldByName('orden').AsString) then detfactIB.Edit else detfactIB.Append;
          detfactIB.Append;
          detfactIB.FieldByName('periodo').AsString     := xperiodo; // detexpt.FieldByName('periodo').AsString;
          detfactIB.FieldByName('idprof').AsString      := detexpt.FieldByName('idprof').AsString;
          detfactIB.FieldByName('codos').AsString       := detexpt.FieldByName('codos').AsString;
          detfactIB.FieldByName('items').AsString       := detexpt.FieldByName('items').AsString;
          detfactIB.FieldByName('orden').AsString       := detexpt.FieldByName('orden').AsString;
          detfactIB.FieldByName('codpac').AsString      := detexpt.FieldByName('codpac').AsString;
          detfactIB.FieldByName('nombre').AsString      := detexpt.FieldByName('nombre').AsString;
          detfactIB.FieldByName('codanalisis').AsString := detexpt.FieldByName('codanalisis').AsString;
          if (fieldref1) then
            detfactIB.FieldByName('ref1').AsString        := detexpt.FieldByName('ref1').AsString;
          try
            detfactIB.Post
           except
            detfactIB.Cancel
          end;
        end;

        // Aislamos los pacientes con movimientos para Importarlos
        if (not utiles.verificarItemsLista(lista1, detexpt.FieldByName('idprof').AsString + detexpt.FieldByName('codpac').AsString)) or (lista1.Count = 0) then lista1.Add(detexpt.FieldByName('idprof').AsString + detexpt.FieldByName('codpac').AsString);
      end;
      end;
      detexpt.Next;
    end;

    ffirebird.RegistrarTransaccion(detfactIB);
    detfactIB.Close; detfactIB.Open;

    idexpt.Open;
    while not idexpt.EOF do Begin
      if (idexpt.FieldByName('idprof').AsString = xidprof) and (_noimport) then Begin
        if not (idordenesIB.Active) then idordenesIB.Open;
        if ffirebird.Buscar(idordenesIB, 'Periodo;Idprof', xperiodo, idexpt.FieldByName('idprof').AsString) then idordenesIB.Edit else idordenesIB.Append;
        idordenesIB.FieldByName('periodo').AsString := xperiodo;
        idordenesIB.FieldByName('idprof').AsString  := idexpt.FieldByName('idprof').AsString;
        idordenesIB.FieldByName('orden').AsString   := idexpt.FieldByName('orden').AsString;
        try
          idordenesIB.Post
         except
          idordenesIB.Cancel
        end;
        //ffirebird.RegistrarTransaccion(idordenesIB);
      end;
      idexpt.Next;
    end;
    ffirebird.RegistrarTransaccion(idordenesIB);
    idordenesIB.Close; idordenesIB.Open;
    idexpt.Close; idexpt.Free;

    //paciente.Importar(xidprof, dirlab[i], lista1);
    lista1.Clear;

    profesional.getDatos(xidprof);
    profesional.SincronizarCategoria(xidprof, xperiodo);
    GuardarRefDatosImportados(xperiodo, xidprof, profesional.nombre, directorio, 'I');

    // Transferimos ordenes Auditadas
    if FileExists(dirlab[i] + '\ordenes_audit.db') then Begin    // Si el modulo incluye Facturación de Ordenes Auditadas
      if no_importar then Begin
        auditexpt := datosdb.openDB('ordenes_audit', '', '', dirlab[i]);
        auditexpt.Open;
        while not auditexpt.Eof do Begin
          if not (ordenes_auditIB.Active) then ordenes_auditIB.Open;
          if ffirebird.Buscar(ordenes_auditIB, 'periodo;items;idprof', xperiodo, auditexpt.FieldByName('items').AsString, auditexpt.FieldByName('idprof').AsString) then ordenes_auditIB.Edit else ordenes_auditIB.Append;
          ordenes_auditIB.FieldByName('periodo').AsString      := xperiodo; // auditexpt.FieldByName('periodo').AsString;
          ordenes_auditIB.FieldByName('idprof').AsString       := auditexpt.FieldByName('idprof').AsString;
          ordenes_auditIB.FieldByName('items').AsString        := auditexpt.FieldByName('items').AsString;
          ordenes_auditIB.FieldByName('nroauditoria').AsString := auditexpt.FieldByName('nroauditoria').AsString;
          try
            ordenes_auditIB.Post
           except
            ordenes_auditIB.Cancel
          end;
          //ffirebird.RegistrarTransaccion(ordenes_auditIB);
          auditexpt.Next;
        end;
        ffirebird.RegistrarTransaccion(ordenes_auditIB);
        ordenes_auditIB.Close; ordenes_auditIB.Open;
        auditexpt.Close; auditexpt.Free;
      end;
    end;}

    cabexpt.Open; lote.Clear;
    while not cabexpt.EOF do Begin
      _noimport := False;
      if (utiles.verificarItemsLista(listOS, cabexpt.FieldByName('codos').AsString)) then begin
        if (obsocial.Buscar(cabexpt.FieldByName('codos').AsString)) then begin
          obsocial.getDatos(cabexpt.FieldByName('codos').AsString); // Excluimos las Obras Sociales Capitadas que no se Importan
          if obsocial.NoImporta = 'N' then no_importar := False;   // Flag para Determinar si se Incorporan las ordenes de Auditoria
          if (cabexpt.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, cabexpt.FieldByName('codos').AsString)) and (obsocial.NoImporta <> 'N') then Begin
            rsqlIB := ffirebird.getTransacSQL('select periodo from cabfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + cabexpt.FieldByName('idprof').AsString + '''' + ' and codos = ' + '''' + cabexpt.FieldByName('codos').AsString + '''');
            rsqlIB.Open;
            if (rsqlIB.RecordCount = 0) then begin
              lote.Add('insert into cabfact (periodo, idprof, codos, fecha) values (' +
                '''' + xperiodo + '''' + ', ' +
                '''' + cabexpt.FieldByName('idprof').AsString + '''' + ', ' +
                '''' + cabexpt.FieldByName('codos').AsString + '''' + ', ' +
                '''' + cabexpt.FieldByName('fecha').AsString + '''' + ')');
            end; {else begin
              lote.Add('DELETE FROM detfact WHERE codos = ' + '''' + cabexpt.FieldByName('codos').AsString + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and (orden < ' + '''' + '5000' + ''''  + ' or substring(orden from 1 for 1) = ' + '''' + 'R' + '''' + ') AND periodo = ' + '''' + xperiodo + '''');
              lote.Add('DELETE FROM detfact WHERE codos = ' + '''' + cabexpt.FieldByName('codos').AsString + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and substring(orden from 1 for 1) = ' + '''' + 'R' + '''' + ' AND periodo = ' + '''' + xperiodo + '''');
            end;}

            {if (_noimport = false) then begin
              rs := datosdb.tranSQL(cabexpt.DatabaseName, 'select distinct(codos) from detfact where periodo = ' + '''' + xperiodo + '''');
              rs.Open;
              while not rs.Eof  do begin
                lote.Add('DELETE FROM detfact WHERE codos = ' + '''' + rs.FieldByName('codos').AsString + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and (orden < ' + '''' + '5000' + ''''  + ' or substring(orden from 1 for 1) = ' + '''' + 'R' + '''' + ') AND periodo = ' + '''' + xperiodo + '''');
                rs.next;
              end;
              rs.Close; rs.Free;
            end;}

            _noimport := True;
          end;
        end;
      end;
      cabexpt.Next;
    end;
    cabexpt.Close; cabexpt.Free;

    if (not __iniciar) then begin
      // 21/11/2019
      //lote.Add('DELETE FROM ordenes_audit WHERE idprof = ' + '''' + xidprof + '''' + ' AND periodo = ' + '''' + xperiodo + '''');
      lote.Add('DELETE FROM idordenes WHERE idprof = ' + '''' + xidprof + '''' + ' AND periodo = ' + '''' + xperiodo + '''');
      __iniciar := true;
    end;

    detexpt.Open; idanter := '';
    fieldref1 := datosdb.verificarSiExisteCampo(detexpt, 'ref1');
    fieldretiva := datosdb.verificarSiExisteCampo(detexpt, 'retiva');

    // 23/07/2015 en remplazo de (1)
    // ' and orden < ' + '''' + '5000' + '''' 21/11/2019
    rss := datosdb.tranSQL(detexpt.DatabaseName, 'select distinct(codos) as codos from ' + detexpt.TableName);
    rss.Open;
    while not rss.eof do begin
      if (utiles.verificarItemsLista(listOS, rss.FieldByName('codos').AsString)) then begin
        lote.Add('DELETE FROM detfact WHERE periodo = ' + '''' + xperiodo + '''' + ' AND idprof = ' + '''' + xidprof + '''' + ' AND codos = ' + '''' + rss.FieldByName('codos').AsString + '''' + ' and orden < ' + '''' + '5000' + '''');
      end;
      rss.Next;
    end;
    rss.Close; rss.Free;

    detexpt.First;
    while not detexpt.EOF do Begin
      if (utiles.verificarItemsLista(listOS, detexpt.FieldByName('codos').AsString)) then begin
      if detexpt.FieldByName('codos').AsString <> idanter then Begin    // Excluimos las Obras Sociales Capitadas que no se Importan
        obsocial.getDatos(detexpt.FieldByName('codos').AsString);
        idanter := detexpt.FieldByName('codos').AsString;
      end;
      if (obsocial.Buscar(detexpt.FieldByName('codos').AsString)) then begin
        if (detexpt.FieldByName('idprof').AsString = xidprof) and (utiles.verificarItemsLista(listOS, detexpt.FieldByName('codos').AsString)) and (obsocial.NoImporta <> 'N') then Begin
            if (fieldref1) then ref1 := detexpt.FieldByName('ref1').AsString else ref1 := '';
            if (fieldretiva) then retiva := detexpt.FieldByName('retiva').AsString else retiva := '';

           // (1) lote.Add('DELETE FROM detfact WHERE periodo = ' + '''' + xperiodo + '''' + ' AND idprof = ' + '''' + xidprof + '''' + ' AND codos = ' + '''' + detexpt.FieldByName('codos').AsString + '''' +
           //       ' AND orden = ' + '''' + detexpt.FieldByName('orden').AsString + '''' + ' AND items = ' + '''' + detexpt.FieldByName('items').AsString + '''');

           lote.Add('DELETE FROM detfact WHERE periodo = ' + '''' + xperiodo + '''' + ' AND idprof = ' + '''' + xidprof + '''' + ' AND codos = ' + '''' + detexpt.FieldByName('codos').AsString + '''' +
                    ' AND orden = ' + '''' + detexpt.FieldByName('orden').AsString + '''' + ' AND items = ' + '''' + detexpt.FieldByName('items').AsString + '''');

           lote.Add('insert into detfact (periodo, idprof, codos, items, orden, codpac, nombre, codanalisis, ref1, osiva, retiva, profiva) values (' +
                '''' + xperiodo + '''' + ', ' +
                '''' + detexpt.FieldByName('idprof').AsString + '''' + ', ' +
                '''' + detexpt.FieldByName('codos').AsString + '''' + ', ' +
                '''' + detexpt.FieldByName('items').AsString + '''' + ', ' +
                '''' + detexpt.FieldByName('orden').AsString + '''' + ', ' +
                '''' + detexpt.FieldByName('codpac').AsString + '''' + ', ' +
                QuotedStr(detexpt.FieldByName('nombre').AsString) + ', ' +
                '''' + detexpt.FieldByName('codanalisis').AsString + '''' + ', ' +
                '''' + ref1 + '''' + ', ' +
                '''' + obsocial.Retieneiva + '''' + ', ' +
                '''' + retiva + '''' + ', ' +
                '''' + profesional.Retieneiva + '''' + ')'
                );
            end;

        // Aislamos los pacientes con movimientos para Importarlos
        if (not utiles.verificarItemsLista(lista1, detexpt.FieldByName('idprof').AsString + detexpt.FieldByName('codpac').AsString)) or (lista1.Count = 0) then lista1.Add(detexpt.FieldByName('idprof').AsString + detexpt.FieldByName('codpac').AsString);
      end;
      end;
      detexpt.Next;
    end;

    idexpt.Open;
    while not idexpt.EOF do Begin
      if (idexpt.FieldByName('idprof').AsString = xidprof) and (_noimport) then Begin
        lote.Add('insert into idordenes (periodo,idprof, orden) values (' +
        '''' + xperiodo + '''' + ', ' +
        '''' + idexpt.FieldByName('idprof').AsString + '''' + ', ' +
        '''' + idexpt.FieldByName('orden').AsString + '''' + ')');
      end;
      idexpt.Next;
    end;
    idexpt.Close; idexpt.Free;

    lista1.Clear;

    profesional.getDatos(xidprof);
    profesional.SincronizarCategoria(xidprof, xperiodo);
    GuardarRefDatosImportados(xperiodo, xidprof, profesional.nombre, directorio, 'I');

    // Transferimos ordenes Auditadas
    if FileExists(dirlab[i] + '\ordenes_audit.db') then Begin    // Si el modulo incluye Facturación de Ordenes Auditadas
      if no_importar then Begin
        auditexpt := datosdb.openDB('ordenes_audit', '', '', dirlab[i]);
        auditexpt.Open;
        while not auditexpt.Eof do Begin
          lote.Add('insert into ordenes_audit (periodo, idprof, items, nroauditoria) values (' +
            '''' + xperiodo + '''' + ', ' +
            '''' + auditexpt.FieldByName('idprof').AsString + '''' + ', ' +
            '''' + auditexpt.FieldByName('items').AsString + '''' + ', ' +
            '''' + auditexpt.FieldByName('nroauditoria').AsString + '''' + ')');
          auditexpt.Next;
        end;
        auditexpt.Close; auditexpt.Free;
      end;
    end;

    // guardamos el lote
    ffirebird.TransacSQLBatch(lote);
    lote.Clear;


    //--------------------------------------------------------------------------
    // Transferencia/Conversión de Datos al Sistema NBU

    rsqlIB := ffirebird.getTransacSQL('select * from cabfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
    rsqlIB.open;
    while not rsqlIB.Eof do Begin
      obsocial.getDatos(rsqlIB.FieldByName('codos').AsString);
      obsocial.SincronizarArancelNBU(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('periodo').AsString);
      if obsocial.FactNBU = 'S' then Begin

        transnbu := False;
        rsql := ffirebird.getTransacSQL('select distinct(codanalisis) from detfact where codos = ' + '''' + rsqlIB.FieldByName('codos').AsString + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
        rsql.Open; rsql.First;
        while not rsql.Eof do Begin
          if Length(Trim(rsql.FieldByName('codanalisis').AsString)) < 6 then Begin
            transnbu := True;
            if nbu.BuscarCodigoNNN(rsql.FieldByName('codanalisis').AsString) then codnbu := nbu.setCodigoNBU(rsql.FieldByName('codanalisis').AsString) else
              codnbu := rsql.FieldByName('codanalisis').AsString;

            lote.Add('update detfact set codanalisis = ' + '''' + codnbu + '''' + ' where codos = ' + '''' + rsqlIB.FieldByName('codos').AsString + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and codanalisis = ' + '''' + rsql.FieldByName('codanalisis').AsString + '''');
          end;
          rsql.Next;
        end;
        rsql.Close; rsql.Free;

        ffirebird.TransacSQLBatch(lote);

        // Ahora borramos los códigos excluidos
        r := nbu.setCodigos('E');
        r.Open;
        while not r.Eof do Begin
          lote.Add('delete from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and codanalisis = ' + '''' + r.FieldByName('codigo').AsString + '''' + ' and codos = ' + '''' + rsqlIB.FieldByName('codos').AsString + '''');
          r.Next;
        end;
        r.Close; r.Free;

        ffirebird.TransacSQLBatch(lote);

        rsql := ffirebird.getTransacSQL('select * from detfact where codos = ' + '''' + rsqlIB.FieldByName('codos').AsString + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' order by orden, items');
        j := 0;
        rsql.Open; rsql.First;
        while not rsql.Eof do Begin
          if rsql.FieldByName('orden').AsString <> ordenanter then Begin
            k := 0;
            ordenanter := rsql.FieldByName('orden').AsString;
          end;

          Inc(j);
          Inc(k);
          m[j, 1] := xperiodo; //r.FieldByName('periodo').AsString;
          m[j, 2] := rsql.FieldByName('idprof').AsString;
          m[j, 3] := rsql.FieldByName('codos').AsString;
          m[j, 4] := utiles.sLlenarIzquierda(IntToStr(k), 3, '0');
          m[j, 5] := rsql.FieldByName('orden').AsString;
          m[j, 6] := rsql.FieldByName('codpac').AsString;
          m[j, 7] := rsql.FieldByName('nombre').AsString;
          m[j, 8] := rsql.FieldByName('codanalisis').AsString;
          m[j, 9] := rsql.FieldByName('ref1').AsString;
          m[j,10] := rsql.FieldByName('retiva').AsString;

          rsql.Next;
        end;
        rsql.Close; rsql.Free;

        lote.Add('delete from detfact where codos = ' + '''' + rsqlIB.FieldByName('codos').AsString + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and orden < ' + '''' + '5000' + '''');

        For k := 1 to j do Begin
              lote.Add('delete from detfact where codos = ' + '''' + rsqlIB.FieldByName('codos').AsString + '''' + ' and periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and orden = ' + '''' + m[k, 5] + '''' + ' and items = ' + '''' + m[k, 4] + '''');
              lote.Add('insert into detfact (periodo, idprof, codos, items, orden, codpac, nombre, codanalisis, ref1, retiva) values (' +
                    '''' + m[k, 1] + '''' + ',' +
                    '''' + m[k, 2] + '''' + ',' +
                    '''' + m[k, 3] + '''' + ',' +
                    '''' + m[k, 4] + '''' + ',' +
                    '''' + m[k, 5] + '''' + ',' +
                    '''' + m[k, 6] + '''' + ',' +
                    QuotedStr(m[k, 7]) + ',' +
                    '''' + m[k, 8] + '''' + ',' +
                    '''' + m[k, 9] + '''' + ',' +
                    '''' + m[k, 10] + ''''  + ')'
          );
        End;

        // Incorporamos los códigos incluidos
        if transnbu then Begin
          rsql := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and codos = ' + '''' + rsqlIB.FieldByName('codos').AsString + '''' + ' order by codos, orden, items');
          rsql.Open;
          ordenanter := rsql.FieldByName('orden').AsString;
          while not rsql.Eof do Begin
            if rsql.FieldByName('orden').AsString <> ordenanter then Begin
              InsertarCodigo(k);
              ordenanter := rsql.FieldByName('orden').AsString;
            end;
            k       := rsql.FieldByName('items').AsInteger;
            m[1, 1] := xperiodo;
            m[1, 2] := rsql.FieldByName('idprof').AsString;
            m[1, 3] := rsql.FieldByName('codos').AsString;
            m[1, 4] := '';
            m[1, 5] := rsql.FieldByName('orden').AsString;
            m[1, 6] := rsql.FieldByName('codpac').AsString;
            m[1, 7] := rsql.FieldByName('nombre').AsString;
            m[1, 8] := rsql.FieldByName('codanalisis').AsString;
            rsql.Next;
          end;

          InsertarCodigo(k);

          ffirebird.TransacSQLBatch(lote);

          rsql.Close; rsql.Free;
        End;


      end;
      rsqlIB.Next;
    end;

    if (lote.Count > 0) then ffirebird.TransacSQLBatch(lote);

    //--------------------------------------------------------------------------

    // Transferimos totales profesionales responsables inscriptos
    profesional.getDatos(xidprof);
    profesional.SincronizarListaRetIVA(xperiodo, xidprof);

    if profesional.Retieneiva = 'S' then Begin
      if totpr then Begin
        if dbs.BaseClientServ = 'S' then totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.baseDat) else totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\archdat');
        totalesPROF.Open;
        testeartotalesprof;
        totprof.Open;
        while not totprof.Eof do Begin
          if (utiles.verificarItemsLista(listOS, totprof.FieldByName('codos').AsString)) then begin
          if (obsocial.Buscar(totalesprof.FieldByName('codos').AsString)) then begin
            if datosdb.Buscar(totalesprof, 'periodo', 'idprof', 'codos', xperiodo, totprof.FieldByName('idprof').AsString, totprof.FieldByName('codos').AsString) then totalesprof.Edit else totalesprof.Append;
            totalesprof.FieldByName('periodo').AsString  := xperiodo; // totprof.FieldByName('periodo').AsString;
            totalesprof.FieldByName('idprof').AsString   := totprof.FieldByName('idprof').AsString;
            totalesprof.FieldByName('codos').AsString    := totprof.FieldByName('codos').AsString;
            totalesprof.FieldByName('nombre').AsString   := totprof.FieldByName('nombre').AsString;
            totalesprof.FieldByName('monto').AsFloat     := totprof.FieldByName('monto').AsFloat;
            totalesprof.FieldByName('neto').AsFloat      := totprof.FieldByName('neto').AsFloat;
            totalesprof.FieldByName('retencion').AsFloat := totprof.FieldByName('retencion').AsFloat;
            totalesprof.FieldByName('ug').AsFloat        := totprof.FieldByName('ug').AsFloat;
            totalesprof.FieldByName('ub').AsFloat        := totprof.FieldByName('ub').AsFloat;
            totalesprof.FieldByName('caran').AsFloat     := totprof.FieldByName('caran').AsFloat;
            totalesprof.FieldByName('codfact').AsString  := totprof.FieldByName('codfact').AsString;
            totalesprof.FieldByName('tipoing').AsInteger := 2;
            try
              totalesprof.Post
             except
              totalesprof.Cancel
            end;
          end;
          end;
          totprof.Next;
        end;

        datosdb.closeDB(totprof); datosdb.closeDB(totalesPROF);
      end;
    end;
  end;
  End;

end;

procedure TTFacturacionCCB.GuardarRefDatosImportados(xperiodo, xidprof, xnombre, xdirectorio, xmodo: String);
// Objetivo...: Guardar datos de tratamiento para la facturacion
// Modos......: I (importado) - M (Ingreso manual)
begin
  if Length(Trim(xnombre)) > 0 then Begin
    if not datosdb.Buscar(datosimport, 'periodo', 'idprof', xperiodo, xidprof) then datosimport.Append else datosimport.Edit;
    datosimport.FieldByName('periodo').AsString    := xperiodo;
    datosimport.FieldByName('idprof').AsString     := xidprof;
    datosimport.FieldByName('nombre').AsString     := xnombre;
    datosimport.FieldByName('fechahora').AsString  := FormatDateTime('dd/mm/yy hh:mm:ss', Now);
    datosimport.FieldByName('directorio').AsString := xdirectorio;
    datosimport.FieldByName('usuario').AsString    := usuario.alias;
    datosimport.FieldByName('modo').AsString       := xmodo;
    try
      datosimport.Post
     except
      datosimport.Cancel
    end;
    datosdb.refrescar(datosimport);
  end;
end;

procedure TTFacturacionCCB.getDatosImportados(xperiodo, xidprof: String);
// Objetivo...: Devolver set de datos importados
Begin
  if datosdb.Buscar(datosimport, 'periodo', 'idprof', xperiodo, xidprof) then Begin
    fechahoraImport  := datosimport.FieldByName('fechahora').AsString;
    directorioImport := datosimport.FieldByName('directorio').AsString;
    usuarioImport    := datosimport.FieldByName('usuario').AsString;
    modoImport       := datosimport.FieldByName('modo').AsString;
    transfImport     := datosimport.FieldByName('transferencia').AsString;
  end else Begin
    fechahoraImport  := FormatDateTime('dd/mm/yy hh:mm:ss', Now);
    directorioImport := '';
    usuarioImport    := usuario.usuario;
    modoImport       := '';
    transfImport     := '';
  end;
end;

procedure TTFacturacionCCB.GuardarRefDatosExportados(xperiodo, xidprof, xnombre, xdirectorio, xmodo: String);
// Objetivo...: Guardar datos de tratamiento para la facturacion
// Modos......: E (Exportado) - M (Ingreso manual)
var
  datosExport: TTable;
begin
  if Length(Trim(xnombre)) > 0 then Begin
    datosExport := datosdb.openDB('datosexportados', 'Periodo;idprof', '', dbconexion);
    datosExport.Open;
    if not datosdb.Buscar(datosExport, 'periodo', 'idprof', xperiodo, xidprof) then datosExport.Append else datosExport.Edit;
    datosExport.FieldByName('periodo').AsString    := xperiodo;
    datosExport.FieldByName('idprof').AsString     := xidprof;
    datosExport.FieldByName('nombre').AsString     := xnombre;
    datosExport.FieldByName('fechahora').AsString  := FormatDateTime('dd/mm/yy hh:mm:ss', Now);
    datosExport.FieldByName('directorio').AsString := xdirectorio;
    datosExport.FieldByName('usuario').AsString    := usuario.alias;
    datosExport.FieldByName('modo').AsString       := xmodo;
    try
      datosExport.Post
     except
      datosExport.Cancel
    end;
    datosdb.refrescar(datosExport);
  end;
end;

function TTFacturacionCCB.setDatosImportados(xperiodo: String): TStringList;
// Objetivo...: devolver un set con los registros importados
var
  l, m: TStringList;
  i: Integer;
  r: TIBQuery;
begin
  if (directoryexists(dbs.DirSistema + '\fact_lab\' + copy(xperiodo, 1, 2) + copy(xperiodo, 4, 4))) then interbase := 'N' else interbase := 'S';

  m := TStringList.Create;

  if (interbase = 'N') then begin
    l := utilesarchivos.setListaDirectorios(dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4));
    for i := 1 to l.Count do
      if LowerCase(Copy(l.Strings[i-1], 1, 1)) <> 'f' then m.Add(l.Strings[i-1]);
    l.Destroy;
    tibase := false;
  end;
  if (interbase = 'S') then begin
    //utiles.msgError('punto xx');
    //ffirebird := Nil; 16/04/2014
    if (ffirebird = Nil) then InstanciarTablas('S');
    r := ffirebird.getTransacSQL('select distinct(idprof) from cabfact where periodo = ' + '''' + xperiodo + '''');
    r.Open;
    while not r.eof do begin
      m.Add(r.FieldByName('idprof').AsString);
      r.next;
    end;
    r.Close; r.Free;
    tibase := true;
  end;

  Result := m;
end;

function TTFacturacionCCB.setLaboratoriosImportados(xperiodo: String): TStringList;
// Objetivo...: devolver un set con los registros importados
var
  l: TStringList;
begin
  l := utilesarchivos.setListaDirectorios(dbs.DirSistema + '\fact_lab\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4));
  Result := l;
end;

function TTFacturacionCCB.setDatosIngresadosEnElDia: TQuery;
// Objetivo...: devolver un set con los registros de los laboratorios ingresados en el dia
begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM datosimportados WHERE periodo = ' + '"' + utiles.setPeriodoActual + '"');
end;

function TTFacturacionCCB.BuscarDatosFact(xperiodo, xcodos: String): Boolean;
// Objetivo...: Buscar datos de Facturación
begin
  if datosfact.IndexFieldNames <> 'Periodo;Codos' then datosfact.IndexFieldNames := 'Periodo;Codos';
  ExisteLiquidacion := datosdb.Buscar(datosfact, 'periodo', 'codos', xperiodo, xcodos);
  if (ExisteLiquidacion) then begin
    result := ExisteLiquidacion;
    exit;
  end;

  if not (ExisteLiquidacion) then begin  // 30/04/2024
    if not (omitir_ressql) then begin    // 29/05/2014
      if (ressql = nil) then begin       // 01/07/2014
        ressql := osagrupa.getListaObrasSocialesAgrupadas;
        ressql.Open; ressql.First;
      end;

      while not ressql.eof do begin
        if (ressql.FieldByName('codos').asstring = xcodos) then begin
          ExisteLiquidacion := datosdb.Buscar(datosfact, 'periodo', 'codos', xperiodo, ressql.FieldByName('id').asstring);
          break;
        end;
        ressql.Next;
      end;

      ressql.Close; ressql := nil;
    end;
  end;

  Result := ExisteLiquidacion;
end;

procedure TTFacturacionCCB.getDatosFact(xperiodo, xcodos: String);
// Objetivo...: Recuperar una Instancia de los Datos de Facturación
begin
  if BuscarDatosFact(xperiodo, xcodos) then Begin
    idcFact      := datosfact.FieldByName('idcompr').AsString;
    tipoFact     := datosfact.FieldByName('tipo').AsString;
    sucursalFact := datosfact.FieldByName('sucursal').AsString;
    numeroFact   := datosfact.FieldByName('numero').AsString;
  end else Begin
    idcfact := ''; tipoFact := ''; sucursalFact := ''; numeroFact := '';
  end;
end;

procedure TTFacturacionCCB.AjustarDatosFact(xperiodo, xcodos, xidcompr, xtipo, xsucursal, xnumero: String);
// Objetivo...: Ajustar datos de Facturación
begin
  if BuscarDatosFact(xperiodo, xcodos) then Begin
    datosFact.Edit;
    datosfact.FieldByName('idcompr').AsString  := xidcompr;
    datosfact.FieldByName('tipo').AsString     := xtipo;
    datosfact.FieldByName('sucursal').AsString := xsucursal;
    datosfact.FieldByName('numero').AsString   := xnumero;
    try
      datosfact.Post
     except
      datosfact.Cancel
    end;
    datosdb.refrescar(datosfact);
  end;
end;

function TTFacturacionCCB.BuscarDatosFactDet(xperiodo, xcodos, xitems: String): Boolean;
// Objetivo...: Buscar datos de Facturación
begin
  if datosfactdet.IndexFieldNames <> 'Periodo;Codos;Items' then datosfactdet.IndexFieldNames := 'Periodo;Codos;Items';
  result := datosdb.Buscar(datosfactdet, 'periodo', 'codos', 'items', xperiodo, xcodos, xitems);
end;

{==============================================================================}

procedure TTFacturacionCCB.PrepararDirectorio(xperiodo, xlaboratorio: String);
// Objetivo...: Creamos Via de trabajo para trabajar con el laboratorio eb cuestion
var
  p: String;
begin
  labrem := xlaboratorio;
  p := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  perrem := p;

  if (LaboratorioActual <> xlaboratorio) or (Periodo <> xperiodo) then Begin
    directorio := dir_lab + '\' + p + '\' + xlaboratorio;

    firebird.getModulo('facturacion');

    if (length(trim(firebird.Host)) > 0) then begin
        //directorio := firebird.Dir_Remoto + '\' + p + '\' + xlaboratorio;
        //utilesarchivos.CrearDirectorio(firebird.Dir_Remoto + '\' + p);
        //utilesarchivos.CrearDirectorio(directorio);
        //if (FileExists(firebird.Dir_Remoto1 + '\FACTLAB.GDB')) then begin
          //directorio := firebird.Dir_Remoto + '\' + p + '\' + xlaboratorio;
          //if not (FileExists(directorio + '\FACTLAB.GDB')) then
            //utilesarchivos.CopiarArchivos(firebird.Dir_Remoto1, '*.*', directorio);
          interbase := 'S';
        //end;
    end else
      interbase := 'N';

    if (interbase = 'N') then begin
      if not DirectoryExists(directorio) then Begin
        utilesarchivos.CrearDirectorio(dir_lab + '\' + p);
        utilesarchivos.CrearDirectorio(directorio);
        if (interbase = 'N') then begin
          utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work', '*.*', directorio);
          if DirectoryExists(dbs.DirSistema + '\work\factNBU') then utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\factNBU', '*.*', directorio);
        end;
      end;
    end;

    if directorio <> diractual then SeleccionarLaboratorio(directorio);  // Conectamos al directorio seleccionado
    LaboratorioActual := xlaboratorio;
  end;

  // Guardamos la referencia de los datos ingresados
  profesional.getDatos(xlaboratorio);
  GuardarRefDatosImportados(xperiodo, xlaboratorio, profesional.nombre, directorio, 'M');
  GuardarRefDatosExportados(xperiodo, xlaboratorio, profesional.nombre, directorio, 'M');
  Periodo := xperiodo;
end;

function TTFacturacionCCB.DireccionarLaboratorio(xperiodo, xlaboratorio: String): Boolean;
// Objetivo...: Creamos Via de trabajo para trabajar con el laboratorio eb cuestion
var
  p, s: String;
  i, pos: Integer;
begin
  p := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  directorio := dir_lab + '\' + p + '\' + xlaboratorio;

  firebird.getModulo('facturacion');
  s := firebird.Dir_Remoto + '\' + p + '\' + xlaboratorio;
  perrem := p;
  labrem := xlaboratorio;

  if (DirectoryExists(directorio)) or (length(trim(firebird.Host)) > 0)  then   // Verificamos que exista el directorio
    if (length(trim(firebird.Host)) > 0) or (FileExists(directorio + '\cabfact.db') and FileExists(directorio + '\detfact.db') and FileExists(directorio + '\idordenes.db') and (FileExists(directorio + '\paciente.db'))) {or (FileExists(s + '\FACTLAB.GDB'))} then Begin  // Verificamos que existan los archivos
      // Guardamos la referencia de los datos ingresados - esto refleja el ultimo acceso efectuado
      profesional.getDatos(xlaboratorio);
      GuardarRefDatosImportados(xperiodo, xlaboratorio, profesional.nombre, directorio, 'M');
      GuardarRefDatosExportados(xperiodo, xlaboratorio, profesional.nombre, directorio, 'M');
      SeleccionarLaboratorio(directorio);  // Conectamos al directorio seleccionado
      LaboratorioActual := xlaboratorio;

      if (length(trim(firebird.Host)) > 0) then interbase := 'S';
      if (FileExists(directorio + '\cabfact.db') and FileExists(directorio + '\detfact.db') and FileExists(directorio + '\idordenes.db') and (FileExists(directorio + '\paciente.db'))) then interbase := 'N';

      VerificarOrdenInterna(xperiodo, xlaboratorio);

      pos := 0;
      For i := 1 to listatrab.Count do Begin
        if listatrab.Strings[i-1] = xlaboratorio then Begin
          pos := i;
          Break;
        end;
      end;
      if pos = 0 then listatrab.Add(xlaboratorio);

      Result := True;
    end else Begin
      utiles.msgError('Se ha Producido un Error, si ha Importado los Datos,' + chr(13) + ' vuelva  a Repetir la Operación.');
      Result := False;
    end;
  msgImpresion := 'No Existen Datos para Listar ...!';
end;

function TTFacturacionCCB.verificicarSiExisteLaboratorio(xperiodo, xlaboratorio: String): Boolean;
var
  p, d, s: String;
begin
  if (interbase = 'S') then begin
    result := true;
    exit;
  end;
  interbase := 'N';
  if Length(Trim(xlaboratorio)) = 0 then Result := False else Begin
    p := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    d := Trim(dir_lab + '\' + p + '\' + xlaboratorio);

    //firebird.getModulo('facturacion');
    //s := firebird.Dir_Remoto + '\' + p + '\' + xlaboratorio;
    perrem := p;
    labrem := xlaboratorio;

    //if (length(trim(firebird.Host)) > 0) then interbase := 'S';

    if (DirectoryExists(d)) then Result := True else Begin
      // Si No Existe el directorio, elimino la entrada
      datosdb.tranSQL(DBConexion, 'DELETE FROM datosimportados WHERE Periodo = ' + '"' + xperiodo + '"' + ' AND Idprof = ' + '"' + xlaboratorio + '"');
      Result := False;
    end;

  end;
end;

procedure TTFacturacionCCB.ProcesarDatosCentrales(xperiodo: String);
// Objetivo...: Procesar los datos de centrales, todos
var
  __i: boolean;
begin
  interbase := 'N';
  firebird.getModulo('facturacion');
  if (length(trim(firebird.Host)) = 0) then interbase := 'N' else interbase := 'S';

  if (FileExists(dir_lab + '\facturaciones\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\cabfact.db')) then interbase := 'N';

  if (interbase = 'N') then begin
    QuitarFiltro;
    DBCentral  := dir_lab +  '\facturaciones\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    directorio := DBCentral;
    LaboratorioActual := '';
    if cabfact   <> nil then if cabfact.Active   then datosdb.closeDB(cabfact);
    if detfact   <> nil then if detfact.Active   then datosdb.closeDB(detfact);
    if idordenes <> nil then if idordenes.Active then datosdb.closeDB(idordenes);
    cabfact := nil; detfact := nil; idordenes := nil;

    if not DirectoryExists(DBCentral) then Begin
      if not DirectoryExists(dir_lab + '\facturaciones') then utilesarchivos.CrearDirectorio(dir_lab + '\facturaciones');
      if not DirectoryExists(DBCentral) then utilesarchivos.CrearDirectorio(DBCentral);
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work', '*.*', DBCentral);
      utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\factNBU', '*.*', DBCentral);
    end;

    cabfact   := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', DBCentral);
    detfact   := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', DBCentral);
    idordenes := datosdb.openDB('idordenes', 'Periodo;Idprof', '', DBCentral);

    if not cabfact.Active   then cabfact.Open;
    if not detfact.Active   then detfact.Open;
    if not idordenes.Active then idordenes.Open;

    if not datosdb.verificarSiExisteCampo(detfact, 'profiva') then Begin
      detfact.Close;
      datosdb.tranSQL(DBCentral, 'alter table detfact add Profiva char(1)');
      detfact.Open;
    end;
    if not datosdb.verificarSiExisteCampo(detfact, 'osiva') then Begin
      detfact.Close;
      datosdb.tranSQL(DBCentral, 'alter table detfact add Osiva char(1)');
      detfact.Open;
    end;
  end;

  if (interbase = 'S') then begin

    __c := '';
    firebird.getModulo('facturacion');
    directorio := DBCentral;
    LaboratorioActual := '';
    {if cabfactIB   <> nil then if cabfactIB.Active   then ffirebird.closeDB(cabfactIB);
    if detfactIB   <> nil then if detfactIB.Active   then ffirebird.closeDB(detfactIB);
    if idordenesIB <> nil then if idordenesIB.Active then ffirebird.closeDB(idordenesIB);
    cabfactIB := nil; detfactIB := nil; idordenesIB := nil;}
    
    __i := true;
    if (ffirebird <> nil) then
      if (pos('FACTLABCENT.GDB', ffirebird.IBDatabase.DatabaseName) > 0) then __i := false;

    if (__i) then begin
      if (ffirebird <> nil) then  ffirebird.Desconectar;
      //utiles.msgError('cierre');
      ffirebird := TTFirebird.Create;
      //utiles.msgError('new');
      ffirebird.Conectar(firebird.Host + 'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);
      //utiles.msgError('apertura');
    end;

    {cabfactIB       := ffirebird.InstanciarTabla('cabfact');
    detfactIB       := ffirebird.InstanciarTabla('detfact');
    idordenesIB     := ffirebird.InstanciarTabla('idordenes');
    ordenes_auditIB := ffirebird.InstanciarTabla('ordenes_audit');

    {if not cabfactIB.Active   then cabfactIB.Open;
    if not detfactIB.Active   then detfactIB.Open;
    if not idordenesIB.Active then idordenesIB.Open;}

    //if (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');

  end;

  // Prorrateamos la epoca y de acuerdo a la misma determinamos si trabaja o no en version Client/Server

  totalesOS   := datosdb.openDB('totalesOS', 'Periodo;Codos', '', DBConexion);
  totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', DBConexion);
  idprof := ''; laboratorioactual := '';   // Cambiamos los indicadores de laboratorios
  ProcesamientoCentral := True;
  LaboratorioActivo    := False;
end;

procedure TTFacturacionCCB.CopiarEstructuras(xperiodo: String);
// Objetivo...: Procesar los datos de centrales, todos
begin
  if (interbase = 'N') then begin
    DBCentral  := dir_lab +  '\facturaciones\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work', '*.*', DBCentral);
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\factNBU', '*.*', DBCentral);
  end;
  if (interbase = 'S') then begin
    //DBCentral  := firebird.Dir_Remoto +  'fact_lab\facturaciones\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  end;
end;
//  falta interbase
function TTFacturacionCCB.ProcesarUnificados: Boolean;
// Objetivo...: Procesar los datos Unificados
begin
  {DBCentral  := dir_lab +  '\integracion';
  directorio := DBCentral;
  LaboratorioActual := '';
  if cabfact   <> nil then if cabfact.Active   then datosdb.closeDB(cabfact);
  if detfact   <> nil then if detfact.Active   then datosdb.closeDB(detfact);
  if idordenes <> nil then if idordenes.Active then datosdb.closeDB(idordenes);
  cabfact := nil; detfact := nil; idordenes := nil;

  if DirectoryExists(DBCentral) then Begin
    cabfact   := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', DBCentral);
    detfact   := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', DBCentral);
    idordenes := datosdb.openDB('idordenes', 'Periodo;Idprof', '', DBCentral);

    if not cabfact.Active   then cabfact.Open;
    if not detfact.Active   then detfact.Open;
    if not idordenes.Active then idordenes.Open;

    idprof := ''; laboratorioactual := '';   // Cambiamos los indicadores de laboratorios
    ProcesamientoCentral := False;
    LaboratorioActivo    := False;

    Result := True;
  end else
    Result := False;}

  if (interbase = 'S') then begin
    ProcesarDatosCentrales('');
    __c := '_hist';
    {ProcesamientoCentral := true;
    firebird.getModulo('facturacion');
    if (ffirebird <> nil) then  ffirebird.Desconectar;
    ffirebird := TTFirebird.Create;
    ffirebird.Conectar(firebird.Host + 'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);
    utiles.msgError('1');
    {directorio := DBCentral;
    LaboratorioActual := '';
    if cabfactIB   <> nil then if cabfactIB.Active   then ffirebird.closeDB(cabfactIB);
    if detfactIB   <> nil then if detfactIB.Active   then ffirebird.closeDB(detfactIB);
    if idordenesIB <> nil then if idordenesIB.Active then ffirebird.closeDB(idordenesIB);
    cabfactIB := nil; detfactIB := nil; idordenesIB := nil;

    if (ffirebird <> nil) then  ffirebird.Desconectar;
    ffirebird := TTFirebird.Create;
    ffirebird.Conectar(firebird.Host + 'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);

    cabfactIB       := ffirebird.InstanciarTabla('cabfact');
    detfactIB       := ffirebird.InstanciarTabla('detfact');
    idordenesIB     := ffirebird.InstanciarTabla('idordenes');
    ordenes_auditIB := ffirebird.InstanciarTabla('ordenes_audit');}
  end;
end;

procedure TTFacturacionCCB.ProcesarDatosHistoricos;
// Objetivo...: Procesar los datos de historicos
begin
  SeleccionarLaboratorio(dbs.BDhistorico);
  QuitarFiltro;
  idprof := ''; laboratorioactual := '';   // Cambiamos los indicadores de laboratorios
end;

procedure TTFacturacionCCB.DepurarIB(xperiodo: String);
// Objetivo...: Depurar Datos
begin
  InstanciarTablas('S');
  if (ffirebird <> nil) then begin
    ffirebird.TransacSQL('delete from cabfact where periodo = ' + '''' + xperiodo + '''');
    ffirebird.TransacSQL('delete from detfact where periodo = ' + '''' + xperiodo + '''');
    ffirebird.TransacSQL('delete from idordenes where periodo = ' + '''' + xperiodo + '''');
    ffirebird.TransacSQL('delete from ordenes_audit where periodo <= ' + '''' + xperiodo + '''');
  end;
end;

procedure TTFacturacionCCB.Depurar(xperiodo: String);
// Objetivo...: Depurar Datos
var
  hcabfact, hdetfact, hidordenes, hcabfactos, hliq, hdatosfact, hdatosimport, hdatosexport, datosimport, datosexport: TTable;
begin
  ProcesarDatosCentrales(xperiodo);
  // Transferimos los datos al historico
  hcabfact     := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', dbs.BDhistorico);
  hdetfact     := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', dbs.BDhistorico);
  hidordenes   := datosdb.openDB('idordenes', 'Periodo;Idprof', '', dbs.BDhistorico);
  hcabfactos   := datosdb.openDB('cabfactos', 'Nroliq;Codos', '', dbs.BDhistorico);
  hliq         := datosdb.openDB('liquidaciones', 'Codos;Periodo', '', dbs.BDhistorico);
  hdatosfact   := datosdb.openDB('datosfact', 'Periodo;Nroliq;Codos', '', dbs.BDhistorico);
  hdatosexport := datosdb.openDB('datosexportados', 'Periodo;Idprof', '', dbs.BDhistorico);
  hdatosimport := datosdb.openDB('datosimportados', 'Periodo;Idprof', '', dbs.BDhistorico);

  hcabfact.Open; hdetfact.Open; hidordenes.Open; hcabfactos.Open; hliq.Open; hdatosfact.Open; historico.Open; hdatosexport.Open; hdatosimport.Open;
  cabfact.First; idanter := ''; idanter1 := ''; // Cabecera de Ingresos
  while not cabfact.EOF do Begin
    if cabfact.FieldByName('periodo').AsString = xperiodo then Begin
      if Length(Trim(idanter)) = 0 then Begin
        idanter  := cabfact.FieldByName('periodo').AsString;
        idanter1 := cabfact.FieldByName('idprof').AsString;
      end;
      if datosdb.Buscar(hcabfact, 'periodo', 'idprof', 'codos', cabfact.FieldByName('periodo').AsString, cabfact.FieldByName('idprof').AsString, cabfact.FieldByName('codos').AsString) then hcabfact.Edit else hcabfact.Append;
      hcabfact.FieldByName('periodo').AsString := cabfact.FieldByName('periodo').AsString;
      hcabfact.FieldByName('idprof').AsString  := cabfact.FieldByName('idprof').AsString;
      hcabfact.FieldByName('codos').AsString   := cabfact.FieldByName('codos').AsString;
      hcabfact.FieldByName('fecha').AsString   := cabfact.FieldByName('fecha').AsString;
      try
        hcabfact.Post
       except
        hcabfact.Cancel
      end;

      // Referencias al historico
      if cabfact.FieldByName('periodo').AsString <> idanter then GuardarPeriodoHistorico(idanter);
      // Compactacion de Directorios Individuales
      if (cabfact.FieldByName('periodo').AsString <> idanter) or (cabfact.FieldByName('idprof').AsString <> idanter1) then DepurarDirectorios(idanter, idanter1);
      idanter  := cabfact.FieldByName('periodo').AsString;
      idanter1 := cabfact.FieldByName('idprof').AsString;
    end;
    cabfact.Next;
  end;

  GuardarPeriodoHistorico(idanter);
  {DepurarDirectorios(idanter, idanter1);   // El ultimo de la lista}

  detfact.First;   // Detalle de ingresos
  while not detfact.EOF do Begin
    if detfact.FieldByName('periodo').AsString = xperiodo then Begin
      if datosdb.Buscar(hdetfact, 'periodo', 'idprof', 'codos', 'items', 'orden', detfact.FieldByName('periodo').AsString, detfact.FieldByName('idprof').AsString, detfact.FieldByName('codos').AsString, detfact.FieldByName('items').AsString, detfact.FieldByName('orden').AsString) then hdetfact.Edit else hdetfact.Append;
      hdetfact.FieldByName('periodo').AsString     := detfact.FieldByName('periodo').AsString;
      hdetfact.FieldByName('idprof').AsString      := detfact.FieldByName('idprof').AsString;
      hdetfact.FieldByName('codos').AsString       := detfact.FieldByName('codos').AsString;
      hdetfact.FieldByName('items').AsString       := detfact.FieldByName('items').AsString;
      hdetfact.FieldByName('orden').AsString       := detfact.FieldByName('orden').AsString;
      hdetfact.FieldByName('codpac').AsString      := detfact.FieldByName('codpac').AsString;
      hdetfact.FieldByName('nombre').AsString      := detfact.FieldByName('nombre').AsString;
      hdetfact.FieldByName('codanalisis').AsString := detfact.FieldByName('codanalisis').AsString;
      try
        hdetfact.Post
       except
        hdetfact.Cancel
      end;
    end;
    detfact.Next;
  end;
  idordenes.First;            // Control de liquidaciones
  while not idordenes.EOF do Begin
    if idordenes.FieldByName('periodo').AsString = xperiodo then Begin
      if datosdb.Buscar(hidordenes, 'periodo', 'idprof', idordenes.FieldByName('periodo').AsString, idordenes.FieldByName('idprof').AsString) then hidordenes.Edit else hidordenes.Append;
      hidordenes.FieldByName('periodo').AsString   := idordenes.FieldByName('periodo').AsString;
      hidordenes.FieldByName('idprof').AsString    := idordenes.FieldByName('idprof').AsString;
      hidordenes.FieldByName('orden').AsString     := idordenes.FieldByName('orden').AsString;
      try
        hidordenes.Post
       except
        hidordenes.Cancel
      end;
    end;
    idordenes.Next;
  end;
  hidordenes.Close;
  cabfactos.First;
  while not cabfactos.EOF do Begin  // Detalles de Facturación
    if cabfactos.FieldByName('periodo').AsString = hcabfactos.FieldByName('periodo').AsString then Begin
      if datosdb.Buscar(hcabfactos, 'nroliq', 'codos', cabfactos.FieldByName('nroliq').AsString, cabfactos.FieldByName('codos').AsString) then hcabfactos.Edit else hcabfactos.Append;
      hcabfactos.FieldByName('nroliq').AsString        := cabfactos.FieldByName('nroliq').AsString;
      hcabfactos.FieldByName('codos').AsString         := cabfactos.FieldByName('codos').AsString;
      hcabfactos.FieldByName('periodo').AsString       := cabfactos.FieldByName('periodo').AsString;
      hcabfactos.FieldByName('fecha').AsString         := cabfactos.FieldByName('fecha').AsString;
      hcabfactos.FieldByName('vencimiento').AsString   := cabfactos.FieldByName('vencimiento').AsString;
      hcabfactos.FieldByName('concepto').AsString      := cabfactos.FieldByName('concepto').AsString;
      hcabfactos.FieldByName('segundovenc').AsString   := cabfactos.FieldByName('segundovenc').AsString;
      hcabfactos.FieldByName('ultimovenc').AsString    := cabfactos.FieldByName('ultimovenc').AsString;
      hcabfactos.FieldByName('importevto1').AsFloat    := cabfactos.FieldByName('importevto1').AsFloat;
      hcabfactos.FieldByName('importevto2').AsFloat    := cabfactos.FieldByName('importevto2').AsFloat;
      hcabfactos.FieldByName('observaciones').AsString := cabfactos.FieldByName('observaciones').AsString;
      hcabfactos.FieldByName('total').AsFloat          := cabfactos.FieldByName('total').AsFloat;
      try
        hcabfactos.Post
       except
        hcabfactos.Cancel
      end;
    end;
    cabfactos.Next;
  end;
  liq.First;            // Control de liquidaciones
  while not liq.EOF do Begin
    if liq.FieldByName('periodo').AsString = xperiodo then Begin
      if datosdb.Buscar(hliq, 'codos', 'periodo', liq.FieldByName('codos').AsString, liq.FieldByName('periodo').AsString) then hliq.Edit else hliq.Append;
      hliq.FieldByName('codos').AsString   := liq.FieldByName('codos').AsString;
      hliq.FieldByName('periodo').AsString := liq.FieldByName('periodo').AsString;
      hliq.FieldByName('nroliq').AsString  := liq.FieldByName('nroliq').AsString;
      try
        hliq.Post
       except
        hliq.Cancel
      end;
    end;
    liq.Next;
  end;
  datosfact.First;            // Datos Facturados
  while not datosfact.EOF do Begin
    if datosfact.FieldByName('periodo').AsString = xperiodo then Begin
      if datosdb.Buscar(hdatosfact, 'periodo', 'nroliq', 'codos', datosfact.FieldByName('periodo').AsString, datosfact.FieldByName('nroliq').AsString, datosfact.FieldByName('codos').AsString) then hdatosfact.Edit else hdatosfact.Append;
      hdatosfact.FieldByName('periodo').AsString  := datosfact.FieldByName('periodo').AsString;
      hdatosfact.FieldByName('codos').AsString    := datosfact.FieldByName('codos').AsString;
      hdatosfact.FieldByName('nroliq').AsString   := datosfact.FieldByName('nroliq').AsString;
      hdatosfact.FieldByName('idcompr').AsString  := datosfact.FieldByName('idcompr').AsString;
      hdatosfact.FieldByName('tipo').AsString     := datosfact.FieldByName('tipo').AsString;
      hdatosfact.FieldByName('sucursal').AsString := datosfact.FieldByName('sucursal').AsString;
      hdatosfact.FieldByName('numero').AsString   := datosfact.FieldByName('numero').AsString;
      try
        hdatosfact.Post
       except
        hdatosfact.Cancel
      end;
    end;
    datosfact.Next;
  end;

  datosExport := datosdb.openDB('datosexportados', 'Periodo;idprof');
  datosexport.Open; datosexport.First;
  while not datosexport.EOF do Begin
    if datosexport.FieldByName('periodo').AsString = xperiodo then Begin
      if datosdb.Buscar(hdatosexport, 'Periodo', 'Idprof', datosexport.FieldByName('periodo').AsString, datosexport.FieldByName('idprof').AsString) then hdatosexport.Edit else hdatosexport.Append;
      hdatosexport.FieldByName('periodo').AsString    := datosexport.FieldByName('periodo').AsString;
      hdatosexport.FieldByName('idprof').AsString     := datosexport.FieldByName('idprof').AsString;
      hdatosexport.FieldByName('nombre').AsString     := datosexport.FieldByName('nombre').AsString;
      hdatosexport.FieldByName('fechahora').AsString  := datosexport.FieldByName('fechahora').AsString;
      hdatosexport.FieldByName('directorio').AsString := datosexport.FieldByName('directorio').AsString;
      hdatosexport.FieldByName('usuario').AsString    := datosexport.FieldByName('usuario').AsString;
      hdatosexport.FieldByName('modo').AsString       := datosexport.FieldByName('modo').AsString;
      try
        hdatosexport.Post
       except
        hdatosexport.Cancel
      end;
    end;
    datosexport.Next;
  end;
  datosexport.Close;

  datosimport.First;
  while not datosimport.EOF do Begin
    if datosimport.FieldByName('periodo').AsString = xperiodo then Begin
      if datosdb.Buscar(hdatosimport, 'Periodo', 'Idprof', datosimport.FieldByName('periodo').AsString, datosimport.FieldByName('idprof').AsString) then hdatosimport.Edit else hdatosimport.Append;
      hdatosimport.FieldByName('periodo').AsString       := datosimport.FieldByName('periodo').AsString;
      hdatosimport.FieldByName('idprof').AsString        := datosimport.FieldByName('idprof').AsString;
      hdatosimport.FieldByName('nombre').AsString        := datosimport.FieldByName('nombre').AsString;
      hdatosimport.FieldByName('fechahora').AsString     := datosimport.FieldByName('fechahora').AsString;
      hdatosimport.FieldByName('directorio').AsString    := datosimport.FieldByName('directorio').AsString;
      hdatosimport.FieldByName('usuario').AsString       := datosimport.FieldByName('usuario').AsString;
      hdatosimport.FieldByName('modo').AsString          := datosimport.FieldByName('modo').AsString;
      hdatosimport.FieldByName('transferencia').AsString := datosimport.FieldByName('transferencia').AsString;
      try
        hdatosimport.Post
       except
        hdatosimport.Cancel
      end;
    end;
    datosimport.Next;
  end;
  datosimport.Close;

  datosdb.closeDB(hcabfact); datosdb.closeDB(hdetfact); datosdb.closeDB(hidordenes); datosdb.closeDB(hcabfactos); datosdb.closeDB(hliq); datosdb.closeDB(hdatosfact); datosdb.closeDB(hdatosimport); datosdb.closeDB(hdatosexport); datosdb.closeDB(hdatosimport);

  // Eliminamos los movimientos de la base de datos central
  datosdb.tranSQL(DBConexion, 'DELETE FROM cabfact         WHERE periodo = ' + '"' + xperiodo + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM detfact         WHERE periodo = ' + '"' + xperiodo + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM idordenes       WHERE periodo = ' + '"' + xperiodo + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM cabfactos       WHERE periodo = ' + '"' + xperiodo + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM liquidaciones   WHERE periodo = ' + '"' + xperiodo + '"');
  datosdb.tranSQL(DBConexion, 'DELETE FROM datosfact       WHERE periodo = ' + '"' + xperiodo + '"');
  if usuario.usuario <> 'Administrador' then Begin      // La referencia se mantiene para los superusuarios
    datosdb.tranSQL(DBConexion, 'DELETE FROM datosimportados WHERE periodo = ' + '"' + xperiodo + '"');
    datosdb.tranSQL(DBConexion, 'DELETE FROM datosexportados WHERE periodo = ' + '"' + xperiodo + '"');
  end;
end;

procedure TTFacturacionCCB.DepurarDirectorios(xperiodo, xidprof: String);
// Objetivo...: Depurar Directorios Individuales
begin
  utilesarchivos.CompactarArchivos(dir_lab + '\' + xperiodo + '\' + xidprof + '\*.*', dbs.DirSistema + '\historico\directorios\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + xidprof + '.bck');
end;

procedure TTFacturacionCCB.GuardarPeriodoHistorico(xperiodo: String);
// Objetivo...: Guardar referencia de periodos transferidos al historico
begin
  if Length(Trim(xperiodo)) > 0 then Begin
    historico.Open;
    if historico.FindKey([xperiodo]) then historico.Edit else historico.Append;
    historico.FieldByName('periodo').AsString := xperiodo;
    historico.FieldByName('fecha').AsString   := utiles.setFechaActual;
    historico.FieldByName('estado').AsInteger := 1;
    try
      historico.Post
     except
      historico.Cancel
    end;
    historico.Close;
  end;
end;

procedure TTFacturacionCCB.BorrarDirectoriosDepurados;
// Objetivo...: Borrar Directorios depurados
begin
  if usuario.usuario <> 'Administrador' then Begin    // Si el usuario es Administrador los directorios No se Borran
    historico.Open;
    while not historico.EOF do Begin
      if (historico.FieldByName('fecha').AsString = utiles.setFechaActual) and (historico.FieldByName('estado').AsInteger = 1) then Begin
        if DirectoryExists(dir_lab + '\' + Copy(historico.FieldByName('periodo').AsString, 1, 2) + Copy(historico.FieldByName('periodo').AsString, 4, 4)) then utilesarchivos.Deltree(dir_lab + '\' + Copy(historico.FieldByName('periodo').AsString, 1, 2) + Copy(historico.FieldByName('periodo').AsString, 4, 4));
        historico.Edit;
        historico.FieldByName('estado').AsInteger := 0;
        try
          historico.Post
         except
          historico.Cancel
       end;
      end;
      historico.Next;
    end;
    historico.Close;
  end;

  // Eliminamos Directorios temporales
  if DirectoryExists(dbs.dirSistema + '\temp') then utilesarchivos.Deltree(dbs.dirSistema + '\temp');
  // Volvemos a crearlo
  mkdir(dbs.dirSistema + '\temp');
end;

function  TTFacturacionCCB.VerificarPeriodoHistorico(xperiodo: String): Boolean;
// Objetivo...: Verificar que exista el periodo historico
begin
  historico.Open;
  Result := historico.FindKey([xperiodo]);
  historico.Close;
end;

function  TTFacturacionCCB.VerificarSiElPeriodoEstaDepurado(xperiodo: String): Boolean;
// Objetivo...: Indica si el directorio esta marcado para borrarse, para que, si el usuario selecciona este periodo no pueda acceder a los datos
begin
  historico.Open;
  if not historico.FindKey([xperiodo]) then Result := False else
    if historico.FieldByName('estado').AsInteger = 1 then Result := True else Result := False;
  historico.Close;
end;

procedure TTFacturacionCCB.ConfigurarInforme(xreporte: String; xcopias, xsalto: ShortInt);
// Objetivo...: Configurar datos de informes
begin
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
  datosdb.refrescar(ctrlImpr);
end;

procedure TTFacturacionCCB.getConfiguracionInforme(xreporte: String);
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

{ ============================================================================== }

procedure TTFacturacionCCB.ListarControlesFinales(xperiodo, xtitulo, xcolumnas: String; profSel: TStringList; ObrasSocSel: TStringList; presentar_inf: Boolean; salida: char);
// Objetivo...: Listar Resumen de Prestaciones por Obra Social
var
  i, j, e: ShortInt; r: TQuery;
begin
  e := 18;
  IniciarArreglos;
  pag := 0; listControl := True; datosListados := False;
  Periodo := xperiodo;
  if salida <> 'T' then Begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    list.altopag := 0; list.m := 0;
    list.IniciarTitulos;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Control de Ordenes Ingresadas', 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Paciente', 1, 'Arial, cursiva, 8');
    list.Titulo(17, list.Lineactual, 'Orden', 2, 'Arial, cursiva, 8');
    espaciocol   := 80 div StrToInt(xcolumnas);
    nrocol       := 80 div espaciocol;
    distanciaImp := (nrocol * 12) div StrToInt(xcolumnas);
    j := 2;
    For i := 1 to nrocol do Begin
      list.Titulo((espaciocol * i) + e, list.Lineactual, 'Cód.', j+1, 'Arial, cursiva, 8');
      if not listControl then list.Titulo((((espaciocol * i) + e) + distanciaImp) - (nrocol), list.Lineactual, 'Aran.', j+2, 'Arial, cursiva, 8') else list.Titulo((((espaciocol * i) + e) + distanciaImp) - (nrocol), list.Lineactual, '   ', j+2, 'Arial, cursiva, 8');
      j := j + 2;
    end;
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end else Begin
    if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
    titulo1(xperiodo, xtitulo, xcolumnas);
  end;

  codosanter  := ''; idprofanter := ''; idanter := ''; idanter1 := ''; ordenanter := ''; i := 0; cantidad := 0; cantidadordenes := 0; subtotal := 0; it := 0; tot9984 := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; totprestaciones := 0; periodo := xperiodo; titulo := xtitulo; columnas := xcolumnas; montos[1] := 0; total := 0; it := 0; i := 0; totales[1] := 0;
  ccanUB := 0; ccanUG := 0; ttotUB := 0; ttotUG := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; total := 0;

  if (interbase = 'N') then begin
    if not (detfact.Active) then detfact.Open;
    detfact.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';
    detfact.First;
    obsocial.getDatos(detfact.FieldByname('codos').AsString);
    ordenanter  := detfact.FieldByName('orden').AsString;
    idprofanter := 't';
    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString = xperiodo) and (utiles.verificarItemsLista(profSel, detfact.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) then Begin
        datosListados := True;
        nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);
        if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        if detfact.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, detfact.FieldByname('periodo').AsString);
        end;

        if detfact.FieldByName('idprof').AsString <> idprofanter then Begin   // Ruptura por Profesional
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(IntToStr(nrocol), salida);
            SubtotalProfesional(salida);
            totUB := 0;
          end;
          RupturaPorProfesional('clNavy', salida);
        end;

        if detfact.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(IntToStr(nrocol), salida);
            SubtotalProfesional(salida);
          end;
          RupturaObraSocial(salida, xperiodo, xtitulo, ''); // Ruptura por Obra Social
          idprofanter := ''; cantidad := 0; subtotal := 0; total := 0; totUB := 0;
        end;

        if (i >= nrocol) or (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfact.FieldByName('codpac').AsString <> idanter) or (detfact.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(IntToStr(nrocol), salida) else ListLinea(IntToStr(nrocol), salida);
          i := 0;
          if detfact.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        if (length(trim(detfact.FieldByName('ref1').AsString)) = 7) then periodo := detfact.FieldByName('ref1').AsString else periodo := xperiodo;

        paciente.getDatos(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
        Inc(i);
        if (length(trim(detfact.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfact.FieldByName('retiva').AsString;

        if (obsocial.FactNBU = 'N') or (length(trim(detfact.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfact.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfact.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfact.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfact.FieldByName('codanalisis').AsString);
          codigos[i] := detfact.FieldByName('codanalisis').AsString;
          montos [i] := setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0); // Valor de cada analisis
          nnbu       := True;
        end;

        it := i;

        subtotal := subtotal + montos[i];

        if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfact.FieldByName('codos').AsString;
        idprofanter := detfact.FieldByName('idprof').AsString;
        idanter     := detfact.FieldByName('codpac').AsString;
        ordenanter  := detfact.FieldByName('orden').AsString;
        npac        := detfact.FieldByName('nombre').AsString
      end;
      detfact.Next;
    end;
    it := i;
    ListarLineaDeAnalisis(IntToStr(nrocol), salida);

    if cantidad > 0 then SubtotalProfesional(salida);

    if totales[1] + cantidadordenes <> 0 then Begin   // Cantidades Finales
      if salida <> 'T' then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Total de Ordenes: ', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(25, list.Lineactual, '####', cantidadordenes, 2, 'Arial, negrita, 8');
        if usuario.usuario <> 'Laboratorio' then Begin
          list.Linea(30, list.Lineactual, 'Tot. Com. Arancel.: ', 3, 'Arial, negrita, 8', salida, 'N');
          list.importe(58, list.Lineactual, '', utiles.setNro2Dec(total), 4, 'Arial, negrita, 8');
          list.Linea(67, list.Lineactual, 'Total Facturado: ', 5, 'Arial, negrita, 8', salida, 'N');
          list.importe(96, list.Lineactual, '', totales[1], 6, 'Arial, negrita, 8');
          list.Linea(96, list.Lineactual, ' ', 7, 'Arial, negrita, 8', salida, 'S');
        end else
          list.Linea(95, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end else Begin
        list.LineaTxt(CHR18, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        list.LineaTxt(CHR18 + 'Tot. de Ordenes:  ', False);
        if usuario.usuario <> 'Laboratorio' then Begin
          list.importeTxt(cantidadordenes, 3, 0, False);
          list.LineaTxt(' Total Comp. Aran.: ', False);
          list.importeTxt(total, 7, 2, False);
          list.LineaTxt('    Total Facturado: ', False);
          list.importeTxt(totales[1], 10, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        end else Begin
          list.importeTxt(cantidad, 4, 0, True);
          Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        end;
      list.LineaTxt(utiles.sLlenarIzquierda(CHR18 + lin, 80, Caracter), True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
     end;
    end;
    listControl := False;
  end;

  if (interbase = 'S') then begin
    {detfactIB.Close;
    if not(detfactIB.Active) then detfactIB.Open;
    if not (ProcesamientoCentral) then ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''') else ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''');
    detfactIB.IndexFieldNames := 'Periodo;Codos;Idprof;Orden;Items';
    //firebird.Buscar(detfactIB, 'periodo', xperiodo);
    detfactIB.First;}

    if (factglobal) then __t := 'detfact_gl' else __t := 'detfact';

    if not (ProcesamientoCentral) then
      rsqlIB :=  ffirebird.getTransacSQL('select * from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by periodo, codos, idprof, orden, items')
    else
      rsqlIB :=  ffirebird.getTransacSQL('select * from ' + __t + ' where periodo = ' + '''' + xperiodo + '''' + ' order by periodo, codos, idprof, orden, items');

    rsqlIB.Open; rsqlIB.First;

    __peranter := '';

    obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
    ordenanter  := rsqlIB.FieldByName('orden').AsString;
    idprofanter := 't';
    while not rsqlIB.EOF do Begin
      if (rsqlIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (rsqlIB.FieldByName('periodo').AsString = xperiodo) and (utiles.verificarItemsLista(profSel, rsqlIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) then Begin
        datosListados := True;
        nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
        if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        if rsqlIB.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, rsqlIB.FieldByname('periodo').AsString);
        end;

        if rsqlIB.FieldByName('idprof').AsString <> idprofanter then Begin   // Ruptura por Profesional
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(IntToStr(nrocol), salida);
            SubtotalProfesional(salida);
            totUB := 0;
          end;
          RupturaPorProfesional('clNavy', salida);
        end;

        if rsqlIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(IntToStr(nrocol), salida);
            SubtotalProfesional(salida);
          end;
          RupturaObraSocial(salida, xperiodo, xtitulo, ''); // Ruptura por Obra Social
          idprofanter := ''; cantidad := 0; subtotal := 0; total := 0; totUB := 0;
        end;

        if (i >= nrocol) or (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (rsqlIB.FieldByName('codpac').AsString <> idanter) or (rsqlIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(IntToStr(nrocol), salida) else ListLinea(IntToStr(nrocol), salida);
          i := 0;
          if rsqlIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then begin
          paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
          paciente.Nombre := rsqlIB.FieldByName('nombre').AsString;
        end else
          paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);

        Inc(i);
        if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;

        if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
        __peranter := utiles.getPeriodoAAAAMM(periodo);

        if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := rsqlIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
          nbu.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
          codigos[i] := rsqlIB.FieldByName('codanalisis').AsString;
          montos [i] := setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0); // Valor de cada analisis
          nnbu       := True;
        end;

        it := i;

        subtotal := subtotal + montos[i];

        if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := rsqlIB.FieldByName('codos').AsString;
        idprofanter := rsqlIB.FieldByName('idprof').AsString;
        idanter     := rsqlIB.FieldByName('codpac').AsString;
        ordenanter  := rsqlIB.FieldByName('orden').AsString;
        npac        := rsqlIB.FieldByName('nombre').AsString;
        __perfact   := rsqlIB.FieldByName('ref1').AsString;
      end;
      rsqlIB.Next;
    end;
    it := i;
    ListarLineaDeAnalisis(IntToStr(nrocol), salida);

    rsqlIB.Close; rsqlIB.Free;


    {obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
    ordenanter  := detfactIB.FieldByName('orden').AsString;
    idprofanter := 't';
    while not detfactIB.EOF do Begin
      if (detfactIB.FieldByName('periodo').AsString <> xperiodo) then break;
      if (detfactIB.FieldByName('periodo').AsString = xperiodo) and (utiles.verificarItemsLista(profSel, detfactIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfactIB.FieldByName('codos').AsString)) then Begin
        datosListados := True;
        nomeclatura.getDatos(detfactIB.FieldByName('codanalisis').AsString);
        if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        if detfactIB.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfactIB.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, detfactIB.FieldByname('periodo').AsString);
        end;

        if detfactIB.FieldByName('idprof').AsString <> idprofanter then Begin   // Ruptura por Profesional
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(IntToStr(nrocol), salida);
            SubtotalProfesional(salida);
            totUB := 0;
          end;
          RupturaPorProfesional('clNavy', salida);
        end;

        if detfactIB.FieldByName('codos').AsString <> codosanter then Begin
          if cantidad > 0 then Begin
            ListarLineaDeAnalisis(IntToStr(nrocol), salida);
            SubtotalProfesional(salida);
          end;
          RupturaObraSocial(salida, xperiodo, xtitulo, ''); // Ruptura por Obra Social
          idprofanter := ''; cantidad := 0; subtotal := 0; total := 0; totUB := 0;
        end;

        if (i >= nrocol) or (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then Begin
          if (detfactIB.FieldByName('codpac').AsString <> idanter) or (detfactIB.FieldByName('orden').AsString <> ordenanter) then ListarLineaDeAnalisis(IntToStr(nrocol), salida) else ListLinea(IntToStr(nrocol), salida);
          i := 0;
          if detfactIB.FieldByName('orden').AsString <> ordenanter then idanter1 := '';
        end;

        paciente.getDatos(detfactIB.FieldByName('idprof').AsString, detfactIB.FieldByName('codpac').AsString);
        Inc(i);
        if (length(trim(detfactIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := detfactIB.FieldByName('retiva').AsString;

        if (length(trim(detfactIB.FieldByName('ref1').AsString)) = 7) then periodo := detfactIB.FieldByName('ref1').AsString else periodo := xperiodo;

        if (obsocial.FactNBU = 'N') or (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 4) then Begin
          obsocial.SincronizarArancel(detfactIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) = 0 then codigos[i] := detfactIB.FieldByName('codanalisis').AsString else codigos[i] := nomeclatura.codfact;
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          if nomeclatura.RIE <> '*' then montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if (obsocial.FactNBU = 'S') and (length(trim(detfactIB.FieldByName('codanalisis').AsString)) = 6) then Begin
          obsocial.SincronizarArancelNBU(detfactIB.FieldByname('codos').AsString, periodo);
          nbu.getDatos(detfactIB.FieldByName('codanalisis').AsString);
          codigos[i] := detfactIB.FieldByName('codanalisis').AsString;
          montos [i] := setValorAnalisis(detfactIB.FieldByName('codos').AsString, detfactIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0); // Valor de cada analisis
          nnbu       := True;
        end;

        it := i;

        subtotal := subtotal + montos[i];

        if detfactIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);
        codosanter  := detfactIB.FieldByName('codos').AsString;
        idprofanter := detfactIB.FieldByName('idprof').AsString;
        idanter     := detfactIB.FieldByName('codpac').AsString;
        ordenanter  := detfactIB.FieldByName('orden').AsString;
        npac        := detfactIB.FieldByName('nombre').AsString
      end;
      detfactIB.Next;
    end;
    it := i;
    ListarLineaDeAnalisis(IntToStr(nrocol), salida);}

    if cantidad > 0 then SubtotalProfesional(salida);

    if totales[1] + cantidadordenes <> 0 then Begin   // Cantidades Finales
      if salida <> 'T' then Begin
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Total de Ordenes: ', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(25, list.Lineactual, '####', cantidadordenes, 2, 'Arial, negrita, 8');
        if usuario.usuario <> 'Laboratorio' then Begin
          list.Linea(30, list.Lineactual, 'Tot. Com. Arancel.: ', 3, 'Arial, negrita, 8', salida, 'N');
          list.importe(58, list.Lineactual, '', utiles.setNro2Dec(total), 4, 'Arial, negrita, 8');
          list.Linea(67, list.Lineactual, 'Total Facturado: ', 5, 'Arial, negrita, 8', salida, 'N');
          list.importe(96, list.Lineactual, '', totales[1], 6, 'Arial, negrita, 8');
          list.Linea(96, list.Lineactual, ' ', 7, 'Arial, negrita, 8', salida, 'S');
        end else
          list.Linea(95, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      end else Begin
        list.LineaTxt(CHR18, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        list.LineaTxt(CHR18 + 'Tot. de Ordenes:  ', False);
        if usuario.usuario <> 'Laboratorio' then Begin
          list.importeTxt(cantidadordenes, 3, 0, False);
          list.LineaTxt(' Total Comp. Aran.: ', False);
          list.importeTxt(total, 7, 2, False);
          list.LineaTxt('    Total Facturado: ', False);
          list.importeTxt(totales[1], 10, 2, True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        end else Begin
          list.importeTxt(cantidad, 4, 0, True);
          Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
        end;
      list.LineaTxt(utiles.sLlenarIzquierda(CHR18 + lin, 80, Caracter), True); Inc(lineas); if controlarSalto then titulo1(periodo, titulo, columnas);
     end;
    end;
    listControl := False;

    //detfactIB.Close; detfactIB.Open;

  end;

  if presentar_inf then FinalizarInforme(salida);
end;

procedure TTFacturacionCCB.ListarOrdenesAuditadas(xperiodo: String; profSel: TStringList; presentar_inf: Boolean; salida: char);
var
  r: TQuery; i, j, lt: Integer; lst: String;
Begin
// falta interbase
  if profSel <> Nil then
    For j := 1 to profSel.Count do Begin
      r := setOrdenesAuditoria(xperiodo, profSel.Strings[j-1]);

      if r <> Nil then Begin
        if lt = 0 then Begin
          if salida <> 'T' then Begin
            list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
            list.Linea(0, 0, '*** Control Ordenes Auditadas ***', 1, 'Arial, negrita, 9', salida, 'S');
          end else Begin
            Inc(lineas); list.LineaTxt(' ', True); if controlarSalto then titulo6(xperiodo);
            list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + '*** Control Ordenes Auditadas ***' + list.modo_resaltado_cancelar + CHR15, True); Inc(lineas); if controlarSalto then titulo6(xperiodo);
          end;
          lt := 1;
          datosListados := True;
        end;

        if salida <> 'T' then list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S') else Begin
          list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo6(xperiodo);
        end;

        profesional.getDatos(profSel.Strings[j-1]);
        if salida <> 'T' then Begin
          list.Linea(0, 0, 'Profesional: ' + profesional.nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'S');
          list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5, clNavy', salida, 'S');
        end else Begin
          list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + 'Profesional: ' + profesional.nombre + list.modo_resaltado_cancelar + CHR15, True); Inc(lineas); if controlarSalto then titulo6(xperiodo);
          list.LineaTxt(' ', True); Inc(lineas); if controlarSalto then titulo6(xperiodo);
        end;

        r.Open; i := 0;
        while not r.Eof do Begin
          if i >= lineas_audit then Begin
            if salida <> 'T' then list.Linea(0, 0, lst, 1, 'Arial, normal, 8', salida, 'S') else Begin
              list.LineaTxt(lst, True);
              Inc(lineas); if controlarSalto then titulo6(xperiodo);
            end;
            lst := ''; i := 0;
          end;
          Inc(i);
          lst := lst + r.FieldByName('items').AsString + '-' + r.FieldByName('nroauditoria').AsString + ' / ';
          r.Next;
        end;

        if i > 0 then Begin
          if salida <> 'T' then list.Linea(0, 0, lst, 1, 'Arial, normal, 8', salida, 'S') else Begin
            list.LineaTxt(lst, True);
            Inc(lineas); if controlarSalto then titulo6(xperiodo);
          end;
        end;

        r.Close; r.Free;
      end;
      if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S') else Begin
        list.LineaTxt('', True);
        Inc(lineas); if controlarSalto then titulo6(xperiodo);
      end;
    end;

  if presentar_inf then FinalizarInforme(salida);
end;

procedure TTFacturacionCCB.titulo6(xperiodo: String);
// Objetivo...: Titulo para impresion en modo texto
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt('Control Ordenes Auditoria', true);
  list.LineaTxt('Periodo de Facturacion: ' + xperiodo + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('Items - Nro. de Orden', true);
  lineas := 6;
end;

{ ----------------------------------------------------------------------------- }
procedure TTFacturacionCCB.ListarContorlesAuditoria(xperiodo: String; salida: Char);
var
  r: TQuery;
  l: TStringList;
  i: Integer;
begin
  list.altopag := 0; list.m := 0;
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Informe de Auditoría', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Laboratorio', 1, 'Arial, cursiva, 8');
  list.Titulo(30, list.Lineactual, 'Fecha-Hola           Usuario', 2, 'Arial, cursiva, 8');
  list.Titulo(57, list.Lineactual, 'Directorio', 3, 'Arial, cursiva, 8');
  list.Titulo(90, list.Lineactual, 'Transf. Final', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.LineaLargoPagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  list.Linea(0, 0, 'Laboratorios Exportados ', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  DatosListados := False;
  r := setDatosExport(xperiodo);
  r.Open;
  while not r.EOF do Begin
    list.Linea(0, 0, r.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(30, list.Lineactual, r.FieldByName('fechahora').AsString + '  ' + r.FieldByName('usuario').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(57, list.Lineactual, r.FieldByName('directorio').AsString , 3, 'Arial, normal, 8', salida, 'S');
    DatosListados := True;
    r.Next;
  end;
  r.Close; r.Free;

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Laboratorios Importados ', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  l := setDatosImportados(xperiodo);
  for i := 1 to l.Count do Begin
    profesional.getDatos(l.Strings[i-1]);
    list.Linea(0, 0,profesional.nombre, 1, 'Arial, normal, 8', salida, 'N');
    if datosdb.Buscar(datosimport, 'periodo', 'idprof', xperiodo, l.Strings[i-1]) then Begin
      list.Linea(30, list.Lineactual, datosimport.FieldByName('fechahora').AsString + '  ' + datosimport.FieldByName('usuario').AsString, 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(57, list.Lineactual, datosimport.FieldByName('directorio').AsString , 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(90, list.Lineactual, datosimport.FieldByName('transferencia').AsString , 4, 'Arial, normal, 8', salida, 'S');
    end else
      list.Linea(90, list.Lineactual, '', 2, 'Arial, normal, 8', salida, 'S');

    DatosListados := True;
  end;
  l.Destroy;

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Laboratorios Modificados', 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  r := setDatosIngresados(xperiodo);
  r.Open;
  while not r.EOF do Begin
    list.Linea(0, 0, r.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(30, list.Lineactual, r.FieldByName('fechahora').AsString + '  ' + r.FieldByName('usuario').AsString, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(57, list.Lineactual, r.FieldByName('directorio').AsString , 3, 'Arial, normal, 8', salida, 'S');
    DatosListados := True;
    r.Next;
  end;
  r.Close; r.Free;
  list.FinList;
end;

procedure TTFacturacionCCB.ListarOrdenesAuditoriaFacturadas(lista: TStringList; salida: char);
// Objetivo...: Controlar Ordenes Audorizadas y rechazadas
var
  la, lr, lr2: TStringList; i: Integer; idanter, linea: String;
Begin
  AssignFile(ar1, dbs.DirSistema + '\controles_auditoria.txt');
  AssignFile(ar2, dbs.DirSistema + '\control_audit.txt');
  rewrite(ar1);
  WriteLn(ar1, 'Registro de Control  - Creacion: ' + utiles.setFechaActual + ' -  ' + utiles.setHoraActual24);
  WriteLn(ar1, '');

  if salida <> 'T' then Begin
    if (salida = 'P') or (salida = 'I') then list.Setear(salida);
    list.Titulo(0, 0, 'Control Ordenes Auditoria Facturadas', 1, 'Arial, normal, 12');
    list.Titulo(0, 0, list.Linealargopagina(salida) , 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
  end;

  la := TStringList.Create; lr := TStringList.Create; lr2 := TStringList.Create;
  for i := 0 to lista.Count - 1 do Begin
    if (Copy(lista.Strings[i], 1, 6) <> idanter) and (Length(Trim(idanter)) > 0) then Begin
      Listar_Ordenes(idanter, la, lr, lr2, salida);
      la.Clear; lr.Clear; lr2.Clear;
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    end;
    if Copy(lista.Strings[i], 17, 1) = 'F' then la.Add(Copy(lista.Strings[i], 7, 10)) else
      if Copy(lista.Strings[i], 17, 1) = 'X' then lr.Add(Copy(lista.Strings[i], 7, 10)) else
        if Copy(lista.Strings[i], 17, 1) = 'N' then lr2.Add(Copy(lista.Strings[i], 7, 10));
    idanter := Copy(lista.Strings[i], 1, 6);
  end;
  Listar_Ordenes(idanter, la, lr, lr2, salida);

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Nros. de Documentos Inexistentes', 1, 'Arial, negrita, 9', salida, 'S');
  writeln(ar1, '');
  writeln(ar1, 'Nros. de Documentos Inexistentes');

  reset(ar2);
  while not eof(ar2) do Begin
    ReadLn(ar2, linea);
    if Pos('**', linea) > 0 then Begin
      list.Linea(0, 0, linea, 1, 'Arial, normal, 8', salida, 'S');
      writeln(ar1, linea);
    end;
  end;

  closeFile(ar1);
  closeFile(ar2);
  la.Destroy; lr.Destroy; lr2.Destroy;

  list.FinList;
end;

procedure TTFacturacionCCB.Listar_Ordenes(id: String; la, lr, lr2: TStringList; salida: Char);
// Objetivo...: Controlar Ordenes Audorizadas y rechazadas
var
  i, j, t: Integer; l1: String;
Begin
  if salida <> 'T' then Begin
    profesional.getDatos(id);
    list.Linea(0, 0, 'Profesional: ' + id + ' - ' + profesional.nombre, 1, 'Arial, negrita, 10, clNavy', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    t := 0;
    for j := 0 to la.Count - 1 do Begin   // Ordenes Aceptadas
      if j = 0 then Begin
        list.Linea(0, 0, 'Ordenes Facturadas: ', 1, 'Arial, negrita, 9', salida, 'S');
        i := 1;
        writeln(ar1, 'Ordenes Facturadas');
      end;
      l1 := l1 + la.Strings[j] + '  ';
      Inc(t);
      if t > lineas_audit - 2 then Begin
        listOrd(l1, salida);
        l1 := ''; t := 0;
      end;
    end;
    listOrd(l1, salida);

    l1 := ''; t := 0;

    for j := 0 to lr.Count - 1 do Begin  // Ordenes Rechazadas
      if j = 0 then Begin
        writeln(ar1, '');
        list.Linea(0, 0, 'Ordenes Rechazadas: ', 1, 'Arial, negrita, 9', salida, 'S');
        i := 1;
        writeln(ar1, 'Ordenes Rechazadas');
      end;
      l1 := l1 + lr.Strings[j] + '  ';
      Inc(t);
      if t > lineas_audit - 1 then Begin
        listOrd(l1, salida);
        l1 := ''; t := 0;
      end;
    end;
    listOrd(l1, salida);
    l1 := '';

    l1 := ''; t := 0;

    for j := 0 to lr2.Count - 1 do Begin  // Ordenes Rechazadas de 2do. Nivel
      if j = 0 then Begin
        writeln(ar1, '');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
        list.Linea(0, 0, 'Ordenes de 2do. Nivel Rechazadas: ', 1, 'Arial, negrita, 9', salida, 'S');
        i := 1;
        writeln(ar1, 'Ordenes de 2do. Nivel Rechazadas');
      end;
      l1 := l1 + lr2.Strings[j] + '  ';
      Inc(t);
      if t > lineas_audit - 1 then Begin
        listOrd(l1, salida);
        l1 := ''; t := 0;
      end;
    end;
    listOrd(l1, salida);
    l1 := '';
  end;
end;

procedure TTFacturacionCCB.listOrd(l1: String; salida: Char);
// Objetivo...: Listar Renglon de ordenes
Begin
  if Length(Trim(l1)) > 0 then Begin
  if salida <> 'T' then list.Linea(0, 0, l1, 1, 'Arial, normal, 8', salida, 'S');
  writeln(ar1, l1);
  end;
end;

{--------------------------------------------------------------------------------}

procedure TTFacturacionCCB.ListarResumenRetencionesIVA(xperiodo, xtitulo: String; profSel: TStringList; ObrasSocSel: TStringList; salida: char; xinf_com: Boolean);
// Objetivo...: Generar Informe Resumen Retenciones I.V.A.
var
  id_prof, archdest: string;
  r: TQuery;
Begin
  IniciarArreglos;

  if (exporta_web) then begin
    //utilesarchivos.BorrarArchivos(dbs.DirSistema + '\export_reportes\web_totalesri', '*.txt');
    //list.AnularCaracteresTexto;
    //salida := 'T';
    //ExportarDatos := true;
    //list.IniciarImpresionModoTexto(10000);
    //list.exportar_rep := true;

    datosdb.tranSQL(cabfactos.DatabaseName, 'delete from wtotalesprof where periodo = ' + '''' + xperiodo + '''');
  end;

  informe_ivaret := True;
  if (salida = 'P') or (salida = 'I') then list.Setear(salida);
  pag := 0; datosListados := False;
  Periodo := xperiodo;
  if (salida = 'P') or (salida = 'I') then Begin
    list.altopag := 0; list.m := 0;
    list.IniciarTitulos;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, xtitulo, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, 'Resúmen por Profesionales', 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, 'Período de Facturación: ' + xperiodo, 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 8');
    list.Titulo(0, 0, 'Código   Obra Social', 1, 'Arial, cursiva, 8');
    list.Titulo(36, list.Lineactual, 'Ord.', 2, 'Arial, cursiva, 8');
    list.Titulo(43, list.Lineactual, 'Det.', 3, 'Arial, cursiva, 8');
    list.Titulo(54, list.Lineactual, 'Gravado', 4, 'Arial, cursiva, 8');
    list.Titulo(66, list.Lineactual, 'Exento', 5, 'Arial, cursiva, 8');
    list.Titulo(78, list.Lineactual, 'I.V.A.', 6, 'Arial, cursiva, 8');
    list.Titulo(89, list.Lineactual, 'Total', 7, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end;
  if salida = 'T' then Begin
    if not ExportarDatos then list.IniciarImpresionModoTexto(LineasPag);
    titulo7(xperiodo, xtitulo);
  end;

  // Si exporta, solo transfiere las indicadas
  if not (exporta_web) then begin
    ObrasSocSel := TStringList.Create;
    r := obsocial.setobsocialsAlf;
    r.Open;
    while not r.EOF do Begin
      if r.FieldByName('retieneiva').AsString = 'S' then ObrasSocSel.Add(r.FieldByName('codos').AsString);
      r.Next;
    end;
    r.Close; r.Free;
  end;

  facturacion.ConectarTotalesProf;

  if (interbase = 'N') then begin
    detfact.IndexFieldNames := 'Periodo;Idprof;Codos;Orden;Items';
    detfact.First;
    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; montos[3] := 0; montos[4] := 0; ordenanter := ''; codosanter := ''; idprofanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; datosListados := False;
    while not detfact.EOF do Begin
      if (detfact.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, detfact.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, detfact.FieldByName('codos').AsString)) then Begin
        if not datosListados then Begin
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
          codosanter := detfact.FieldByName('codos').AsString;
          datosListados := True;
        end;

        if detfact.FieldByName('idprof').AsString <> idprofanter then Begin
          //if (totprestaciones > 0) and (cantidad > 0) then LineaObraSocialIvaRet(xperiodo, salida, xinf_com);
          RupturaPorProfesional3(xperiodo, xtitulo, salida);
          if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');


          if salida = 'T' then Begin
            if not (exporta_web) then begin
              list.LineaTxt('', True);
              Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
            end else begin
              {
              if (idprofanter <> '') then begin
                list.FinalizarExportacion;
                archdest := copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + idprofanter + '_REIN' + '.txt';
                CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_totalesri\' + archdest), false);
                list.IniciarImpresionModoTexto(10000);
                list.exportar_rep := true;
              end;
              }
            end;

          end;
          if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social
        end;

        nomeclatura.getDatos(detfact.FieldByName('codanalisis').AsString);
        if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones

        if (detfact.FieldByName('codos').AsString <> codosanter) and (totprestaciones > 0) and (cantidad > 0) then LineaObraSocialIvaRet(xperiodo, salida, xinf_com);

        if (detfact.FieldByName('codos').AsString <> codosanter) and (totprestaciones > 0) and (cantidad > 0) then LineaObraSocialIvaRet(xperiodo, salida, xinf_com);
        if detfact.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if detfact.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(detfact.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);
        end;
         obsocial.SincronizarArancel(detfact.FieldByname('codos').AsString, xperiodo);

        if obsocial.FactNBU = 'N' then Begin
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          paciente.getDatos(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if obsocial.FactNBU = 'S' then Begin
          paciente.getDatos(detfact.FieldByName('idprof').AsString, detfact.FieldByName('codpac').AsString);
          subtotal := subtotal + setValorAnalisis(detfact.FieldByName('codos').AsString, detfact.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis
        end;

        codosanter  := detfact.FieldByName('codos').AsString;
        idprofanter := detfact.FieldByName('idprof').AsString;
        ordenanter  := detfact.FieldByName('orden').AsString;
      end;
      detfact.Next;
    end;

    LineaObraSocialIvaRet(xperiodo, salida, xinf_com);

    if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social
    informe_ivaret := False;
  end;

  if (interbase = 'S') then begin
    if not (ProcesamientoCentral) then rsqlIB := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + laboratorioactual + '''' + ' order by Periodo, Idprof, Codos, Orden, Items') else rsqlIB := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' order by Periodo, Idprof, Codos, Orden, Items');
    rsqlIB.Open; rsqlIB.First;
    cantidad := 0; subtotal := 0; montos[1] := 0; montos[2] := 0; montos[3] := 0; montos[4] := 0; ordenanter := ''; codosanter := ''; idprofanter := ''; totUB := 0; totUG := 0; canUB := 0; canUG := 0; tot9984 := 0; ttotUB := 0; ttotUG := 0; ccanUB := 0; ccanUG := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0;
    ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; datosListados := False; __peranter := '';
    while not rsqlIB.EOF do Begin

      if (rsqlIB.FieldByName('periodo').AsString >= xperiodo) and (utiles.verificarItemsLista(profSel, rsqlIB.FieldByName('idprof').AsString)) and (utiles.verificarItemsLista(ObrasSocSel, rsqlIB.FieldByName('codos').AsString)) then Begin
        if not datosListados then Begin
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, xperiodo);
          codosanter := rsqlIB.FieldByName('codos').AsString;
          datosListados := True;
        end;

        if (obsocial.FactNBU = 'N') or (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 4) then Begin
           nomeclatura.getDatos(rsqlIB.FieldByName('codanalisis').AsString);
           if nomeclatura.CF <> 'F' then Inc(totprestaciones); // Total de prestaciones
        end;

        if (obsocial.FactNBU = 'S') and (length(trim(rsqlIB.FieldByName('codanalisis').AsString)) = 6) then Inc(totprestaciones);

        if (rsqlIB.FieldByName('codos').AsString <> codosanter) and (totprestaciones > 0) and (cantidad > 0) then LineaObraSocialIvaRet(xperiodo, salida, xinf_com);

        if (rsqlIB.FieldByName('idprof').AsString <> idprofanter) then Begin

          RupturaPorProfesional3(xperiodo, xtitulo, salida);

          if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          if salida = 'T' then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
          end;

          if totales[1] + totales[2] > 0 then begin
            SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social;
          end;
        end;

        if rsqlIB.FieldByname('codos').AsString <> codosanter then Begin
          obsocial.getDatos(rsqlIB.FieldByname('codos').AsString);
        end;

        profesional.SincronizarCategoria(rsqlIB.FieldByName('idprof').AsString, xperiodo);

        if (length(trim(rsqlIB.FieldByName('ref1').AsString)) = 7) then periodo := rsqlIB.FieldByName('ref1').AsString else periodo := xperiodo;

         // 21/03/2022
        if  (utiles.getPeriodoAAAAMM(periodo) > __peranter) then __maxperiodo := periodo;
        __peranter := utiles.getPeriodoAAAAMM(periodo);

        if (rsqlIB.FieldByName('codos').AsString <> codosanter) and (totprestaciones > 0) and (cantidad > 0) then LineaObraSocialIvaRet(xperiodo, salida, xinf_com);
        if rsqlIB.FieldByName('orden').AsString <> ordenanter then Inc(cantidad);

        if obsocial.FactNBU = 'N' then Begin
          obsocial.SincronizarArancel(rsqlIB.FieldByname('codos').AsString, periodo);
          if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
          paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);
          if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
          if nomeclatura.RIE <> '*' then subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
        end;
        if obsocial.FactNBU = 'S' then Begin
          obsocial.SincronizarArancelNBU(rsqlIB.FieldByname('codos').AsString, periodo);
          paciente.getDatos(rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codpac').AsString);
          if (length(trim(rsqlIB.FieldByName('retiva').AsString)) > 0) then paciente.Gravadoiva := rsqlIB.FieldByName('retiva').AsString;
          subtotal := subtotal + setValorAnalisis(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('codanalisis').AsString, 0, 0, 0, 0);  // Valor de cada analisis

          totivaol[1] := totivaol[1] + rsqlIB.FieldByName('monto').AsFloat;
          totivaol[2] := totivaol[2] + rsqlIB.FieldByName('iva').AsFloat;
          totivaol[3] := totivaol[3] + rsqlIB.FieldByName('exento').AsFloat;
        end;

        codosanter  := rsqlIB.FieldByName('codos').AsString;
        idprofanter := rsqlIB.FieldByName('idprof').AsString;
        ordenanter  := rsqlIB.FieldByName('orden').AsString;
      end;
      rsqlIB.Next;
    end;

    LineaObraSocialIvaRet(xperiodo, salida, xinf_com);

    if totales[1] + totales[2] > 0 then SubtotalObraSocialResumenProf('Subtotal:', salida);    // Subtotales Obra Social
    informe_ivaret := False;

    rsqlIB.Close; rsqlIB.Free;
  end;

  facturacion.DesconectarTotalesProf;

  if (exporta_web) and (salida = 'T') then begin
    list.FinalizarExportacion;
    list.exportar_rep := false;
    {
    list.FinalizarExportacion;
    list.exportar_rep := false;
    CopyFile(PChar(dbs.DirSistema + '\list.txt'), PChar(dbs.DirSistema + '\export_reportes\web_totalesri\' + copy(xperiodo, 1, 2) + copy(xperiodo, 4, 6) + '_' + idprofanter + '_REIN' + '.txt'), false);
    }
  end else begin
    if salida <> 'N' then FinalizarInforme(salida);
    //list.FinList;
  end;

  if salida = 'N' then list.m := 0;

  exporta_web := false;

end;

procedure TTFacturacionCCB.LineaObraSocialIvaRet(xperiodo: String; salida: char; xinf_com: Boolean);
begin
  subtotal := subtotal + utiles.setNro2Dec(tot9984) + utiles.setNro2Dec(caran);
  obsocial.getDatos(codosanter);
  obsocial.SincronizarPosicionFiscal(codosanter, Periodo);
  if (salida = 'P') or (salida = 'I') then Begin
    if xinf_com then Begin
      list.Linea(0, 0, obsocial.Nombrec, 1, 'Arial, normal, 7', salida, 'N');
      list.Linea(40, list.Lineactual, obsocial.direccion, 2, 'Arial, normal, 7', salida, 'N');
      list.Linea(70, list.Lineactual, obsocial.localidad, 3, 'Arial, normal, 7', salida, 'N');
      list.Linea(90, list.Lineactual, obsocial.nrocuit, 4, 'Arial, normal, 7', salida, 'S');
    end;
    list.Linea(0, 0, ' ' + obsocial.codos + '  ' + Copy(obsocial.Nombre, 1, 30), 1, 'Arial, normal, 8', salida, 'N');
    list.importe(38, list.Lineactual, '####', cantidad, 2, 'Arial, normal, 8');
    list.importe(45, list.Lineactual, '####', totprestaciones, 3, 'Arial, normal, 8');
    list.importe(60, list.Lineactual, '', totiva[1] {ivaret + ivaret9984 + ivaretcaran}, 4, 'Arial, normal, 8');
    list.importe(71, list.Lineactual, '', totiva[2] {ivaexento + ivaexe9984 + ivaexecaran}, 5, 'Arial, normal, 8');
    list.importe(82, list.Lineactual, '', totiva[3] {(ivaret + ivaret9984 + ivaretcaran) * (obsocial.retencioniva * 0.01)}, 6, 'Arial, normal, 9');
    list.importe(94, list.Lineactual, '##0.00', StrToFloat(utiles.FormatearNumero(FloatToStr((totiva[3])))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaexento + ivaexe9984 + ivaexecaran)))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaret + ivaret9984 + ivaretcaran)))), 7, 'Arial, normal, 8');
    list.Linea(99, list.Lineactual, '  ', 8, 'Arial, normal, 8', salida, 'S');
    if xinf_com then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'T' then Begin
    if xinf_com then Begin
      list.LineaTxt(Copy(obsocial.Nombrec, 1, 45) + utiles.espacios(46 - Length(TrimRight(Copy(obsocial.Nombrec, 1, 45)))), False);
      list.LineaTxt(Copy(obsocial.direccion, 1, 30) + utiles.espacios(31 - Length(TrimRight(Copy(obsocial.direccion, 1, 30)))), False);
      list.LineaTxt(Copy(obsocial.localidad, 1, 20) + utiles.espacios(21 - Length(TrimRight(Copy(obsocial.localidad, 1, 20)))), False);
      list.LineaTxt(obsocial.nrocuit, True);
      Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
    end;
    if controlarSalto then titulo7(periodo, titulo);
    list.LineaTxt('  ' + obsocial.codos + ' ' + Copy(obsocial.Nombre, 1, 38) + utiles.espacios(45 - Length(TrimRight(Copy(obsocial.Nombre, 1, 38)))), False);
    list.ImporteTxt(cantidad, 4, 0, False);
    list.ImporteTxt(totprestaciones, 5, 0, False);
    list.LineaTxt('         ', False);
    list.importeTxt(totiva[1] {ivaret + ivaret9984 + ivaretcaran}, 10, 2, False);
    list.importeTxt(totiva[2] {ivaexento + ivaexe9984 + ivaexecaran}, 10, 2, False);
    list.importeTxt(totiva[3] {(ivaret + ivaret9984 + ivaretcaran) * (obsocial.retencioniva * 0.01)}, 10, 2, False);
    list.importeTxt(StrToFloat(utiles.FormatearNumero(FloatToStr(((ivaret + ivaret9984 + ivaretcaran) * (obsocial.retencioniva * 0.01))))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaexento + ivaexe9984 + ivaexecaran)))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaret + ivaret9984 + ivaretcaran)))), 10, 2, True);
    Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
    if xinf_com then Begin
      list.LineaTxt('', True);
      Inc(lineas); if controlarSalto then titulo7(periodo, titulo);
    end;
  end;

  if Length(Trim(obsocial.codosdif)) = 0 then GuardarTotalProfIVA(xperiodo, idprofanter, codosanter, StrToFloat(utiles.FormatearNumero(FloatToStr(((ivaret + ivaret9984 + ivaretcaran) * (obsocial.retencioniva * 0.01))))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaexento + ivaexe9984 + ivaexecaran)))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaret + ivaret9984 + ivaretcaran)))), totiva[1] + totiva[2]);
  if Length(Trim(obsocial.codosdif)) > 0 then GuardarTotalProfIVA(xperiodo, idprofanter, obsocial.codosdif, StrToFloat(utiles.FormatearNumero(FloatToStr(((ivaret + ivaret9984 + ivaretcaran) * (obsocial.retencioniva * 0.01))))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaexento + ivaexe9984 + ivaexecaran)))) + StrToFloat(utiles.FormatearNumero(FloatToStr((ivaret + ivaret9984 + ivaretcaran)))), totiva[1] + totiva[2]);

  if (exporta_web) and (idprofanter <> '') then GuardarTotalProfIVAExport(xperiodo, idprofanter, codosanter, totivaol[1], totivaol[2], totivaol[3], totivaol[2] + totivaol[3], cantidad, totprestaciones);
  //utiles.msgError(idprofanter + ' ' + floattostr(totiva[2]));

  totales[1] := totales[1] + cantidad;
  totales[2] := totales[2] + totprestaciones;
  totales[3] := totales[3] + totiva[1];
  totales[4] := totales[4] + totiva[3];
  totales[9] := totales[9] + totiva[2];
  // Totales Finales
  totales[5]  := totales[5]  + cantidad;
  totales[6]  := totales[6]  + totprestaciones;
  totales[7]  := totales[7]  + totiva[1];
  totales[8]  := totales[8]  + totiva[3];
  totales[10] := totales[10] + totiva[2];

  cantidad := 0; totprestaciones := 0; totUB := 0; totUG := 0; canUB := 0; canUG := 0; caran := 0; subtotal := 0; tot9984 := 0; ivaret := 0; ivaret9984 := 0; ivaretcaran := 0; ivaexento := 0; ivaexe9984 := 0; ivaexecaran := 0;
  totiva[1] := 0; totiva[2] := 0; totiva[3] := 0; _caran := 0;
  totivaol[1] := 0; totivaol[2] := 0; totivaol[3] := 0;

end;

procedure TTFacturacionCCB.titulo7(xperiodo, xtitulo: String);
// Objetivo...: Titulo para impresion en modo texto
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt(xtitulo, true);
  list.LineaTxt('Resumen por Profesionales', true);
  list.LineaTxt('Periodo de Facturacion: ' + xperiodo + utiles.espacios(30) + IntToStr(pag), true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('Codigo  Obra Social                               Nro.Ord. Cant.Det.      Subtotal    Exento    I.V.A.     Total' + CHR18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  lineas := 8;
end;

procedure TTFacturacionCCB.titulo8(xperiodo: String);
// Objetivo...: Titulo para impresion en modo texto
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt('Inf. de Control Totales Fact. Profesionales - Período: ' + xperiodo + '    ' + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt(CHR18 + 'Profesional                            Comprobante          Neto Tot.Fact.' + CHR18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  lineas := 5;
end;

procedure TTFacturacionCCB.titulo9(xperiodo: String);
// Objetivo...: Titulo para impresion en modo texto
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt('Inf. de Control Totales de Obras Sociales - Período: ' + xperiodo + '    ' + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  list.LineaTxt('Obra Social                                 Monto Fact.', True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  lineas := 5;
end;

procedure TTFacturacionCCB.titulo10(xperiodo: String);
// Objetivo...: Titulo para impresion en modo texto
begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  list.LineaTxt('Resumen Facturacion Profesionales - Periodo: ' + xperiodo + '    ' + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  if not u_h then list.LineaTxt(CHR18 + 'Profesional                                               Neto Tot.Fact.' + CHR18, True) else
    list.LineaTxt(CHR18 + 'Profesional                                             U.Hon. Tot.Fact.' + CHR18, True);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
  lineas := 5;
end;

{--------------------------------------------------------------------------------}

procedure TTFacturacionCCB.ExportarInforme(xarchivo: String);
// Objetivo...: Exportar Informe
Begin
  ExportarDatos := True;
  list.ExportarInforme(xarchivo);
  CHR18 := ''; CHR15 := ''; Caracter := '';
end;

procedure TTFacturacionCCB.FinalizarExportacion;
// Objetivo...: Finalizar exportacion
Begin
  list.FinalizarExportacion;
  ExportarDatos := False;
  CHR18 := CHR(18); CHR15 := CHR(15); Caracter := '-';
end;

{ ============================================================================== }

procedure TTFacturacionCCB.Bloquear;
var
  bloqueos: TTable;
begin
  bloqueos := datosdb.openDB('bloqueos', '', '', dbconexion);
  bloqueos.Open;
  if bloqueos.RecordCount > 0 then bloqueos.Edit else bloqueos.Append;
  bloqueos.FieldByName('tarea1').AsString := '1';
  try
    bloqueos.Post
   except
    bloqueos.Cancel
  end;
  datosdb.closeDB(bloqueos);
end;

function  TTFacturacionCCB.verificarBloqueo: Boolean;
var
  bloqueos: TTable;
begin
  Result := False;
  bloqueos := datosdb.openDB('bloqueos', '', '', dbconexion);
  bloqueos.Open;
  if bloqueos.RecordCount > 0 then Begin
    bloqueos.First;
    if bloqueos.FieldByName('tarea1').AsString = '1' then Result := True;
  end;
  bloqueos.Close;
end;

procedure TTFacturacionCCB.QuitarBloqueo;
var
  bloqueos: TTable;
begin
  bloqueos := datosdb.openDB('bloqueos', '', '', dbconexion);
  bloqueos.Open;
  if bloqueos.RecordCount > 0 then bloqueos.Edit else bloqueos.Append;
  bloqueos.FieldByName('tarea1').AsString := '0';
  try
    bloqueos.Post
   except
    bloqueos.Cancel
  end;
  datosdb.closeDB(bloqueos);
end;

{ ----------------------------------------------------------------------------- }

procedure TTFacturacionCCB.ReiniciarProcesamientoIndividual;
begin
  {if (ibase <> nil) then begin
    ibase.Desconectar;
    ibase := nil;
  end;}
  if (ffirebird <> nil) then begin
    if (pos('FACTLABWORK.GDB', ffirebird.IBDatabase.DatabaseName) = 0) then begin
      ffirebird.Desconectar;
      ffirebird := nil;
      InstanciarTablas('S');
    end;
  end;
  __c := '';
end;


procedure TTFacturacionCCB.PrepararRegistrosTransferenciaFinalTodos(xperiodo: string);
// Objetivo...: Iniciar las Estructuras de Información antes de la Integración Final
Begin
  if (interbase = 'N') then begin
    datosdb.tranSQL(DBCentral, 'DELETE FROM cabfact');
    datosdb.tranSQL(DBCentral, 'DELETE FROM detfact');
    datosdb.tranSQL(DBCentral, 'DELETE FROM idordenes');
  end;
  {if (tibase) then begin
    if (ibase = nil) then begin
      ibase := TTFirebird.Create;
      firebird.getModulo('facturacion');
      ibase.Conectar(firebird.Host + 'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);
      cabexptIB := ibase.InstanciarTabla('cabfact');
      detexptIB := ibase.InstanciarTabla('detfact');
      idexptIB  := ibase.InstanciarTabla('idordenes');

      // 16/04/2014
      //if (ffirebird <> nil) then ffirebird.Desconectar;

      //ffirebird := Nil;
    end;
  end;

  if (ibase <> nil) then begin
      ibase.TransacSQL('DELETE FROM cabfact WHERE periodo = ' + '''' + xperiodo + '''');
      ibase.TransacSQL('DELETE FROM detfact WHERE periodo = ' + '''' + xperiodo + '''');
      ibase.TransacSQL('DELETE FROM idordenes WHERE periodo = ' + '''' + xperiodo + '''');
  end;}

  if (interbase = 'S') then begin
    lote.Clear;
    lote.Add('DELETE FROM cabfact WHERE periodo = ' + '''' + xperiodo + '''');
    lote.Add('DELETE FROM detfact WHERE periodo = ' + '''' + xperiodo + '''');
    lote.Add('DELETE FROM idordenes WHERE periodo = ' + '''' + xperiodo + '''');
  end;

end;

procedure TTFacturacionCCB.PrepararRegistrosTransferenciaFinal(xperiodo, xidprof: String);
// Objetivo...: Iniciar las Estructuras de Información antes de la Integración Final,
//              para un profesional
Begin
  if (interbase = 'N') then begin
    datosdb.tranSQL(DBCentral, 'DELETE FROM cabfact where idprof = ' + '"' + xidprof + '"');
    datosdb.tranSQL(DBCentral, 'DELETE FROM detfact where idprof = ' + '"' + xidprof + '"');
    datosdb.tranSQL(DBCentral, 'DELETE FROM idordenes where idprof = ' + '"' + xidprof + '"');
  end;
  {if (tibase) then begin // 16/04/2014
    if (ibase = nil) then begin
      ibase := TTFirebird.Create;
      firebird.getModulo('facturacion');
      ibase.Conectar(firebird.Host + 'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);

      {cabexptIB := ibase.InstanciarTabla('cabfact');
      detexptIB := ibase.InstanciarTabla('detfact');
      idexptIB  := ibase.InstanciarTabla('idordenes');}
      {if (ffirebird <> nil) then ffirebird.Desconectar;

      ffirebird := Nil;
    end;

    ibase.transacSQL('DELETE FROM cabfact where idprof = ' + '"' + xidprof + '"' + ' AND periodo = ' + '''' + xperiodo + '''');
    ibase.transacSQL('DELETE FROM detfact where idprof = ' + '"' + xidprof + '"' + ' AND periodo = ' + '''' + xperiodo + '''');
    ibase.transacSQL('DELETE FROM idordenes where idprof = ' + '"' + xidprof + '"' + ' AND periodo = ' + '''' + xperiodo + '''');}

  if (interbase = 'S') then begin
    lote.Add('DELETE FROM cabfact where idprof = ' + '"' + xidprof + '"' + ' AND periodo = ' + '''' + xperiodo + '''');
    lote.Add('DELETE FROM detfact where idprof = ' + '"' + xidprof + '"' + ' AND periodo = ' + '''' + xperiodo + '''');
    lote.Add('DELETE FROM idordenes where idprof = ' + '"' + xidprof + '"' + ' AND periodo = ' + '''' + xperiodo + '''');
  end;

end;

procedure TTFacturacionCCB.ReiniciarProcesamientoCentral;
begin
  //if (ibase <> nil) then ibase.Desconectar;
  proceso_central := false;
end;

procedure TTFacturacionCCB.TransferenciaFinal(xperiodo, xidprof, xprofesional: String);
// Objetivo...: Transferir datos Importados/Locales a la Base de Datos Final
var
  cabexpt, detexpt, idexpt: TTable; dir, codosant, _dir, osiva: String;
  monto1, monto2, monto3, monto4: double;
begin
  if (interbase = 'N') then begin
    if DireccionarLaboratorio(xperiodo, xidprof) then Begin // Activamos el directorio a Exportar
      dir := directorio;
      // Direccionamos la base de datos central
      ProcesarDatosCentrales(xperiodo);
      // Instanciamos las tablas en su directorio original
      cabexpt := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', dir);
      idexpt  := datosdb.openDB('idordenes', 'Periodo;Idprof', '', dir);
      detexpt := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', dir);
      // Copiamos los datos a la base de datos central
      cabexpt.Open;
      while not cabexpt.EOF do Begin
        if Buscar(cabexpt.FieldByName('periodo').AsString, cabexpt.FieldByName('idprof').AsString, cabexpt.FieldByName('codos').AsString) then cabfact.Edit else cabfact.Append;
        cabfact.FieldByName('periodo').AsString := cabexpt.FieldByName('periodo').AsString;
        cabfact.FieldByName('idprof').AsString  := cabexpt.FieldByName('idprof').AsString;
        cabfact.FieldByName('codos').AsString   := cabexpt.FieldByName('codos').AsString;
        cabfact.FieldByName('fecha').AsString   := cabexpt.FieldByName('fecha').AsString;
        try
          cabfact.Post
         except
          cabfact.Cancel
        end;
        cabexpt.Next;
      end;
      cabexpt.Close;

      profesional.getDatos(cabfact.FieldByName('idprof').AsString);
      profesional.SincronizarListaRetIVA(xperiodo, xidprof);

      datosdb.refrescar(cabfact);

      datosdb.tranSQL(directorio, 'DELETE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      detexpt.Open;
      while not detexpt.EOF do Begin
        detfact.Append;
        detfact.FieldByName('periodo').AsString     := detexpt.FieldByName('periodo').AsString;
        detfact.FieldByName('idprof').AsString      := detexpt.FieldByName('idprof').AsString;
        detfact.FieldByName('codos').AsString       := detexpt.FieldByName('codos').AsString;
        detfact.FieldByName('items').AsString       := detexpt.FieldByName('items').AsString;
        detfact.FieldByName('orden').AsString       := detexpt.FieldByName('orden').AsString;
        detfact.FieldByName('codpac').AsString      := detexpt.FieldByName('codpac').AsString;
        detfact.FieldByName('nombre').AsString      := detexpt.FieldByName('nombre').AsString;
        detfact.FieldByName('codanalisis').AsString := detexpt.FieldByName('codanalisis').AsString;
        detfact.FieldByName('profiva').AsString     := profesional.Retieneiva;
        detfact.FieldByName('ref1').AsString        := detexpt.FieldByName('ref1').AsString;
        detfact.FieldByName('retiva').AsString      := detexpt.FieldByName('retiva').AsString;
        if detfact.FieldByName('codos').AsString <> codosant then obsocial.getDatos(detfact.FieldByName('codos').AsString);
        if obsocial.retencioniva > 0 then detfact.FieldByName('osiva').AsString := 'S' else detfact.FieldByName('osiva').AsString := 'N';
        try
          detfact.Post
         except
          detfact.Cancel
        end;
        codosant := detfact.FieldByName('codos').AsString;
        detexpt.Next;
      end;
      detexpt.Close;
      datosdb.refrescar(detfact);

      idexpt.Open;
      while not idexpt.EOF do Begin
        if datosdb.Buscar(idordenes, 'periodo', 'idprof', idexpt.FieldByName('periodo').AsString, idexpt.FieldByName('idprof').AsString) then idordenes.Edit else idordenes.Append;
        idordenes.FieldByName('periodo').AsString := idexpt.FieldByName('periodo').AsString;
        idordenes.FieldByName('idprof').AsString  := idexpt.FieldByName('idprof').AsString;
        idordenes.FieldByName('orden').AsString   := idexpt.FieldByName('orden').AsString;
        try
          idordenes.Post
         except
          idordenes.Cancel
        end;
        idexpt.Next;
      end;
      idexpt.Close;
      datosdb.refrescar(idordenes);

      cabexpt.Free; detexpt.Free; idexpt.Free;
      cabexpt := Nil; detexpt := Nil; idexpt := Nil;

      paciente.TransferenciaFinal(directorio);

      // Guardamos la referencia
      if datosdb.Buscar(datosimport, 'periodo', 'idprof', xperiodo, xidprof) then Begin
        datosimport.Edit;
        datosimport.FieldByName('transferencia').AsString := FormatDateTime('dd/mm/yy hh:mm:ss', Now);
        try
          datosimport.Post
         except
          datosimport.Cancel
        end;
      end;
    end else
      if Length(Trim(xprofesional)) > 0 then utiles.msgError('El Laboratorio ' + xprofesional + ',' + CHR(13) + 'No tiene Operaciones Registradas ...!');
  End;

  if (interbase = 'S') then begin
      //utiles.msgError('punto0');  16/04/2014
      //if (ffirebird = Nil) then InstanciarTablas('S');

      //if not (cabexptIB.Active) then cabexptIB.Open;
      //if not (cabfactIB.Active) then cabfactIB.Open;
      //ffirebird.Filtrar(cabfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');

      rsqlIB := ffirebird.getTransacSQL('select * from cabfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      rsqlIB.Open; rsqlIB.First;
      //utiles.msgError(inttostr(rsqlIB.recordcount));

      //////lote.Clear;
      ///
      ///
         //utiles.msgError('punto1');
      while not rsqlIB.EOF do Begin
        {if ibase.Buscar(cabexptIB, 'periodo;idprof;codos', rsqlIB.FieldByName('periodo').AsString, rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codos').AsString) then cabexptIB.Edit else cabexptIB.Append;
        cabexptIB.FieldByName('periodo').AsString := rsqlIB.FieldByName('periodo').AsString;
        cabexptIB.FieldByName('idprof').AsString  := rsqlIB.FieldByName('idprof').AsString;
        cabexptIB.FieldByName('codos').AsString   := rsqlIB.FieldByName('codos').AsString;
        cabexptIB.FieldByName('fecha').AsString   := rsqlIB.FieldByName('fecha').AsString;
        try
          cabexptIB.Post
         except
          cabexptIB.Cancel
        end;}

        lote.Add('insert into cabfact (periodo, idprof, codos, fecha) values (' + // 01/03/2014
          '''' + rsqlIB.FieldByName('periodo').AsString + '''' + ', ' +
          '''' + rsqlIB.FieldByName('idprof').AsString + '''' + ', ' +
          '''' + rsqlIB.FieldByName('codos').AsString + '''' + ', ' +
          '''' + rsqlIB.FieldByName('fecha').AsString + '''' + ')' );

        rsqlIB.Next;
      end;

      //ibase.TransacSQLBatch(lote);
      //lote.Clear;

      //ibase.RegistrarTransaccion(cabexptIB);
      //firebird.closeDB(cabexptIB);
      rsqlIB.Close; rsqlIB.Free;

      {cabfactIB.First;
      while not cabfactIB.EOF do Begin
        if ibase.Buscar(cabexptIB, 'periodo;idprof;codos', cabfactIB.FieldByName('periodo').AsString, cabfactIB.FieldByName('idprof').AsString, cabfactIB.FieldByName('codos').AsString) then cabexptIB.Edit else cabexptIB.Append;
        cabexptIB.FieldByName('periodo').AsString := cabfactIB.FieldByName('periodo').AsString;
        cabexptIB.FieldByName('idprof').AsString  := cabfactIB.FieldByName('idprof').AsString;
        cabexptIB.FieldByName('codos').AsString   := cabfactIB.FieldByName('codos').AsString;
        cabexptIB.FieldByName('fecha').AsString   := cabfactIB.FieldByName('fecha').AsString;
        try
          cabexptIB.Post
         except
          cabexptIB.Cancel
        end;
        cabfactIB.Next;
      end;
      ibase.RegistrarTransaccion(cabexptIB);
      firebird.closeDB(cabexptIB);
      ffirebird.QuitarFiltro(cabfactIB);}

      profesional.getDatos(xidprof);
      profesional.SincronizarListaRetIVA(xperiodo, xidprof);
         //utiles.msgError('punto2');

      //ibase.TransacSQL('DELETE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND idprof = ' + '"' + xidprof + '"');
      //if not (detexptIB.Active) then detexptIB.Open;
      //detexptIB.IndexFieldNames := 'periodo;idprof;codos;items;orden';
      //if not (detfactIB.Active) then detfactIB.Open;

      //ffirebird.Filtrar(detfactIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      //detfactIB.First;

      // 28/04/2014    firebird.getTransacSQL('delete from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      lote.Add('delete from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      rsqlIB := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      rsqlIB.Open; rsqlIB.First;

      while not rsqlIB.EOF do Begin
        //if ibase.Buscar(detexptIB, 'periodo;idprof;codos;items;orden', rsqlIB.FieldByName('periodo').AsString, rsqlIB.FieldByName('idprof').AsString, rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('items').AsString, rsqlIB.FieldByName('orden').AsString) then detexptIB.Edit else detexptIB.Append;
        if rsqlIB.FieldByName('codos').AsString <> codosant then obsocial.getDatos(rsqlIB.FieldByName('codos').AsString);
        if obsocial.retencioniva > 0 then osiva := 'S' else osiva := 'N';

        if (rsqlIB.FieldByName('monto').AsString = '') then monto1 := 0 else monto1 := rsqlIB.FieldByName('monto').AsFloat;
        if (rsqlIB.FieldByName('iva').AsString = '') then monto2 := 0 else monto2 := rsqlIB.FieldByName('iva').AsFloat;
        if (rsqlIB.FieldByName('exento').AsString = '') then monto3 := 0 else monto3 := rsqlIB.FieldByName('exento').AsFloat;
        if (rsqlIB.FieldByName('coseguro').AsString = '') then monto4 := 0 else monto4 := rsqlIB.FieldByName('coseguro').AsFloat;


        lote.Add('insert into detfact (periodo, idprof, codos, items, orden, codpac, nombre, codanalisis, ref1, retiva, profiva, monto, iva, exento, coseguro, osiva) values (' +
          '''' + rsqlIB.FieldByName('periodo').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('idprof').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('codos').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('items').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('orden').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('codpac').AsString + '''' + ',' +
          QuotedStr(rsqlIB.FieldByName('nombre').AsString) + ',' +
          '''' + rsqlIB.FieldByName('codanalisis').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('ref1').AsString + ''''  + ',' +
          '''' + rsqlIB.FieldByName('retiva').AsString + ''''  + ',' +
          '''' + profesional.Retieneiva + ''''  + ',' +
          utiles.StringRemplazarCaracteres(FloatToStr(monto1), ',', '.') + ',' +
          utiles.StringRemplazarCaracteres(FloatToStr(monto2), ',', '.') + ',' +
          utiles.StringRemplazarCaracteres(FloatToStr(monto3), ',', '.') + ',' +
          utiles.StringRemplazarCaracteres(FloatToStr(monto4), ',', '.') + ',' +
          '''' + osiva + '''' + ')' );

        {ibase.TransacSQL('insert into detfact (periodo, idprof, codos, items, orden, codpac, nombre, codanalisis, ref1, retiva, profiva, osiva) values (' +
          '''' + rsqlIB.FieldByName('periodo').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('idprof').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('codos').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('items').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('orden').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('codpac').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('nombre').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('codanalisis').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('ref1').AsString + ''''  + ',' +
          '''' + rsqlIB.FieldByName('retiva').AsString + ''''  + ',' +
          '''' + profesional.Retieneiva + ''''  + ',' +
          '''' + osiva + '''' + ')' ); }




        {detexptIB.Append;
        detexptIB.FieldByName('periodo').AsString     := rsqlIB.FieldByName('periodo').AsString;
        detexptIB.FieldByName('idprof').AsString      := rsqlIB.FieldByName('idprof').AsString;
        detexptIB.FieldByName('codos').AsString       := rsqlIB.FieldByName('codos').AsString;
        detexptIB.FieldByName('items').AsString       := rsqlIB.FieldByName('items').AsString;
        detexptIB.FieldByName('orden').AsString       := rsqlIB.FieldByName('orden').AsString;
        detexptIB.FieldByName('codpac').AsString      := rsqlIB.FieldByName('codpac').AsString;
        detexptIB.FieldByName('nombre').AsString      := rsqlIB.FieldByName('nombre').AsString;
        detexptIB.FieldByName('codanalisis').AsString := rsqlIB.FieldByName('codanalisis').AsString;
        detexptIB.FieldByName('ref1').AsString        := rsqlIB.FieldByName('ref1').AsString;
        detexptIB.FieldByName('profiva').AsString     := profesional.Retieneiva;
        detexptIB.FieldByName('retiva').AsString      := rsqlIB.FieldByName('retiva').AsString;

        try
          detexptIB.Post
         except
          detexptIB.Cancel
        end;}

        codosant := rsqlIB.FieldByName('codos').AsString;
        rsqlIB.Next;
      end;

      {ibase.TransacSQLBatch(lote);
      lote.Clear; }

      //ibase.RegistrarTransaccion(detexptIB);
      //firebird.closeDB(detexptIB);
      //ffirebird.QuitarFiltro(detfactIB);
      rsqlIB.close; rsqlIB.Free;

      //if not (idexptIB.Active) then idexptIB.Open;
      //if not (idordenesIB.Active) then idordenesIB.Open;
      //ffirebird.Filtrar(idordenesIB, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      //idordenesIB.Open;
         //utiles.msgError('punto3');
      rsqlIB := ffirebird.getTransacSQL('select * from idordenes where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
      rsqlIB.Open; rsqlIB.First;

      while not rsqlIB.EOF do Begin
        lote.Add('insert into idordenes (periodo, idprof, orden) values (' +
          '''' + rsqlIB.FieldByName('periodo').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('idprof').AsString + '''' + ',' +
          '''' + rsqlIB.FieldByName('orden').AsString + '''' + ')' );

        {if ibase.Buscar(idexptIB, 'periodo;idprof', rsqlIB.FieldByName('periodo').AsString, rsqlIB.FieldByName('idprof').AsString) then idexptIB.Edit else idexptIB.Append;
        idexptIB.FieldByName('periodo').AsString := rsqlIB.FieldByName('periodo').AsString;
        idexptIB.FieldByName('idprof').AsString  := rsqlIB.FieldByName('idprof').AsString;
        idexptIB.FieldByName('orden').AsString   := rsqlIB.FieldByName('orden').AsString;
        try
          idexptIB.Post
         except
          idexptIB.Cancel
        end;}
        rsqlIB.Next;
      end;
      //ibase.RegistrarTransaccion(idexptIB);
      //firebird.closeDB(idexptIB);
      rsqlIB.Close; rsqlIB.free;
      //ffirebird.QuitarFiltro(idordenesIB);

      //ibase.TransacSQLBatch(lote);  // 01/03/2014 (guardamos todo en un solo viaje a la DB)

      // Guardamos la referencia
      if datosdb.Buscar(datosimport, 'periodo', 'idprof', xperiodo, xidprof) then Begin
        datosimport.Edit;
        datosimport.FieldByName('transferencia').AsString := FormatDateTime('dd/mm/yy hh:mm:ss', Now);
        try
          datosimport.Post
         except
          datosimport.Cancel
        end;
      end;

  end;
end;

procedure TTFacturacionCCB.TransferenciaFinalLaboratorios(xperiodo: String);
// Objetivo...: Transferir todos los Laboratorios del Periodo ...
var
  l: TStringList;
  i: Integer;
begin
  l := setDatosImportados(xperiodo);    // Nomina de los Laboratorios con Operaciones
  for i := 1 to l.Count do TransferenciaFinal(xperiodo, l.Strings[i-1], '');
  l.Destroy;
end;

procedure TTFacturacionCCB.CerrarTransferenciaFinal;
begin
  if (interbase = 'S') then begin // 16/04/2014
    ffirebird.Desconectar; ffirebird := nil;

    ffirebird := TTFirebird.Create;
    //firebird.getModulo('facturacion');
    ffirebird.Conectar(firebird.Host + 'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);
    ffirebird.TransacSQLBatch(lote);
    ffirebird.Desconectar;
    lote.Clear;

    {ibase := TTFirebird.Create;
    firebird.getModulo('facturacion');
    ibase.Conectar(firebird.Host + 'FACTLABCENT.GDB', firebird.Usuario , firebird.Password);
    ibase.TransacSQLBatch(lote);
    ibase.Desconectar;
    lote.Clear;}
    ffirebird := TTFirebird.Create;
    ffirebird.Conectar(firebird.Host + 'FACTLABWORK.GDB', firebird.Usuario , firebird.Password);
  end;
end;

// -----------------------------------------------------------------------------

procedure TTFacturacionCCB.UnificarPeriodosFacturados(xperiodos: TStringList);
// Objetivo...: Preparar estructura para Transferencia Final Periodos Unificados
var
  i: Integer;
  dire, codosant: String;
  cabexpt, detexpt, idexpt: TTable;
  arch: TextFile;
Begin
  DBCentral  := dir_lab +  '\integracion';
  directorio := DBCentral;
  LaboratorioActual := '';

  if not DirectoryExists(DBCentral) then Begin
    if not DirectoryExists(dir_lab + '\integracion') then utilesarchivos.CrearDirectorio(dir_lab + '\integracion');
    if not DirectoryExists(DBCentral) then utilesarchivos.CrearDirectorio(DBCentral);
  end;
  utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work', '*.*', DBCentral);

  cabexpt := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', DBCentral);
  detexpt := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', DBCentral);
  idexpt  := datosdb.openDB('idordenes', 'Periodo;Idprof', '', DBCentral);

  // Restructuramos los Indices para Informes
  datosdb.tranSQL(DBCentral, 'drop index detfact.DETFACT_RESUMENOS');
  datosdb.tranSQL(DBCentral, 'create index DETFACT_RESUMENOS on detfact(periodo, codos, idprof, orden, items)');
  datosdb.tranSQL(DBCentral, 'drop index detfact.DETFACT_RESUMENPROF');
  datosdb.tranSQL(DBCentral, 'create index DETFACT_RESUMEPROF on detfact(idprof, periodo, codos, orden, items)');

  if not cabexpt.Active then cabexpt.Open;
  if not detexpt.Active then detexpt.Open;
  if not idexpt.Active  then idexpt.Open;

  if not datosdb.verificarSiExisteCampo(detexpt, 'profiva') then Begin
    detexpt.Close;
    datosdb.tranSQL(DBCentral, 'alter table detfact add Profiva char(7)');
    detexpt.Open;
  end;
  if not datosdb.verificarSiExisteCampo(detexpt, 'osiva') then Begin
    detexpt.Close;
    datosdb.tranSQL(DBCentral, 'alter table detfact add Osiva char(1)');
    detexpt.Open;
  end;
  if not datosdb.verificarSiExisteCampo(detexpt, 'retiva') then Begin
    detexpt.Close;
    datosdb.tranSQL(DBCentral, 'alter table detfact add retiva char(1)');
    detexpt.Open;
  end;

  idprof := ''; laboratorioactual := '';   // Cambiamos los indicadores de laboratorios
  ProcesamientoCentral := True;
  LaboratorioActivo    := False;

  For i := 1 to xperiodos.Count do Begin

    if i = 1 then Begin   // Guardamos el Menor Periodo
      AssignFile(arch, DBCentral + '\periodos.dat');
      Rewrite(arch);
      WriteLn(arch, xperiodos.Strings[i-1]);
      closeFile(arch);
    end;

    ProcesarDatosCentrales(xperiodos.Strings[i-1]);

    cabfact.First;
    while not cabfact.EOF do Begin
      if datosdb.Buscar(cabexpt, 'periodo', 'idprof', 'codos', cabfact.FieldByName('periodo').AsString, cabfact.FieldByName('idprof').AsString, cabfact.FieldByName('codos').AsString) then cabexpt.Edit else cabexpt.Append;
      cabexpt.FieldByName('periodo').AsString := cabfact.FieldByName('periodo').AsString;
      cabexpt.FieldByName('idprof').AsString  := cabfact.FieldByName('idprof').AsString;
      cabexpt.FieldByName('codos').AsString   := cabfact.FieldByName('codos').AsString;
      cabexpt.FieldByName('fecha').AsString   := cabfact.FieldByName('fecha').AsString;
      try
        cabexpt.Post
       except
        cabexpt.Cancel
      end;

      profesional.getDatos(cabexpt.FieldByName('idprof').AsString);

      datosdb.refrescar(cabexpt);

      datosdb.Filtrar(detfact, 'periodo = ' + '''' + xperiodos.Strings[i-1] + '''' + ' AND idprof = ' + '''' + cabfact.FieldByName('idprof').AsString + '''');
      //datosdb.tranSQL(DBCentral, 'DELETE FROM detfact WHERE periodo = ' + '"' + xperiodos.Strings[i-1] + '"' + ' AND idprof = ' + '"' + cabexpt.FieldByName('idprof').AsString + '"');
      detfact.First;
      while not detfact.EOF do Begin
        if datosdb.Buscar(detexpt, 'periodo', 'idprof', 'codos', 'items', 'orden', detfact.FieldByName('periodo').AsString, detfact.FieldByName('idprof').AsString, detfact.FieldByName('codos').AsString, detfact.FieldByName('items').AsString, detfact.FieldByName('orden').AsString) then detexpt.Edit else detexpt.Append;
        detexpt.FieldByName('periodo').AsString     := detfact.FieldByName('periodo').AsString;
        detexpt.FieldByName('idprof').AsString      := detfact.FieldByName('idprof').AsString;
        detexpt.FieldByName('codos').AsString       := detfact.FieldByName('codos').AsString;
        detexpt.FieldByName('items').AsString       := detfact.FieldByName('items').AsString;
        detexpt.FieldByName('orden').AsString       := detfact.FieldByName('orden').AsString;
        detexpt.FieldByName('codpac').AsString      := detfact.FieldByName('codpac').AsString;
        detexpt.FieldByName('nombre').AsString      := detfact.FieldByName('nombre').AsString;
        detexpt.FieldByName('codanalisis').AsString := detfact.FieldByName('codanalisis').AsString;
        detexpt.FieldByName('profiva').AsString     := profesional.Retieneiva;
        if detfact.FieldByName('codos').AsString <> codosant then obsocial.getDatos(detfact.FieldByName('codos').AsString);
        if obsocial.retencioniva > 0 then detexpt.FieldByName('osiva').AsString := 'S' else detexpt.FieldByName('osiva').AsString := 'N';
        try
          detexpt.Post
         except
          detexpt.Cancel
        end;
        codosant := detfact.FieldByName('codos').AsString;
        detfact.Next;
      end;
      datosdb.QuitarFiltro(detfact);
      datosdb.refrescar(detexpt);

      datosdb.Filtrar(idordenes, 'periodo = ' + '''' + xperiodos.Strings[i-1] + '''' + ' AND idprof = ' + '''' + cabfact.FieldByName('idprof').AsString + '''');
      idordenes.First;
      while not idordenes.EOF do Begin
        if datosdb.Buscar(idexpt, 'periodo', 'idprof', idordenes.FieldByName('periodo').AsString, idordenes.FieldByName('idprof').AsString) then idexpt.Edit else idexpt.Append;
        idexpt.FieldByName('periodo').AsString := idordenes.FieldByName('periodo').AsString;
        idexpt.FieldByName('idprof').AsString  := idordenes.FieldByName('idprof').AsString;
        idexpt.FieldByName('orden').AsString   := idordenes.FieldByName('orden').AsString;
        try
          idexpt.Post
         except
          idexpt.Cancel
        end;
        idordenes.Next;
      end;
      datosdb.refrescar(idexpt);
      datosdb.QuitarFiltro(idordenes);

      cabfact.Next;
    end;

  end;

  datosdb.closedb(cabexpt);
  datosdb.closedb(detexpt);
  datosdb.closedb(idexpt);

  datosdb.closedb(cabfact);
  datosdb.closedb(detfact);
  datosdb.closedb(idordenes);
end;

function TTFacturacionCCB.setPeriodoUnificacion: String;
// objetivo...: devolver el menor periodo en el proceso de unificacion
var
  arch: TextFile;
  p: String;
Begin
  if FileExists(dir_lab +  '\integracion' + '\periodos.dat') then Begin
    AssignFile(arch, dir_lab +  '\integracion' + '\periodos.dat');
    Reset(arch);
    ReadLn(arch, p);
    closeFile(arch);
    Result := p;
  end else
    Result := '';
end;

// -----------------------------------------------------------------------------

function TTFacturacionCCB.setTotalFactObraSocial(xperiodo, xcodos: String): Real;
// Objetivo...: Devolver el total facturado para una Obra Social determinada
begin
  if totalesOS = Nil then totalesOS := datosdb.openDB('totalesOS', 'Periodo;Codos', '', DBConexion);
  totalesOS.Open;
  if datosdb.Buscar(totalesOS, 'Periodo', 'Codos', xperiodo, xcodos) then Result := totalesOS.FieldByName('monto').AsFloat else Result := 0;
  totalesOS.close;
end;

procedure TTFacturacionCCB.BorrarTotalFactObraSocial(xperiodo, xcodos: String);
// Objetivo...: Borrar Instancia
begin
  if totalesOS = Nil then totalesOS := datosdb.openDB('totalesOS', 'Periodo;Codos', '', DBConexion);
  totalesOS.Open;
  if datosdb.Buscar(totalesOS, 'Periodo', 'Codos', xperiodo, xcodos) then totalesOS.Delete;
  totalesOS.close;
end;

function TTFacturacionCCB.setTotalProfesional(xperiodo, xidprof, xcodos: String): Real;
// Objetivo...: Devolver el total facturado para un profesional para una Obra Social determinada
begin
  if dbs.BaseClientServ = 'S' then totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.baseDat) else totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\archdat');
  totalesPROF.Open;
  testeartotalesprof;
  if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then Begin
    Result     := totalesPROF.FieldByName('monto').AsFloat;
    totales[1] := totalesPROF.FieldByName('ub').AsFloat;
    totales[2] := totalesPROF.FieldByName('ug').AsFloat;
    totales[3] := totalesPROF.FieldByName('caran').AsFloat;
    totales[4] := totalesPROF.FieldByName('neto').AsFloat;
  end else Begin
    Result := 0;
    totales[1] := 0;
    totales[2] := 0;
    totales[3] := 0;
    totales[4] := 0;
  end;
  totalesPROF.Close;
end;

function TTFacturacionCCB.setTotalUB: Real;
// Objetivo...: Devolver el total UB
Begin
  Result := totales[1];
end;

function TTFacturacionCCB.setTotalUG: Real;
// Objetivo...: Devolver el total UG
Begin
  Result := totales[2];
end;

function TTFacturacionCCB.setTotalCaran: Real;
// Objetivo...: Devolver el total Caran
Begin
  Result := totales[3];
end;

function TTFacturacionCCB.setTotalNeto: Real;
// Objetivo...: Devolver el total Neto
Begin
  Result := totales[4];
end;

function TTFacturacionCCB.setTotalProfesional(xperiodo, xcodos: String): Real;
// Objetivo...: Devolver el total facturado para un Profesional
var
  t: Real;
begin
  t := 0;
  if dbs.BaseClientServ = 'S' then totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.baseDat) else totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\archdat');
  totalesPROF.Open;
  testeartotalesprof;
  while not totalesPROF.Eof do Begin
    if (totalesPROF.FieldByName('periodo').AsString = xperiodo) and (totalesPROF.FieldByName('codos').AsString = xcodos) then t := t + totalesPROF.FieldByName('monto').AsFloat;
    totalesPROF.Next;
  end;
  totalesPROF.Close;
  Result := t;
end;

function TTFacturacionCCB.setTotalProfesionalFacturaElectronica(xperiodo, xidprof: String): TQuery;
// Objetivo...: Devolver el total facturado para un Profesional
begin
  result := datosdb.tranSQL(totalesPROF.DatabaseName, 'select * from totalesPROF where idprof = ' + '''' + xidprof + '''' + 'and periodo = ' + '''' + xperiodo + '''');
end;

procedure TTFacturacionCCB.registrarFacturaElectronica(xperiodo, xidprof, xcodos, xtipo, xsucursal, xnumero: String);
begin
  if (datosdb.Buscar(totalesPROF, 'periodo', 'idprof', 'codos', xperiodo, xidprof, xcodos)) then begin
    totalesprof.Edit;
    totalesPROF.FieldByName('tipo').AsString := xtipo;
    totalesPROF.FieldByName('sucursal').AsString := xsucursal;
    totalesPROF.FieldByName('numero').AsString := xnumero;
    totalesPROF.Post;
    datosdb.refrescar(totalesPROF);
  end;
end;

procedure TTFacturacionCCB.IniciarTotalFacturado(xperiodo: String);
// Objetivo...: Inicializar los totales Facturados por Obra Social y por Profesional
begin
  datosdb.tranSQL(DBConexion, 'DELETE FROM totalesos WHERE periodo = ' + '"' + xperiodo + '"' + ' AND tipoing = 1');
  datosdb.tranSQL(DBConexion, 'DELETE FROM totalesprof WHERE periodo = ' + '"' + xperiodo + '"' + ' AND tipoing = 1');
end;

procedure TTFacturacionCCB.IniciarTotalFacturadoObrasSociales(xperiodo: String);
// Objetivo...: Inicializar los totales Facturados por Obra Social
begin
  datosdb.tranSQL(DBConexion, 'DELETE FROM totalesos WHERE periodo = ' + '"' + xperiodo + '"' + ' AND tipoing = 1');
end;

function TTFacturacionCCB.setTotalFacturado(xperiodo: String): Real;
// Objetivo...: Obtener el Total Facturado por Todas las Obras Sociales
begin
  ListarTotGralesObrasSociales(xperiodo, '', Nil, 'N');
  rsql := datosdb.tranSQL(DBConexion, 'select sum(monto) from totalesos where periodo = ' + '''' + xperiodo + '''');
  rsql.Open;
  Result := rsql.Fields[0].AsFloat;
  rsql.Close; rsql.Free;
end;

function TTFacturacionCCB.setTotalFacturado(xperiodo, xcodos: String): Real;
// Objetivo...: Obtener el Total Facturado por Todas las Obras Sociales
var
  l: TStringList;
begin
  l := TStringList.Create;
  l.Add(xcodos);
  ListarTotGralesObrasSociales(xperiodo, '', l, 'N');
  Result := 0;
end;

function  TTFacturacionCCB.setItemsTotalFacturado(xperiodo: String): TQuery;
// Objetivo...: Devolver un set con lo Facturado por cada Obra Social
Begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM ' + totalesOS.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND tipoing = 1 ORDER BY Nombre');
end;

procedure TTFacturacionCCB.IniciarTotalObrasSociales(xperiodo: String);
begin
  datosdb.tranSQL(DBCentral, 'DELETE FROM ' + totalesOS.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND tipoing = 1');
end;

procedure TTFacturacionCCB.GuardarTotalObrasSociales(xperiodo, xcodos: String; xmonto: Real);
// Objetivo...: Guardamos los totales de cada Obra Social
begin
  if (Length(Trim(laboratorioactual)) = 0) and (xmonto <> 0) then Begin
    obsocial.getDatos(xcodos);
    if datosdb.Buscar(totalesOS, 'Periodo', 'Codos', xperiodo, xcodos) then totalesOS.Edit else totalesOS.Append;
    totalesOS.FieldByName('periodo').AsString  := xperiodo;
    totalesOS.FieldByName('codos').AsString    := xcodos;
    totalesOS.FieldByName('nombre').AsString   := obsocial.Nombre;
    totalesOS.FieldByName('monto').AsString    := utiles.FormatearNumero(FloatToStr(xmonto));
    totalesOS.FieldByName('tipoing').AsInteger := 1;
    try
      totalesOS.Post
     except
      totalesOS.Cancel
    end;
    datosdb.refrescar(totalesOS);
  end;
end;

{-------------------------------------------------------------------------------}

function TTFacturacionCCB.setTotalFacturadoProfesionales(xperiodo: String): Real;
// Objetivo...: Obtener el Total Facturado por Profesionales
begin
  IniciarTotalProfesional(xperiodo);
  ListarResumenPorProfesional(xperiodo, '', Nil, Nil, 'N');
  rsql := datosdb.tranSQL(DBConexion, 'select sum(monto) from totalesprof where periodo = ' + '''' + xperiodo + '''');
  rsql.Open;
  Result := rsql.Fields[0].AsFloat;
  rsql.Close; rsql.Free;
end;

procedure TTFacturacionCCB.CalcularTotalFacturadoProfesionales(xperiodo: String; xinicializa_montos: Boolean);
// Objetivo...: Recalcular el Total Facturado por Profesionales
begin
  if xinicializa_montos then IniciarTotalProfesional(xperiodo);
  if ExcluirLab then ListarResumenPorProfesional(xperiodo, '', Nil, Nil, 'N')   // Monotributarios
  else ListarResumenRetencionesIVA(xperiodo, '', Nil, Nil, 'N', True);    // Responsables Inscriptos
end;

function TTFacturacionCCB.setTotalFacturadoProfesionales(xperiodo, xcodos: String): Real;
// Objetivo...: Obtener el Total Facturado por Profesionales, y dentro de cada uno el total por Obra Social
var
  t: TStringList;
begin
  t := TStringList.Create;
  t.Add(xcodos);
  ListarResumenPorProfesional(xperiodo, '', Nil, t, 'N');
  Result := totales[11];
end;

function  TTFacturacionCCB.setItemsTotalFacturadoProfesionales(xperiodo: String): TQuery;
// Objetivo...: Devolver un set con lo Facturado por cada Profesiona´l
Begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF WHERE periodo = ' + '"' + xperiodo + '"' + ' ORDER BY Nombre');
end;

function  TTFacturacionCCB.setItemsTotalFacturadoProfesionales(xperiodo, xidprof: String): TQuery;
// Objetivo...: Devolver un set con lo Facturado por cada Profesiona´l
Begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF WHERE periodo = ' + '"' + xperiodo + '"' + ' AND Idprof = ' + '"' + xidprof + '"' + ' ORDER BY Nombre');
end;

function  TTFacturacionCCB.setListaTotalFacturadoProfesionales(xperiodo, xidprof: String): TStringList;
// Objetivo...: Devolver un set con lo Facturado por cada Profesiona´l
var
  l: TStringList;
Begin
  l   := TStringList.Create;
  lub := TStringList.Create;
  totalesPROF := datosdb.openDB('totalesPROF', '', '', DBConexion);
  totalesPROF.Open;
  testeartotalesprof;
  datosdb.Filtrar(totalesPROF, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' +  xidprof + '''');
  while not totalesprof.Eof do Begin
    l.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + totalesPROF.FieldByName('monto').AsString);
    lub.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + utiles.FormatearNumero(totalesPROF.FieldByName('ub').AsString));
    //utiles.msgerror(utiles.StringLongitudFija(totalesPROF.FieldByName('periodo').AsString, 7) + utiles.StringLongitudFija(totalesPROF.FieldByName('idprof').AsString, 6) + utiles.StringLongitudFija(totalesPROF.FieldByName('codos').AsString, 6) + utiles.FormatearNumero(totalesPROF.FieldByName('ub').AsString));
    totalesPROF.Next;
  end;
  totalesPROF.Close;
  Result := l;
end;

function  TTFacturacionCCB.setListaTotalFacturadoProfesionales(xperiodo, xidprof, xcodos: String): TStringList;
// Objetivo...: Devolver un set con lo Facturado por cada Profesiona´l
var
  l: TStringList;
Begin
  l   := TStringList.Create;
  lub := TStringList.Create;
  totalesPROF := datosdb.openDB('totalesPROF', '', '', DBConexion);
  totalesPROF.Open;
  testeartotalesprof;
  datosdb.Filtrar(totalesPROF, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' +  xidprof + '''' + ' and codos = ' + '''' + xcodos + '''');
  while not totalesprof.Eof do Begin
    l.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + totalesPROF.FieldByName('monto').AsString);
    lub.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + utiles.FormatearNumero(totalesPROF.FieldByName('ub').AsString));
    //utiles.msgerror(utiles.StringLongitudFija(totalesPROF.FieldByName('periodo').AsString, 7) + utiles.StringLongitudFija(totalesPROF.FieldByName('idprof').AsString, 6) + utiles.StringLongitudFija(totalesPROF.FieldByName('codos').AsString, 6) + utiles.FormatearNumero(totalesPROF.FieldByName('ub').AsString));
    totalesPROF.Next;
  end;
  totalesPROF.Close;
  Result := l;
end;

function  TTFacturacionCCB.setListaTotalFacturadoProfesionalesExcluyendoObrasSocialesInscriptas(xperiodo, xidprof: String): TStringList;
// Objetivo...: Devolver un set con lo Facturado por cada Profesional,
//              aquellas obras sociales inscriptas en i.v.a para profesionales inscriptos quedan excluidas
var
  l: TStringList;
  n: Boolean;
Begin
  l := TStringList.Create; lub := TStringList.Create;
  totalesPROF := datosdb.openDB('totalesPROF', '', '', DBConexion);
  totalesPROF.Open;
  testeartotalesprof;
  profesional.getDatos(xidprof);
  datosdb.Filtrar(totalesPROF, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' +  xidprof + '''');
  while not totalesprof.Eof do Begin
    obsocial.getDatos(totalesPROF.FieldByName('codos').AsString);
    profesional.SincronizarListaRetIVA(xperiodo, xidprof);

    n := False;
    if obsocial.Retieneiva <> 'S' then n := True else
      if profesional.Retieneiva <> 'S' then n := True;
    if n then Begin
      l.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + totalesPROF.FieldByName('monto').AsString);
      lub.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + utiles.FormatearNumero(totalesPROF.FieldByName('ub').AsString));
    end;
    totalesPROF.Next;
  end;
  totalesPROF.Close;
  Result := l;
end;

function  TTFacturacionCCB.setListaTotalFacturadoProfesionalesIncluyendoObrasSocialesInscriptas(xperiodo, xidprof: String): TStringList;
// Objetivo...: Devolver un set con lo Facturado por cada Profesional,
//              aquellas obras sociales inscriptas en i.v.a para profesionales inscriptos
var
  l: TStringList;
  n: Boolean;
Begin
  l := TStringList.Create; lNeto := TStringList.Create; lub := TStringList.Create;
  totales[1]  := 0; totales[2] := 0;
  totalesPROF := datosdb.openDB('totalesPROF', '', '', DBConexion);
  totalesPROF.Open;
  testeartotalesprof;
  profesional.getDatos(xidprof);
  datosdb.Filtrar(totalesPROF, 'periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' +  xidprof + '''');
  totalesprof.First;
  while not totalesprof.Eof do Begin
    obsocial.getDatos(totalesPROF.FieldByName('codos').AsString);
    profesional.SincronizarListaRetIVA(xperiodo, xidprof);
    n := False;
    if (obsocial.Retieneiva = 'S') and (profesional.Retieneiva = 'S') then n := True;
    if n then Begin
      l.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + utiles.FormatearNumero(totalesPROF.FieldByName('monto').AsString));
      if totalesPROF.FieldByName('neto').AsFloat > 0 then lNeto.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + utiles.FormatearNumero(totalesPROF.FieldByName('neto').AsString));
      if totalesPROF.FieldByName('neto').AsFloat = 0 then lNeto.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + utiles.FormatearNumero(totalesPROF.FieldByName('monto').AsString));
      lub.Add(totalesPROF.FieldByName('periodo').AsString + totalesPROF.FieldByName('idprof').AsString + totalesPROF.FieldByName('codos').AsString + utiles.FormatearNumero(totalesPROF.FieldByName('ub').AsString));
    end;
    totalesPROF.Next;
  end;
  totalesPROF.Close;
  Result := l;
end;

function  TTFacturacionCCB.setNetoFacturado: TStringList;
// Objetivo...: Devolver Neto Facturado
Begin
  Result := lNeto;
end;

function  TTFacturacionCCB.setUBFacturadas: TStringList;
// Objetivo...: Devolver Unidades Honorarios Facturadas
Begin
  Result := lub;
end;

procedure TTFacturacionCCB.IniciarTotalProfesional(xperiodo: String);
begin
  datosdb.tranSQL(DBConexion, 'DELETE FROM ' + totalesPROF.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND tipoing = 1');
end;

procedure TTFacturacionCCB.GuardarTotalProfesional(xperiodo, xidprof, xcodos: String; xmonto, xUB, xUG, xCaran: Real);
// Objetivo...: Guardamos los totales de cada Obra Profesional
begin
  if ExcluirLab then Begin    // No calcula aquellos laboratorios y obras sociales inscriptas
    if (Length(Trim(laboratorioactual)) = 0) and (xmonto <> 0) then Begin
      profesional.getDatos(xidprof);
      if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, idprofanter, codosanter) then totalesPROF.Edit else totalesPROF.Append;
      totalesPROF.FieldByName('periodo').AsString  := xperiodo;
      totalesPROF.FieldByName('idprof').AsString   := xidprof;
      totalesPROF.FieldByName('nombre').AsString   := profesional.nombre;
      totalesPROF.FieldByName('codos').AsString    := xcodos;
      totalesPROF.FieldByName('monto').AsString    := utiles.FormatearNumero(FloatToStr(xmonto));
      totalesPROF.FieldByName('neto').AsFloat      := totalesPROF.FieldByName('monto').AsFloat + totalesPROF.FieldByName('retencion').AsFloat;
      totalesPROF.FieldByName('UB').AsFloat        := xUB;
      totalesPROF.FieldByName('UG').AsFloat        := xUG;
      totalesPROF.FieldByName('Caran').AsFloat     := xCaran;
      totalesPROF.FieldByName('codfact').AsString  := profesional.Codfact;
      totalesPROF.FieldByName('tipoing').AsInteger := 1;
      totalesPROF.FieldByName('gravado').AsFloat   := totiva[4];
      totalesPROF.FieldByName('exento').AsFloat    := totiva[5];
      totalesPROF.FieldByName('iva').AsFloat       := totiva[6];
      try
        totalesPROF.Post
       except
        totalesPROF.Cancel
      end;
      datosdb.closeDB(totalesPROF); totalesPROF.Open;
    end;
  end;
end;

procedure TTFacturacionCCB.GuardarTotalProfIVA(xperiodo, xidprof, xcodos: String; xmonto, xneto: Real);
// Objetivo...: Guardamos los totales de cada Obra Profesional de aquellos que retienen I.V.A.
begin
  if ((Length(Trim(laboratorioactual)) = 0) and (xmonto <> 0)) or ((ExportarTotalesProfInscriptosIVA) and (obsocial.Retieneiva = 'S')) then Begin
    profesional.getDatos(xidprof);
    if (totalesPROF <> Nil) or (totalesPROF = Nil) then Begin  // Solo se exportan los montos si el procesamiento es general
      if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, idprofanter, codosanter) then totalesPROF.Edit else totalesPROF.Append;
      totalesPROF.FieldByName('periodo').AsString  := xperiodo;
      totalesPROF.FieldByName('idprof').AsString   := xidprof;
      totalesPROF.FieldByName('nombre').AsString   := profesional.nombre;
      totalesPROF.FieldByName('codos').AsString    := xcodos;
      totalesPROF.FieldByName('monto').AsString    := utiles.FormatearNumero(FloatToStr(xmonto));
      totalesPROF.FieldByName('neto').AsString     := utiles.FormatearNumero(FloatToStr(xneto));
      totalesPROF.FieldByName('codfact').AsString  := profesional.Codfact;
      totalesPROF.FieldByName('tipoing').AsInteger := 1;
      totalesPROF.FieldByName('gravado').AsFloat   := totiva[4];
      totalesPROF.FieldByName('exento').AsFloat    := totiva[5];
      totalesPROF.FieldByName('iva').AsFloat       := totiva[6];
      try
        totalesPROF.Post
       except
        totalesPROF.Cancel
      end;
      datosdb.closeDB(totalesPROF); totalesPROF.Open;
    end;
  end;
end;


procedure TTFacturacionCCB.GuardarTotalProfesionalDistribucion(xperiodo, xidprof, xcodos: String; xmonto, xneto, xgrabado, xexento, xiva: Real);
// Objetivo...: Guardamos los totales de cada Obra Profesional de aquellos que retienen I.V.A.
begin
    profesional.getDatos(xidprof);
    if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then totalesPROF.Edit else totalesPROF.Append;
    totalesPROF.FieldByName('periodo').AsString  := xperiodo;
    totalesPROF.FieldByName('idprof').AsString   := xidprof;
    totalesPROF.FieldByName('nombre').AsString   := profesional.nombre;
    totalesPROF.FieldByName('codos').AsString    := xcodos;
    totalesPROF.FieldByName('neto').AsFloat      := xneto;
    totalesPROF.FieldByName('codfact').AsString  := profesional.Codfact;
    totalesPROF.FieldByName('tipoing').AsInteger := 1;
    totalesPROF.FieldByName('gravado').AsFloat   := xgrabado;
    totalesPROF.FieldByName('exento').AsFloat    := xexento;
    totalesPROF.FieldByName('iva').AsFloat       := xiva;
    totalesPROF.FieldByName('monto').AsFloat     := xmonto;
    try
      totalesPROF.Post
     except
      totalesPROF.Cancel
    end;
    datosdb.closeDB(totalesPROF); totalesPROF.Open;
end;

procedure TTFacturacionCCB.GuardarTotalProfIVAExport(xperiodo, xidprof, xcodos: String; xneto, xiva, xexento, xtotal: Real; xcantidad, xprestaciones: integer);
// Objetivo...: Guardamos los totales de cada Obra Profesional de aquellos que retienen I.V.A.
begin
  //utiles.msgError(xidprof + ' ' + xcodos + ' ' + xperiodo + ' ' + floattostr(xneto));

  if (xcodos = '') then exit;

  if (wtotalesPROF <> Nil) then Begin  // Solo se exportan los montos si el procesamiento es general
      wtotalesPROF.Open;
      if datosdb.Buscar(wtotalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then wtotalesPROF.Edit else wtotalesPROF.Append;
      obsocial.getDatos(xcodos);
      wtotalesPROF.FieldByName('periodo').AsString      := xperiodo;
      wtotalesPROF.FieldByName('idprof').AsString       := xidprof;
      wtotalesPROF.FieldByName('codos').AsString        := xcodos;
      wtotalesPROF.FieldByName('obsocial').AsString     := obsocial.Nombre;
      wtotalesPROF.FieldByName('grabado').AsString      := utiles.FormatearNumero(FloatToStr(xiva)); //utiles.FormatearNumero(FloatToStr(totiva[4]));
      wtotalesPROF.FieldByName('neto').AsString         := utiles.FormatearNumero(FloatToStr(xneto));
      wtotalesPROF.FieldByName('iva').AsString          := '0'; //utiles.FormatearNumero(FloatToStr(totiva[6]));
      wtotalesPROF.FieldByName('exento').AsString       := utiles.FormatearNumero(FloatToStr(xexento)); //utiles.FormatearNumero(FloatToStr(totiva[5]));
      wtotalesPROF.FieldByName('total').AsString        := utiles.FormatearNumero(FloatToStr(xtotal));
      wtotalesPROF.FieldByName('ordenes').AsInteger     := xcantidad;
      wtotalesPROF.FieldByName('prestaciones').AsInteger:= xprestaciones;
      try
        wtotalesPROF.Post
       except
        wtotalesPROF.Cancel
      end;
      datosdb.closeDB(wtotalesPROF);
    end;
end;

function  TTFacturacionCCB.setDeterminacionesFacturadas(xperiodo: String): TQuery;
// Objetivo...: Devolver las Determinaciones Facturadas en el Periodo
Begin
  Result := datosdb.tranSQL(DBCentral, 'SELECT idprof, codos, codanalisis FROM ' + detFact.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' ORDER BY codos, codanalisis');
end;

function TTFacturacionCCB.setRangoPeriodos: String;
// Objetivo...: Devolver el Rango de periodos unificados
var
  r: TQuery;
  p1, p2: String;
Begin
  r := datosdb.tranSQL(DBCentral, 'SELECT DISTINCT periodo FROM ' + cabFact.TableName + ' ORDER BY periodo');
  r.Open;
  p1 := r.FieldByName('periodo').AsString;
  while not r.Eof do Begin
    p2 := r.FieldByName('periodo').AsString;
    r.Next;
  End;
  r.Close; r.Free;
  Result := p1 + ' - ' + p2;
end;

function  TTFacturacionCCB.setDeterminacionesFacturadasPorObraSocial(xperiodo, xcodos: String): TQuery;
// Objetivo...: Devolver las Determinaciones Facturadas en el Periodo para una Determinada Obra Social
Begin
  Result := datosdb.tranSQL(DBCentral, 'SELECT periodo, codos, codanalisis, idprof, codpac, orden FROM ' + detFact.TableName + ' WHERE codos = ' + '"' + xcodos + '"' + ' ORDER BY codanalisis');
end;

function  TTFacturacionCCB.setDeterminacionesFacturadasPorObraSocialIB(xperiodo, xcodos: String): TIBQuery;
// Objetivo...: Devolver las Determinaciones Facturadas en el Periodo para una Determinada Obra Social
Begin
  Result := ffirebird.getTransacSQL('SELECT periodo, codos, codanalisis, idprof, codpac, orden, ref1 FROM detfact WHERE codos = ' + '"' + xcodos + '"' + ' AND periodo = ' + '''' + xperiodo + '''' + ' ORDER BY codanalisis');
end;

function TTFacturacionCCB.setCantidadPacientesFacturadosObraSocial(xperiodo, xcodos: String): Integer;
// Objetivo...: determinar la cantidad de pacientes facturados en la obra social
var
  rs: TQuery;
  ri: TIBQuery;
  i: integer;
Begin
  if (interbase = 'N') then begin
    rs := datosdb.tranSQL(DBCentral, 'SELECT DISTINCT idprof, nombre FROM ' + detFact.TableName + ' WHERE periodo = ' + '"' + xperiodo + '"' + ' AND codos = ' + '"' + xcodos + '"');
    rs.Open;
    Result := rs.RecordCount;
    rs.Close; rs.Free;
  end;
  if (interbase = 'S') then begin
    ri := ffirebird.getTransacSQL('SELECT DISTINCT IDPROF, NOMBRE FROM detfact WHERE periodo = ' + '"' + xperiodo + '"' + ' AND codos = ' + '"' + xcodos + '"');
    ri.Open; i := 0;
    while not ri.Eof do begin
      inc(i);
      ri.Next;
    end;
    ri.Close; ri.Free;
    result := i;
  end;
end;

function  TTFacturacionCCB.setNominaProfesionalesQueFacturaronPorObraSocial(xperiodo, xcodos: String): TQuery;
// Objetivo...: Extraer los Profesionales que Facturaron en el periodo en las diferentes obras sociales
Begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT DISTINCT idprof, Nombre FROM totalesPROF WHERE Periodo = ' + '"' + xperiodo + '"' + ' AND Codos = ' + '"' + xcodos + '"' + ' ORDER BY Nombre');
end;

procedure TTFacturacionCCB.CalcularMontosFacturacion(xperiodo: String);
// Objetivo...: Subtotalizar aquellos profesionales que Facturan
var
  estado: Boolean;
  r: TQuery;
Begin
  estado := totalesPROF.Active;
  if not estado then Begin
    if dbs.BaseClientServ = 'S' then totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.baseDat) else totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\archdat');
    totalesPROF.Open;
    testeartotalesprof;
  end;

  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0;
  r := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF WHERE codfact > ' + '''' + ' ' + '''' + ' AND periodo = ' + '"' + xperiodo + '"' + ' ORDER BY codfact, codos');
  r.Open;
  idprofanter := r.FieldByName('codfact').AsString;
  codosanter  := r.FieldByName('codos').AsString;

  while not r.Eof do Begin
    if r.FieldByName('codfact').AsString <> idprofanter then GuardarTotalProf(xperiodo, idprofanter, codosanter) else
      if r.FieldByName('codos').AsString <> codosanter then GuardarTotalProf(xperiodo, idprofanter, codosanter);
    totales[1] := totales[1] + r.FieldByName('monto').AsFloat;
    totales[2] := totales[2] + r.FieldByName('neto').AsFloat;
    totales[3] := totales[3] + r.FieldByName('retencion').AsFloat;
    totales[4] := totales[4] + r.FieldByName('ug').AsFloat;
    totales[5] := totales[5] + r.FieldByName('ub').AsFloat;
    totales[6] := totales[6] + r.FieldByName('caran').AsFloat;
    idprofanter := r.FieldByName('codfact').AsString;
    codosanter  := r.FieldByName('codos').AsString;
    r.Next;
  end;
  r.Close; r.Free;

  GuardarTotalProf(xperiodo, idprofanter, codosanter);
  totalesPROF.Active := estado;

  r := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF WHERE periodo = ' + '"' + xperiodo + '"' + ' ORDER BY codos');
  r.Open; totales[1] := 0;
  codosanter  := r.FieldByName('codos').AsString;

  while not r.Eof do Begin
    if r.FieldByName('codos').AsString <> codosanter then Begin
      GuardarTotalObrasSociales(xperiodo, codosanter, totales[1]);
      totales[1] := 0;
    end;
    totales[1] := totales[1] + r.FieldByName('monto').AsFloat;
    codosanter  := r.FieldByName('codos').AsString;
    r.Next;
  end;

  GuardarTotalObrasSociales(xperiodo, codosanter, totales[1]);

  r.Close; r.Free;
end;

procedure TTFacturacionCCB.GuardarTotalProf(xperiodo, xidprof, xcodos: String);
// Objetivo...: Guardar el total Facturado
Begin
  if totales[1] + totales[2] + totales[3] <> 0 then Begin
    if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then totalesPROF.Edit else totalesPROF.Append;
    profesional.getDatos(xidprof);
    totalesPROF.FieldByName('periodo').AsString  := xperiodo;
    totalesPROF.FieldByName('idprof').AsString   := xidprof;
    totalesPROF.FieldByName('codos').AsString    := xcodos;
    totalesPROF.FieldByName('nombre').AsString   := profesional.nombre;
    totalesPROF.FieldByName('monto').AsFloat     := totalesPROF.FieldByName('monto').AsFloat + totales[1];
    totalesPROF.FieldByName('neto').AsFloat      := totalesPROF.FieldByName('neto').AsFloat + totales[2];
    totalesPROF.FieldByName('retencion').AsFloat := totalesPROF.FieldByName('retencion').AsFloat + totales[3];
    totalesPROF.FieldByName('UG').AsFloat        := totalesPROF.FieldByName('UG').AsFloat + totales[4];
    totalesPROF.FieldByName('UB').AsFloat        := totalesPROF.FieldByName('UB').AsFloat + totales[5];
    totalesPROF.FieldByName('caran').AsFloat     := totalesPROF.FieldByName('caran').AsFloat + totales[6];
    totalesPROF.FieldByName('tipoing').AsInteger := 1;
    try
      totalesPROF.Post
     except
      totalesPROF.Cancel
    end;
    datosdb.closeDB(totalesPROF); totalesPROF.Open;
  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0;
end;

function  TTFacturacionCCB.setImporteAnalisis(xcodos, xcodanalisis: String): Real;
// Objetivo...: Determinar el Costo de un Análisis
Begin
  if xcodos <> codosanter then obsocial.getDatos(xcodos);
  codosanter := xcodos;
  nomeclatura.getDatos(xcodanalisis);
  if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
  if nomeclatura.RIE <> '*' then Result := setValorAnalisis(xcodos, xcodanalisis, nomeclatura.ub, obsocial.UB, nomeclatura.gastos, obsocial.UG) else Result := setValorAnalisis(xcodos, xcodanalisis, nomeclatura.ub, obsocial.RIEUB, nomeclatura.gastos, obsocial.RIEUG);  // Valor de cada analisis
end;

function  TTFacturacionCCB.setImporteAnalisis(xcodos, xcodanalisis, xperiodo: String): Real;
// Objetivo...: Determinar el Costo de un Análisis
Begin
  if xcodos <> codosanter then obsocial.getDatos(xcodos);
  codosanter := xcodos;
  Periodo    := xperiodo;
  obsocial.SincronizarArancel(xcodos, xperiodo);
  Result     := setImporteAnalisis(xcodos, xcodanalisis);
end;

function  TTFacturacionCCB.setImporteAnalisis(xcodos, xcodanalisis: String; xosub, xosug, xosrieub, xosrieug: Real): Real;
// Objetivo...: Determinar el Costo de un Análisis
Begin
  if xcodos <> codosanter then obsocial.getDatos(xcodos);
  codosanter := xcodos;
  nomeclatura.getDatos(xcodanalisis);
  if Length(Trim(nomeclatura.codfact)) > 0 then nomeclatura.getDatos(nomeclatura.codfact);
  obsocial.UB    := xosub;
  obsocial.UG    := xosug;
  obsocial.RIEUB := xosrieub;
  obsocial.RIEUG := xosrieug;
  if nomeclatura.RIE <> '*' then Result := setValorAnalisis(xcodos, xcodanalisis, nomeclatura.ub, xosub, nomeclatura.gastos, xosug) else Result := setValorAnalisis(xcodos, xcodanalisis, nomeclatura.ub, xosrieub, nomeclatura.gastos, xosrieug);  // Valor de cada analisis
end;

function  TTFacturacionCCB.setImporteAnalisis(xcodos, xcodanalisis, xperiodo: String; xnbu: real): Real;
// Objetivo...: Determinar el Costo de un Análisis directo por un modulo NBU
Begin
  nbu.getDatos(xcodanalisis);
  result := nbu.unidad * xnbu;
end;

function  TTFacturacionCCB.setCodigoRecepcionToma: Boolean;
// Objetivo...: Determinar si tiene o como código Fijo de Toma y Muestra
Begin
  Result := codigo_tomamuestra;
end;

procedure TTFacturacionCCB.IngresarMontoFacturadoObraSocial(xperiodo, xcodos, xnombre: String; ximporte: Real);
// Objetivo...: Fijar el monto total facturado por la Obra Social
Begin
  if datosdb.Buscar(totalesOS, 'Periodo', 'Codos', xperiodo, xcodos) then totalesOS.Edit else totalesOS.Append;
  totalesOS.FieldByName('periodo').AsString  := xperiodo;
  totalesOS.FieldByName('codos').AsString    := xcodos;
  totalesOS.FieldByName('nombre').AsString   := xnombre;
  totalesOS.FieldByName('monto').AsFloat     := ximporte;
  totalesOS.FieldByName('tipoing').AsInteger := 2;
  try
    totalesOS.Post
   except
    totalesOS.Cancel
  end;
  datosdb.refrescar(totalesOS);
end;

procedure TTFacturacionCCB.InformeTotalObrasSociales(xperiodo: String; listSel: TStringList; salida: Char);
// Objetivo...: Generar informe de control para el total de obras sociales
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.altopag := 0; list.m := 0;
    list.IniciarTitulos;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Inf. de Control Totales de Obras Sociales - Período: ' + xperiodo, 1, 'Arial, negrita, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, 'Obra Social', 1, 'Arial, cursiva, 8');
    list.Titulo(85, list.Lineactual, 'Monto Fact.', 2, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo9(xperiodo);
  end;
  totalesOS := datosdb.openDB('totalesOS', 'Periodo;Codos', '', DBConexion);
  totalesOS.Open; totalesOS.First; totales[1] := 0;
  while not totalesOS.Eof do Begin
    if (utiles.verificarItemsLista(listSel, totalesOS.FieldByName('codos').AsString)) and (totalesOS.FieldByName('periodo').AsString = xperiodo)  then Begin
      obsocial.getDatos(totalesOS.FieldByName('codos').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, obsocial.codos + '   ' + obsocial.Nombre, 1, 'Arial, normal, 8', salida, 'N');
        list.importe(93, list.Lineactual, '', totalesOS.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
        list.Linea(95, list.Lineactual, ' ', 3, 'Arial, normal, 8', salida, 'S');
      end;
      if (salida = 'T') then Begin
        list.LineaTxt(obsocial.codos + ' ', False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 35) + ' ' + utiles.espacios(36 - Length(TrimRight(Copy(obsocial.nombre, 1, 35)))), False);
        list.ImporteTxt(totalesOS.FieldByName('monto').AsFloat, 11, 2, True);
        Inc(lineas); if controlarsalto then titulo9(xperiodo);
      end;
      totales[1] := totales[1] + totalesOS.FieldByName('monto').AsFloat;
    end;
    totalesOS.Next;
  end;
  totalesOS.Close;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(93, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  if (salida = 'T') then Begin
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
    Inc(lineas); if controlarsalto then titulo9(xperiodo);
    list.LineaTxt('Total General:' + utiles.espacios(30), False);
    list.importeTxt(totales[1], 11, 2, True);
    Inc(lineas); if controlarsalto then titulo9(xperiodo);
  end;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTFacturacionCCB.IngresarMontoFacturadoProfesional(xperiodo, xidprof, xnombre, xcodos, xcodfact: String; xub, xug, xcaran, ximporte, xneto: Real);
// Objetivo...: Fijar el monto total facturado por Profesional
Begin
  if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then totalesPROF.Edit else totalesPROF.Append;
  totalesPROF.FieldByName('periodo').AsString  := xperiodo;
  totalesPROF.FieldByName('idprof').AsString   := xidprof;
  totalesPROF.FieldByName('codos').AsString    := xcodos;
  totalesPROF.FieldByName('nombre').AsString   := xnombre;
  totalesPROF.FieldByName('monto').AsFloat     := ximporte;
  totalesPROF.FieldByName('ub').AsFloat        := xub;
  totalesPROF.FieldByName('ug').AsFloat        := xug;
  totalesPROF.FieldByName('caran').AsFloat     := xcaran;
  totalesPROF.FieldByName('tipoing').AsInteger := 2;
  totalesPROF.FieldByName('neto').AsFloat      := xneto;
  try
    totalesPROF.Post
   except
    totalesPROF.Cancel
  end;
  datosdb.closeDB(totalesPROF); totalesPROF.Open;
end;

procedure TTFacturacionCCB.BorrarMontoFacturadoProfesional(xperiodo, xidprof, xcodos: String);
// Objetivo...: Fijar el monto total facturado por Profesional
Begin
  ConectarTotalesProf;
  if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then totalesPROF.Delete;
  DesconectarTotalesProf;
end;

procedure TTFacturacionCCB.RegistrarNetoACobrarProfesional(xperiodo, xidprof, xcodos: String; ximporte: Real);
// Objetivo...: Fijar el monto Neto a cobrar de la Obra Social
Begin
  ConectarTotalesProf;
  if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then Begin
    totalesPROF.Edit;
    totalesPROF.FieldByName('Retencion').AsFloat := ximporte;
    totalesPROF.FieldByName('Neto').AsFloat      := totalesPROF.FieldByName('Monto').AsFloat + ximporte;
    try
      totalesPROF.Post
     except
      totalesPROF.Cancel
    end;
  end;
  DesconectarTotalesProf;
end;

function TTFacturacionCCB.setNetoACobrarProfesional(xperiodo, xidprof, xcodos: String): Real;
// Objetivo...: Obtener el Neto a Cobrar por el Profesional para una Obra Social
var
  e: Boolean;
Begin
  e := totalesPROF.Active;
  if dbs.BaseClientServ = 'S' then totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.baseDat) else totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', dbs.DirSistema + '\archdat');
  if datosdb.Buscar(totalesPROF, 'Periodo', 'Idprof', 'Codos', xperiodo, xidprof, xcodos) then Result := totalesPROF.FieldByName('monto').AsFloat + totalesPROF.FieldByName('retencion').AsFloat else Result := 0;
  if not e then DesconectarTotalesProf;
end;

procedure TTFacturacionCCB.InformeTotalProfesionales(xperiodo: String; listSel: TStringList; salida: Char; xincluirinscriptosiva: Boolean);
// Objetivo...: Generar Informe de total a Profesionales
var
  r: TQuery;
  listar: Boolean;
Begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida);
    list.altopag := 0; list.m := 0;
    list.IniciarTitulos;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Inf. de Control Totales Fact. Profesionales - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, '    Profesional', 1, 'Arial, cursiva, 8');
    list.Titulo(38, list.Lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
    list.Titulo(70, list.Lineactual, 'Neto', 4, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Total', 5, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo8(xperiodo);
  end;
  r := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF ORDER BY Codos, Idprof');
  r.Open; idanter := ''; totales[2] := 0; totales[1] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0;
  while not r.Eof do Begin
    if (utiles.verificarItemsLista(listSel, r.FieldByName('codos').AsString)) and (r.FieldByName('periodo').AsString = xperiodo) then Begin

      listar := False;
      if not xincluirinscriptosiva then listar := True else Begin
        profesional.getDatos(r.FieldByName('idprof').AsString);
        profesional.SincronizarListaRetIVA(xperiodo, r.FieldByName('idprof').AsString); 
        obsocial.getDatos(r.FieldByName('codos').AsString);
        if (profesional.Retieneiva = 'S') and (obsocial.Retieneiva = 'S') then listar := True;
      end;

      if listar then Begin

      if r.FieldByName('codos').AsString <> idanter then Begin
        if idanter <> '' then Begin
          TotalOS(xperiodo, salida);
          if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          if salida = 'T' then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarsalto then titulo8(xperiodo);
          end;
        end;
        obsocial.getDatos(r.FieldByName('codos').AsString);
        obsocial.SincronizarArancel(r.FieldByname('codos').AsString, xperiodo);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Obra Social: ' + obsocial.codos + ' - ' + obsocial.Nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if salida = 'T' then Begin
          list.LineaTxt(CHR(18) + 'Obra Social: ' + obsocial.codos + ' - ' + obsocial.Nombre, True); Inc(lineas); if controlarsalto then titulo8(xperiodo);
          list.LineaTxt('', True); Inc(lineas); if controlarsalto then titulo8(xperiodo);
        end;
        idanter := r.FieldByName('codos').AsString;
      end;
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, Copy(r.FieldByName('Nombre').AsString, 1, 35), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(33, list.Lineactual, '|', 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(52, list.Lineactual, '|', 3, 'Arial, normal, 8', salida, 'N');
        list.importe(75, list.Lineactual, '', r.FieldByName('neto').AsFloat, 4, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', r.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
        list.Linea(95, list.Lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, list.Linealargopagina('..', salida), 1, 'Arial, normal, 11', salida, 'S');
      end;
      if salida = 'T' then Begin
        list.LineaTxt(CHR(18) + TrimRight(Copy(r.FieldByName('Nombre').AsString, 1, 35)) + utiles.espacios(36 - Length(TrimRight(Copy(r.FieldByName('Nombre').AsString, 1, 35)))) + '|                |', False);
        list.ImporteTxt(r.FieldByName('neto').AsFloat, 10, 2, False);
        list.ImporteTxt(r.FieldByName('monto').AsFloat, 10, 2, True);
        Inc(lineas); if controlarsalto then titulo8(xperiodo);
        list.LineaTxt(CHR(18) + utiles.sLlenarIzquierda(lin, 80, '.'), True);
        Inc(lineas); if controlarsalto then titulo8(xperiodo);
      end;
      totales[2] := totales[2] + r.FieldByName('monto').AsFloat;
      totales[3] := totales[3] + r.FieldByName('neto').AsFloat;
      end;
    end;
    r.Next;
  end;
  TotalOS(xperiodo, salida);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(CHR(18) + 'Total General:' + utiles.espacios(40), False);
    list.ImporteTxt(totales[1], 10, 2, False);
    list.ImporteTxt(totales[4], 10, 2, True);
    Inc(lineas); if controlarsalto then titulo8(xperiodo);
  end;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

function TTFacturacionCCB.setTotalProfesionalesLiquidacion(xperiodo: String; listSel: TStringList; xincluirinscriptosiva: Boolean): TStringList;
// Objetivo...: Generar Informe de total a Profesionales
var
  r: TQuery;
  listar: Boolean;
  l: TStringList;
Begin
  l := TStringList.Create;
  r := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF WHERE periodo = ' + '''' + xperiodo + '''' + ' ORDER BY Codos, Idprof');
  r.Open; idanter := ''; totales[2] := 0; totales[1] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0;
  while not r.Eof do Begin
    if (utiles.verificarItemsLista(listSel, r.FieldByName('codos').AsString)) and (r.FieldByName('periodo').AsString = xperiodo) then Begin

      listar := False;
      if not xincluirinscriptosiva then listar := True else Begin
        profesional.getDatos(r.FieldByName('idprof').AsString);
        obsocial.getDatos(r.FieldByName('codos').AsString);
        profesional.SincronizarListaRetIVA(xperiodo, r.FieldByName('idprof').AsString);
        if (profesional.Retieneiva = 'S') and (obsocial.Retieneiva = 'S') then listar := True;
      end;

      if listar then l.Add(r.FieldByName('idprof').AsString + r.FieldByName('neto').AsString + ';1' + r.FieldByName('monto').AsString);

    end;
    r.Next;
  end;

  Result := l;
end;

function TTFacturacionCCB.setRecalcularProfesionalesLiquidacion(xperiodo: String; listSel: TStringList; xincluirinscriptosiva: Boolean): Real;
// Objetivo...: Recalcular Total Obra Social a partir del Total de Profesionales
var
  r: TQuery;
  listar: Boolean;
  l: TStringList;
Begin
  l := TStringList.Create;
  r := datosdb.tranSQL(DBConexion, 'SELECT periodo, codos, idprof, monto FROM totalesPROF WHERE codos = ' + '''' + listSel.Strings[0] + '''' + ' AND periodo = ' + '''' + xperiodo + '''');
  r.Open; idanter := ''; totales[2] := 0; totales[1] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0;
  while not r.Eof do Begin
    if (utiles.verificarItemsLista(listSel, r.FieldByName('codos').AsString)) and (r.FieldByName('periodo').AsString = xperiodo) then Begin

      listar := False;
      if not xincluirinscriptosiva then listar := True else Begin
        profesional.getDatos(r.FieldByName('idprof').AsString);
        obsocial.getDatos(r.FieldByName('codos').AsString);
        profesional.SincronizarListaRetIVA(xperiodo, r.FieldByName('idprof').AsString);
        if (profesional.Retieneiva = 'S') and (obsocial.Retieneiva = 'S') then listar := True;
      end;

      //if listar then l.Add(r.FieldByName('idprof').AsString + r.FieldByName('neto').AsString + ';1' + r.FieldByName('monto').AsString);
      totales[1] := totales[1] + r.FieldByName('monto').AsFloat;

    end;
    r.Next;
  end;

  Result := totales[1];
end;

procedure TTFacturacionCCB.InformeResumenProfesionales(xperiodo: String; listSel: TStringList; salida: Char; xincluirinscriptosiva: Boolean);
// Objetivo...: Generar Informe Resumen a Profesionales
var
  r: TQuery;
  listar: Boolean;
Begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida);
    list.altopag := 0; list.m := 0; u_h := False;
    list.IniciarTitulos;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Resumen Facturación Profesionales - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, '    Profesional', 1, 'Arial, cursiva, 8');
    list.Titulo(70, list.Lineactual, 'Neto', 3, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Total', 4, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo10(xperiodo);
  end;
  r := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF ORDER BY Idprof, Codos');
  r.Open; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; idanter := '';
  while not r.Eof do Begin
    if (utiles.verificarItemsLista(listSel, r.FieldByName('codos').AsString)) and (r.FieldByName('periodo').AsString = xperiodo) then Begin

      listar := False;
      if not xincluirinscriptosiva then listar := True else Begin
        profesional.getDatos(r.FieldByName('idprof').AsString);
        obsocial.getDatos(r.FieldByName('codos').AsString);
        profesional.SincronizarListaRetIVA(xperiodo, r.FieldByName('idprof').AsString);
        if (profesional.Retieneiva = 'S') and (obsocial.Retieneiva = 'S') then listar := True;
      end;

      if listar then Begin
        if r.FieldByName('idprof').AsString <> idanter then Begin
          if (totales[1] + totales[2] > 0) then LineaProfesional(idanter, xperiodo, salida);
          profesional.getDatos(r.FieldByName('idprof').AsString);
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, profesional.codigo + '  ' + profesional.nombre, 1, 'Arial, negrita, 8', salida, 'S');
          end;
          if salida = 'T' then Begin
            list.LineaTxt(CHR18 + profesional.codigo + '  ' + profesional.nombre, True);
            Inc(lineas); if controlarsalto then titulo10(xperiodo);
          end;

          idanter := r.FieldByName('idprof').AsString;
        end;

        obsocial.getDatos(r.FieldByName('codos').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '  ' + obsocial.codos + '  ' + obsocial.Nombre, 1, 'Arial, normal, 8', salida, 'N');
          if r.FieldByName('neto').AsFloat > 0 then list.importe(75, list.Lineactual, '', r.FieldByName('neto').AsFloat, 2, 'Arial, normal, 8') else
            list.importe(75, list.Lineactual, '', r.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', r.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
        end;
        if salida = 'T' then Begin
          list.LineaTxt(CHR(18) + ' ' + TrimRight(Copy(obsocial.codos + ' ' + obsocial.nombre, 1, 49)) + utiles.espacios(52 - Length(TrimRight(' ' + Copy(obsocial.codos + ' ' + obsocial.nombre, 1, 49)))), False);
          if r.FieldByName('neto').AsFloat > 0 then list.ImporteTxt(r.FieldByName('neto').AsFloat, 10, 2, False) else
            list.ImporteTxt(r.FieldByName('monto').AsFloat, 10, 2, False);
          list.ImporteTxt(r.FieldByName('monto').AsFloat, 10, 2, True);
          Inc(lineas); if controlarsalto then titulo10(xperiodo);
        end;

        totales[2] := totales[2] + r.FieldByName('monto').AsFloat;
        if r.FieldByName('neto').AsFloat > 0 then totales[1] := totales[1] + r.FieldByName('neto').AsFloat else
          totales[1] := totales[1] + r.FieldByName('monto').AsFloat;
      end;

    end;
    r.Next;
  end;

  LineaProfesional(idanter, xperiodo, salida);

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt('', True); Inc(lineas); if controlarsalto then titulo10(xperiodo);
    list.LineaTxt(CHR(18) + 'Total General:' + utiles.espacios(38), False);
    list.ImporteTxt(totales[3], 10, 2, False);
    list.ImporteTxt(totales[4], 10, 2, True);
    Inc(lineas); if controlarsalto then titulo10(xperiodo);
    list.LineaTxt('', True); Inc(lineas); if controlarsalto then titulo10(xperiodo);
  end;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTFacturacionCCB.InformeResumenProfesionalesUnidadesHonorarios(xperiodo: String; listSel: TStringList; salida: Char; xincluirinscriptosiva: Boolean);
// Objetivo...: Generar Informe Resumen a Profesionales Unidades Honorarios
var
  r: TQuery;
  listar: Boolean;
Begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida);
    list.altopag := 0; list.m := 0; u_h := True;
    list.IniciarTitulos;
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
    list.Titulo(0, 0, 'Resumen Facturación Profesionales - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, '    Profesional', 1, 'Arial, cursiva, 8');
    list.Titulo(70, list.Lineactual, 'U.Hon.', 3, 'Arial, cursiva, 8');
    list.Titulo(90, list.Lineactual, 'Total', 4, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  end;
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto;
    titulo10(xperiodo);
  end;
  r := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF ORDER BY Idprof, Codos');
  r.Open; totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; idanter := '';
  while not r.Eof do Begin
    if (utiles.verificarItemsLista(listSel, r.FieldByName('codos').AsString)) and (r.FieldByName('periodo').AsString = xperiodo) then Begin

      listar := False;
      if not xincluirinscriptosiva then listar := True else Begin
        profesional.getDatos(r.FieldByName('idprof').AsString);
        obsocial.getDatos(r.FieldByName('codos').AsString);
        profesional.SincronizarListaRetIVA(xperiodo, r.FieldByName('idprof').AsString);
        if (profesional.Retieneiva = 'S') and (obsocial.Retieneiva = 'S') then listar := True;
      end;

      if listar then Begin
        if r.FieldByName('idprof').AsString <> idanter then Begin
          if (totales[1] + totales[2] > 0) then LineaProfesional(idanter, xperiodo, salida);
          profesional.getDatos(r.FieldByName('idprof').AsString);
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, profesional.codigo + '  ' + profesional.nombre, 1, 'Arial, negrita, 8', salida, 'S');
          end;
          if salida = 'T' then Begin
            list.LineaTxt(CHR18 + profesional.codigo + '  ' + profesional.nombre, True);
            Inc(lineas); if controlarsalto then titulo10(xperiodo);
          end;

          idanter := r.FieldByName('idprof').AsString;
        end;

        obsocial.getDatos(r.FieldByName('codos').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '  ' + obsocial.codos + '  ' + obsocial.Nombre, 1, 'Arial, normal, 8', salida, 'N');
          list.importe(75, list.Lineactual, '', r.FieldByName('ub').AsFloat, 2, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', r.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
        end;
        if salida = 'T' then Begin
          list.LineaTxt(CHR(18) + ' ' + TrimRight(Copy(obsocial.codos + ' ' + obsocial.nombre, 1, 49)) + utiles.espacios(52 - Length(TrimRight(' ' + Copy(obsocial.codos + ' ' + obsocial.nombre, 1, 49)))), False);
          list.ImporteTxt(r.FieldByName('ub').AsFloat, 10, 2, False);
          list.ImporteTxt(r.FieldByName('monto').AsFloat, 10, 2, True);
          Inc(lineas); if controlarsalto then titulo10(xperiodo);
        end;

        totales[2] := totales[2] + r.FieldByName('monto').AsFloat;
        totales[1] := totales[1] + r.FieldByName('ub').AsFloat;
      end;

    end;
    r.Next;
  end;

  LineaProfesional(idanter, xperiodo, salida);

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt('', True); Inc(lineas); if controlarsalto then titulo10(xperiodo);
    list.LineaTxt(CHR(18) + 'Total General:' + utiles.espacios(38), False);
    list.ImporteTxt(totales[3], 10, 2, False);
    list.ImporteTxt(totales[4], 10, 2, True);
    Inc(lineas); if controlarsalto then titulo10(xperiodo);
    list.LineaTxt('', True); Inc(lineas); if controlarsalto then titulo10(xperiodo);
  end;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTFacturacionCCB.LineaProfesional(xidanter, xperiodo: String; salida: char);
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(CHR(18) + TrimRight('Subtotal:') + utiles.espacios(52 - Length(TrimRight('Subtotal:'))), False);
    list.ImporteTxt(totales[1], 10, 2, False);
    list.ImporteTxt(totales[2], 10, 2, True);
    Inc(lineas); if controlarsalto then titulo10(xperiodo);
    list.LineaTxt('', True); Inc(lineas); if controlarsalto then titulo10(xperiodo);
  end;
  totales[3] := totales[3] + totales[1];
  totales[4] := totales[4] + totales[2];
  totales[1] := 0; totales[2] := 0;
end;

function  TTFacturacionCCB.setTotalesProfesionales(xperiodo, xcodos: String): TQuery;
// Objetivo...: Retornar totales profesionales
Begin
  Result := datosdb.tranSQL(DBConexion, 'SELECT * FROM totalesPROF where periodo = ' + '"' + xperiodo + '"' + ' AND codos = ' + '"' + xcodos + '"');
end;

function  TTFacturacionCCB.setPracticasFacturadas: TQuery;
// Objetivo...: Retornar practicas facturadas en el período
Begin
  Result := datosdb.tranSQL(detfact.DatabaseName, 'SELECT codanalisis FROM detfact order by codanalisis');
end;

procedure TTFacturacionCCB.TotalOS(xperiodo: String; salida: Char);
// Objetivo...: Totales OS
Begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'N');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.Linea(95, list.Lineactual, ' ', 4, 'Arial, negrita, 8', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt(CHR(18) + 'Subtotal: ' + utiles.espacios(44), False);
    list.ImporteTxt(totales[3], 10, 2, False);
    list.ImporteTxt(totales[2], 10, 2, True);
    Inc(lineas); if controlarsalto then titulo8(xperiodo);
  end;
  totales[1] := totales[1] + totales[3];
  totales[4] := totales[4] + totales[2];
  totales[2] := 0; totales[3] := 0;
end;

procedure TTFacturacionCCB.FinalizarInforme(salida: Char);
// Objetivo...: Obtener el monto a cobrar por un profesional de todas las obras sociales
Begin

  if (salida = 'P') or (salida = 'I') then begin
    list.FinList;
    exit;
  end;
  if salida = 'X' then excel.Visulizar else Begin
    if not (ExportarDatos) and (salida <> 'N') then Begin
      if not datosListados then utiles.msgError(msgImpresion) else
        if salida <> 'T' then list.FinList else list.FinalizarImpresionModoTexto(1);
    end else
      if salida <> 'N' then FinalizarExportacion;
  end;
end;

procedure TTFacturacionCCB.IniciarArreglos;
// Objetivo...: Iniciar Arreglos
var
  i: Integer;
Begin
  for i := 1 to elementos do Begin
    codigos[i] := ''; montos[i] := 0; totales[i] := 0; dirlab[i] := '';
  end;
  totiva[1] := 0; totiva[2] := 0; _caran := 0; total_orden := 0;
  totivaol[1] := 0; totivaol[2] := 0; totivaol[3] := 0; totivaol[4] := 0;
end;

function TTFacturacionCCB.setMontoACobrarProfesional(xperiodo, xidprof: String): Real;
// Objetivo...: Obtener el monto a cobrar por un profesional de todas las obras sociales
var
  e: Boolean;
Begin
  total := 0;
  e := totalesPROF.Active;
  ConectarTotalesProf;
  if not e then Begin
    totalesPROF.Open;
    testeartotalesprof;
  end;
  datosdb.Filtrar(totalesPROF, 'Periodo = ' + '''' + xperiodo + '''' + ' and Idprof = ' + '''' + xidprof + '''');
  totalesPROF.First;
  while not totalesPROF.EOF do Begin
    total := total + (totalesPROF.FieldByName('monto').AsFloat + totalesPROF.FieldByName('retencion').AsFloat);
    totalesPROF.Next;
  end;
  if not e then DesconectarTotalesProf;
  Result := total;
end;

procedure TTFacturacionCCB.ConectarTotalesProf;
// Objetivo...: Conectar tabla de totalesProf
Begin
  totalesPROF := datosdb.openDB('totalesPROF', 'Periodo;Idprof;Codos', '', DBConexion);
  totalesOS   := datosdb.openDB('totalesOS', 'Periodo;Codos', '', DBConexion);
end;

procedure TTFacturacionCCB.DesconectarTotalesProf;
// Objetivo...: Desconectar tabla de totalesProf
Begin
  if totalesPROF <> Nil then datosdb.closeDB(totalesPROF);
  if totalesOS <> Nil then datosdb.closeDB(totalesOS);
end;

function TTFacturacionCCB.ProcesandoDatosCentrales: Boolean;
// Objetivo...: Retornar el tipo de Procesamiento
Begin
  Result := ProcesamientoCentral;
end;

function TTFacturacionCCB.setNetoACobrarProfesional(xperiodo, xidprof: String): Real;
// Objetivo...: Obtener el Neto a Cobrar por el Profesional
Begin
  subtotal := 0;
  datosdb.Filtrar(totalesPROF, 'Periodo = ' + xperiodo + ' AND Idprof = ' + xidprof);
  totalesPROF.First;
  while not totalesPROF.Eof do Begin
    subtotal := subtotal + (totalesPROF.FieldByName('monto').AsFloat - totalesPROF.FieldByName('neto').AsFloat);
    totalesPROF.Next;
  end;
  datosdb.QuitarFiltro(totalesPROF);
  Result := subtotal;
end;

function TTFacturacionCCB.setCompensacionArancelaria: Real;
// Objetivo...: Devolver la compensación arancelaria
Begin
  Result := caran;
  caran  := 0;
end;

function TTFacturacionCCB.setCompensacionArancelariaIndividual: Real;
// Objetivo...: Devolver la compensación arancelaria
Begin
  Result := _caran;
  _caran := 0;
end;

{ ============================================================================== }
procedure TTFacturacionCCB.PrepararDirectorio_OrdenesAuditadas(xperiodo, xlaboratorio: String);
// Objetivo...: Creamos Via de trabajo para trabajar con el laboratorio en cuestion
var
  p: String;
  t: TTable;
begin
  p := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
  directorio1 := dir_lab + '\' + p + '\' + xlaboratorio + '\';

  if (interbase = 'N') then begin
    if not DirectoryExists(directorio1) then PrepararDirectorio(xperiodo, xlaboratorio);
    if Not FileExists(directorio1 + '\' + 'ordenes_audit.db') then Begin//utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\auditoria', '*.*', directorio1);
      datosdb.tranSQL(directorio1, 'create table ordenes_audit (Periodo char(7), Items char(3), Idprof char(6), Nroauditoria char(10), Facturada char(1), primary key(Periodo, Items, Idprof))');
      t := datosdb.openDB('ordenes_audit', '', '', directorio1);  // Cambios del 12/09/2007
      t.Open; datosdb.closeDB(t);
      datosdb.tranSQL(directorio1, 'create index auditoria_nroauditoria on ordenes_audit(nroauditoria)');
    end;
    if directorio1 <> diractual1 then SeleccionarLaboratorio_Auditoria(xperiodo, directorio1);  // Conectamos al directorio seleccionado
  end;

  if (interbase = 'S') then lote.Clear;

  Periodo := xperiodo;
end;

function TTFacturacionCCB.verificarDirectorio_OrdenesAuditadas(xperiodo, xlaboratorio: String): Boolean;
// Objetivo...: Verificamos si existe la Via
var
  p: String;
begin
  if (interbase = 'N') then begin
    p := Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4);
    directorio1 := dir_lab + '\' + p + '\' + xlaboratorio;
    if not DirectoryExists(directorio1) then Result := False else Begin
      SeleccionarLaboratorio_Auditoria(xperiodo, directorio1);
      Result := True;
    end;
  end;
  profesional.getDatos(xlaboratorio);
  Periodo := xperiodo;
end;

procedure TTFacturacionCCB.SeleccionarLaboratorio_Auditoria(xperiodo, xdirectorio: String);
// Objetivo...: Cambiar directorio de trabajo
begin
  directorio1 := xdirectorio;

  if (interbase = 'N') then begin
    InstanciarTablas_Auditoria(xdirectorio);
    if ordenes_audit <> Nil then Begin
      diractual1  := directorio1;
      if not ordenes_audit.Active then ordenes_audit.Open;
    end;
  end;

  if (interbase = 'N') then InstanciarTablas(xdirectorio);
end;


procedure TTFacturacionCCB.RegistrarOrdenes(xperiodo, xitems, xidprof, xnroauditoria, xestado: String; xcantidad_items: Integer);
// Objetivo...: Registrar Ordenes
Begin
  if (interbase = 'N') then begin
    if datosdb.Buscar(ordenes_audit, 'periodo', 'items', 'idprof', xperiodo, xitems, xidprof) then ordenes_audit.Edit else ordenes_audit.Append;
    ordenes_audit.FieldByName('periodo').AsString      := xperiodo;
    ordenes_audit.FieldByName('idprof').AsString       := xidprof;
    ordenes_audit.FieldByName('items').AsString        := xitems;
    ordenes_audit.FieldByName('nroauditoria').AsString := utiles.sLlenarIzquierda(xnroauditoria, 10, '0');
    try
      ordenes_audit.Post
     except
      ordenes_audit.Cancel
    end;

    if xitems = utiles.sLlenarIzquierda(IntToStr(xcantidad_items), 3, '0') then Begin
      datosdb.tranSQL(diractual1, 'delete from ordenes_audit where periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantidad_items), 3, '0') + '"');
      datosdb.refrescar(ordenes_audit);
    end;
  end;

  if (interbase = 'S') then begin
    if (xitems = '001') then lote.Add('delete from ordenes_audit where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
    lote.Add('insert into ordenes_audit (periodo, idprof, items, nroauditoria, facturada) values (' +
      '"' + xperiodo + '"' + ',' +
      '"' + xidprof + '"' + ',' +
      '"' + xitems + '"' + ',' +
      '"' + xnroauditoria + '"' + ',' +
      '"' + xestado + '"' + ')');

    if (xitems = utiles.sLlenarIzquierda(IntToStr(xcantidad_items), 3, '0')) then begin
      ffirebird.TransacSQLBatch(lote);
      lote.Clear;
    end;
  end;

    {if ffirebird.Buscar(ordenes_auditIB, 'periodo;items;idprof', xperiodo, xitems, xidprof) then ordenes_auditIB.Edit else ordenes_auditIB.Append;
    ordenes_auditIB.FieldByName('periodo').AsString      := xperiodo;
    ordenes_auditIB.FieldByName('idprof').AsString       := xidprof;
    ordenes_auditIB.FieldByName('items').AsString        := xitems;
    ordenes_auditIB.FieldByName('nroauditoria').AsString := utiles.sLlenarIzquierda(xnroauditoria, 10, '0');
    try
      ordenes_auditIB.Post
     except
      ordenes_auditIB.Cancel
    end;
    ffirebird.RegistrarTransaccion(ordenes_auditIB);

    if (xitems = utiles.sLlenarIzquierda(IntToStr(xcantidad_items), 3, '0')) then Begin
      ffirebird.TransacSQL('delete from ordenes_audit where periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantidad_items), 3, '0') + '"');
      ffirebird.closeDB(ordenes_auditIB); ordenes_auditIB.open;
    end;
  end;}
end;

procedure TTFacturacionCCB.BorrarOrdenAuditoria(xperiodo, xitems, xidprof: String);
// Objetivo...: Borrar Orden de Auditoria
Begin
  ordenes_audit.IndexFieldNames := 'periodo;items;idprof';
  if datosdb.Buscar(ordenes_audit, 'periodo', 'items', 'idprof', xperiodo, xitems, xidprof) then ordenes_audit.Delete;
  datosdb.refrescar(ordenes_audit);
end;

procedure TTFacturacionCCB.BorrarOrdenAuditoriaIB(xperiodo, xidprof: String);
// Objetivo...: Borrar Orden de Auditoria
Begin
  ffirebird.TransacSQL('delete from ordenes_audit where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
end;

procedure TTFacturacionCCB.BorrarOrdenAuditoria(xperiodo, xidprof: String);
// Objetivo...: Borrar Todas las Ordenes de Auditoria
Begin
  if (interbase = 'N') then begin
    datosdb.tranSQL(ordenes_audit.DatabaseName, 'delete from ' + ordenes_audit.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''');
    datosdb.refrescar(ordenes_audit);
  end;

  if (interbase = 'S') then BorrarOrdenAuditoriaIB(xperiodo, xidprof);
end;

function TTFacturacionCCB.setOrdenesAuditoria(xperiodo, xidprof: String): TQuery;
// Objetivo...: devolver las ordenes de un determinado periodo y un determinado profesional
Begin
  if not verificarDirectorio_OrdenesAuditadas(xperiodo, xidprof) then Result := Nil else
    if ordenes_audit <> Nil then Result := datosdb.tranSQL(diractual1, 'select * from ordenes_audit where periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"' + ' order by items') else Result := Nil;
end;

function TTFacturacionCCB.setOrdenesAuditoriaIB(xperiodo, xidprof: String): TIBQuery;
// Objetivo...: devolver las ordenes de un determinado periodo y un determinado profesional
Begin
  Result := ffirebird.getTransacSQL('select * from ordenes_audit where periodo = ' + '"' + xperiodo + '"' + ' and idprof = ' + '"' + xidprof + '"' + ' order by items');
end;

function TTFacturacionCCB.verificarOrden(xidprof, xorden: String): Boolean;
// Objetivo...: verificar si la orden esta registrada
Begin
  if ordenes_audit <> Nil  then
   if ordenes_audit.Active then Begin
    ordenes_audit.IndexFieldNames := 'Nroauditoria';
    if ordenes_audit.FindKey([xorden]) then
      if ordenes_audit.FieldByName('idprof').AsString <> xidprof then Begin
        profesional.getDatos(ordenes_audit.FieldByName('idprof').AsString);
        NProfesional := profesional.Nombre;
        Result := True;
      end else Result := False;
    ordenes_audit.IndexFieldNames := 'Periodo;Items;Idprof';
  end else
    Result := False;
end;

procedure TTFacturacionCCB.MarcarOrdenAuditoria(xperiodo, xitems, xidprof, xestado: String);
// Objetivo.... verificar estado de la orden
Begin
  if (interbase = 'N') then begin
    if ordenes_audit <> nil then Begin
      ordenes_audit.IndexFieldNames := 'Periodo;Items;Idprof';
      if datosdb.Buscar(ordenes_audit, 'periodo', 'items', 'idprof', xperiodo, xitems, xidprof) then Begin
        ordenes_audit.Edit;
        ordenes_audit.FieldByName('facturada').AsString := xestado;
        try
          ordenes_audit.Post
         except
          ordenes_audit.Cancel
        end;
      end;
      datosdb.refrescar(ordenes_audit);
    end;
  end;

  if (interbase = 'S') then begin
    ffirebird.TransacSQL('update ordenes_audit set facturada = ' + '''' + xestado + '''' + ' where periodo = ' + '''' + xperiodo + '''' + ' and items = ' + '''' + xitems + '''' + ' and idprof = ' + '''' + xidprof + '''');
  end;
end;

procedure TTFacturacionCCB.BorrarOrdenesPorId(xid, xperiodo, xidprof: String);
// Objetivo...: Borrar Ordenes con un Id. Mayor a
Begin
  if (interbase = 'N') then
    datosdb.tranSQL(directorio, 'delete from detfact where (orden > ' + '"' + xid + '"' + ' and orden < ' + '"' + 'R000' + '"' + ')');
  if (interbase = 'S') then
    ffirebird.TransacSQL('delete from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and (orden > ' + '"' + xid + '"' + ' and orden < ' + '"' + 'R000' + '"' + ')');
end;

function  TTFacturacionCCB.ObtenerUltimoId(xperiodo, xidprof: string): Integer;
// Objetivo...: Devolver el ultimo Id de las Ordenes Facturadas desde la Auditoria
var
  r: TQuery;
  s: TIBQuery;
Begin
  if (interbase = 'N') then begin
    Result := 5000;
    r := datosdb.tranSQL(directorio, 'select orden from detfact where (orden > ' + '"' + '5000' + '"' + ' and orden < ' + '"' + 'R000' + '"' + ') order by orden');
    r.Open; r.Last;
    if r.RecordCount > 0 then Result := StrToInt(r.Fields[0].AsString);
    r.Close; r.Free;
  end;
  if (interbase = 'S') then begin
    Result := 5000;
    s := ffirebird.getTransacSQL('select orden from detfact where periodo = ' + '''' + xperiodo + '''' + ' and idprof = ' + '''' + xidprof + '''' + ' and (orden > ' + '"' + '5000' + '"' + ' and orden < ' + '"' + 'R000' + '"' + ') order by orden');
    s.Open; s.Last;
    if s.RecordCount > 0 then Result := StrToInt(s.Fields[0].AsString);
    s.Close; s.Free;
  end;
end;

{ ------------------------------------------------------------------------------ }

function TTFacturacionCCB.listarLinea: Boolean;
// Objetivo...: Evaluar las posibilidades en cuanto a I.V.A. de Listar o No Operación
Begin
  if not (ProcesamientoCentral) or not (SC) then Result := True else Begin
    Result := False;
    if (interbase = 'N') then begin
      if ExcluirLab then Begin
        if (detfact.FieldByName('profiva').AsString = 'N') then Result := True;
        if (detfact.FieldByName('profiva').AsString = 'S') and (detfact.FieldByName('osiva').AsString = 'N') then Result := True;
      end;
      if not ExcluirLab then Begin
        if (detfact.FieldByName('profiva').AsString = 'S') and (detfact.FieldByName('osiva').AsString = 'S') then Result := True;
      end;
    end;

    if (interbase = 'S') then begin
      if ExcluirLab then Begin
        if (rsqlIB.FieldByName('profiva').AsString = 'N') then Result := True;
        if (rsqlIB.FieldByName('profiva').AsString = 'S') and (rsqlIB.FieldByName('osiva').AsString = 'N') then Result := True;
      end;
      if not ExcluirLab then Begin
        if (rsqlIB.FieldByName('profiva').AsString = 'S') and (rsqlIB.FieldByName('osiva').AsString = 'S') then Result := True;
      end;
      if not ExcluirLab then Begin
        if (length(trim(rsqlIB.FieldByName('profiva').AsString)) = 0) and (length(trim(rsqlIB.FieldByName('osiva').AsString)) = 0) then Result := True;
      end;
      // 18/06/2014 - historico
      {if (length(trim(rsqlIB.FieldByName('profiva').AsString)) = 0) and (length(trim(rsqlIB.FieldByName('osiva').AsString)) = 0) then begin
        profesional.getDatos(rsqlIB.FieldByName('idprof').AsString);
        if (profesional.Retieneiva = 'N') then result := true;
        obsocial.SincronizarPosicionFiscal(rsqlIB.FieldByName('codos').AsString, rsqlIB.FieldByName('periodo').AsString);
        if (profesional.Retieneiva = 'S') and (obsocial.Retieneiva = 'N') then result := true;
      end;}
    end;
  end;
end;

function TTFacturacionCCB.setDeterminacionesProfesional(xperiodo: String): TQuery;
// Objetivo...: Listar Determinaciones por Profesional
Begin
   Result := datosdb.tranSQL(cabfact.DatabaseName, 'select cabfact.periodo, cabfact.idprof, cabfact.codos, detfact.codanalisis from cabfact, detfact where ' +
                                                   'cabfact.idprof = detfact.idprof and cabfact.codos = detfact.codos order by idprof, codos, codanalisis');
end;

procedure TTFacturacionCCB.CambiarTipoTotalProfesional(xperiodo, xidprof, xcodos: string; xmodo: integer);
begin
  datosdb.tranSQL(totalesprof.DatabaseName, 'update totalesprof set tipoing = ' + inttostr(xmodo) + ' where periodo = ' + '''' + xperiodo + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and idprof = ' + '''' + xidprof + '''');
end;

function TTFacturacionCCB.getLaboratoriosARefacturar(xperiodo: string): TIBQuery;
// Objetivo...: devolver un set de items facturados
begin
  Result := ffirebird.getTransacSQL('select distinct(idprof) from detfact where periodo=' + '''' + xperiodo + '''' +
     ' and (orden > ' + '''' + '5000' + '''' + ' and substring(orden from 1 for 1) <> ' + '''' + 'R' + '''' + ') and nroauditoria is null');
end;

function TTFacturacionCCB.getLaboratoriosARefacturarAll(xperiodo: string): TIBQuery;
// Objetivo...: devolver un set de items facturados
begin
  Result := ffirebird.getTransacSQL('select distinct(idprof) from detfact where periodo=' + '''' + xperiodo + '''' +
     ' and (orden > ' + '''' + '5000' + '''' + ' and substring(orden from 1 for 1) <> ' + '''' + 'R' + '''' + ')');
end;

{ ============================================================================== }

function TTFacturacionCCB.getLaboratoriosConCoseguro(xperiodo: string): TIBQuery;
begin
  Result := ffirebird.getTransacSQL('select distinct(idprof) as idprof from detfact where periodo=' + '''' + xperiodo + '''' + ' and coseguro > 0');
end;

function TTFacturacionCCB.getCoseguroLaboratorios(xperiodo, xidprof: string): TIBQuery;
begin
  Result := ffirebird.getTransacSQL('select sum(coseguro) as coseguro, codos from detfact where idprof=' + '''' + xidprof + '''' + ' and periodo=' + '''' + xperiodo + '''' + ' and coseguro > 0 group by (codos) order by codos');
end;

function  TTFacturacionCCB.getListObrasSocialesRegla(xperiodo, xregla: string): TIBQuery;
var
  r: TQuery;
  s, t: string;
begin
  r := obsocial.getReglas(xregla);
  r.open; s := '';
  while not r.eof do begin
    s := s + r.fieldbyname('codos').asstring + ', ';
    r.next;
  end;
  r.close; r.free;

  if (s = '') then result := nil;

  t := '(' + copy(s, length(s) - 1) + ')';

  result := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and codos in ' + t + ' order by periodo, codos, idprof, orden, items');
  
end;

procedure TTFacturacionCCB.exportarRegla(xperiodo, xregla: string);
var
  r: TQuery;
  s: TIBQuery;
  t: TTable;
  idprofanter: string;
  monto: double;
begin

  datosdb.tranSQL('delete from obsocial_export_temp');

  t := datosdb.openDB('obsocial_export_temp', '');
  t.open;

  r := datosdb.tranSQL('select c.* from obsocial_export_sopmag c, obsocial_reglas t where c.periodo= ' + '''' + xperiodo + '''' + ' and c.codos = t.codos and t.regla = ' + xregla + ' order by c.tipo, c.sucursal, c.numero');
  r.Open; r.first;

  while not r.Eof do begin

    obsocial.SincronizarPosicionFiscal(r.fieldbyname('codos').asstring, xperiodo);

    s := ffirebird.getTransacSQL('select * from detfact where periodo = ' + '''' + xperiodo + '''' + ' and codos = ' + '''' + r.fieldbyname('codos').asstring + '''' + ' and idprof = ' + '''' + r.fieldbyname('idprof').asstring + '''' + ' order by periodo, codos, idprof, orden, items');
    s.open; s.first;

    while not s.eof do begin

      if (t.FieldByName('idprof').asstring <> idprofanter) then begin
        profesional.getDatos(t.FieldByName('idprof').asstring);
        idprofanter := t.FieldByName('idprof').asstring;
      end;


      t.Append;
      t.FieldByName('periodo').asstring := s.FieldByName('periodo').asstring;
      t.FieldByName('codos').asstring := s.FieldByName('codos').asstring;
      t.FieldByName('idprof').asstring := s.FieldByName('idprof').asstring;
      t.FieldByName('orden').asstring := s.FieldByName('orden').asstring;
      t.FieldByName('items').asstring := s.FieldByName('items').asstring;
      t.FieldByName('codigo').asstring := s.FieldByName('codanalisis').asstring;
      t.FieldByName('monto').value := s.FieldByName('monto').value;
      t.FieldByName('iva').value := s.FieldByName('iva').value;

      t.FieldByName('tipo').asstring := r.FieldByName('tipo').asstring;
      t.FieldByName('sucursal').asstring := utiles.sLlenarIzquierda(r.FieldByName('sucursal').asstring, 4, '0');
      t.FieldByName('numero').asstring := utiles.sLlenarIzquierda(r.FieldByName('numero').asstring, 8, '0');

      t.FieldByName('op1').asstring := r.FieldByName('fecha').asstring;
      t.FieldByName('op2').asstring := s.FieldByName('nroafiliado').asstring;
      t.FieldByName('op3').asstring := profesional.Nrocuit;

      if (s.FieldByName('retiva').asstring = 'S') and (r.FieldByName('tipo').asstring <> 'C') then begin
        monto := t.FieldByName('monto').AsFloat + (t.FieldByName('iva').AsFloat * (obsocial.retencioniva * 0.01));
        t.FieldByName('montofinal').value := monto;
      end else
        t.FieldByName('montofinal').value := s.FieldByName('monto').value;

      t.Post;

      s.next;
    end;

    s.close; s.Free;

    r.next;

  end;

  t.close;

  r.close; r.free;

end;

function TTFacturacionCCB.exportarReglaFacturasRI(xperiodo: string): TQuery;
begin
  //result := datosdb.tranSQL('select tipo, sucursal, numero, op1, sum(montofinal) as monto from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + '  group by tipo, sucursal, numero, op1');
  result := datosdb.tranSQL('select tipo, sucursal, numero, op1, idprof, sum(montofinal) as monto from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + ' and tipo <> ' + '''' + 'C' + '''' + '  group by idprof, tipo, sucursal, numero, op1 order by tipo, sucursal, numero');
end;

function TTFacturacionCCB.exportarReglaFacturasRM(xperiodo: string): TQuery;
begin
  //result := datosdb.tranSQL('select tipo, sucursal, numero, op1, sum(montofinal) as monto from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + '  group by tipo, sucursal, numero, op1');
  result := datosdb.tranSQL('select tipo, sucursal, numero, op1, sum(montofinal) as monto from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + ' and tipo = ' + '''' + 'C' + '''' + '  group by tipo, sucursal, numero, op1 order by tipo, sucursal, numero');
end;


function TTFacturacionCCB.exportarReglaFacturasDetalle(xperiodo: string): TQuery;
begin
  result := datosdb.tranSQL('select * from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + ' order by idprof, tipo, sucursal, numero');
  //result := datosdb.tranSQL('select * from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + ' order by idprof, codos, tipo, sucursal, numero, orden, items');
  //result := datosdb.tranSQL('select * from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + ' order by tipo, sucursal, numero, codos, idprof, orden, items');
end;

function TTFacturacionCCB.exportarReglaFacturasDetalleRM(xperiodo: string): TQuery;
begin
  //result := datosdb.tranSQL('select * from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + ' order by idprof, codos, tipo, sucursal, numero, orden, items');
  result := datosdb.tranSQL('select * from obsocial_export_temp where periodo = ' + '''' + xperiodo + '''' + ' order by tipo, sucursal, numero, codos, idprof, orden, items');
end;

procedure  TTFacturacionCCB.listarUBFacturadas(xperiodo: string; salida: char);
// Objetivo: Listar UB Facturadas
var
  t, m: TIBQuery;
  unidades, total: real;
begin
  list.altopag := 0; list.m := 0;
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'UB Facturadas - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  list.Titulo(15, list.Lineactual, 'Obra Social', 2, 'Arial, cursiva, 8');
  list.Titulo(70, list.Lineactual, 'Prestaciones', 3, 'Arial, cursiva, 8');
  list.Titulo(89, list.Lineactual, 'UB Fact.', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.LineaLargoPagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  t := ffirebird.getTransacSQL('select distinct(codos) as codos from detfact where periodo = ' + '''' + xperiodo + '''');

  t.open; t.first;
  while not t.eof do begin

    // Unidades facturadas
    m := ffirebird.getTransacSQL('select codanalisis, count(codanalisis) as cant from detfact where periodo = ' + '''' + xperiodo + '''' + ' and codos = ' + '''' + t.FieldByName('codos').AsString + '''' + ' group by codanalisis');
    m.open; m.first; total := 0; unidades := 0;
    while not m.eof do begin
      unidades := unidades + m.fieldbyname('cant').asfloat;

      nbu.getDatos(m.fieldbyname('codanalisis').asstring);
      total := total + (m.fieldbyname('cant').asfloat * nbu.unidad);

      m.next;
    end;
    m.close; m.free;

    obsocial.getDatos(t.FieldByName('codos').AsString);
    list.Linea(0, 0, obsocial.codos, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(15, list.Lineactual, obsocial.Nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', unidades, 3, 'Arial, normal, 8');
    list.importe(95, list.Lineactual, '', total, 4, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    t.next;
  end;

  t.close; t.free;

  list.FinList;
end;

{ ----------------------------------------------------------------------------- }
procedure TTFacturacionCCB.ListarCosegurosFacturados(xperiodo: String; salida: Char);
var
  s: TQuery;
  l: TStringList;
  i: Integer;
  r, t: TIBQuery;
  total: double;
begin
  list.altopag := 0; list.m := 0;
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Coseguros Facturados - Período: ' + xperiodo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  list.Titulo(15, list.Lineactual, 'Obra Social', 2, 'Arial, cursiva, 8');
  list.Titulo(90, list.Lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.LineaLargoPagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  l := TStringList.Create;
  s := obsocial.getReglasCoseguros;
  s.open; s.first;
  while not s.eof do begin
    l.Add(s.FieldByName('codos').AsString);
    s.next;
  end;
  s.Close; s.free;

  DatosListados := False;
  r := getLaboratoriosConCoseguro(xperiodo);
  r.Open; total := 0;
  while not r.EOF do Begin
    profesional.getDatos(r.FieldByName('idprof').AsString);

    t := getCoseguroLaboratorios(xperiodo, r.FieldByName('idprof').AsString);
    t.open; t.first; i := 0;
    while not t.eof do begin
      if (utiles.verificarItemsLista(l, t.FieldByName('codos').AsString)) then begin

        if (i = 0) then begin
           list.Linea(0, 0, 'Profesional: ' +  profesional.nombre, 1, 'Arial, negrita, 9', salida, 'N');
           list.Linea(70, list.Lineactual, profesional.codigo, 2, 'Arial, negrita, 9', salida, 'S');
           list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
           i := 1;
        end;

        obsocial.getDatos(t.FieldByName('codos').AsString);
        list.Linea(0, 0, obsocial.codos, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(15, list.Lineactual, obsocial.Nombre, 2, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', t.FieldByName('coseguro').AsFloat, 3, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
        total := total + t.FieldByName('coseguro').AsFloat;
      end;
      t.Next;
    end;
    t.Close; t.free;

    if (i = 1) then list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
    

    DatosListados := True;
    r.Next;
  end;
  r.Close; r.Free;

  if (DatosListados) then begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, 'Total Coseguro: ', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', total, 2, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  end;

  list.FinList;
end;


{ ============================================================================== }

procedure TTFacturacionCCB.vaciarBuffer;
// Objetivo...: Vaciar Buffers
begin
  if (interbase = 'N') then begin
    datosdb.closedb(cabfact); cabfact.Open;
    datosdb.closedb(detfact); detfact.Open;
    datosdb.closedb(idordenes); idordenes.Open;
  end;
  if (interbase = 'S') then begin
    ffirebird.TransacSQLBatch(lote);
    lote.Clear;
  end;
end;

function  TTFacturacionCCB.setLaboratoriosBackup(xperiodo: String): TStringList;
// Objetivo...: Respaldar Laboratorios
var
  l1, l2: TStringList;
  i: Integer;
begin
  l2 := TStringList.Create;
  l1 := utilesarchivos.setListaArchivos(dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4), '*.bck');
  For i := 1 to l1.Count do
    l2.Add(Copy(ExtractFileName(l1.Strings[i-1]), 1, 6));
  Result := l2;
end;

procedure TTFacturacionCCB.RealizarBackupLaboratorios(xperiodo: String);
// Objetivo...: Respaldar Laboratorios
var
  l: TStringList;
  i: Integer;
begin
  l := ListaLaboratoriosActualizados;
  For i := 1 to l.Count do
    if DirectoryExists(dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + l.Strings[i-1]) then
      utilesarchivos.CompactarArchivos(dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + l.Strings[i-1] + '\*.*', dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + l.Strings[i-1] + '.bck');
  listatrab.Clear;
end;

procedure TTFacturacionCCB.RealizarRestauracionLaboratorios(xperiodo, xidprof: String);
// Objetivo...: Restaurar Laboratorios
begin
  utilesarchivos.RestaurarBackup(dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + xidprof + '.bck', dir_lab + '\' + Copy(xperiodo, 1, 2) + Copy(xperiodo, 4, 4) + '\' + xidprof);
end;

function  TTFacturacionCCB.ListaLaboratoriosActualizados: TStringList;
// Objetivo...: Listar Laboratorios que tuvieron movimientos
begin
  Result := listatrab;;
end;

procedure TTFacturacionCCB.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  // Si es un usuario de Laboratorio, apunta al directorio comun arch
  LaboratorioActivo := False;
  profesional.conectar;
  paciente.conectar;
  obsocial.conectar;
  nomeclaturaos.conectar;
  nbu.conectar;

  if not (__laboratorios) then osagrupa.conectar;

  if not modeloc.Active     then modeloc.Open;
  if not cabfactos.Active   then cabfactos.Open;
  if not liq.Active         then liq.Open;
  if not datosfact.Active   then datosfact.Open;
  //if not datosfactdet.Active   then datosfactdet.Open;
  if not ctrlImpr.Active    then ctrlImpr.Open;
  if not datosImport.Active then datosImport.Open;

  if (interbase = 'N') then begin
    if conexiones = 0 then Begin
      if Length(Trim(diractual)) > 0 then Begin
        if not cabfact.Active   then cabfact.Open;
        if not detfact.Active   then detfact.Open;
        if not idordenes.Active then idordenes.Open;
        LaboratorioActivo := True;
      end;
    End;
  end;

  Inc(conexiones);
end;

procedure TTFacturacionCCB.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  {if (ibase <> nil) then begin
    ibase.Desconectar;
    ibase := nil;
    cabfactIB := nil;
  end;}

  if (ffirebird <> nil) then begin
    ffirebird.Desconectar;
    ffirebird := nil;
    //cabfactIB := nil;
  end;
  
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if (interbase = 'N') then begin
      if (cabfact <> nil) then datosdb.closeDB(cabfact);
      if (detfact <> nil) then datosdb.closeDB(detfact);
      if (idordenes <> nil) then datosdb.closeDB(idordenes);
      if (ordenes_audit <> nil) then datosdb.closeDB(ordenes_audit);
    end;
    datosdb.closeDB(modeloc);
    datosdb.closeDB(cabfactos);
    datosdb.closeDB(liq);
    datosdb.closeDB(datosfact);
    //datosdb.closeDB(datosfactdet);
    datosdb.closeDB(ctrlImpr);
    datosdb.closeDB(datosImport);
  end;
  obsocial.desconectar;
  profesional.desconectar;
  paciente.desconectar;
  nomeclaturaos.desconectar;
  nbu.desconectar;
  if not (__laboratorios) then osagrupa.desconectar;
  directorio := ''; diractual := '';
  LaboratorioActual := ''; LaboratorioActivo := False;

  if (ressql <> nil) then
    if (ressql.Active) then ressql.Close;
  ressql := nil;

  __codigos := nil; __montos := nil;
end;

procedure TTFacturacionCCB.SeleccionarLaboratorio(xdirectorio: String);
// Objetivo...: Cambiar directorio de trabajo
begin
  if (length(trim(firebird.Host)) = 0)  then interbase := 'N';

  directorio := xdirectorio;
  InstanciarTablas(xdirectorio);
  diractual  := directorio;
  if (interbase = 'N') then begin
    if not cabfact.Active   then cabfact.Open;
    if not detfact.Active   then detfact.Open;
    if not idordenes.Active then idordenes.Open;
  end;
  if (interbase = 'S') then begin
    {if not cabfactIB.Active   then cabfactIB.Open;
    if not detfactIB.Active   then detfactIB.Open;
    if not idordenesIB.Active then idordenesIB.Open;}
  end;
  LaboratorioActivo    := True;
  ProcesamientoCentral := False;
end;

procedure TTFacturacionCCB.InstanciarTablas(xdirectorio: String);
// Objetivo...: Crear las tablas de persistencias en un directorio determinado
begin
  // Prorrateamos la epoca y de acuerdo a la misma determinamos si trabaja o no en version Client/Server
  if (FileExists(xdirectorio + '\cabfact.db')) then interbase := 'N' else interbase := 'S';

  if (interbase = 'N') then begin
    if cabfact   <> nil then if cabfact.Active   then datosdb.closeDB(cabfact);
    if detfact   <> nil then if detfact.Active   then datosdb.closeDB(detfact);
    if idordenes <> nil then if idordenes.Active then datosdb.closeDB(idordenes);
    cabfact := nil; detfact := nil; idordenes := nil;
    cabfact   := datosdb.openDB('cabfact', 'Periodo;Idprof;Codos', '', xdirectorio);
    detfact   := datosdb.openDB('detfact', 'Periodo;Idprof;Codos;Items;Orden', '', xdirectorio);
    idordenes := datosdb.openDB('idordenes', 'Periodo;Idprof', '', xdirectorio);

    if not (datosdb.verificarSiExisteCampo('detfact', 'ref1', detfact.DatabaseName)) then
      datosdb.tranSQL(detfact.DatabaseName, 'alter table detfact add ref1 char(7)');
    if not (datosdb.verificarSiExisteCampo('detfact', 'retiva', detfact.DatabaseName)) then
      datosdb.tranSQL(detfact.DatabaseName, 'alter table detfact add retiva char(1)');
  end;
  if (interbase = 'S') or (xdirectorio = 'S') then begin
    //if cabfactIB   <> nil then firebird.Desconectar;

    if (firebird.Usuario = '') then firebird.getModulo('facturacion');
    //if cabfactIB   <> nil then if cabfactIB.Active   then firebird.closeDB(cabfactIB);
    //if detfactIB   <> nil then if detfactIB.Active   then firebird.closeDB(detfactIB);
    //if idordenesIB <> nil then if idordenesIB.Active then firebird.closeDB(idordenesIB);
    //if ordenes_auditIB <> nil then if ordenes_auditIB.Active then firebird.closeDB(ordenes_auditIB);
    //cabfactIB := nil; detfactIB := nil; idordenesIB := nil; ordenes_auditIB := nil;

    //if (length(trim(firebird.Host)) > 0) and (length(trim(perrem)) > 0) then begin

    if (ffirebird = nil) and (xdirectorio <> 'PersistObjetos') then begin
      //firebird.Conectar(firebird.Host + perrem + '\' + labrem + '\FACTLAB.GDB', firebird.Usuario , firebird.Password);
      //firebird.getModulo('facturacion');
      //utiles.msgError('punto01');

      ffirebird := TTFirebird.Create;
      //if (ffirebird <> nil) then utiles.msgError('no nula');

      ffirebird.Conectar(firebird.Host +  'FACTLABWORK.GDB', firebird.Usuario , firebird.Password);
      //utiles.msgError('punto11');

      {if not (factglobal) then begin
        cabfactIB       := ffirebird.InstanciarTabla('cabfact');
        detfactIB       := ffirebird.InstanciarTabla('detfact');
        idordenesIB     := ffirebird.InstanciarTabla('idordenes');
        ordenes_auditIB := ffirebird.InstanciarTabla('ordenes_audit');
      end else begin
        cabfactIB       := ffirebird.InstanciarTabla('cabfact_gl');
        detfactIB       := ffirebird.InstanciarTabla('detfact_gl');
        idordenesIB     := ffirebird.InstanciarTabla('idordenes_gl');
        ordenes_auditIB := ffirebird.InstanciarTabla('ordenes_audit');
      end;}

    end;
  end;
end;

procedure TTFacturacionCCB.InstanciarTablas_Auditoria(xdirectorio: String);
// Objetivo...: Crear las tablas de persistencias en un directorio determinadp
begin
  if (interbase = 'N') then begin
    if ordenes_audit <> nil then if ordenes_audit.Active then datosdb.closeDB(ordenes_audit);
    if FileExists(xdirectorio + '\' + 'ordenes_audit.db') then ordenes_audit := datosdb.openDB('ordenes_audit', '', '', xdirectorio) else ordenes_audit := Nil;
  end;
  if (interbase = 'S') then begin
    InstanciarTablas(xdirectorio);
    //if ordenes_auditIB <> nil then if ordenes_auditIB.Active then firebird.closeDB(ordenes_auditIB);
    //ordenes_audit := datosdb.openDB('ordenes_audit', '', '', xdirectorio) else ordenes_audit := Nil;
  end;
end;

procedure TTFacturacionCCB.testeartotalesprof;
var
  d: String;
  e: Boolean;
Begin
  if totalesPROF <> Nil then Begin
    e := totalesPROF.Active;
    d := totalesPROF.DatabaseName;
    if not datosdb.verificarSiExisteCampo(totalesPROF, 'Neto') then Begin
      totalesPROF.Close;
      if dbs.BaseClientServ = 'N' then datosdb.tranSQL(d, 'alter table ' + totalesPROF.TableName + ' add Neto NUMERIC');
      if dbs.BaseClientServ = 'S' then datosdb.tranSQL(d, 'alter table ' + totalesPROF.TableName + ' add Neto REAL');
      totalesPROF.Open;
    end;
    totalesPROF.Active := e;
  end;
end;

procedure TTFacturacionCCB.VerificarEstructuraDetFact;
var
  twork: TTable;
  direc: String;
  i, j: Integer;
Begin
  if (detfact <> Nil) and (LaboratorioActivo) then Begin
    if detfact.Active then Begin
      if Length(detfact.FieldByName('codanalisis').AsString) < 6 then Begin
        i     := 0;
        direc := detfact.DatabaseName;
        datosdb.closeDB(detfact);

        utilesarchivos.CopiarArchivos(direc, 'detfact.*', dbs.DirSistema + '\temp');

        if DirectoryExists(dbs.DirSistema + '\work\factNBU') then Begin
          utilesarchivos.CopiarArchivos(dbs.DirSistema + '\work\factNBU', '*.*', direc);
          detfact := datosdb.openDB('detfact', '', '', direc);
          twork   := datosdb.openDB('detfact', '', '', dbs.DirSistema + '\temp');
          detfact.Open; twork.Open;
          while not twork.Eof do Begin
            if datosdb.Buscar(detfact, 'periodo', 'idprof', 'codos', 'items', 'orden', twork.FieldByName('periodo').AsString, twork.FieldByName('idprof').AsString, twork.FieldByName('codos').AsString, twork.FieldByName('items').AsString, twork.FieldByName('orden').AsString) then detfact.Edit else detfact.Append;
            detfact.FieldByName('periodo').AsString     := twork.FieldByName('periodo').AsString;
            detfact.FieldByName('idprof').AsString      := twork.FieldByName('idprof').AsString;
            detfact.FieldByName('codos').AsString       := twork.FieldByName('codos').AsString;
            detfact.FieldByName('items').AsString       := twork.FieldByName('items').AsString;
            detfact.FieldByName('orden').AsString       := twork.FieldByName('orden').AsString;
            detfact.FieldByName('codpac').AsString      := twork.FieldByName('codpac').AsString;
            detfact.FieldByName('nombre').AsString      := twork.FieldByName('nombre').AsString;
            detfact.FieldByName('codanalisis').AsString := twork.FieldByName('codanalisis').AsString;
            try
              detfact.Post
             except
              detfact.Cancel
            end;
            twork.Next;
          end;
        end;

      end;
    end;
  end;
end;

procedure TTFacturacionCCB.CerrarConexiones;
// Objetivo...: cerrar todas las conexiones
Begin
  desconectar;
  DesconectarTotalesProf;
end;

function TTFacturacionCCB.verificarEfector(xidprof: string): boolean;
begin
  if (interbase = 'S') then begin
    InstanciarTablas('');
    rsqlIB := ffirebird.getTransacSQL('select count(*) as cant from cabfact where idprof = ' + '''' + xidprof + '''');
    rsqlIB.Open;
    if rsqlIB.FieldByName('cant').asInteger = 0 then result := true else result := false;
    rsqlIB.Close; rsqlIB.Free;
  end;
end;

function TTFacturacionCCB.verificarObraSocial(xcodos: string): boolean;
begin
  if (interbase = 'S') then begin
    InstanciarTablas('');
    rsqlIB := ffirebird.getTransacSQL('select count(*) as cant from cabfact where codos = ' + '''' + xcodos + '''');
    rsqlIB.Open;
    if rsqlIB.FieldByName('cant').asInteger = 0 then result := true else result := false;
    rsqlIB.Close; rsqlIB.Free;
    result := false;
  end;
end;

function TTFacturacionCCB.verificarDeterminacion(xcodigo: string): boolean;
begin
  if (interbase = 'S') then begin
    InstanciarTablas('');
    rsqlIB := ffirebird.getTransacSQL('select count(*) as cant from detfact where codanalisis = ' + '''' + xcodigo + '''');
    rsqlIB.Open;
    if rsqlIB.FieldByName('cant').asInteger = 0 then result := true else result := false;
    rsqlIB.Close; rsqlIB.Free;
    result := false;
  end;
end;

procedure  TTFacturacionCCB.vaciarLoteSecundario;
begin
  ffirebird.TransacSQLBatch(lotesec);
  lotesec.clear;
end;

procedure  TTFacturacionCCB.vaciarLoteSecundario(xlote: TStringList);
begin
  ffirebird.TransacSQLBatch(xlote);
end;

function TTFacturacionCCB.getTotalesInicidenciaPorDeterminacion_Detallada(xperiodo: string): TQuery;
begin
  result := datosdb.tranSQL(DBConexion, 'select * from totos where periodo = ' + '''' + xperiodo + '''');
end;

procedure TTFacturacionCCB.BorrarTotalesInicidenciaPorDeterminacion_Detallada(xperiodo, xcodos: string);
begin
  datosdb.tranSQL(DBConexion, 'delete from totos where periodo = ' + '''' + xperiodo + '''' + ' and codos = ' + '''' + xcodos + '''');
end;

function TTFacturacionCCB.getDBConexion: string;
begin
  result := dbconexion;
end;

function TTFacturacionCCB.getPracticasFacturadas(xdesde, xhasta: string): TIBQuery;
var
  p, per: string;
  i: integer;
begin
  p := xdesde;
  per := '''' + xdesde + '''';
  for i := 1 to 1000 do begin
     p := utiles.SumarPeriodo(p, '1');
     per := per + ',' + '''' +  p + '''';
     if (p = xhasta) then break;
  end;

  p := ' in (' + per + ')';

  if (xdesde = xhasta) then p := ' in (' + per + ')';

  InstanciarTablas('');
  _query := 'select distinct(codanalisis) from detfact where periodo ' + p + ' and codanalisis is not null order by codanalisis';
  //utiles.msgerror(_query);
  if (ffirebird <> Nil) then Result := ffirebird.getTransacSQL(_query) else Result := nil;
end;

function TTFacturacionCCB.getCantidadPracticasFacturadas(xdesde, xhasta, xcodigo: string): integer;
var
  p, per: string;
  i, cant: integer;
  q: TIBQuery;
  //x: textfile;
begin
  p := xdesde;
  per := '''' + xdesde + '''';
  for i := 1 to 1000 do begin
     p := utiles.SumarPeriodo(p, '1');
     per := per + ',' + '''' +  p + '''';
     if (p = xhasta) then break;
  end;

  p := ' in (' + per + ')';

//  if (xdesde = xhasta) then utiles.msgError('zzz');

  if (xdesde = xhasta) then p := ' in (' + '''' + xdesde + '''' + ')';

  //InstanciarTablas('');
  _query := 'select count(codanalisis) from detfact where periodo ' + p + ' and codanalisis = ' + '''' + xcodigo + '''';
   {
   assignfile(x, 'c:\temp\log.txt');
   rewrite(x);
   WriteLn(x, _query);
   closefile(x);
   }
   q := ffirebird.getTransacSQL(_query);
   q.open; q.First;
   cant := q.Fields[0].AsInteger;
   q.close; q.Free;

   Result := cant;
end;

procedure TTFacturacionCCB.ListarPracticasFacturadas(xdesde, xhasta: string; lista: TStringList; salida: char);
var
  i, c, t: integer;
begin
  if (salida = 'P') or (salida = 'I') then list.Setear(salida);
  list.altopag := 0; list.m := 0;
  list.IniciarTitulos;
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Prácticas Realizadas en el Período: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Código', 1, 'Arial, cursiva, 8');
  list.Titulo(10, list.Lineactual, 'Practica', 2, 'Arial, cursiva, 8');
  list.Titulo(75, list.Lineactual, 'Cantidad', 3, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');

  t := 0;
  for i := 0 to lista.Count - 1 do begin
    c := getCantidadPracticasFacturadas(xdesde, xhasta, lista[i]);
    t := t + c;

    nbu.getDatos(lista[i]);

    list.Linea(0, 0, nbu.Codigo, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, nbu.Descrip, 2, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '#####', c, 3, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');

  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Total Prácticas Realizadas: ', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(80, list.Lineactual, '#####', t, 2, 'Arial, negrita, 8');
  list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');


  list.FinList;
end;

function TTFacturacionCCB.getListPracticasFacturadas(xperiodo, xcodos: string): TIBQuery;
begin
  //result := ffirebird.getTransacSQL('select distinct(idprof), sum(monto) as monto, sum(iva) as iva, sum(exento) as exento, max(nroautorizacion) as nroautorizacion from detfact where periodo=' + '''' + xperiodo + '''' +
  //' and codos=' + '''' + xcodos + '''' + ' and monto > 0 and orden >= ' + '''' + '5000' + '''' + ' group by idprof');
  result := ffirebird.getTransacSQL('select distinct(idprof), sum(monto) as monto, sum(iva) as iva, sum(exento) as exento, max(nroautorizacion) as nroautorizacion from detfact where periodo=' + '''' + xperiodo + '''' +
  ' and codos=' + '''' + xcodos + '''' + ' and orden >= ' + '''' + '5000' + '''' + ' group by idprof');

end;

function TTFacturacionCCB.getListItemsFacturados(xperiodo, xcodos: string): TIBQuery;
begin
  result := ffirebird.getTransacSQL('select idprof, fecha, items, orden, codanalisis, monto, iva, exento, nroautorizacion, nroafiliado, nroauditoria, nombre from detfact ' +
  'where periodo=' + '''' + xperiodo + '''' +  ' and codos=' + '''' + xcodos + '''' + ' and fecha is not null and monto > 0 and orden >= ' + '''' + '5000' + '''' + ' order by idprof, codpac, orden, items');
end;

function TTFacturacionCCB.getListItemsFacturadosSNF(xperiodo, xcodos: string): TIBQuery;
begin
  result := ffirebird.getTransacSQL('select idprof, fecha, items, orden, codanalisis, monto, iva, exento, nroautorizacion, nroafiliado, nroauditoria from detfact ' +
  'where periodo=' + '''' + xperiodo + '''' +  ' and codos=' + '''' + xcodos + '''' + ' and monto > 0 ' + ' order by idprof, codpac, orden, items');
end;

{===============================================================================}

function facturacion: TTFacturacionCCB;
begin
  if xfacturacion = nil then
    xfacturacion := TTFacturacionCCB.Create;
  Result := xfacturacion;
end;

{===============================================================================}

initialization

finalization
  xfacturacion.Free;

end.
