unit CCreditos_Asociacion;

interface

uses CPrestatarios_Asociacion, CCategoriasCreditosAsociacion, CBDT, SysUtils,
     DBTables, CUtiles, CListar, CIDBFM, Classes, CUtilidadesArchivos, CCodPost,
     CMunicipios_Asociacion, CBancos, CIndices_Asociacion, CServers2000_Excel,
     CItemsGastosFijosAsociacion, CPlanctasAsociacion, CLogSeg, CUsuario,
     CDigitoVerificador, CBoletasADR, CCuentasBancariasCont_ADR,
     CExcluirExpedienteBarrasADR, Contnrs;

const
  cantitems = 15;
  masc = '#######0.00';

type

TTCreditos = class
  Codprest, Expediente, Fecha, Idcredito, Formapago, Cantcuotas, Pergracia, Concepto, Refinanciado, RefinanciaCuota, FechaRefinanciacion, IntervaloPG, TipoIndice, CuotasRef, TipoCalculo, Fechappago, Anulado, Fecharecibo, Modo, FechaTope: String;
  Monto, Entrega, Aporte, Indice_credito, Interes, InteresRef, vIndex, Efectivo, Cheques, tasaInteresFlotante, monto_real, Monto_ref, Monto_refc: Real;
  FechaJud, ConceptoJud, EstudioJud, FechaCheque, IndiceCalculo: String;
  LineasSep, LineasDet, LineaDiv, Modelo, FechaCobro, CCodprest, CExpediente, MargenSup, MargenIzq, Fuentecb, observacion_historico, observacion_credito: String;
  Nrocheque, Codcta: String;
  ExisteCredito, ExpresarEnPesos, ViaJudicial, credito_historico, codigobarras: Boolean;
  CodprestTF, ExpedienteTF, TransaccionTF, EstadoTF: String;
  CapitalTF, AmortizacionTF, InteresTF, PunitorioTF: Real;
  Itemsgar, Tipogar, Observacgar, Altagar, Vencegar: String;
  creditos_cab, creditos_det, creditos_cabhist, creditos_dethist, creditos_cabrefinanciados, creditos_detrefinanciados, creditos_cabrefcuotas, creditos_detrefcuotas, recibos, exptesjudiciales, distribucioncobros,
  recibos_detalle, cheques_mov, formato_impresion, calculo_indice, gastos, creditos_cabext, creditos_detext, segexptes, cheques_creditos, codigo_barras, creditos_det_tf, garantias, totales_lineas, obs_credito: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  { Gestion de Cr�ditos }
  function    Buscar(xcodprest, xexpediente: String): Boolean; overload;
  function    Buscar(xcodprest, xexpediente, xitems, xrecibo: String): Boolean; overload;
  function    BuscarRecibo(xidcredito, xnrorecibo: String): Boolean;
  procedure   Guardar(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xintervalopg, xTipoIndice, xtipocalculo, xfechappago: String; xmonto, xentrega, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xmonto_real: Real; xcantitems: Integer);
  procedure   getDatos(xcodprest, xexpediente: String);
  procedure   Borrar(xcodprest, xexpediente: String);
  function    setItems: TQuery;
  function    setItemsCreditoOriginal: TQuery;
  function    setExpedientes: TQuery; overload;
  function    setExpedientes(xcodprest: String): TQuery; overload;
  function    setListaExpedientes: TStringList;
  function    verificarSiTieneCuotasPagas(xcodprest, xexpediente: String): Boolean;
  procedure   SaldarCredito(xcodprest, xexpediente: String; SaldarDeuda: Boolean);
  procedure   AjustarItems(xcodprest, xexpediente, xitems, xconcepto, xfecha, xfechapago: String; xamortizacion, xaporte: Real); overload;
  procedure   AjustarItems(xcodprest, xexpediente, xitems, xconcepto, xfecha, xfechapago: String; xamortizacion, xaporte, xtotal, xsaldo, xsaldocredito: Real); overload;
  procedure   AjustarItems(xcodprest, xexpediente, xitems: String; xsaldocredito: Real); overload;

  { Imputaci�n de Pagos }
  procedure   RegistrarPago(xcodprest, xexpediente, xidcredito, xitems_registracion, xitems_imputacion, xrecibo, xfecha, xconcepto: String; ximporte, xsaldo_individual, xsaldocuota, xinteres, xindice, xdescuento, xtasainteres, xmontointeres: Real; xcuotarefinanciada, xnrocuotarefinanciada, xnrotrans: String);
  procedure   RegistrarSaldo(xcodprest, xexpediente, xitems_registracion, xrecibo, xcuotarefinanciada, xnrocuotarefinanciada: String; ximporte: Real);
  procedure   AjustarSaldoCuota(xcodprest, xexpediente, xitems_imputacion, xcuota_refinanciada: String; xsaldocuota: Real; xnrotrans: String);
  procedure   AnularPago(xcodprest, xexpediente, xidcredito, xitems_registracion, xitems_imputacion, xrecibo, xnrocuotarefinanciada: String; xsaldocuota: Real);
  function    setPagos(xcuota: String): TQuery; overload;
  function    setPagos(xcuota, xcuotarefinanciada: String): TQuery; overload;
  { Ajustes de Saldos para Creditos con tipo de c�lculo 5 }
  procedure   RestaurarCuota(xcodprest, xexpediente, xitems: String; xsaldocuota, xtotal: Real);
  procedure   AjustarSaldoCuota5(xcodprest, xexpediente, xitems: String; xaporte, xtotal, xsaldocuota: Real);
  procedure   AjustarSaldoCredito5(xcodprest, xexpediente, xitems, xitems_imput, xrecibo: String; xsaldocuota: Real);

  { Informes }
  procedure   IniciarInformes(salida: char);
  procedure   ListarCreditosIndividuales(listSel: TStringList; salida: char);
  procedure   ListarCreditosIndividualesHistorico(listSel: TStringList; salida: char);
  procedure   ListarResumenDePagos(listSel: TStringList; xfecha: String; disc_linea, xinfresumido: Boolean; salida: char);
  procedure   ListarResumenDePagosHistorico(listSel: TStringList; xfecha: String; disc_linea, xinfresumido: Boolean; salida: char);
  procedure   ListCuotasAtrazadas(listSel: TStringList; xfecha, xcantmeses, xcp, xorden: String; disc_linea, listaJudiciales: Boolean; salida: char);
  procedure   ListarMontosACobrar(listSel: TStringList; xdfecha, xhfecha, xcp, xorden: String; xjudiciales: Boolean; salida: Char);
  procedure   ListarMontosACobrarResumen(listSel: TStringList; xdfecha, xhfecha, xcp, xorden: String; xjudiciales: Boolean; salida: Char);
  procedure   ListarCreditosPorLocalidad(xlista: TStringList; xdfecha, xhfecha: String; salida: char);
  procedure   ListarMontosCreditosCobrados(xdesde, xhasta: String; salida: char);
  procedure   ListarMontosCaptitalAmortizaciones(xdesde, xhasta: String; salida: char);
  procedure   ListarMontosACobrarHistoricos(xdesde, xhasta: String; salida: char);
  procedure   ListarCancelacionCuotasAnticipadas(listSel: TStringList; xdesde, xhasta: String; salida: char);
  procedure   ListarMontosACobrarBanco(xlocalidad: TStringList; xdfecha, xhfecha: String; salida: Char);
  procedure   InfPresentarCredito(salida: Char);

  { Informes de Control }
  procedure   ListCreditosOtorgados(xdesde, xhasta: String; salida: char);
  procedure   ListDetalleInformesCreditosRefinanciados(xdesde, xhasta: String; salida: char);
  procedure   ListDetalleInformesCuotasRefinanciadas(xdesde, xhasta: String; salida: char);
  procedure   ListCreditosCancelados(xdesde, xhasta: String; salida: char);
  procedure   ListInformeExpedientesViaJudicial(salida: char);
  procedure   ListarGastosySelladosAdministrarivos(xdesde, xhasta: String; salida: char);
  procedure   ListarCreditosSaldados(xdesde, xhasta: String; salida: char);

  procedure   PresentarInforme;
  procedure   ExportarInforme(xarchivo: String);
  procedure   FinalizarExportacionInforme;

  { Gesti�n de Hist�ricos }
  procedure   TransferirHistorico(xcodprest, xexpediente: String);
  function    verificarSiExisteExpedienteHistorico(xcodprest, xexpediente: String): Boolean;
  procedure   getDatosExpedienteHistorico(xcodprest, xexpediente: String);
  function    setCreditosHistoricos(xcodprest: String): TQuery;
  function    setDetalleCreditosHistoricos(xcodprest, xexpediente: String): TQuery;
  function    setExpedientesHistoricos: TQuery; overload;
  function    setExpedientesHistoricos(xcodprest: String): TQuery; overload;
  procedure   CancelarCredito(xcodprest, xexpediente, xfecha: String);
  procedure   DarDeBajaCredito(xcodprest, xexpediente, xfecha, xmotivobaja: String);
  procedure   RecuperarHistorico(xcodprest, xexpediente: String);
  procedure   RecuperarHistorico_CreditoRefinanciado(xcodprest, xexpediente: String);
  procedure   RecuperarHistorico_CreditoCuotasRefinanciadas(xcodprest, xexpediente: String);
  procedure   RegistrarObservacionHistorico(xcodprest, xexpediente, xobservacion: string);
  procedure   RegistrarObservacionCredito(xcodprest, xexpediente, xobservacion: string);
  function    getObservacionHistorico(xcodprest, xexpediente: string): string;
  function    getObservacionCredito(xcodprest, xexpediente: string): string;

  { Varios }
  function    setMontoInteresesPunitorios(xfechaInicial, xfechaActual: String; xmonto, xindice, xinteres: Real): Real;
  function    setCreditosPrestatario(xcodprest: String): TQuery;

  { Refinanciaci�n total del cr�dito ----------------------------------------- }
  procedure   GuardarRefinanciacion(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xtipoindice, xtipocalculo: String; xmonto, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xinteresRef, xmonto_real: Real; xcantitems: Integer);
  procedure   RefinanciarCredito(xcodprest, xexpediente: String);
  function    verificarSiElCreditoTieneCuotasRefinanciadas(xcodprest, xexpediente: String): Boolean;
  procedure   AnularRefinanciacionCredito(xcodprest, xexpediente: String);
  procedure   getDatosCreditoRefinanciado(xcodprest, xexpediente: String);

  { Refinanciaci�n total de cuotas de cr�ditos ------------------------------- }
  procedure   GuardarRefinanciacionCuota(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xtipoindice, xintervalopg, xtipocalculo, xfechappago: String; xmonto, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xmonto_real: Real; xcantitems: Integer; xNroCuotaRefinanciarInicial, xNroCuotaRefinanciarFinal: String);
  procedure   RefinanciarCuota(xcodprest, xexpediente, xNroCuotaRefinanciar, xNroCuotaRefinanciarInicial, xNroCuotaRefinanciarFinal: String);
  function    setItemsCuotaRefinanciada(xcodprest, xexpediente, xnrocuota: String): TQuery;
  function    verificarSiLaCuotaRefinanciadaTienePagos(xcodprest, xexpediente, xnrocuota: String): Boolean;
  function    verificarSiLaCuotaRefinanciadaEstaSaldada(xcodprest, xexpediente, xnrocuota: String): Boolean;
  procedure   AnularRefinanciacionCuota(xcodprest, xexpediente, xnrocuota: String);

  { Informes Estad�sticos }
  procedure   InfNivelCreditos(xdfecha, xhfecha: String; salida: char);
  procedure   InfCreditosOtorgadosPorLinea(xdfecha, xhfecha: String; xlista: TStringList; salida, xmodo: char);
  procedure   InfCreditosOtorgadosPorLineaResumen(xdfecha, xhfecha: String; xlista: TStringList; salida: char);
  procedure   InfDetalleCuotasCreditos(xlista: TStringList; xdfecha, xhfecha: String; salida: char);
  procedure   InfMorosidadPorLinea(xdfecha, xhfecha: String; excluirhistorico: Boolean; salida: char);

  { Expedientes en V�a Judicial }
  procedure   MarcarExpedienteViaJudicial(xcodprest, xexpediente, xfecha, xestudio, xconcepto: String);
  procedure   RecuperarExpedienteViaJudicial(xcodprest, xexpediente: String);
  function    setExpedientesViaJudicial: TQuery;

  { Gesti�n de Cobros }
  function    BuscarCobro(xsucursal, xnumero: String): Boolean;
  procedure   RegistrarCobro(xsucursal, xnumero, xexpediente, xfecha: String; xefectivo, xcheque: Real);
  procedure   getDatosCobro(xsucursal, xnumero: String);
  procedure   BorrarCobro(xsucursal, xnumero: String);

  { Gesti�n de Recibos de Pago }
  function    BuscarReciboCobro(xsucursal, xnumero, xitems: String): Boolean;
  procedure   RegistrarRecibo(xsucursal, xnumero, xitems, xconcepto, xidc, xtipo, xsucrec, xnumrec, xfecha, xmodo, xtipomov: String; xmonto: Real; xcantitems: Integer);
  function    setRecibosPago(xsucursal, xnumero: String): TQuery;
  function    setRecibosManualesExpediente(xcodprest, xexpediente: String): TQuery;
  function    BuscarReciboPorNumeroImpresion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure   AnularReciboPago(xidc, xtipo, xsucursal, xnumero, xanular: String);
  function    setRecibosFechas(xdesde, xhasta: String): TQuery;
  procedure   AjustarNumeroRecibo(xsucursalrecibo, xnumerorecibo, xnumerocorrelativo: String);

  // Formato de Impresi�n
  procedure   RegistrarFormatoImpresion(xlineassep, xlineasdet, xlineaDiv, xmargenSup, xmargenIzq, xmodelo: String);
  procedure   getFormatoImpresion;
  procedure   RegistrarFormatoImpresionBoletas(xlineassep, xlineasdet, xlineaDiv, xmargenSup, xmargenIzq, xmodelo, xfuentecb: String);
  procedure   getFormatoImpresionBoletas;
  // Impresiones
  procedure   ImprimirRecibo(xsucursal, xnumero, xcodprest, xexpediente: String; salida: char);
  procedure   IniciarInforme(salida: char);

  { Registraci�n de Cheques }
  procedure   RegistrarCheque(xsucursal, xnumero, xitems, xnrocheque, xfecha, xcodbanco, xfilial, xpropio: String; xmonto: real; xcantitems: Integer; xcodprest: string);
  function    setCheques(xsucursal, xnumero: String): TQuery; overload;
  function    setCheques(xcodbco: String): TQuery; overload;
  function    setChequesDevueltos(xcodbco: String): TQuery; overload;
  function    setChequesDevueltos(xdfecha, xhfecha: String): TQuery; overload;
  function    setChequesDevueltosPrestatarios(xcodprest, xexpediente: String): TQuery;
  procedure   RechazarCheque(xsucursal, xnumero, xitems, xnrorecibo, xfecha: String; xcomision: Real);
  procedure   RechazarChequeManual(xsucursal, xnumero, xitems, xnrorecibo, xfecha: String; xcomision: Real);
  procedure   AnularRechazoCheque(xsucursal, xnumero, xitems: String);
  procedure   getDatosCheque(xsucursal, xnumero, xitems: String);

  { Informes de Control de Pagos }
  procedure   ListarControlRecibos(xdfecha, xhfecha, xlistar: String; salida: char; xincluir_detalle: Boolean);
  procedure   ListarControlChequesRecibos(xdfecha, xhfecha, xlistar: String; salida: char);
  procedure   ListarControlChequesRecibosFechaRecepcion(xdfecha, xhfecha, xlistar: String; salida: char);
  procedure   ListarInformeCapitalAportes(xdfecha, xhfecha: String; salida: char);
  //procedure   ListarChequesDevueltosPrestatario(codprest, expediente: string; salida: char);

  { Asociaci�n entre Tipo de Calculo e Indice }
  procedure   RegistrarIndice(xtipocalculo, xindice: String);
  procedure   BorrarIndice(xtipocalculo, xindice: String);
  function    setCalculoIndices: TQuery;
  function    setIndiceCalculo(xtipocalculo: String): String;

  { Controlar si el Expediente tiene Movimientos }
  function    verificarOperacionesEnExpediente(xcodprest: String): Boolean;
  function    verificarSiElCreditoEstaSaldado(xcodprest, xexpediente: String): Boolean;

  { Gastos Imputados en Cr�ditos del tipo Administrativo }
  function    BuscarGasto(xcodprest, xexpediente, xitems: String): Boolean;
  procedure   RegistrarGasto(xcodprest, xexpediente, xitems, xidgasto, xrecibo, xfecha, xconcepto: String; xmonto: Real; xcantitems: Integer);
  function    setItemsGasto(xcodprest, xexpediente: String): TStringList;
  procedure   BorrarGasto(xcodprest, xexpediente, xitems: String);
  procedure   RegistrarReferenciaGasto(xcodprest, xexpediente, xitems, xrecibo: String);
  function    setReferenciaGasto(xcodprest, xexpediente, xitems: String): String;
  procedure   ListarGastos(xdfecha, xhfecha: String; salida: char);
  procedure   RegistrarGastoComoPagado(xcodigobarra, xfecha, xhora, xcodprest, xexpediente, xfechaliq, ximput: String);

  { Refinanciones Anexas a Creditos }
  procedure   HabilitarExt;
  procedure   InHabilitarExt;
  procedure   GuardarRefinanciacionExtendida(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xintervalopg, xTipoIndice, xtipocalculo, xfechappago: String; xmonto, xentrega, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xmonto_real: Real; xcantitems: Integer);
  procedure   InfPresentarCreditoRefinanciacionExtendida(salida: Char);
  procedure   ListarResumenDePagosRefinanciacionExtendida(listSel: TStringList; xfecha: String; disc_linea, xinfresumido: Boolean; salida: char);
  function    BuscarRefinanciacionExtendida(xcodprest, xexpediente: String): Boolean;
  procedure   BorrarRefinanciacionExtendida(xcodprest, xexpediente: String);
  function    setItemsRefinanciacionExtendida: TQuery;
  procedure   TransferirHistoricoRefinanciacionExtendida(xcodprest, xexpediente: String);
  function    setExpedientesRefinanciacionExtendida(xcodprest: String): TQuery;

  { Seguimiento de Expedientes en V�a Judicial }
  function    BuscarItemsSeg(xcodprest, xexpediente, xitems: String): Boolean;
  procedure   RegistrarItemsSeg(xcodprest, xexpediente, xitems, xfecha, xconcepto: String; xcantitems: Integer);
  function    setItemsSeg(xcodprest, xexpediente: String): TStringList;
  procedure   BorrarItemsSeg(xcodprest, xexpediente: String);

  { Detalle de Cheques Entregados por Creditos }
  function    BuscarChequeCredito(xcodprest, xexpediente, xitems: String): Boolean;
  procedure   RegistrarChequeCredito(xcodprest, xexpediente, xitems, xnrocheque, xcodcta: String; xmonto: Real; xcantitems: Integer);
  procedure   BorrarChequeCredito(xcodprest, xexpediente: String);
  procedure   getDatosChequeCredito(xcodprest, xexpediente, xitems: String);
  function    setChequesCredito(xcodprest, xexpediente: String): TStringList;
  function    setChequesCreditoHistorico(xcodprest, xexpediente: String): TStringList;

  { Funciones de Bloqueo de Archivo }
  function    Bloquear: Boolean;
  procedure   QuitarBloqueo;

  { Ajustes Varios }
  procedure   AjustarIndiceCalculo(xcodprest, xexpediente, xindice: String);

  { C�digo de Barra }
  procedure   EstablecerCodigoBarras(xopcion: Integer);
  function    setCodigoBarras: Boolean;
  procedure   AgregarItemsRecibo(xitems, xconcepto, xmonto: String);
  procedure   ListarRecibo(xcodprest, xexpediente, xcuentabcaria, xfechaemis, xfechavto1, xmontovto1, xfechavto2, xmontovto2, xidcredito, xidc, xtipo, xsucursal, xnumero: String; salida: char; xtipo_recibo, xnrotrans: String);
  procedure   ReimprimirRecibo(xcodigobarra, xfecha, xhora: String; salida: char);

  { Procesos Vinculados al Manejo de C�digo de Barra }
  procedure   ReiniciarExpediente_Work;
  procedure   GuardarExpediente_Work(xcodprest, xexpediente: String);
  procedure   RestaurarExpediente_Work(xcodprest, xexpediente: String);
  procedure   GuardarExpediente_WorkActualizado(xnrotrans, xcodprest, xexpediente: String);
  procedure   RestaurarExpediente_WorkActualizado(xnrotrans, xcodigobarra, xfecha, xhora, xcodprest, xexpediente, xfechaliq, ximput: String);
  procedure   RestaurarExpediente_WorkActualizado_Temporalmente(xcodprest, xexpediente: String);

  { Procesos Vinculados a Pagos a Cuenta Tasa Banco Nacion }   // 23/10/2007
  function    BuscarTF(xcodprest, xexpediente, xtransaccion: String): Boolean;
  procedure   RegistrarTF(xcodprest, xexpediente, xtransaccion, xitems, xrecibo, xitems_recibo: String; xcapital, xamortizacion, xinteres, xpunitorio, xmontocuota: Real; xestado: String);
  procedure   getDatosTF(xcodprest, xexpediente, xtransaccion: String);
  procedure   BorrarTF(xcodprest, xexpediente, xtransaccion, xitems, xit1, xcuota_amortizacion: String);
  function    VerificarPagosTF(xcodprest, xexpediente, xitems: String): Boolean;
  function    SetTotalPagosTF(xcodprest, xexpediente, xitems: String): Real;
  procedure   ControlarSaldoTF(xcodprest, xexpediente, xitems: String);
  function    SetSaldoOriginalTF(xcodprest, xexpediente, xitems: String): Real;
  function    SetTotalPagadoTF(xcodprest, xexpediente, xitems: String): Real;

  // Gesti�n de Garantias
  function    BuscarGarantia(xcodprest, xexpediente, xitems: String): Boolean;
  procedure   RegistrarGarantia(xcodprest, xexpediente, xitems, xtipo, xobservac, xalta, xvence: String; xcantitems: Integer);
  procedure   BorrarGarantia(xcodprest, xexpediente: String);
  procedure   getDatosGarantia(xcodprest, xexpediente, xitems: String);
  function    setGarantia(xcodprest, xexpediente: String): TObjectList;
  procedure   ListarGarantias(xdesde, xhasta: String; salida, xtipo: char);

  { Controles Generales }
  procedure   VerificarQueElCreditoNoEsteCancelado(xcodprest, xexpediente, xestado: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  idanter: array [1..cantitems] of String;
  totales: array [1..cantitems] of Real;
  totgral: array [1..cantitems] of Real;
  totfin : array [1..cantitems] of Real;
  tcuotas: array[1..200, 1..13]  of String;
  mov: array[1..800, 1..14] of String;
  tfinal: TStringList;
  lcuotas, c1: Integer; l1, r1, r2: String;
  total_fin, tasa_Int, monto_indice: Real;
  detcred: TTable;              // Tabla de intercambio que maneja el detalle de los cr�ditos, varia de acuerdo al credito que se este liquidando (normal, refinanciado total, refinanciado cuotas)
  bloqueos: TTable;             // Tabla que maneja el bloqueo de procesos
  NroCuotaRefinanciada: String; // Referencia para saber el nro. de cuota Refinanciada
  cab_credito, cab_creditohist, det_creditos, det_creditohist, gastos_hist, obs_historico: TTable;      // Tablas de Intercambio para la Transferencia a Historicos
  rsql, rt: TQuery;             // Objeto SQL para consultas generales
  infIniciado, ol, ir: Boolean; // Flag para el control de informes
  ref1, ref2: TStringList;      // Listas para el control de cuotas refinanciadas: ref1, creditos convencionales / ref2, cr�ditos refinanciados
  trc: Byte;                    // 1- Si la refinacion de la cuota es de un credito o es de uno ya refinanciado
  ncr: String;                  // N�mero de cuota refinanciada
  NoPresentarSubtotales: Boolean;  // Flag para determinar si se presentan o no los subtotales
  ref_c, ref_u, desdefecha, fuente, idanter_work: String;
  tipoList: char;
  listResumen, listdat: Boolean;
  nroItems, itbol: Integer;
  creditos_detwork: TTable;     // Tablas de Intercambio para el Proceso de Bancarizaci�n
  lista: Boolean;
  t1_linea, t2_linea, t3_linea: TStringList;

  procedure   AjustarNroItems(xcodprest, xexpediente: String; xcantitems: Integer);
  procedure   AjustarNroItemsRefinanciacion(xcodprest, xexpediente: String; xcantitems: Integer);
  procedure   AjustarNroItemsRefCuotas(xcodprest, xexpediente: String; xcantitems: Integer);
  procedure   IniciarArreglos;
  procedure   IniciarArreglosGenerales;
  procedure   ListDatosPrestatario(salida: char);
  procedure   ListTotalesPagos(salida: char);
  procedure   SaldoCredito(salida: char);
  procedure   TotalDeuda(salida: char);
  procedure   ListCreditoIndividual(listSel: TStringList; salida: char);

  procedure   ListTituloControles(xconcepto: String; salida: char);
  procedure   ListDetalleInformesControl(salida: char);
  procedure   ListOperacionesCredito(salida: char);
  procedure   ListarResumenDePagos_Creditos(listSel: TStringList; xfecha: String; disc_linea: Boolean; salida: char);
  procedure   ListarResumenDePagos_Items(xfecha: String; salida: char);

  procedure   conectar_creditosRefinanciados;
  procedure   desconectar_creditosRefinanciados;
  procedure   conectar_cuotasRefinanciadas;
  procedure   desconectar_cuotasRefinanciadas;
  procedure   TransferirHistorico_CreditoRefinanciado(xcodprest, xexpediente: String);
  procedure   TransferirHistorico_CreditoCuotasRefinanciadas(xcodprest, xexpediente: String);
  procedure   TransferirRegistrosAlHistorico(xcodprest, xexpediente: String);

  procedure   RupturaLinea(salida: char);
  procedure   TotalLinea(salida: char);
  procedure   TotalDeudaLinea(salida: char);
  procedure   ListMontosACobrar(listSel: TStringList; xdfecha, xhfecha, xcriterio, xcp, xorden: String; xjudiciales: Boolean; salida: Char);
  procedure   TotalLineaACobrar(salida: Char);
  procedure   FinalizarLinea(salida: char);

  procedure   ActivarTP;

  procedure   TotalCreditosLinea(salida: char);
  procedure   TotalCreditosLineaResumen(salida: char);
  procedure   TotalCreditosRubro(salida: char);
  procedure   TotalCreditosRubroResumen(salida: char);
  procedure   TotalPorLinea(salida: char);
  procedure   TotalMorosidadLinea(xidanter: String; salida: char);
  procedure   TotalCreditosNivel(salida: char);
  procedure   TotalCreditosNivelResumen(salida: char);
  procedure   TotalLineaDetalleCuotas(salida: char);
  procedure   TotalMorosidadRubro(salida: char);
  procedure   TotalPorDia(salida: char);
  procedure   TotalDiaCheque(salida: char);
  procedure   ListarChequesDevueltos(xdfecha, xhfecha: String; salida: char);
  procedure   ListarCreditosJJ(salida: char);
  function    setSaldoCuotaRef(xcodprest, xexpediente: String): Real;
  procedure   RecuperarRegistrosDelHistorico(xcodprest, xexpediente: String);
  function    setCreditosLocalidad(xcp, xorden: String): TQuery;
  function    setCreditosCanceladosLocalidad(xcp, xorden: String): TQuery;
  procedure   ListarTotalEstadosCreditos(salida: char);
  procedure   ListarCreditosEnGestionJudicial(salida: char);

  procedure   ProcesarMontosCreditos(estado: String; salida: char);
  procedure   LineaCobros(salida: char);
  procedure   ProcesarMontosCapitalAmortizaciones(estado: String; salida: char);
  procedure   LineaCapitalAmortizaciones(salida: char);
  procedure   ListDetalleCreditos(xlinea, xdfecha, xhfecha, tipo: String; salida: char);
  procedure   LineaExpediente(xdesde, xhasta: String; salida: char);
  procedure   TotLineaMontosACobrarHistoricos(xdesde, xhasta: String; salida: char);
  procedure   ProcesarCreditosRefinanciados(xdesde, xhasta, xtipo: String; r: TQuery; salida: char);
  procedure   ListControlChequesRecibos(xdfecha, xhfecha, xlistar: String; salida: char);
  procedure   ListarSeguimientoExpediente(xcodprest, xexpediente: String; salida: char);

  procedure   ListCancelacionAnticipada(xdesde, xhasta: String; salida: char);
  procedure   ListarPagosFueraDeTermino(salida: char);
end;

function credito: TTCreditos;

implementation

var
  xcredito: TTCreditos = nil;

constructor TTCreditos.Create;
begin
  creditos_cab              := datosdb.openDB('creditos_cab', '');
  creditos_det              := datosdb.openDB('creditos_det', '');
  creditos_cabhist          := datosdb.openDB('creditos_cabhist', '');
  creditos_dethist          := datosdb.openDB('creditos_dethist', '');
  creditos_cabrefinanciados := datosdb.openDB('creditos_cabrefinanciados', '');
  creditos_detrefinanciados := datosdb.openDB('creditos_detrefinanciados', '');
  creditos_cabrefcuotas     := datosdb.openDB('creditos_cabrefcuotas', '');
  creditos_detrefcuotas     := datosdb.openDB('creditos_detrefcuotas', '');
  creditos_cabext           := datosdb.openDB('creditos_cabext', '');
  creditos_detext           := datosdb.openDB('creditos_detext', '');
  recibos                   := datosdb.openDB('recibos', '');
  exptesjudiciales          := datosdb.openDB('exp_judiciales', '');
  distribucioncobros        := datosdb.openDB('distribucioncobros', '');
  recibos_detalle           := datosdb.openDB('recibos_detalle', '');
  cheques_mov               := datosdb.openDB('cheques_mov', '');
  formato_Impresion         := datosdb.openDB('formatoImpresion', '');
  calculo_indice            := datosdb.openDB('calculo_indice', '');
  gastos                    := datosdb.openDB('movgastoscreditos', '');
  segexptes                 := datosdb.openDB('segexpedientes', '');
  cheques_creditos          := datosdb.openDB('cheques_creditos', '');
  bloqueos                  := datosdb.openDB('bloqueos', '');
  codigo_barras             := datosdb.openDB('codigobarras', '');
  creditos_det_tf           := datosdb.openDB('creditos_det_tf', '');
  garantias                 := datosdb.openDB('garantias', '');
  obs_historico             := datosdb.openDB('obs_historico', '');
  obs_credito               := datosdb.openDB('obs_credito', '');
  totales_lineas            := datosdb.openDB('totales_lineas', '');
  ref1 := TStringList.Create; ref2 := TStringList.Create; tfinal := TStringList.Create;
end;

destructor TTCreditos.Destroy;
begin
  inherited Destroy;
end;

function  TTCreditos.Buscar(xcodprest, xexpediente: String): Boolean;
// Objetivo...: Buscar expediente
Begin
  ExisteCredito := datosdb.Buscar(creditos_cab, 'Codprest', 'Expediente', xcodprest, xexpediente);
  Codprest      := xcodprest;
  Expediente    := xexpediente;
  Result        := ExisteCredito;
end;

function TTCreditos.Buscar(xcodprest, xexpediente, xitems, xrecibo: String): Boolean;
// Objetivo...: Buscar Items en expediente
Begin
  ActivarTP;
  if detcred.IndexFieldNames <> 'Codprest;Expediente;Items;Recibo' then detcred.IndexFieldNames := 'Codprest;Expediente;Items;Recibo';
  Result := datosdb.Buscar(detcred, 'Codprest', 'Expediente', 'Items', 'Recibo', xcodprest, xexpediente, xitems, xrecibo);
end;

function TTCreditos.BuscarRecibo(xidcredito, xnrorecibo: String): Boolean;
// Objetivo...: Buscar Items en expediente
Begin
  Result := datosdb.Buscar(recibos, 'Idcredito', 'Recibo', xidcredito, xnrorecibo);
end;

procedure TTCreditos.Guardar(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xintervalopg, xtipoindice, xtipocalculo, xfechappago: String; xmonto, xentrega, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xmonto_real: Real; xcantitems: Integer);
// Objetivo...: Guardar datos en tabla de persistencia
Begin
  if xitems = '001' then Begin
    if Buscar(xcodprest, xexpediente) then creditos_cab.Edit else creditos_cab.Append;
    creditos_cab.FieldByName('codprest').AsString    := xcodprest;
    creditos_cab.FieldByName('expediente').AsString  := xexpediente;
    creditos_cab.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
    creditos_cab.FieldByName('idcredito').AsString   := xidcredito;
    creditos_cab.FieldByName('formapago').AsString   := xformapago;
    creditos_cab.FieldByName('cantcuotas').AsString  := xcantcuotas;
    creditos_cab.FieldByName('pergracia').AsString   := xpergracia;
    creditos_cab.FieldByName('intervalopg').AsString := xintervalopg;
    creditos_cab.FieldByName('concepto').AsString    := xconcepto;
    creditos_cab.FieldByName('monto').AsFloat        := xmonto;
    creditos_cab.FieldByName('entrega').AsFloat      := xentrega;
    creditos_cab.FieldByName('indice').AsFloat       := xindice;
    creditos_cab.FieldByName('aporte').AsFloat       := xaporte;
    creditos_cab.FieldByName('interes').AsFloat      := xinteres;
    creditos_cab.FieldByName('estado').AsString      := 'I';
    creditos_cab.FieldByName('tipoIndice').AsString  := xtipoindice;
    creditos_cab.FieldByName('tipocalculo').AsString := xtipocalculo;
    if Length(Trim(xfechappago)) = 8 then creditos_cab.FieldByName('fechappago').AsString  := utiles.sExprFecha2000(xfechappago) else
      creditos_cab.FieldByName('fechappago').AsString  := utiles.sExprFecha2000(xfecha);
    creditos_cab.FieldByName('monto_real').AsFloat   := xmonto_real;
    try
      creditos_cab.Post
     except
      creditos_cab.Cancel
    end;
    // Si ya estaba Registrado, Regeneramos Items
    if ExisteCredito then datosdb.tranSQL('DELETE FROM creditos_det WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
    if ExisteCredito then logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Modificando Expediente ' + xcodprest + '-' + expediente) else logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Expediente ' + xcodprest + '-' + expediente);
  end;
  if Buscar(xcodprest, xexpediente, xitems, '-') then creditos_det.Edit else creditos_det.Append;
  creditos_det.FieldByName('codprest').AsString    := xcodprest;
  creditos_det.FieldByName('expediente').AsString  := xexpediente;
  creditos_det.FieldByName('items').AsString       := xitems;
  creditos_det.FieldByName('recibo').AsString      := '-';
  creditos_det.FieldByName('fechavto').AsString    := utiles.sExprFecha2000(xfechavto);
  creditos_det.FieldByName('concepto').AsString    := xconceptoitems;
  creditos_det.FieldByName('amortizacion').AsFloat := xamortizacion;
  creditos_det.FieldByName('aporte').AsFloat       := xaportec;
  creditos_det.FieldByName('total').AsFloat        := xtotal;
  creditos_det.FieldByName('saldo').AsFloat        := xsaldo;
  creditos_det.FieldByName('saldocuota').AsFloat   := xtotal;
  creditos_det.FieldByName('tipomov').AsInteger    := 1;
  creditos_det.FieldByName('estado').AsString      := 'I';
  try
    creditos_det.Post
   except
    creditos_det.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    AjustarNroItems(xcodprest, xexpediente, xcantitems);
    datosdb.closeDB(creditos_det); creditos_det.Open;
    datosdb.closeDB(creditos_cab); creditos_cab.Open;
  end;
  datosdb.refrescar(creditos_cab);
  datosdb.refrescar(creditos_det);
end;

procedure TTCreditos.getDatos(xcodprest, xexpediente: String);
// Objetivo...: Recuperar un cr�dito
var
  estado: Boolean;
Begin
  if Buscar(xcodprest, xexpediente) then Begin
    Fecha           := utiles.sFormatoFecha(creditos_cab.FieldByName('fecha').AsString);
    Idcredito       := creditos_cab.FieldByName('idcredito').AsString;
    Formapago       := creditos_cab.FieldByName('formapago').AsString;
    Cantcuotas      := utiles.sLlenarIzquierda(creditos_cab.FieldByName('cantcuotas').AsString, 2, '0');
    Pergracia       := creditos_cab.FieldByName('pergracia').AsString;
    Intervalopg     := creditos_cab.FieldByName('intervalopg').AsString;
    Concepto        := creditos_cab.FieldByName('concepto').AsString;
    Monto           := creditos_cab.FieldByName('monto').AsFloat;
    Entrega         := creditos_cab.FieldByName('entrega').AsFloat;
    Aporte          := creditos_cab.FieldByName('aporte').AsFloat;
    Indice_credito  := creditos_cab.FieldByName('indice').AsFloat;
    Interes         := creditos_cab.FieldByName('interes').AsFloat;
    InteresRef      := creditos_cab.FieldByName('interesRef').AsFloat;
    Refinanciado    := creditos_cab.FieldByName('refinancia').AsString;
    RefinanciaCuota := creditos_cab.FieldByName('refcuotas').AsString;
    TipoIndice      := creditos_cab.FieldByName('tipoindice').AsString;
    TipoCalculo     := creditos_cab.FieldByName('tipocalculo').AsString;
    Fechappago      := utiles.sFormatoFecha(creditos_cab.FieldByName('fechappago').AsString);
    monto_real      := creditos_cab.FieldByName('monto_real').AsFloat;
    IndiceCalculo   := creditos_cab.FieldByName('indicecalculo').AsString;
  end else Begin
    Fecha := ''; Idcredito := ''; Formapago := ''; Cantcuotas := ''; pergracia := ''; concepto := ''; Monto := 0; Aporte := 0; Indice_credito := 0; Interes := 0; Refinanciado := ''; RefinanciaCuota := ''; interesRef := 0; Intervalopg := ''; TipoIndice := ''; TipoCalculo := ''; Fechappago := ''; Entrega := 0; IndiceCalculo := '';
  end;
  Codprest   := xcodprest;
  Expediente := xexpediente;
  ref_c      := Refinanciado;
  ref_u      := RefinanciaCuota;

  // Verificamos si est� en V�a Judicial
  if datosdb.Buscar(exptesjudiciales, 'codprest', 'expediente', xcodprest, xexpediente) then Begin
    FechaJud    := utiles.sFormatoFecha(exptesjudiciales.FieldByName('fecha').AsString);
    EstudioJud  := exptesjudiciales.FieldByName('estudio').AsString;
    ConceptoJud := exptesjudiciales.FieldByName('concepto').AsString;
    ViaJudicial := True;
  end else Begin
    Fechajud := ''; EstudioJud := ''; ConceptoJud := '';
    ViaJudicial := False;
  end;

  // Verificamos el tipo de Liquidacion de recibos
  setCodigoBarras;
  if codigobarras then
    if excluirexpedientes.setExcluye(xcodprest, xexpediente) then codigobarras := False else codigobarras := True;

  monto_ref := 0; monto_refc := 0;
  if Refinanciado = 'S' then Begin
    estado := creditos_cabrefinanciados.Active;
    if not estado then creditos_cabrefinanciados.Open;
    if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', xcodprest, xexpediente) then monto_ref := creditos_cabrefinanciados.FieldByName('monto').AsFloat;
    creditos_cabrefinanciados.Active := estado;
  end;

  if RefinanciaCuota = 'S' then Begin
    estado := creditos_cabrefcuotas.Active;
    if not estado then creditos_cabrefinanciados.Open;
    if datosdb.Buscar(creditos_cabrefcuotas, 'codprest', 'expediente', xcodprest, xexpediente) then monto_ref := creditos_cabrefcuotas.FieldByName('monto').AsFloat;
    creditos_cabrefcuotas.Active := estado;
  end;
end;

procedure TTCreditos.Borrar(xcodprest, xexpediente: String);
// Objetivo...: Dar de Baja un Cr�dito
Begin
  if Buscar(xcodprest, xexpediente) then Begin
    creditos_cab.Delete;
    datosdb.tranSQL('DELETE FROM creditos_det WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
    datosdb.refrescar(creditos_cab);
    datosdb.refrescar(creditos_det);
    logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Borrando Expediente ' + xcodprest + '-' + xexpediente);
  end;
end;

function TTCreditos.setItems: TQuery;
// Objetivo...: Devolver los items de los cr�ditos
Begin
  if Refinanciado = ''  then Result := setItemsCreditoOriginal;
  if Refinanciado = 'S' then Begin
    Result := datosdb.tranSQL('SELECT * FROM creditos_detrefinanciados WHERE codprest = ' + '"' + codprest + '"' + ' AND expediente = ' + '"' + expediente + '"' + ' AND estado <> ' + '"' + 'R' + '"' + ' ORDER BY items');
    if Indice_credito = 0 then  // Verificamos si el Indice se fijo durante la refinanciaci�n
      if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', codprest, expediente) then Indice_credito := creditos_cabrefinanciados.FieldByName('indice').AsFloat;
    if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', codprest, expediente) then
      tipoCalculo :=  creditos_cabrefinanciados.FieldByName('tipocalculo').AsString;
  end;
end;

function TTCreditos.setItemsCreditoOriginal: TQuery;
// Objetivo...: Devolver los Items de los Cr�ditos
Begin
  Result := datosdb.tranSQL('SELECT * FROM creditos_det WHERE codprest = ' + '"' + codprest + '"' + ' AND expediente = ' + '"' + expediente + '"' + ' AND estado <> ' + '"' + 'R' + '"' + ' ORDER BY items');
end;

function  TTCreditos.setExpedientes: TQuery;
// Objetivo...: Devolver N�mina de Expedientes
Begin
  Result := datosdb.tranSQL('SELECT creditos_cab.codprest, creditos_cab.expediente, creditos_cab.concepto, creditos_cab.idcredito, prestatarios.nombre, prestatarios.cp, prestatarios.orden ' +
                            'FROM creditos_cab, prestatarios WHERE creditos_cab.codprest = prestatarios.codprest ORDER BY nombre, expediente');
end;

function TTCreditos.setExpedientes(xcodprest: String): TQuery;
// Objetivo...: Devolver los expedientes para un prestatario
Begin
  Result := datosdb.tranSQL('SELECT * FROM creditos_cab WHERE codprest = ' + '"' + xcodprest + '"');
end;

function  TTCreditos.setListaExpedientes: TStringList;
// Objetivo...: Devolver N�mina de Expedientes
var
  l: TStringList;
Begin
  rsql := datosdb.tranSQL('SELECT creditos_cab.codprest, creditos_cab.expediente, creditos_cab.concepto, creditos_cab.idcredito, prestatarios.nombre FROM creditos_cab, prestatarios WHERE creditos_cab.codprest = prestatarios.codprest ORDER BY idcredito');
  rsql.Open; l := Nil;
  while not rsql.Eof do Begin
    if l = Nil then l := TStringList.Create;
    l.Add(rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString + rsql.FieldByName('idcredito').AsString);
    rsql.Next;
  end;
  rsql.Close; rsql := Nil;
  Result := l;
end;


function TTCreditos.verificarSiTieneCuotasPagas(xcodprest, xexpediente: String): Boolean;
// Objetivo...: verificar si el cr�dito tiene cuotas pagas
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM ' + detcred.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND estado = ' + '"' + 'R' + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

procedure TTCreditos.SaldarCredito(xcodprest, xexpediente: String; SaldarDeuda: Boolean);
// Objetivo...: Cancelar/Quitar Cancelaci�n al Cr�dito
Begin
  if Buscar(xcodprest, xexpediente) then Begin
    creditos_cab.Edit;
    if SaldarDeuda then Begin
      creditos_cab.FieldByName('estado').AsString           := 'C';
      creditos_cab.FieldByName('fechacancelacion').AsString := utiles.sExprFecha2000(utiles.setFechaActual);
      logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Saldando Expediente ' + xcodprest + '-' + xexpediente);
    end else Begin
      creditos_cab.FieldByName('estado').AsString           := 'I';
      creditos_cab.FieldByName('fechacancelacion').AsString := '';
      logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Modificando Saldo Expediente ' + xcodprest + '-' + xexpediente);
    end;
    try
      creditos_cab.Post
     except
      creditos_cab.Cancel
    end;
    datosdb.closeDB(creditos_cab); creditos_cab.Open;
  end;
end;

procedure TTCreditos.AjustarItems(xcodprest, xexpediente, xitems, xconcepto, xfecha, xfechapago: String; xamortizacion, xaporte: Real);
// Objetivo...: Ajustar Datos en Cuotas en los Cr�ditos
Begin
  if refinanciado    = 'S' then detcred := creditos_detrefinanciados;
  if RefinanciaCuota = 'S' then detcred := creditos_detrefcuotas;
  if Buscar(xcodprest, xexpediente, xitems, '-') then detcred.Edit else detcred.Append;
  detcred.FieldByName('codprest').AsString   := xcodprest;
  detcred.FieldByName('expediente').AsString := xexpediente;
  detcred.FieldByName('items').AsString      := xitems;
  detcred.FieldByName('recibo').AsString     := '-';
  detcred.FieldByName('concepto').AsString   := xconcepto;
  detcred.FieldByName('fechavto').AsString   := utiles.sExprFecha2000(xfecha);
  if Length(Trim(xfechapago)) = 8 then detcred.FieldByName('fechapago').AsString := utiles.sExprFecha2000(xfechapago) else
    detcred.FieldByName('fechapago').AsString := '';
  detcred.FieldByName('amortizacion').AsFloat := xamortizacion;
  detcred.FieldByName('aporte').AsFloat       := xaporte;
  detcred.FieldByName('tipomov').AsString     := '1';
  if detcred.FieldByName('estado').AsString = '' then detcred.FieldByName('estado').AsString := 'I';
  try
    detcred.Post
   except
    detcred.Cancel
  end;
  datosdb.closeDB(detcred); detcred.Open;

  detcred := creditos_det;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Ajustando Items Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AjustarItems(xcodprest, xexpediente, xitems: String; xsaldocredito: Real);
// Objetivo...: Ajustar Datos en Cuotas en los Cr�ditos
Begin
  if refinanciado    = 'S' then detcred := creditos_detrefinanciados;
  if RefinanciaCuota = 'S' then detcred := creditos_detrefcuotas;
  if Buscar(xcodprest, xexpediente, xitems, '-') then Begin
    detcred.Edit;
    detcred.FieldByName('saldo').AsFloat := xsaldocredito;
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
  detcred := creditos_det;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Ajustando Items Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AjustarItems(xcodprest, xexpediente, xitems, xconcepto, xfecha, xfechapago: String; xamortizacion, xaporte, xtotal, xsaldo, xsaldocredito: Real);
// Objetivo...: Ajustar Datos en Cuotas en los Cr�ditos
Begin
  AjustarItems(xcodprest, xexpediente, xitems, xconcepto, xfecha, xfechapago, xamortizacion, xaporte);
  if refinanciado    = 'S' then detcred := creditos_detrefinanciados;
  if RefinanciaCuota = 'S' then detcred := creditos_detrefcuotas;
  if datosdb.Buscar(detcred, 'codprest', 'expediente', 'items', 'recibo', xcodprest, xexpediente, xitems, '-') then Begin
    detcred.Edit;
    detcred.FieldByName('amortizacion').AsFloat := xamortizacion;
    detcred.FieldByName('aporte').AsFloat       := xaporte;
    detcred.FieldByName('total').AsFloat        := xtotal;
    detcred.FieldByName('saldocuota').AsFloat   := xsaldo;
    detcred.FieldByName('saldo').AsFloat        := xsaldocredito;
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
  detcred := creditos_det;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Ajustando Items Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AjustarNroItems(xcodprest, xexpediente: String; xcantitems: Integer);
// Objetivo...: Ajustar Numero de Items
Begin
  datosdb.tranSQL('DELETE FROM creditos_det WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '"');
end;

procedure TTCreditos.RegistrarPago(xcodprest, xexpediente, xidcredito, xitems_registracion, xitems_imputacion, xrecibo, xfecha, xconcepto: String; ximporte, xsaldo_individual, xsaldocuota, xinteres, xindice, xdescuento, xtasainteres, xmontointeres: Real; xcuotarefinanciada, xnrocuotarefinanciada, xnrotrans: String);
// Objetivo... Registrar Pagos
Begin
  if (Length(Trim(xcuotarefinanciada)) = 0) then ref_u := '';

  if Buscar(xcodprest, xexpediente, xitems_registracion, xrecibo) then detcred.Edit else detcred.Append;
  detcred.FieldByName('codprest').AsString   := xcodprest;
  detcred.FieldByName('expediente').AsString := xexpediente;
  detcred.FieldByName('items').AsString      := xitems_registracion;
  detcred.FieldByName('recibo').AsString     := xrecibo;
  detcred.FieldByName('fechavto').AsString   := utiles.sExprFecha2000(xfecha);
  detcred.FieldByName('concepto').AsString   := xconcepto;
  detcred.FieldByName('tipomov').AsInteger   := 2;
  detcred.FieldByName('total').AsFloat       := ximporte;
  detcred.FieldByName('refpago').AsString    := xcodprest + xexpediente + xitems_imputacion;
  detcred.FieldByName('estado').AsString     := 'R';
  detcred.FieldByName('Interes').AsFloat     := xinteres;
  detcred.FieldByName('Indice').AsFloat      := xindice;
  detcred.FieldByName('saldocuota').AsFloat  := xsaldo_individual;
  detcred.FieldByName('descuento').AsFloat   := xdescuento;
  detcred.FieldByName('tasaint').AsFloat     := xtasainteres;
  detcred.FieldByName('montoint').AsFloat    := xmontointeres;
  if xcuotarefinanciada = 'S' then detcred.FieldByName('refinancia').AsString := xnrocuotarefinanciada;
  detcred.FieldByName('nrotrans').AsString   := xnrotrans;
  try
    detcred.Post
   except
    detcred.Cancel
  end;
  datosdb.refrescar(detcred);
  NroCuotaRefinanciada := xnrocuotarefinanciada;
  AjustarSaldoCuota(xcodprest, xexpediente, xitems_imputacion, NroCuotaRefinanciada, xsaldocuota, xnrotrans);
  codprest   := xcodprest;
  expediente := xexpediente;
  if Refinanciado = 'S' then desconectar_creditosRefinanciados;
  detcred := creditos_det;
  { Insercion del control de recibos }
  if BuscarRecibo(Idcredito, xrecibo) then recibos.Edit else Begin
    recibos.Append;
    recibos.FieldByName('fecha').AsString := utiles.sExprFecha2000(utiles.setFechaActual);
  end;
  recibos.FieldByName('idcredito').AsString := Idcredito;
  recibos.FieldByName('recibo').AsString    := xrecibo;
  try
    recibos.Post
   except
    recibos.Cancel
  end;
  datosdb.refrescar(recibos);
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Pago ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.RegistrarSaldo(xcodprest, xexpediente, xitems_registracion, xrecibo, xcuotarefinanciada, xnrocuotarefinanciada: String; ximporte: Real);
Begin
 if (Refinanciado = 'S') and (xcuotarefinanciada <> 'S') then Begin
    conectar_creditosRefinanciados;
    RefinanciaCuota := '';   // Cuota NO Refinanciada
  end;
  if xcuotarefinanciada = 'S' then conectar_cuotasRefinanciadas;

  if (Length(Trim(xcuotarefinanciada)) = 0) and (Length(Trim(xnrocuotarefinanciada)) = 0) then Begin
    Refinanciado := ''; RefinanciaCuota := '';
  end;

  if Buscar(xcodprest, xexpediente, xitems_registracion, xrecibo) then Begin
    detcred.Edit;
    detcred.FieldByName('saldocuota').AsFloat  := ximporte;
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Actualizando Saldo Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AnularPago(xcodprest, xexpediente, xidcredito, xitems_registracion, xitems_imputacion, xrecibo, xnrocuotarefinanciada: String; xsaldocuota: Real);
// Objetivo...: Anular un pago del cr�dito
Begin
  if (ref_c = 'S') or (Length(Trim(xnrocuotarefinanciada)) > 0) then ActivarTP;
  datosdb.tranSQL('delete from ' + detcred.TableName + ' where codprest = ' + '"' + xcodprest + '"' + ' and expediente = ' + '"' + xexpediente + '"' + ' and refpago = ' + '"' + xcodprest + xexpediente + xitems_imputacion + '"' + ' and tipomov = 2');
  datosdb.refrescar(detcred);
  AjustarSaldoCuota(xcodprest, xexpediente, xitems_imputacion, xnrocuotarefinanciada, xsaldocuota, '');
  if Refinanciado = 'S' then desconectar_creditosRefinanciados;
  if (ref_c = 'S') or (Length(Trim(xnrocuotarefinanciada)) > 0) then desconectar_cuotasRefinanciadas;
  if BuscarRecibo(Idcredito, xrecibo) then recibos.Delete;   { Eliminaci�n del control de recibos }
  datosdb.refrescar(recibos);
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Anulando Pago Expediente ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AjustarSaldoCuota(xcodprest, xexpediente, xitems_imputacion, xcuota_refinanciada: String; xsaldocuota: Real; xnrotrans: String);
// Objetivo...: Ajustar Saldo Cuota
var
  nt: TTable; r: TQuery; totPagos: Real; i, inicio, tope: Integer;
Begin
  if Length(Trim(xcuota_refinanciada)) = 0 then ref_u := '';
  if Buscar(xcodprest, xexpediente, xitems_imputacion, '-') then Begin
    detcred.Edit;
    detcred.FieldByName('saldocuota').AsFloat := xsaldocuota;
    if Length(Trim(xnrotrans)) > 0 then detcred.FieldByName('nrotrans').AsString := xnrotrans;
    if xsaldocuota = 0  then detcred.FieldByName('estado').AsString := 'P' else detcred.FieldByName('estado').AsString := 'I';    // Marcamos la cuota esta saldada o no
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Ajustando Saldo Expte. ' + xcodprest + '-' + xexpediente);

  { -------------------------------------------------------------------------- }
  if Length(Trim(xcuota_refinanciada)) > 0 then Begin
    totPagos := -1; // Si lo que se esta saldando es el una cuota refinanciada, marcamos tambien la cuota original
    if detcred.TableName = 'creditos_detrefcuotas' then Begin
      r := datosdb.tranSQL('SELECT SUM (saldocuota) FROM creditos_detrefcuotas WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + xcuota_refinanciada + '"');
      r.Open;     // Obtenemoe el total de cuotas pagas
      if r.RecordCount > 0 then totPagos := r.Fields[0].AsFloat;
      r.Close; r.Free;
      if Refinanciado = 'S' then nt := creditos_detrefinanciados else nt := creditos_det;

      if Length(Trim(xcuota_refinanciada)) = 3 then Begin
        inicio := StrToInt(xcuota_refinanciada);
        tope   := StrToInt(xcuota_refinanciada);
      end else Begin
        inicio := StrToInt(Copy(xcuota_refinanciada, 1, 3));
        tope   := StrToInt(Copy(xcuota_refinanciada, 5, 3));
      end;

      for i := inicio to tope do Begin    // Recorremos cada una de las Cuotas del Plan y las Marcamos, i - Inicio, tope - Cuota Final
        if datosdb.Buscar(nt, 'Codprest', 'Expediente', 'Items', 'Recibo', xcodprest, xexpediente, utiles.sLlenarIzquierda(IntToStr(i), 3, '0') , '-') then Begin
          nt.Edit;
          if totPagos = 0 then nt.FieldByName('estado').AsString := 'P' else nt.FieldByName('estado').AsString := 'I';    // Marcamos la cuota esta saldada o no
          try
            nt.Post
           except
            nt.Cancel
          end;
          datosdb.refrescar(nt);
        end;
      end;
      logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Marcando Cuotas Refinanciadas Expte. ' + xcodprest + '-' + xexpediente);
    end;
  end;
  { -------------------------------------------------------------------------- }
  NroCuotaRefinanciada := '';
end;

procedure TTCreditos.IniciarArreglos;
// Objetivo...: Iniciar arreglos de datos
var
  i: Integer;
Begin
  for i := 1 to cantitems do totales[i] := 0;
  for i := 1 to cantitems do idanter[i] := '';
end;

procedure TTCreditos.IniciarArreglosGenerales;
// Objetivo...: Iniciar arreglos de datos
var
  i, j: Integer;
Begin
  for i := 1 to cantitems do Begin
    totgral[i] := 0; idanter[i] := '';
  end;
  for i := 1 to 100 do
    for j := 1 to 9 do tcuotas[i, j] := '';
  lcuotas := 0;
  IniciarArreglos;
end;

function  TTCreditos.setPagos(xcuota: String): TQuery;
// Objetivo...: Devolver items de pagos
Begin
  if Refinanciado = ''  then Result := datosdb.tranSQL('SELECT * FROM ' + creditos_det.TableName + ' WHERE codprest = ' + '"' + codprest + '"' + ' AND expediente = ' + '"' + expediente + '"' + ' AND estado = ' + '"' + 'R' + '"' + ' AND refpago = ' + '"' + codprest + expediente + xcuota + '"' + ' ORDER BY fechavto, items');
  if Refinanciado = 'S' then Result := datosdb.tranSQL('SELECT * FROM creditos_detrefinanciados WHERE codprest = ' + '"' + codprest + '"' + ' AND expediente = ' + '"' + expediente + '"' + ' AND estado = ' + '"' + 'R' + '"' + ' AND refpago = ' + '"' + codprest + expediente + xcuota + '"' + ' ORDER BY fechavto, items');
end;

procedure TTCreditos.RestaurarCuota(xcodprest, xexpediente, xitems: String; xsaldocuota, xtotal: Real);
// Objetivo...: Restablecer Cr�ditos tipo c�lculo 5
Begin
  if Buscar(xcodprest, xexpediente, xitems, '-') then Begin
    detcred.Edit;
    detcred.FieldByName('estado').AsString    := 'I';
    detcred.FieldByName('aporte').AsFloat     := 0;
    detcred.FieldByName('total').AsFloat      := xtotal;
    if xsaldocuota < 0 then detcred.FieldByName('saldocuota').AsFloat := 0 else detcred.FieldByName('saldocuota').AsFloat := xsaldocuota;
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Restableciendo Cuota Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AjustarSaldoCuota5(xcodprest, xexpediente, xitems: String; xaporte, xtotal, xsaldocuota: Real);
// Objetivo...: Ajustes Cr�ditos tipo c�lculo 5
Begin
  if (tipoCalculo = '5') or (tipoCalculo = 'B')  then Begin
    if Buscar(xcodprest, xexpediente, xitems, '-') then Begin
      detcred.Edit;
      detcred.FieldByName('total').AsFloat      := xtotal;
      detcred.FieldByName('aporte').AsFloat     := xaporte;
      detcred.FieldByName('saldocuota').AsFloat := xsaldocuota;
      try
        detcred.Post
       except
        detcred.Cancel
      end;
      datosdb.closeDB(detcred); detcred.Open;
    end;
    logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Ajustando Saldo Expte. TC=5 ' + xcodprest + '-' + xexpediente);
  end;
end;

procedure TTCreditos.AjustarSaldoCredito5(xcodprest, xexpediente, xitems, xitems_imput, xrecibo: String; xsaldocuota: Real);
// Objetivo...: Ajustes Cr�ditos tipo c�lculo 5 - Recibos
Begin
  if Buscar(xcodprest, xexpediente, xitems, xrecibo) then Begin
    detcred.Edit;
    detcred.FieldByName('saldocuota').AsFloat := xsaldocuota;
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
  if Buscar(xcodprest, xexpediente, xitems_imput, '-') then Begin
    detcred.Edit;
    if StrToFloat(utiles.FormatearNumero(FloatToStr(xsaldocuota))) = 0 then detcred.FieldByName('estado').AsString := 'P' else detcred.FieldByName('estado').AsString := 'I';
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Ajustando Saldo Expte. ' + xcodprest + '-' + xexpediente);
end;

function  TTCreditos.setPagos(xcuota, xcuotarefinanciada: String): TQuery;
// Objetivo...: Devolver items de pagos, de las cuotas refinanciadas
Begin
  Result := datosdb.tranSQL('SELECT * FROM creditos_detrefcuotas WHERE codprest = ' + '"' + codprest + '"' + ' AND expediente = ' + '"' + expediente + '"' + ' AND estado = ' + '"' + 'R' + '"' + ' AND refpago = ' + '"' + codprest + expediente + xcuota + '"' + ' AND refinancia = ' + '"' + xcuotarefinanciada + '"' + ' ORDER BY fechavto, items');
end;

//------------------------------------------------------------------------------

procedure TTCreditos.ListarCancelacionCuotasAnticipadas(listSel: TStringList; xdesde, xhasta: String; salida: char);
// Objetivo...: Listar cr�ditos Individuales (en sus diferentes modalidades)
var
  i, j: Integer; id_anter: String;
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado Cancelaci�n Cuotas Anticipadas - Lapso: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Concepto', 1, 'Arial, cursiva, 8');
  List.Titulo(20, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  List.Titulo(32, List.lineactual, 'F. Pago - Vto.', 3, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, 'Total', 4, 'Arial, cursiva, 8');
  List.Titulo(74, List.lineactual, 'Inter�s', 5, 'Arial, cursiva, 8');
  List.Titulo(81, List.lineactual, 'I.Punit.', 6, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Saldo', 7, 'Arial, cursiva, 8');
  List.Titulo(96, List.lineactual, 'Ref', 8, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  detcred := creditos_det;     { Cr�dito Convencional }
  IniciarArreglosGenerales;

  For i := 0 to listSel.Count - 1 do Begin
    if Length(Trim(listSel.Strings[i])) = 0 then Break;
    //list.Linea(0, 0,  listSel.Strings[i], 1, 'Arial, normal, 10', salida, 'S');
    //list.Linea(0, 0,  '', 1, 'Arial, normal, 10', salida, 'S');
    { Cr�ditos Convencionales }
    ref1.Clear; ref2.Clear;
    getDatos(Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4));
    if (credito.TipoCalculo = '5') or (credito.TipoCalculo = 'B') then tasa_Int := indice.setIndice(Copy(utiles.sExprFecha2000(fecha), 1, 4), credito.setIndiceCalculo('5'), Copy(utiles.sExprFecha2000(fecha), 5, 2)) else tasa_int := 0;
    if not ExpresarEnPesos then vindex := Indice_credito else vindex := 1;
    if vindex = 0 then vindex := 1;
    Codprest := Copy(listSel.Strings[i], 1, 5);
    detcred  := creditos_det;
    rsql     := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"' + ' order by tipomov, items');
    ListCancelacionAnticipada(xdesde, xhasta, salida);
    { Cr�ditos Refinanciados }
    if Refinanciado = 'S' then Begin
      conectar_creditosRefinanciados;
      if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4)) then Monto := creditos_cabrefinanciados.FieldByName('monto').AsFloat;
      detcred := creditos_detrefinanciados;
      rsql := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"' + ' order by tipomov, items');
      ListCancelacionAnticipada(xdesde, xhasta, salida);
      desconectar_creditosRefinanciados;
    end;

    { Detalle de Refinanciaciones }
    {if (ref1.Count > 0) or (ref2.Count > 0) then Begin

      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      conectar_cuotasRefinanciadas;
      detcred := creditos_detrefcuotas;

      if ref1.Count > 0 then Begin  // Cr�ditos Normales
        list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, '***  Refinanciaci�n de Cuotas s/Cr�ditos  ***', 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        For j := 1 to ref1.Count do Begin    // Recorremos cada cuota refinanciada
          rsql := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"'  + ' and refinancia = ' + '"' + ref1.Strings[j-1] + '"' + ' order by tipomov, items'); // Tipomov, Fechavto, Refpago');
          ListCancelacionAnticipada(xdesde, xhasta, salida);
        end;
      end;

      if ref2.Count > 0 then Begin  // Cr�ditos Refinanciados
        list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, '***  Refinanciaci�n de Cuotas s/Cr�ditos Refinanciados  ***', 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        For j := 1 to ref2.Count do Begin    // Recorremos cada cuota refinanciada
          rsql := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"' + ' order by tipomov, items');
          ListCancelacionAnticipada(xdesde, xhasta, salida);
        end;
      end;

      desconectar_cuotasRefinanciadas;
    end;}

    if totales[7] > 0 then Begin
      list.Linea(0, 0, list.Linealargopagina(salida) , 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    end;
  end;

  PresentarInforme;
end;

procedure TTCreditos.ListCancelacionAnticipada(xdesde, xhasta: String; salida: char);
var
  i, j, k, m, n: Integer;
  tm1: array[1..200, 1..2] of String;
  l: TStringList;
  lm, lp: Boolean;
  prest, nexpt: String;
  mpres: Real;
Begin
  IniciarArreglosGenerales;
  l := TStringList.Create;
  rsql.Open;  rsql.First; i := 0; j := 0; m := 0;
  while not rsql.Eof do Begin
    if (rsql.FieldByName('codprest').AsString <> idanter[1]) or (rsql.FieldByName('expediente').AsString <> idanter[2]) then Begin
      ListTotalesPagos(salida);
      prest := ''; lp := False;
      if (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_detext') or (detcred.TableName = 'creditos_detrefinanciados') or (detcred.TableName = 'creditos_detrefcuotas') then Begin
        prestatario.getDatos(Codprest);
        prest := prestatario.codigo + '-' + Copy(prestatario.nombre, 1, 30);
        nexpt := creditos_det.FieldByName('expediente').AsString;
        mpres :=  Monto * vindex;
      end;
      idanter[1] := rsql.FieldByName('codprest').AsString;
      idanter[2] := rsql.FieldByName('expediente').AsString;
      totales[2] := 0; totales[4] := 0;
    end;
    if rsql.FieldByName('tipomov').AsString = '1' then Begin
      totales[3] := totales[3] + (rsql.FieldByName('total').AsFloat * vindex);
      if Length(Trim(rsql.FieldByName('refinancia').AsString)) > 0 then Begin
        if detcred.TableName = 'creditos_det'              then Begin
          if rsql.FieldByName('cuotasref').AsString <> idanter[9] then ref1.Add(rsql.FieldByName('items').AsString);
          idanter[9] := rsql.FieldByName('cuotasref').AsString;
        end;
        if detcred.TableName = 'creditos_detrefinanciados' then Begin
          if rsql.FieldByName('cuotasref').AsString <> idanter[10] then
          if rsql.FieldByName('cuotasref').AsString <> idanter[10] then ref2.Add(rsql.FieldByName('items').AsString);
          idanter[10] := rsql.FieldByName('cuotasref').AsString;
        end;
      end;

      Inc(m);
      tm1[m, 1] := rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString + rsql.FieldByName('items').AsString;
      tm1[m, 2] := rsql.FieldByName('fechavto').AsString;
    end;

    if rsql.FieldByName('tipomov').AsString = '2' then Begin
      Inc(i);
      tcuotas[i, 1] := rsql.FieldByName('concepto').AsString;
      tcuotas[i, 2] := Copy(rsql.FieldByName('recibo').AsString, 12, 4) + '-' + Copy(rsql.FieldByName('recibo').AsString, 1, 8);
      tcuotas[i, 3] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('total').AsFloat * vindex));
      tcuotas[i, 4] := utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString);
      tcuotas[i, 5] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('montoInt').AsFloat * vindex));
      tcuotas[i, 6] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('interes').AsFloat));
      tcuotas[i, 7] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('saldocuota').AsFloat * vindex));
      tcuotas[i, 8] := rsql.FieldByName('refpago').AsString + rsql.FieldByName('items').AsString;
      l.Add(rsql.FieldByName('refpago').AsString + rsql.FieldByName('items').AsString);

      if rsql.FieldByName('Refinancia').AsString <> 'S' then Begin
        totales[2] := totales[2] + (rsql.FieldByName('total').AsFloat * vindex);
        totales[4] := totales[4] + (rsql.FieldByName('interes').AsFloat * vindex);
        totales[5] := totales[5] + (rsql.FieldByName('montoint').AsFloat * vindex);
      end;
    end;
    rsql.Next;
  end;

  l.Sort; totales[7] := 0;
  i := l.Count;
  For j := 1 to i do Begin
    For k := 1 to i do Begin
      if tcuotas[k, 8] = l.Strings[j-1] then Begin

        lm := False;
        for n := 1 to m do
          if tm1[n, 1] = Copy(tcuotas[k, 8], 1, 12) then begin
            if tm1[n, 2] > utiles.sExprFecha2000(tcuotas[k, 4]) then Begin
              lm := True;
              Break;
            end;
          end;

        if (lm) and ((tm1[n, 2] >= utiles.sExprFecha2000(xdesde)) and (tm1[n, 2] <= utiles.sExprFecha2000(xhasta))) then Begin
          if not lp then Begin
            if detcred.TableName = 'detcred_refinanciados' then Begin
              list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
              list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
              list.Linea(0, 0, '***  Refinanciaci�n del Cr�dito  ***', 1, 'Arial, normal, 10', salida, 'S');
              list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
            end;
            list.Linea(0, 0, 'Prestatario: ' + prest, 1, 'Arial, negrita, 8', salida, 'N');
            list.Linea(50, list.Lineactual, 'Expediente: ' + nexpt, 2, 'Arial, negrita, 8', salida, 'N');
            list.Linea(80, list.Lineactual, 'Monto: ', 3, 'Arial, negrita, 8', salida, 'N');
            list.importe(95, list.Lineactual, '', mpres, 4, 'Arial, normal, 8');
            list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
            list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
            lp := True;
          end;
          list.Linea(0, 0, tcuotas[k, 1], 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(20, list.Lineactual, tcuotas[k, 2], 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(32, list.Lineactual, utiles.sFormatoFecha(tm1[n, 2]) + '  -  ' + tcuotas[k, 4], 3, 'Arial, normal, 8', salida, 'N');
          list.importe(65, list.Lineactual, '', StrToFloat(tcuotas[k, 3]), 4, 'Arial, normal, 8');
          list.importe(80, list.Lineactual, '', StrToFloat(tcuotas[k, 5]), 5, 'Arial, normal, 8');
          list.importe(87, list.Lineactual, '', StrToFloat(tcuotas[k, 6]), 6, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', StrToFloat(tcuotas[k, 7]), 7, 'Arial, normal, 8');
          list.Linea(96, list.Lineactual, '', 8, 'Arial, normal, 8', salida, 'S');
          totales[7] := totales[7] + StrToFloat(tcuotas[k, 3]);
        end;
      end;
    end;
  end;
  l.Destroy;

  if totales[7] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total Adelantado:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(65, list.Lineactual, '', totales[7], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  rsql.Close; rsql.Free; rsql := Nil;
end;

// -----------------------------------------------------------------------------

procedure TTCreditos.IniciarInformes(salida: char);
// Objetivo...: listar cr�ditos individuales
Begin
  list.Setear(salida);
end;

// -----------------------------------------------------------------------------

procedure TTCreditos.ListarPagosFueraDeTermino(salida: char);
// Verificamos si Existen Pagos Fuera de Termino
var
  r, s: TQuery;
  t, d: Real;
Begin
  r :=  datosdb.tranSQL('select distribucioncobros.expediente, recibos_detalle.* from distribucioncobros, recibos_detalle where expediente = ' + '''' + codprest + '-' + expediente + '''' +
                            ' and  distribucioncobros.sucursal = recibos_detalle.sucursal and distribucioncobros.numero = recibos_detalle.numero and modo = ' + '''' + 'M' + '''');
  r.Open; t := 0; d := 0;
  if r.RecordCount > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, '***  Pagos Fuera del Cr�dito / Devoluciones de Cheques ***', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '***  Pagos Fuera del Cr�dito / Devoluciones de Cheques ***', 'Arial, negrita, 9');
    end;
    while not r.Eof do Begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(10, list.Lineactual, r.FieldByName('idc').AsString + '  ' + r.FieldByName('tipo').AsString + '  ' + r.FieldByName('sucrec').AsString + ' ' + r.FieldByName('numrec').AsString, 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(27, list.Lineactual, r.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', r.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, r.FieldByName('anulado').AsString, 5, 'Arial, normal, 8', salida, 'S');
      end;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 'Arial, normal, 8');
        excel.setString('b' + l1, 'b' + l1, r.FieldByName('idc').AsString + '  ' + r.FieldByName('tipo').AsString + '  ' + r.FieldByName('sucrec').AsString + ' ' + r.FieldByName('numrec').AsString, 'Arial, normal, 8');
        excel.setString('c' + l1, 'c' + l1, r.FieldByName('concepto').AsString, 'Arial, normal, 8');
        excel.setReal('d' + l1, 'd' + l1, r.FieldByName('monto').AsFloat, 'Arial, normal, 8');
        excel.setString('e' + l1, 'e' + l1, r.FieldByName('anulado').AsString, 'Arial, normal, 8');
      end;
      if (r.FieldByName('anulado').AsString <> 'S') then t := t + r.FieldByName('monto').AsFloat;

      // Checuqes devueltos por el Banco
      s := datosdb.tranSQL('select * from cheques_mov where sucursal = ' + '''' + r.FieldByName('sucursal').AsString + '''' + ' and numero = ' + '''' + r.FieldByName('numero').AsString + '''' + ' and devuelto = ' + '''' + 'S' + '''');
      s.open;
      if (s.recordcount > 0) then begin
        while not s.eof do begin
          entbcos.getDatos(s.FieldByName('codbanco').AsString);
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, utiles.sFormatoFecha(s.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(10, list.Lineactual, copy(s.FieldByName('nrocheque').AsString, 2, 10), 2, 'Arial, normal, 8', salida, 'N');
            list.Linea(27, list.Lineactual, utiles.sFormatoFecha(s.FieldByName('fechadev').AsString), 3, 'Arial, normal, 8', salida, 'N');
            list.Linea(37, list.Lineactual, copy(entbcos.descrip, 1, 23) + ' (' + s.FieldByName('filial').AsString + ')', 4, 'Arial, normal, 8', salida, 'N');
            list.importe(75, list.Lineactual, '', s.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
            list.importe(95, list.Lineactual, '', s.FieldByName('comision').AsFloat, 6, 'Arial, normal, 8');
            list.Linea(96, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
          end;
          if (salida = 'X') then Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(s.FieldByName('fecha').AsString), 'Arial, normal, 8');
            excel.setString('b' + l1, 'b' + l1, copy(s.FieldByName('nrocheque').AsString, 2, 10), 'Arial, normal, 8');
            excel.setString('c' + l1, 'c' + l1, utiles.sFormatoFecha(s.FieldByName('fechadev').AsString), 'Arial, normal, 8');
            excel.setString('d' + l1, 'd' + l1, copy(entbcos.descrip, 1, 23) + ' (' + s.FieldByName('filial').AsString + ')', 'Arial, normal, 8');
            excel.setReal('d' + l1, 'd' + l1, s.FieldByName('monto').AsFloat, 'Arial, normal, 8');
            excel.setReal('e' + l1, 'e' + l1, s.FieldByName('comision').AsFloat, 'Arial, normal, 8');
          end;
          d := d + (s.FieldByName('monto').AsFloat + s.FieldByName('comision').AsFloat);
          s.Next;
        end;
      end;
      s.Close; s.Free;

      r.Next;
    end;

    r.Close; r.Free;

    if t > 0 then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(86, list.Lineactual, '-----------------', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, 'Total Pagos:', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', t, 2, 'Arial, negrita, 8');
        list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, 'Total Pagos:', 'Arial, negrita, 8');
        excel.setReal('d' + l1, 'd' + l1, t, 'Arial, normal, 8');
      end;
    end;

    if d > 0 then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(86, list.Lineactual, '-----------------', 2, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, 'Total Devoluci�n Cheques:', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', d, 2, 'Arial, negrita, 8');
        list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, 'Total Devoluci�n Cheques:', 'Arial, negrita, 8');
        excel.setReal('d' + l1, 'd' + l1, d, 'Arial, normal, 8');
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TTCreditos.ListarCreditosIndividuales(listSel: TStringList; salida: char);
// Objetivo...: listar cr�ditos individuales
Begin
  list.Setear(salida);
  if (salida = 'P') or (salida = 'I') then Begin
    list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Ficha de Control de Pagos', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Concepto', 1, 'Arial, cursiva, 8');
    List.Titulo(31, List.lineactual, 'Amortizaci�n', 2, 'Arial, cursiva, 8');
    List.Titulo(45, List.lineactual, 'Aporte', 3, 'Arial, cursiva, 8');
    List.Titulo(61, List.lineactual, 'Total', 4, 'Arial, cursiva, 8');
    List.Titulo(68, List.lineactual, 'F.Vto.', 5, 'Arial, cursiva, 8');
    List.Titulo(74, List.lineactual, 'Inter.', 6, 'Arial, cursiva, 8');
    List.Titulo(81, List.lineactual, 'I.Punit.', 7, 'Arial, cursiva, 8');
    List.Titulo(90, List.lineactual, 'Saldo', 8, 'Arial, cursiva, 8');
    List.Titulo(96, List.lineactual, 'Ref', 9, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
    if not ExpresarEnPesos then List.Titulo(0, 0, '***  Montos Expresados en Pesos  ***', 1, 'Arial, normal, 10') else
      List.Titulo(0, 0, '***  Montos Expresados en Unidades  ***', 1, 'Arial, normal, 10');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'T') then Begin
    List.LineaTxt(' Ficha de Control de Pagos', True);
    List.LineaTxt('', True);
    List.LineaTxt('Concepto               Amortizaci�n    Aporte     Total F.Vto.    Inter.   I.Punit.   Saldo  Ref', True);
    List.LineaTxt('--------------------------------------------------------------------------------', True);
    List.LineaTxt(' ', True);
    if not ExpresarEnPesos then List.LineaTxt('***  Montos Expresados en Pesos  ***', true) else
      List.Lineatxt('***  Montos Expresados en Unidades  ***', true);
    List.LineaTxt(' ', True);
  end;

  detcred := creditos_det;     { Cr�dito Convencional }
  IniciarArreglosGenerales;
  ListCreditoIndividual(listSel, salida);
  ListarPagosFueraDeTermino(salida);
end;

procedure TTCreditos.ListarCreditosIndividualesHistorico(listSel: TStringList; salida: char);
// Objetivo...: listar cr�ditos individuales
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Ficha de Control de Pagos (Registro Hist�rico)', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Concepto', 1, 'Arial, cursiva, 8');
  List.Titulo(31, List.lineactual, 'Amortizaci�n', 2, 'Arial, cursiva, 8');
  List.Titulo(45, List.lineactual, 'Aporte', 3, 'Arial, cursiva, 8');
  List.Titulo(61, List.lineactual, 'Total', 4, 'Arial, cursiva, 8');
  List.Titulo(68, List.lineactual, 'F.Vto.', 5, 'Arial, cursiva, 8');
  List.Titulo(74, List.lineactual, 'Inter.', 6, 'Arial, cursiva, 8');
  List.Titulo(81, List.lineactual, 'I.Punit.', 7, 'Arial, cursiva, 8');
  List.Titulo(90, List.lineactual, 'Saldo', 8, 'Arial, cursiva, 8');
  List.Titulo(96, List.lineactual, 'Ref', 9, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  desconectar;
  credito_historico := True;
  creditos_cab := nil; creditos_dethist := nil; gastos_hist := nil; creditos_detrefinanciados := nil; creditos_detrefcuotas := nil;
  creditos_cab              := datosdb.openDB('creditos_cabhist', '');
  creditos_dethist          := datosdb.openDB('creditos_dethist', '');
  creditos_detrefinanciados := datosdb.openDB('creditos_dethistrefinanciados', '');
  creditos_detrefcuotas     := datosdb.openDB('creditos_dethistrefcuotas', '');
  creditos_cab.Open; creditos_dethist.Open; creditos_detrefinanciados.Open; creditos_detrefcuotas.Open;
  if not credito_historico then detcred := creditos_det else detcred := creditos_dethist;
  prestatario.conectar;
  IniciarArreglosGenerales;
  ListCreditoIndividual(listSel, salida);
  creditos_cabhist.Close; creditos_dethist.Close; creditos_detrefinanciados.Close; creditos_detrefcuotas.Close;
  PresentarInforme;
  prestatario.desconectar;
  credito_historico := False;
  creditos_cab      := datosdb.openDB('creditos_cab', '');
  conectar;
end;

procedure TTCreditos.ListCreditoIndividual(listSel: TStringList; salida: char);
// Objetivo...: Listar cr�ditos Individuales (en sus diferentes modalidades)
var
  i, j: Integer; id_anter: String;
Begin
  For i := 0 to listSel.Count - 1 do Begin
    if Length(Trim(listSel.Strings[i])) = 0 then Break;
    { Cr�ditos Convencionales }
    if detcred = Nil then Begin
      if not credito_historico then detcred := creditos_det else detcred := creditos_dethist;  // Valor por Defecto
    end;

    ref1.Clear; ref2.Clear;
    getDatos(Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4));
    //if detcred.TableName = 'creditos_det' then Begin
      if (credito.TipoCalculo = '5') or (credito.TipoCalculo = 'B') then tasa_Int := indice.setIndice(Copy(utiles.sExprFecha2000(fecha), 1, 4), credito.setIndiceCalculo('5'), Copy(utiles.sExprFecha2000(fecha), 5, 2)) else tasa_int := 0;
    //end;

    if not ExpresarEnPesos then vindex := Indice_credito else vindex := 1;
    if vindex = 0 then vindex := 1;


    Codprest := Copy(listSel.Strings[i], 1, 5);
    rsql := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"' + ' order by tipomov, items');
    ListOperacionesCredito(salida);
    { Cr�ditos Refinanciados }
    if Refinanciado = 'S' then Begin
      conectar_creditosRefinanciados;
      if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4)) then Monto := creditos_cabrefinanciados.FieldByName('monto').AsFloat;
      Indice_credito := creditos_cabrefinanciados.FieldByName('indice').AsFloat;
      detcred := creditos_detrefinanciados;

      if not ExpresarEnPesos then vindex := creditos_cabrefinanciados.FieldByName('indice').AsFloat else vindex := 1;
      if vindex = 0 then vindex := 1;

      rsql := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"' + ' order by tipomov, items');
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
        list.Linea(0, 0, '***  Refinanciaci�n del Cr�dito  ***', 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      end;
      if (salida = 'T') then Begin
        List.LineaTxt('--------------------------------------------------------------------------------', True);
        list.LineaTxt('', True);
        list.LineaTxt('***  Refinanciaci�n del Cr�dito  ***', True);
        list.LineaTxt('', True);
      end;
      ListOperacionesCredito(salida);
      desconectar_creditosRefinanciados;
    end;

    // Detalle de Refinanciaciones
    if (ref1.Count > 0) or (ref2.Count > 0) then Begin
      if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      if (salida = 'T') then list.LineaTxt('', True);

      conectar_cuotasRefinanciadas;
      detcred := creditos_detrefcuotas;

      if not ExpresarEnPesos then vindex := creditos_cabrefcuotas.FieldByName('indice').AsFloat else vindex := 1;
      if vindex = 0 then vindex := 1;
      Indice_credito := creditos_cabrefcuotas.FieldByName('indice').AsFloat;

      if ref1.Count > 0 then Begin  // Cr�ditos Normales
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
          list.Linea(0, 0, '***  Refinanciaci�n de Cuotas s/Cr�ditos  ***', 1, 'Arial, normal, 11', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          List.LineaTxt('--------------------------------------------------------------------------------', True);
          list.LineaTxt('***  Refinanciaci�n de Cuotas s/Cr�ditos  ***', True);
          list.LineaTxt('', True);
        end;

        For j := 1 to ref1.Count do Begin    // Recorremos cada cuota refinanciada
          rsql := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"'  + ' and refinancia = ' + '"' + ref1.Strings[j-1] + '"' + ' order by tipomov, items'); // Tipomov, Fechavto, Refpago');
          ListOperacionesCredito(salida);
        end;
      end;

      if ref2.Count > 0 then Begin  // Cr�ditos Refinanciados
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
          list.Linea(0, 0, '***  Refinanciaci�n de Cuotas s/Cr�ditos Refinanciados  ***', 1, 'Arial, normal, 11', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          List.LineaTxt('--------------------------------------------------------------------------------', True);
          list.LineaTxt('***  Refinanciaci�n de Cuotas s/Cr�ditos Refinanciados  ***', True);
          list.LineaTxt('', True);
        end;

        For j := 1 to ref2.Count do Begin    // Recorremos cada cuota refinanciada
          rsql := datosdb.tranSQL('select * from ' + detcred.TableName + ' where codprest = '  + '"' + Copy(listSel.Strings[i], 1, 5) + '"' + ' and expediente = ' + '"' + Copy(listSel.Strings[i], 6, 4) + '"' + ' order by tipomov, items');
          ListOperacionesCredito(salida);
        end;
      end;

      desconectar_cuotasRefinanciadas;
    end;

    codprest   := Copy(listSel.Strings[i], 1, 5);
    expediente := Copy(listSel.Strings[i], 6, 4);
    ListarPagosFueraDeTermino(salida);
    //ListarChequesDevueltosPrestatario(codprest, expediente, salida);

    // Observaciones del Credito
    if (datosdb.Buscar(obs_credito, 'codprest', 'expediente', Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4))) then begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
        list.Linea(0, 0, 'Observaciones del Cr�dito', 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.ListMemo('observaciones', 'Arial, normal, 8', 5, salida, obs_credito, 500);
      End;
      if (salida = 'T') then begin
        list.LineaTxt('', true);
        list.LineaTxt('Observaciones del Credito', true);
        list.ListMemo('observaciones', 'Arial, normal, 8', 5, salida, obs_credito, 500);
      end;
    end;

    // Observaciones del Historico
    if (datosdb.Buscar(obs_historico, 'codprest', 'expediente', Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4))) then begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
        list.Linea(0, 0, 'Observaciones', 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.ListMemo('observaciones', 'Arial, normal, 8', 5, salida, obs_historico, 500);
      End;
      if (salida = 'T') then begin
        list.LineaTxt('', true);
        list.LineaTxt('Observaciones:', true);
        list.ListMemo('observaciones', 'Arial, normal, 8', 5, salida, obs_historico, 500);
      end;
    end;

    if (lista) then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
      end;
      if (salida = 'T') then Begin
        List.LineaTxt('--------------------------------------------------------------------------------', True);
        list.LineaTxt('', True);
      end;
    end;
    lista := False;

  end;
end;

{==============================================================================}

procedure TTCreditos.ListOperacionesCredito(salida: char);
var
  i, j, k, m, z, ii: Integer;
  l: TStringList;
  c: String;
  r: TQuery;
Begin
  IniciarArreglosGenerales;
  l := TStringList.Create;
  rsql.Open;  rsql.First; i := 0; j := 0;

  while not rsql.Eof do Begin
    if (rsql.FieldByName('codprest').AsString <> idanter[1]) or (rsql.FieldByName('expediente').AsString <> idanter[2]) then Begin
      ListTotalesPagos(salida);
      if (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_detext') or (detcred.TableName = 'creditos_dethist') then ListDatosPrestatario(salida);
      idanter[1] := rsql.FieldByName('codprest').AsString;
      idanter[2] := rsql.FieldByName('expediente').AsString;
      totales[2] := 0; totales[4] := 0;
    end;
    if rsql.FieldByName('tipomov').AsString = '1' then Begin

      totales[3]  := totales[3] + (rsql.FieldByName('total').AsFloat * vindex);
      lista := True;

      // 29/08/07 - Deducci�n del Saldo Final
      if rsql.FieldByName('saldocuota').AsFloat <> 0 then
        totales[9]  := totales[9] + (rsql.FieldByName('saldocuota').AsFloat - rsql.FieldByName('aporte').AsFloat);
      totales[10] := Indice_credito;

      if (salida = 'P') or (salida = 'I') then
        list.Linea(0, 0, rsql.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
      if (salida = 'T') then
        list.LineaTxt(utiles.StringLongitudFija(rsql.FieldByName('concepto').AsString, 25), False);
      if ((tipoCalculo <> '5') or (tasa_Int = 0)) then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.importe(40, list.Lineactual, '', (rsql.FieldByName('amortizacion').AsFloat * vindex), 2, 'Arial, normal, 8');
          list.importe(50, list.Lineactual, '', (rsql.FieldByName('aporte').AsFloat * vindex), 3, 'Arial, normal, 8');
          list.importe(65, list.Lineactual, '', (rsql.FieldByName('total').AsFloat * vindex), 4, 'Arial, normal, 8');
        end;
        if (salida = 'T') then Begin
          list.importeTxt((rsql.FieldByName('amortizacion').AsFloat * vindex), 10, 2, False);
          list.importeTxt((rsql.FieldByName('aporte').AsFloat * vindex), 10, 2, False);
          list.importeTxt((rsql.FieldByName('total').AsFloat * vindex), 10, 2, False);
        end;
      end else Begin
        if Copy(rsql.FieldByName('concepto').AsString, 1, 3) = 'Mes' then Begin
          if (salida = 'P') or (salida = 'I') then Begin
            list.importe(40, list.Lineactual, '', (((monto * vIndex) * (tasa_Int * 0.01)) / 12), 2, 'Arial, normal, 8');
            list.importe(50, list.Lineactual, '', 0, 3, 'Arial, normal, 8');
            list.importe(65, list.Lineactual, '', (((monto * vIndex) * (tasa_Int * 0.01)) / 12), 4, 'Arial, normal, 8');
          end;
          if (salida = 'T') then Begin
            list.importeTxt((((monto * vIndex) * (tasa_Int * 0.01)) / 12), 10, 2, False);
            list.importeTxt(0, 10, 2, False);
            list.importeTxt((((monto * vIndex) * (tasa_Int * 0.01)) / 12), 10, 2, False);
          end;
        end else Begin
          if (salida = 'P') or (salida = 'I') then Begin
            list.importe(40, list.Lineactual, '', (rsql.FieldByName('amortizacion').AsFloat * vindex), 2, 'Arial, normal, 8');
            list.importe(50, list.Lineactual, '', (rsql.FieldByName('aporte').AsFloat * vindex), 3, 'Arial, normal, 8');
            list.importe(65, list.Lineactual, '', (rsql.FieldByName('total').AsFloat * vindex), 4, 'Arial, normal, 8');
          end;
          if (salida = 'T') then Begin
            list.importeTxt((rsql.FieldByName('amortizacion').AsFloat * vindex), 10, 2, False);
            list.importeTxt((rsql.FieldByName('aporte').AsFloat * vindex), 10, 2, False);
            list.importeTxt((rsql.FieldByName('total').AsFloat * vindex), 10, 2, False);
          end;
       end;
      end;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(66, list.Lineactual, utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString), 5, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', (rsql.FieldByName('saldo').AsFloat * vindex), 6, 'Arial, normal, 8');
      end;
      if (salida = 'T') then Begin
        list.LineaTxt(' ' + utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString), False);
        list.importeTxt((rsql.FieldByName('saldo').AsFloat * vindex), 10, 2, False);
      end;

      if Length(Trim(rsql.FieldByName('refinancia').AsString)) > 0 then Begin
        if (salida = 'P') or (salida = 'I') then
          //list.Linea(96, list.Lineactual, rsql.FieldByName('refinancia').AsString, 7, 'Arial, normal, 8', salida, 'S');
          list.Linea(96, list.Lineactual, rsql.FieldByName('cuotasref').AsString, 7, 'Arial, normal, 8', salida, 'S');
        if (salida = 'T') then
          //list.LineaTxt(rsql.FieldByName('refinancia').AsString, True);
          list.LineaTxt(rsql.FieldByName('cuotasref').AsString, True);

        if (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_dethist') then Begin
          if rsql.FieldByName('cuotasref').AsString <> idanter[9] then ref1.Add(rsql.FieldByName('items').AsString);
          idanter[9] := rsql.FieldByName('cuotasref').AsString;
        end;
        if detcred.TableName = 'creditos_detrefinanciados' then Begin
          if rsql.FieldByName('cuotasref').AsString <> idanter[10] then
          if rsql.FieldByName('cuotasref').AsString <> idanter[10] then ref2.Add(rsql.FieldByName('items').AsString);
          idanter[10] := rsql.FieldByName('cuotasref').AsString;
        end;
      end else Begin
        if (salida = 'P') or (salida = 'I') then
          if rsql.FieldByName('refcredito').AsString = '' then list.Linea(96, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S') else list.Linea(96, list.Lineactual, 'CR', 7, 'Arial, normal, 8', salida, 'S');
        if (salida = 'T') then
          if rsql.FieldByName('refcredito').AsString = '' then list.LineaTxt('', True) else list.LineaTxt('CR', True);
      end;
    end;

    if rsql.FieldByName('tipomov').AsString = '2' then Begin
      if totales[2] = 0 then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, 'Detalle de Pagos', 1, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          list.Linea(0, 0, 'Concepto', 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(18, list.Lineactual, 'Comprobante', 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(38, list.Lineactual, 'V. Hist.', 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(49, list.Lineactual, 'P.V. Real', 4, 'Arial, normal, 8', salida, 'N');
          list.Linea(61, list.Lineactual, 'Indice', 5, 'Arial, normal, 8', salida, 'N');
          list.Linea(67, list.Lineactual, 'F. Pago', 6, 'Arial, normal, 8', salida, 'N');
          list.Linea(77, list.Lineactual, 'Int.', 7, 'Arial, normal, 8', salida, 'N');
          list.Linea(84, list.Lineactual, 'Pun.', 8, 'Arial, normal, 8', salida, 'N');
          list.Linea(91, list.Lineactual, 'Saldo', 9, 'Arial, normal, 8', salida, 'S');
        end;
        if (salida = 'T') then Begin
          List.LineaTxt('--------------------------------------------------------------------------------', True);
          list.LineaTxt('Detalle de Pagos', True);
          list.LineaTxt('', True);
        end;
      end;

      Inc(i);

      if ExpresarEnPesos then vindex := 0; // else vindex := credito.Indice_credito; // rsql.FieldByName('indice').AsFloat;
      if vindex = 0 then vindex := 1;

      tcuotas[i, 1] := rsql.FieldByName('concepto').AsString {+ '  ' + floattostr(credito.indice_credito)};
      tcuotas[i, 2] := Copy(rsql.FieldByName('recibo').AsString, 12, 4) + '-' + Copy(rsql.FieldByName('recibo').AsString, 1, 8);
      if not ExpresarEnPesos then Begin
        if (credito.Indice_credito <> 0) then tcuotas[i, 3] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('total').AsFloat * credito.Indice_credito ))
          else tcuotas[i, 3] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('total').AsFloat ));
      end else
        tcuotas[i, 3] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('total').AsFloat ));
      tcuotas[i, 4] := utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString);
      if not ExpresarEnPesos then Begin
        tcuotas[i, 5] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('montoInt').AsFloat * vindex));
        tcuotas[i, 6] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('interes').AsFloat * vindex));
        tcuotas[i, 7] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('saldocuota').AsFloat * vindex));
      end else Begin
        tcuotas[i, 5] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('montoInt').AsFloat));
        tcuotas[i, 6] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('interes').AsFloat));
        tcuotas[i, 7] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('saldocuota').AsFloat));
      End;
      l.Add(rsql.FieldByName('refpago').AsString + rsql.FieldByName('items').AsString);
      tcuotas[i, 8] := rsql.FieldByName('refpago').AsString + rsql.FieldByName('items').AsString;
      tcuotas[i,10] := rsql.FieldByName('recibo').AsString;
      if vindex <> 1 then Begin
        tcuotas[i, 12] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('total').AsFloat * rsql.FieldByName('indice').AsFloat));
        //totales[10]    := rsql.FieldByName('indice').AsFloat;
      end else
        tcuotas[i, 12] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('total').AsFloat));

      tcuotas[i, 13] := utiles.FormatearNumero(rsql.FieldByName('indice').AsString, '#####0.0000');

      //if not BuscarReciboCobro(Copy(tcuotas[i, 10], 12, 4), Copy(tcuotas[i, 10], 1, 8) + Copy(tcuotas[i, 10], 9, 3), '01') then tcuotas[i, 11] := Copy(tcuotas[i, 10], 12, 4) + '-' + Copy(tcuotas[i, 10], 1, 8) + '/' + Copy(tcuotas[i, 10], 9, 3) else tcuotas[i, 11] := recibos_detalle.FieldByName('idc').AsString + '  ' + recibos_detalle.FieldByName('tipo').AsString + '  ' + recibos_detalle.FieldByName('sucrec').AsString + '-' + recibos_detalle.FieldByName('numrec').AsString;
      if BuscarReciboCobro(Copy(tcuotas[i, 10], 12, 4), Copy(tcuotas[i, 10], 1, 8) + Copy(tcuotas[i, 10], 9, 3), '01') then tcuotas[i, 11] := recibos_detalle.FieldByName('idc').AsString + '  ' + recibos_detalle.FieldByName('tipo').AsString + '  ' + recibos_detalle.FieldByName('sucrec').AsString + '-' + recibos_detalle.FieldByName('numrec').AsString else tcuotas[i, 11] := 'N';

      if rsql.FieldByName('Refinancia').AsString <> 'S' then Begin
        totales[2]  := totales[2]  + (rsql.FieldByName('total').AsFloat * vindex);
        totales[4]  := totales[4]  + (rsql.FieldByName('interes').AsFloat * vindex);
        totales[5]  := totales[5]  + (rsql.FieldByName('montoint').AsFloat * vindex);
        totales[15] := totales[15] + (rsql.FieldByName('interes').AsFloat * indice_credito);
        if rsql.FieldByName('indice').AsFloat <> 0 then totales[7] := totales[7] + (rsql.FieldByName('interes').AsFloat * rsql.FieldByName('indice').AsFloat);
      end;
    end;
    rsql.Next;
  end;

  if (salida = 'P') or (salida = 'I') then
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');


  l.Sort;
  i := l.Count;

  // Prorrateamos el Comprobante para los casos en que se liquide mas de una cuota con el mismo recibo
  for z := 1 to i do Begin    // Hacemos la sincronia por fecha, se decanta que ambos fueron liquidados el mismo dia
    if tcuotas[z, 11] = 'N' then Begin
      for m := 1 to i do Begin
        c := '';
        if (tcuotas[m, 4] = tcuotas[z, 4]) and (tcuotas[m, 11] <> 'N') then Begin
          c := tcuotas[m, 11];
          Break;
        end;
      end;
      for m := 1 to i do Begin
        if (tcuotas[m, 4] = tcuotas[z, 4]) and (tcuotas[m, 11] = 'N') then Begin
          tcuotas[m, 11] := c;
          Break;
        end;
      end;
    end;
  end;

  // Prorrateamos los recibos con los pagos fuera de t�rmino
  ii := 0;
  for z := 1 to i do
    if tcuotas[z, 11] = '' then Begin
      ii := 1;
      Break;
    end;

  if ii = 1 then Begin
    r :=  datosdb.tranSQL('select distribucioncobros.expediente, recibos_detalle.* from distribucioncobros, recibos_detalle where expediente = ' + '''' + codprest + '-' + expediente + '''' +
                            ' and  distribucioncobros.sucursal = recibos_detalle.sucursal and distribucioncobros.numero = recibos_detalle.numero and modo = ' + '''' + 'M' + '''');
    r.Open;
    for z := 1 to i do Begin    // Hacemos la sincronia por fecha, se decanta que ambos fueron liquidados el mismo dia
      if tcuotas[z, 11] = '' then Begin
        r.First;
        while not r.Eof do Begin
          if (utiles.sFormatoFecha(r.FieldByName('fecha').AsString) = tcuotas[z, 4]) and (tcuotas[z, 11] = '') then Begin
            tcuotas[z, 11] := r.FieldByName('idc').AsString + '  ' + r.FieldByName('tipo').AsString + '  ' + r.FieldByName('sucrec').AsString + ' ' + r.FieldByName('numrec').AsString;
          end;
          r.Next;
        end;
      end;
    end;
    r.Close; r.Free;
  end;

  //----------------------------------------------------------------------------

  For j := 1 to i do Begin
    For k := 1 to i do Begin
      if tcuotas[k, 8] = l.Strings[j-1] then Begin
        // Pago parciales tipo calculo 5 - 05/11/2007
        if BuscarTF(Codprest, Expediente, Copy(tcuotas[k,10], 12, 4) + Copy(tcuotas[k,10], 1, 11)) then Begin
          tcuotas[k, 3]  := utiles.FormatearNumero(FloatToStr (creditos_det_tf.FieldByName('capital').AsFloat + creditos_det_tf.FieldByName('interes').AsFloat) );
          tcuotas[k, 12] := utiles.FormatearNumero(FloatToStr (creditos_det_tf.FieldByName('capital').AsFloat + creditos_det_tf.FieldByName('interes').AsFloat) );
          tcuotas[k, 13] := '0';
          tcuotas[k, 6]  := creditos_det_tf.FieldByName('punitorio').AsString;
          totales[6]  := totales[6] + (creditos_det_tf.FieldByName('capital').AsFloat + creditos_det_tf.FieldByName('interes').AsFloat + creditos_det_tf.FieldByName('punitorio').AsFloat);
        end else begin
          totales[6]  := totales[6] + StrToFloat(tcuotas[k, 12]);
        end;

        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, tcuotas[k, 1], 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(18, list.Lineactual, tcuotas[k, 11], 2, 'Arial, normal, 8', salida, 'N');
          list.importe(43, list.Lineactual, '', StrToFloat(tcuotas[k, 3]), 3, 'Arial, normal, 8');
          list.importe(55, list.Lineactual, '', StrToFloat(tcuotas[k, 12]), 4, 'Arial, normal, 8');
          list.importe(65, list.Lineactual, '', StrToFloat(tcuotas[k, 13]), 5, 'Arial, normal, 8');
          list.Linea(67, list.Lineactual, tcuotas[k, 4], 6, 'Arial, normal, 8', salida, 'N');
          list.importe(80, list.Lineactual, '', StrToFloat(tcuotas[k, 5]), 7, 'Arial, normal, 8');
          list.importe(87, list.Lineactual, '', StrToFloat(tcuotas[k, 6]), 8, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', StrToFloat(tcuotas[k, 7]), 9, 'Arial, normal, 8');
          list.Linea(96, list.Lineactual, '', 10, 'Arial, normal, 8', salida, 'S');
        end;
        if (salida = 'T') then Begin
          list.LineaTxt(tcuotas[k, 1] + ' ', False);
          list.LineaTxt(utiles.StringLongitudFija(tcuotas[k, 11], 20), False);
          list.importeTxt(StrToFloat(tcuotas[k, 3]), 10, 2, False);
          list.importeTxt(StrToFloat(tcuotas[k, 12]), 10, 2, False);
          list.importeTxt(StrToFloat(tcuotas[k, 13]), 10, 2, False);
          list.LineaTxt(' ' + tcuotas[k, 4] + ' ', False);
          list.importeTxt(StrToFloat(tcuotas[k, 5]), 10, 2, False);
          list.importeTxt(StrToFloat(tcuotas[k, 6]), 10, 2, False);
          list.importeTxt(StrToFloat(tcuotas[k, 7]), 10, 2, True);
        end;
        //totales[6]  := totales[6] + StrToFloat(tcuotas[k, 12]);
        totales[10] := StrToFloat(tcuotas[k, 13]);
        Break;
      end;
    end;
  end;
  l.Destroy;

  ListTotalesPagos(salida);
  rsql.Close; rsql.Free; rsql := Nil;
end;

procedure TTCreditos.ListDatosPrestatario(salida: char);
// Objetivo...: Listar datos prestatarios
var
  fuente: String;
Begin
  if not ir then fuente := 'Arial, negrita, 8' else Begin
    fuente := 'Arial, normal, 8';
    if Length(Trim(Codprest)) > 0 then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  end;
  prestatario.getDatos(Codprest);
  if not ol then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      if not ir then
        if Length(Trim(idanter[1])) > 0 then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Prestatario: ' + prestatario.codigo + '-' + Copy(prestatario.nombre, 1, 30), 1, fuente, salida, 'N');
      if not credito_historico then list.Linea(55, list.Lineactual, 'Expediente: ' + creditos_det.FieldByName('expediente').AsString, 2, fuente, salida, 'N') else
      list.Linea(55, list.Lineactual, 'Expediente: ' + creditos_dethist.FieldByName('expediente').AsString, 2, fuente, salida, 'N');
      list.Linea(70, list.Lineactual, 'Monto: ', 3, fuente, salida, 'S');
      list.importe(96, list.Lineactual, '', Monto * vindex, 4, fuente);
      list.Linea(96, list.Lineactual, '', 5, fuente, salida, 'S');
      list.Linea(0, 0, 'Localidad: ' + prestatario.codpost + '-' + prestatario.orden + '  ' + prestatario.localidad, 1, fuente, salida, 'S');
      if not ir then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end;

    if (salida = 'T') then Begin
      if not ir then
        if Length(Trim(idanter[1])) > 0 then list.LineaTxt('', True);
      list.LineaTxt('Prestatario: ' + prestatario.codigo + '-' + Copy(prestatario.nombre, 1, 30), False);
      if not credito_historico then list.LineaTxt('  Expediente: ' + creditos_det.FieldByName('expediente').AsString, True) else
        list.LineaTxt('  Expediente: ' + creditos_dethist.FieldByName('expediente').AsString, True);
      list.LineaTxt('Monto: ', False);
      list.importeTxt(Monto * vindex, 12, 2, True);
      list.LineaTxt('Localidad: ' + prestatario.codpost + '-' + prestatario.orden + '  ' + copy(prestatario.localidad, 1, 20), true);
      if not ir then list.LineaTxt('', True);
    end;

    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Prestatario: ' + prestatario.codigo + '-' + Copy(prestatario.nombre, 1, 30), 'Arial, negrita, 8');
      excel.setString('d' + l1, 'd' + l1, 'Expediente: ' + creditos_det.FieldByName('expediente').AsString, 'Arial, negrita, 8');
      excel.setString('g' + l1, 'g' + l1, 'Monto:', 'Arial, negrita, 8');
      excel.setReal('h' + l1, 'h' + l1, Monto * vindex, 'Arial, negrita, 8');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Localidad: ' + prestatario.codpost + '-' + prestatario.orden + '  ' + prestatario.localidad, 'Arial, negrita, 8');
    end;
  end;
end;

procedure TTCreditos.ListTotalesPagos(salida: char);
// Objetivo...: Listar Total de Pagos
Begin
  if totales[10] = 0 then totales[10] := 1;
  if (totales[2] + totales[3] <> 0) and not (NoPresentarSubtotales) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Total Pagos:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(30, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
      if indice_credito = 0 then
        list.Linea(33, list.Lineactual, 'Saldo:', 3, 'Arial, negrita, 8', salida, 'N')
      else
        list.Linea(33, list.Lineactual, '(*) Saldo:', 3, 'Arial, negrita, 8', salida, 'N');
      list.importe(53, list.Lineactual, '', totales[9] * totales[10] {indice_credito}, 4, 'Arial, negrita, 8');
      list.Linea(55, list.Lineactual, 'Punitorios:', 5, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', totales[4], 6, 'Arial, negrita, 8');
      list.Linea(77, list.Lineactual, 'I.Tasa Flot.:', 7, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[5], 8, 'Arial, negrita, 8');
      list.Linea(97, list.Lineactual, '', 9, 'Arial, negritra, 8', salida, 'S');
      list.Linea(0, 0, 'Total Aj. Indices:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(30, list.Lineactual, '', totales[6], 2, 'Arial, negrita, 8');
      list.Linea(33, list.Lineactual, 'Punit. Act.:', 3, 'Arial, negrita, 8', salida, 'N');
      list.importe(53, list.Lineactual, '', totales[7], 4, 'Arial, negrita, 8');
      list.Linea(55, list.Lineactual, 'Dif. Punit.:', 5, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', totales[7] - totales[15], 6, 'Arial, negrita, 8');
      list.Linea(77, list.Lineactual, 'Diferencia:', 7, 'Arial, negrita, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[6] - totales[2], 8, 'Arial, negrita, 8');
      list.Linea(97, list.Lineactual, '', 9, 'Arial, negritra, 8', salida, 'S');
      list.Linea(0, 0, '(*) Saldo = (' + utiles.FormatearNumero(FloatToStr(totales[9])) + ' * ' + utiles.FormatearNumero(FloatToStr(totales[10])) + ') = ' + utiles.FormatearNumero(FloatToStr(totales[9] * totales[10])), 1, 'Arial, cursiva, 8', salida, 'S');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt('', True);
      list.LineaTxt('Total Pagos:', False);
      list.importeTxt(totales[2], 12, 2, False);
      list.LineaTxt('  Saldo: ', False);
      list.importeTxt(totales[9] * totales[10], 12, 2, False);
      list.LineaTxt(' Punitorios:', False);
      list.importeTxt(totales[4], 12, 2, False);
      list.LineaTxt(' I.Tasa Flot.:', False);
      list.importeTxt(totales[5], 12, 2, True);
      list.LineaTxt('(*) Saldo = (' + utiles.FormatearNumero(FloatToStr(totales[9])) + ' * ' + utiles.FormatearNumero(FloatToStr(totales[10])) + ') = ' + utiles.FormatearNumero(FloatToStr(totales[9] * totales[10])), True);
    end;
  end;
  totales[2] := 0; totales[3] := 0; totales[6] := 0; totales[7] := 0; totales[9] := 0; totales[10] := 0;
end;

{------------------------------------------------------------------------------}

procedure TTCreditos.ListarResumenDePagos(listSel: TStringList; xfecha: String; disc_linea, xinfresumido: Boolean; salida: char);
// Objetivo...: Listar Resumen de Pagos
Begin
  ir := xinfresumido; listdat := False;
  if not ol then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Setear(salida); list.altopag := 0; list.m := 0;
      List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
      if not credito_historico then List.Titulo(0, 0, ' Resumen Operaciones de Pagos', 1, 'Arial, negrita, 14') else
        List.Titulo(0, 0, ' Resumen Operaciones de Pagos (Registro Hist�rico)', 1, 'Arial, negrita, 14');
      List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
      List.Titulo(0, 0, 'Fecha        Concepto', 1, 'Arial, cursiva, 8');
      List.Titulo(45, List.lineactual, 'Debe', 2, 'Arial, cursiva, 8');
      List.Titulo(59, List.lineactual, 'Haber', 3, 'Arial, cursiva, 8');
      List.Titulo(71, List.lineactual, 'Saldo', 4, 'Arial, cursiva, 8');
      List.Titulo(78, List.lineactual, 'I.T.Flot.', 5, 'Arial, cursiva, 8');
      List.Titulo(88, List.lineactual, 'Punitorios', 6, 'Arial, cursiva, 8');
      if not ir then List.Titulo(96, List.lineactual, 'Ref.', 7, 'Arial, cursiva, 8');
      List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
      List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
      if not ExpresarEnPesos then List.Titulo(0, 0, '***  Montos Expresados en Pesos  ***', 1, 'Arial, normal, 10') else
        List.Titulo(0, 0, '***  Montos Expresados en Unidades  ***', 1, 'Arial, normal, 10');
      List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
    end;

    if (salida = 'X') then Begin
      c1 := 0;
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.FijarAnchoColumna('a' + l1, 'a' + l1, 9.5);
      excel.setString('a' + l1, 'a' + l1, 'Resumen Operaciones de Pagos al: ' + xfecha, 'Arial, negrita, 12');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Fecha', 'Arial, normal, 8');
      excel.FijarAnchoColumna('b' + l1, 'b' + l1, 15);
      excel.setString('b' + l1, 'b' + l1, 'Concepto', 'Arial, normal, 8');
      excel.FijarAnchoColumna('c' + l1, 'c' + l1, 15);
      excel.setString('d' + l1, 'd' + l1, 'Debe', 'Arial, normal, 8');
      excel.FijarAnchoColumna('d' + l1, 'd' + l1, 10);
      excel.setString('e' + l1, 'e' + l1, 'Haber', 'Arial, normal, 8');
      excel.FijarAnchoColumna('e' + l1, 'e' + l1, 10);
      excel.setString('f' + l1, 'f' + l1, 'Saldo', 'Arial, normal, 8');
      excel.FijarAnchoColumna('f' + l1, 'f' + l1, 10);
      excel.setString('g' + l1, 'g' + l1, 'I.T.Flot.', 'Arial, normal, 8');
      excel.FijarAnchoColumna('g' + l1, 'g' + l1, 10);
      excel.setString('h' + l1, 'h' + l1, 'Punitorios', 'Arial, normal, 8');
      excel.FijarAnchoColumna('h' + l1, 'h' + l1, 10);
      excel.setString('i' + l1, 'i' + l1, 'Ref.', 'Arial, normal, 8');
      excel.FijarAnchoColumna('i' + l1, 'i' + l1, 10);
      Inc(c1);
    end;
  end;

  lcuotas := 0;
  IniciarArreglosGenerales;
  ListarResumenDePagos_Creditos(listSel, xfecha, disc_linea, salida);

  if (totgral[3] + totgral[4] <> 0) and not (ol) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL: ', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(40, list.Lineactual, '', totgral[3], 2, 'Arial, negrita, 9');
      list.importe(53, list.Lineactual, '', totgral[4], 3, 'Arial, negrita, 9');
      list.importe(65, list.Lineactual, '', totgral[3] - totgral[4], 4, 'Arial, negrita, 9');
      list.importe(75, list.Lineactual, '', totgral[8], 5, 'Arial, negrita, 9');
      list.importe(85, list.Lineactual, '', totgral[7], 6, 'Arial, negrita, 9');
      list.importe(96, list.Lineactual, '', (totgral[3] - totgral[4]) + totgral[7] + totgral[8], 7, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 8, 'Arial, negrita, 9', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL GENERAL', 'Arial, negrita, 9');
      excel.setReal('c' + l1, 'c' + l1, totgral[3], 'Arial, negrita, 9');
      excel.setReal('d' + l1, 'd' + l1, totgral[4], 'Arial, negrita, 9');
      excel.setReal('e' + l1, 'e' + l1, totgral[3] - totgral[4], 'Arial, negrita, 9');
      excel.setReal('f' + l1, 'f' + l1, totgral[8], 'Arial, negrita, 9');
      excel.setReal('g' + l1, 'g' + l1, totgral[7], 'Arial, negrita, 9');
      excel.setReal('h' + l1, 'h' + l1, (totgral[3] - totgral[4]) + totgral[7] + totgral[8], 'Arial, negrita, 9');
    end;
  end;

  if (salida = 'P') or (salida = 'I') then
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');

  if salida = 'X' then excel.Visulizar;

  ir := False;
end;

procedure TTCreditos.ListarResumenDePagos_Creditos(listSel: TStringList; xfecha: String; disc_linea: Boolean; salida: char);
// Objetivo...: Detalle de Cr�ditos Normales
var
  i, j: Integer;
  r: TQuery;
  l: Boolean;
  t: Real;
Begin
  fuente := 'Arial, negrita, 9'; idanter[5] := '';
  For i := 0 to listSel.Count - 1 do Begin
    if Length(Trim(listSel.Strings[i])) = 0 then Break;

    ref1.Clear; ref2.Clear;
    if not credito_historico then detcred := creditos_det else detcred := creditos_dethist;

    Codprest   := Copy(listSel.Strings[i], 1, 5);
    Expediente := Copy(listSel.Strings[i], 6, 4);

    getDatos(Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4));
    if not ExpresarEnPesos then vindex := Indice_credito else vindex := 1;
    if vindex = 0 then vindex := 1;

    if disc_linea then Begin
      if (Copy(listSel.Strings[i], 10, 3) <> idanter[5]) and (Length(Trim(idanter[5])) > 0) then Begin
        TotalLinea(salida);
        RupturaLinea(salida);
      end;
      idanter[5] := Copy(listSel.Strings[i], 10, 3);
    end;

    ListarResumenDePagos_Items(xfecha, salida);

    if Refinanciado = 'S' then Begin    // Listamos la Refinanciaci�n
      if not ol then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
          list.Linea(0, 0, '***  Refinanciaci�n del Cr�dito  ***', 1, 'Arial, normal, 11', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end;
        if (salida = 'X') then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '***  Refinanciaci�n del Cr�dito  ***', 'Arial, negrita, 9');
        end;
      end;

      conectar_creditosRefinanciados;
      detcred := creditos_detrefinanciados;

      if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4)) then Monto := creditos_cabrefinanciados.FieldByName('monto').AsFloat;

      if not ExpresarEnPesos then vindex := creditos_cabrefinanciados.FieldByName('indice').AsFloat else vindex := 1;
      if vindex = 0 then vindex := 1;

      ListarResumenDePagos_Items(xfecha, salida);
      desconectar_creditosRefinanciados;
    end;

    if (ref1.Count > 0) or (ref2.Count > 0) then Begin       // Cr�ditos con Cuotas Refinanciadas
      if not ol then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
          list.Linea(0, 0, '***  Refinanciaci�n de Cuotas s/Cr�ditos  ***', 1, 'Arial, normal, 11', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end;
        if (salida = 'X') then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '***  Refinanciaci�n de Cuotas s/Cr�ditos  ***', 'Arial, negrita, 9');
        end;
      end;
      conectar_cuotasRefinanciadas;
      if datosdb.Buscar(creditos_cabrefcuotas, 'codprest', 'expediente', Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4)) then Monto := creditos_cabrefcuotas.FieldByName('monto').AsFloat;

      if not ExpresarEnPesos then vindex := creditos_cabrefcuotas.FieldByName('indice').AsFloat else vindex := 1;
      if vindex = 0 then vindex := 1;

      For j := 1 to ref1.Count do Begin    // Recorremos cada cuota refinanciada
        ListarResumenDePagos_Items(xfecha, salida);
      end;
      desconectar_cuotasRefinanciadas;
    end;

    if ref2.Count > 0 then Begin       // Cr�ditos Refinanciados con Cuotas Refinanciadas
      if not ol then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, list.Linealargopagina('--', salida) , 1, 'Arial, normal, 10', salida, 'S');
          list.Linea(0, 0, '***  Refinanciaci�n de Cuotas s/Cr�ditos Refinanciados  ***', 1, 'Arial, normal, 11', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end;
        if (salida = 'X') then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '***  Refinanciaci�n de Cuotas s/Cr�ditos Refinanciados  ***', 'Arial, negrita, 9');
        end;
      end;
      conectar_cuotasRefinanciadas;
      if datosdb.Buscar(creditos_cabrefcuotas, 'codprest', 'expediente', Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4)) then Monto := creditos_cabrefcuotas.FieldByName('monto').AsFloat;
      For j := 1 to ref2.Count do Begin    // Recorremos cada cuota refinanciada
        ListarResumenDePagos_Items(xfecha, salida);
      end;
      desconectar_cuotasRefinanciadas;
    end;

    // Para los Cr�ditos historicos verificamos cobros extras

    {if credito_historico then Begin
      r := setRecibosManualesExpediente(Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4));
      r.Open;
      r.First; totgral[14] := 0;
      while not r.Eof do Begin
        credito.BuscarReciboCobro(r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, '01');
        if recibos_detalle.FieldByName('modo').AsString = 'M' then Begin
          if not l then Begin
            if (salida = 'P') or (salida = 'I') then Begin
              list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
              list.Linea(0, 0, '*** Otros Cobros ***', 1, 'Arial, normal, 10', salida, 'S');
              list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
            end;
            if (salida = 'X') then Begin
              Inc(c1); l1 := Trim(IntToStr(c1));
              excel.setString('a' + l1, 'a' + l1, '***  Refinanciaci�n de Cuotas s/Cr�ditos Refinanciados  ***', 'Arial, negrita, 9');
            end;
            l := True;
          end;

          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, '      ' + recibos_detalle.FieldByName('tipo').AsString + ' ' + recibos_detalle.FieldByName('sucrec').AsString + '-' + recibos_detalle.FieldByName('numrec').AsString + '  ' + utiles.sFormatoFecha(recibos_detalle.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(26, list.Lineactual, recibos_detalle.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
            list.Importe(85, list.Lineactual, '', recibos_detalle.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
            list.Linea(87, list.Lineactual, recibos_detalle.FieldByName('anulado').AsString, 4, 'Arial, normal, 8', salida, 'S');
          end;
          if (salida = 'X') then Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, recibos_detalle.FieldByName('tipo').AsString + ' ' + recibos_detalle.FieldByName('sucrec').AsString + '-' + recibos_detalle.FieldByName('numrec').AsString, 'Arial, normal, 8');
            excel.setString('b' + l1, 'b' + l1, utiles.sFormatoFecha(recibos_detalle.FieldByName('fecha').AsString), 'Arial, normal, 8');
            excel.setString('c' + l1, 'c' + l1, recibos_detalle.FieldByName('concepto').AsString, 'Arial, normal, 8');
            excel.setReal('d' + l1, 'd' + l1, recibos_detalle.FieldByName('monto').AsFloat, 'Arial, normal, 8');
            excel.setString('e' + l1, 'e' + l1, recibos_detalle.FieldByName('anulado').AsString, 'Arial, normal, 8');
          end;
          if Length(Trim(recibos_detalle.FieldByName('anulado').AsString)) = 0 then totales[14] := totales[14] + recibos_detalle.FieldByName('monto').AsFloat;
        end;
        r.Next;
      end;
      r.Close; r.Free;

      if totales[14] > 0 then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
          list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 8', salida, 'S');
          list.Importe(85, list.Lineactual, '', totales[14], 2, 'Arial, negrita, 8');
          list.Linea(85, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        end;
        if (salida = 'E') then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, 'Total:', 'Arial, negrita, 8');
          excel.setReal('d' + l1, 'd' + l1, totales[14], 'Arial, negrita, 8');
        end;
      end;
    end;}

    // Otros Cobros
    ListarPagosFueraDeTermino(salida);

    if (lista) then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
      end;
      if (salida = 'T') then Begin
        List.LineaTxt('--------------------------------------------------------------------------------', True);
        list.LineaTxt('', True);
      end;
    end;
    lista := False;

  end;

  ref1.Clear; ref2.Clear;

  detcred.IndexFieldNames := 'codprest;expediente;items;recibo';
end;

procedure TTCreditos.RupturaLinea(salida: char);
// Objetivo...: Realizar Ruptura por Linea de Cr�dito
Begin
  categoria.getDatos(idcredito);
  if not ol then Begin
    if (salida = 'I') or (salida = 'P') then Begin
      list.Linea(0, 0, 'Linea: ' + idcredito + '  ' + categoria.Descrip, 1, fuente, salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Linea: ' + idcredito + '  ' + categoria.Descrip, fuente);
    end;
    if (salida = 'T') then Begin
      list.LineaTxt('Linea: ' + idcredito + '  ' + categoria.Descrip, True);
    end;
  end;
end;

procedure TTCreditos.TotalLinea(salida: char);
// Objetivo...: Realizar Ruptura por Linea de Cr�dito
Begin
  if (totgral[1] + totgral[2] <> 0) and not (ol) then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Total ' + categoria.Descrip + ':', 1, fuente, salida, 'N');
      list.importe(40, list.Lineactual, '', totgral[1], 2, fuente);
      list.importe(53, list.Lineactual, '', totgral[2], 3, fuente);
      list.importe(65, list.Lineactual, '', totgral[1] - totgral[2], 4, fuente);
      list.importe(75, list.Lineactual, '', totgral[6], 5, fuente);
      list.importe(85, list.Lineactual, '', totgral[5], 6, fuente);
      list.importe(96, list.Lineactual, '', (totgral[1] - totgral[2]) + totgral[5] + totgral[6], 7, fuente);
      list.Linea(96, list.Lineactual, '', 8, fuente, salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Total ' + categoria.Descrip + ':', fuente);
      excel.setReal('c' + l1, 'c' + l1, totgral[1], fuente);
      excel.setReal('d' + l1, 'd' + l1, totgral[2], fuente);
      excel.setReal('e' + l1, 'e' + l1, totgral[1] - totgral[2], fuente);
      excel.setReal('f' + l1, 'f' + l1, totgral[6], fuente);
      excel.setReal('g' + l1, 'g' + l1, totgral[5], fuente);
      excel.setReal('h' + l1, 'h' + l1, (totgral[1] - totgral[2]) + totgral[5] + totgral[6], fuente);
    end;
  end;

  // Arreglo de totales Finales
  if (totgral[1] + totgral[2] <> 0) then Begin
    Inc(lcuotas);
    tcuotas[lcuotas, 1] := categoria.Items;
    tcuotas[lcuotas, 2] := categoria.Descrip;
    tcuotas[lcuotas, 3] := FloatToStr(totgral[1]);
    tcuotas[lcuotas, 4] := FloatToStr(totgral[2]);
    tcuotas[lcuotas, 5] := FloatToStr(totgral[1] - totgral[2]);
    tcuotas[lcuotas, 6] := FloatToStr(totgral[6]);
    tcuotas[lcuotas, 7] := FloatToStr(totgral[5]);
    tcuotas[lcuotas, 8] := FloatToStr((totgral[1] - totgral[2]) + totgral[5] + totgral[6]);
    tcuotas[lcuotas, 9] := categoria.IdLinea;
  end;

  totgral[3] := totgral[3] + totgral[1];
  totgral[4] := totgral[4] + totgral[2];
  totgral[7] := totgral[7] + totgral[5];
  totgral[8] := totgral[8] + totgral[6];
  totgral[1] := 0; totgral[2] := 0; totgral[5] := 0; totgral[6] := 0;
end;

procedure TTCreditos.ListarResumenDePagos_Items(xfecha: String; salida: char);
// Objetivo...: Listar Detalle de Pagos
var
  it, ncomp: String; ls, l, mb, ajusteIndice: Boolean; i, j, k, z, m, cantIndice: Integer;
  tot: array[1..2] of real;
  r: TQuery;
  m_cuota: Real;
Begin
  IniciarArreglos;
  for i := 1 to 100 do
    for j := 1 to 14 do mov[i, j] := '';

  if detcred.IndexFieldNames <> 'codprest;expediente;fechavto;items' then detcred.IndexFieldNames := 'codprest;expediente;fechavto;items';
  datosdb.Filtrar(detcred, 'codprest = ' + codprest + ' and expediente = ' + expediente);

  detcred.First; i := 0; ajusteIndice := False; cantIndice := 0;
  while not detcred.Eof do Begin
    if detcred.FieldByName('tipomov').AsInteger = 2 then Begin
      Inc(i);
      if detcred.FieldByName('indice').AsFloat <> 0 then ajusteIndice := True;
      mov[i, 1] := detcred.FieldByName('refpago').AsString;
      mov[i, 2] := detcred.FieldByName('fechavto').AsString;
      mov[i, 3] := detcred.FieldByName('recibo').AsString;
      mov[i, 4] := detcred.FieldByName('concepto').AsString;
      mov[i, 5] := FloatToStr(detcred.FieldByName('total').AsFloat * vindex);
      mov[i, 6] := FloatToStr(detcred.FieldByName('saldocuota').AsFloat * vindex);
      mov[i, 7] := FloatToStr(detcred.FieldByName('interes').AsFloat * vindex);
      mov[i, 8] := detcred.FieldByName('tipomov').AsString;
      mov[i, 9] := detcred.FieldByName('refinancia').AsString;
      if Length(Trim(detcred.FieldByName('montoint').AsString)) > 0 then mov[i,10] := detcred.FieldByName('montoint').AsString else mov[i,10] := '0';
      if BuscarReciboCobro(Copy(mov[i, 3], 12, 4), Copy(mov[i, 3], 1, 8) + Copy(mov[i, 3], 9, 3), '01') then mov[i, 11] := recibos_detalle.FieldByName('idc').AsString + '  ' + recibos_detalle.FieldByName('tipo').AsString + '  ' + recibos_detalle.FieldByName('sucrec').AsString + '-' + recibos_detalle.FieldByName('numrec').AsString else mov[i, 11] := 'N';
      listdat   := True;
    end;
    detcred.Next;
  end;

  // Prorrateamos los recibos que se pagaron en la misma fecha
  for z := 1 to i do Begin
    if mov[z, 11] = 'N' then Begin
      ncomp := '';
      for m := 1 to i do Begin
        if (mov[m, 11] <> 'N') and (mov[m, 2] = mov[z, 2]) then Begin
          ncomp := mov[m, 11];
          Break;
        end;
      end;
      if ncomp <> '' then mov[z, 11] := ncomp;
    end;
  end;

  // Averiguamos si quedan ranuras en blanco
  ls := False;
  for z := 1 to i do Begin
    if mov[z, 11] = 'N' then Begin
      ls := True;
      Break;
    end;
  end;

  if ls then Begin  // Si quedan ranuras prorrateamos con los Pagos Anticipados
    r :=  datosdb.tranSQL('select distribucioncobros.expediente, recibos_detalle.* from distribucioncobros, recibos_detalle where expediente = ' + '''' + codprest + '-' + expediente + '''' +
                            ' and  distribucioncobros.sucursal = recibos_detalle.sucursal and distribucioncobros.numero = recibos_detalle.numero and modo = ' + '''' + 'M' + '''');
    r.Open;
    for m := 1 to i do Begin    // Hacemos la sincronia por fecha, se decanta que ambos fueron liquidados el mismo dia
      if mov[m, 11] = 'N' then Begin
        r.First;
        while not r.Eof do Begin
          if (r.FieldByName('fecha').AsString = mov[m, 2]) then Begin
            mov[m, 11] := r.FieldByName('idc').AsString + '  ' + r.FieldByName('tipo').AsString + '  ' + r.FieldByName('sucrec').AsString + ' ' + r.FieldByName('numrec').AsString;
          end;
          r.Next;
        end;
      end;
    end;
    r.Close; r.Free;
  end;

  detcred.First;

  while not detcred.Eof do Begin
    l := False;
    if (detcred.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xfecha)) and not (ol) then l := True;
    if ol then
      if (detcred.FieldByName('fechavto').AsString >= utiles.sExprFecha2000(desdeFecha)) and (detcred.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xfecha)) then l := True;

    if l then Begin
      if (detcred.FieldByName('codprest').AsString <> idanter[1]) or (detcred.FieldByName('expediente').AsString <> idanter[2]) then Begin
        SaldoCredito(salida);
        Buscar(detcred.FieldByName('codprest').AsString, detcred.FieldByName('expediente').AsString);
        if (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_dethist') then ListDatosPrestatario(salida);
        idanter[1] := detcred.FieldByName('codprest').AsString;
        idanter[2] := detcred.FieldByName('expediente').AsString;
        totales[2] := 0;
      end;

      if detcred.FieldByName('tipomov').AsInteger = 1 then Begin   // Movimiento Debe
        if not ir then Begin
          if not ol then Begin

            m_cuota := detcred.FieldByName('total').AsFloat * vindex;  // 05/11/2007 -> Si hay Pagos Parciales, Obtenemos el total
            if (tipoCalculo = '5') or (credito.TipoCalculo = 'B') then Begin
              if VerificarPagosTF(codprest, expediente, detcred.FieldByName('items').AsString) then
                m_cuota := credito.SetTotalPagadoTF(codprest, expediente, detcred.FieldByName('items').AsString);
            end;

            lista := True;
            if (salida = 'P') or (salida = 'I') then Begin
              list.Linea(0, 0, utiles.sFormatoFecha(detcred.FieldByName('fechavto').AsString) + '  ' + detcred.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
              if detcred.FieldByName('tipomov').AsInteger = 1 then list.importe(50, list.Lineactual, '', m_cuota {(detcred.FieldByName('total').AsFloat * vindex)}, 2, 'Arial, normal, 8') else
                list.importe(65, list.Lineactual, '', m_cuota {(detcred.FieldByName('total').AsFloat * vindex)}, 2, 'Arial, normal, 8');
            end;
            if (salida = 'X') then Begin
              Inc(c1); l1 := Trim(IntToStr(c1));
              excel.setString('a' + l1, 'a' + l1, '''' + utiles.sFormatoFecha(detcred.FieldByName('fechavto').AsString), 'Arial, normal, 8');
              excel.setString('b' + l1, 'b' + l1, detcred.FieldByName('concepto').AsString, 'Arial, normal, 8');
              if detcred.FieldByName('tipomov').AsInteger = 1 then  excel.setReal('d' + l1, 'd' + l1, m_cuota {(detcred.FieldByName('total').AsFloat * vindex)}, 'Arial, normal, 8') else
                excel.setReal('e' + l1, 'e' + l1, m_cuota {(detcred.FieldByName('total').AsFloat * vindex)}, 'Arial, normal, 8');
            end;

          end;
        end;

        // Acumulamos los pagos para obtener el saldo si el pago no corresponde al per�odo de gracia, Creditos Normales
        if (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_dethist') then Begin
          if (detcred.FieldByName('tipomov').AsInteger = 1) and (detcred.FieldByName('refcredito').AsString = '') and (detcred.FieldByName('refinancia').AsString = '') then totales[1] := totales[1] + m_cuota; //(detcred.FieldByName('total').AsFloat * vindex);
          // Creditos Refinanciados pero, con cuotas parcialmente pagas
          if (detcred.FieldByName('tipomov').AsInteger = 1) and (detcred.FieldByName('refcredito').AsString <> '') and (detcred.FieldByName('refinancia').AsString = '') then totales[1] := totales[1] + ((detcred.FieldByName('total').AsFloat - detcred.FieldByName('saldocuota').AsFloat) * vindex);
        end;
        // Creditos Refinanciados
        if (detcred.TableName = 'creditos_detrefinanciados') or (detcred.TableName = 'creditos_dethistrefinanciados') then
          if (detcred.FieldByName('tipomov').AsInteger = 1) then totales[1] := totales[1] + m_cuota; //(detcred.FieldByName('total').AsFloat * vindex);
        // Cuotas Refinanciadas
        if (detcred.TableName = 'creditos_detrefcuotas') or (detcred.TableName = 'creditos_dethistrefcuotas') then
          if (detcred.FieldByName('tipomov').AsInteger = 1) then totales[1] := totales[1] + m_cuota; //(detcred.FieldByName('total').AsFloat * vindex);

        it := detcred.FieldByName('items').AsString;

        For j := 1 to i do Begin
          if Copy(mov[j, 1], 10, 3) = it then Begin
            ls := True;
            if not ol then Begin
              if not ir then Begin

                if (TipoCalculo = '5') or (credito.TipoCalculo = 'B') then Begin            // 09/11/2007 -> tomamos el monto que corresponde al cobro de capital
                  if credito.BuscarTF(Codprest, Expediente, Copy(mov[j, 3], 12, 4) + Copy(mov[j, 3], 1, 11)) then Begin
                    mov[j, 5]  := creditos_det_tf.FieldByName('capital').AsString;
                  end;
                end;

                if (salida = 'P') or (salida = 'I') then Begin
                  list.Linea(0, 0, '         ' + utiles.sFormatoFecha(mov[j, 2]) + '  ' + mov[j, 11], 1, 'Arial, normal, 8', salida, 'N');
                  list.Linea(28, list.Lineactual, mov[j, 4], 2, 'Arial, normal, 8', salida, 'N');
                  list.importe(63, list.Lineactual, '###,###,##0.00', StrToFloat(mov[j, 5]), 3, 'Arial, normal, 8');
                  if StrToFloat(utiles.FormatearNumero(mov[j, 6], '########0.00')) = 0 then list.importe(75, list.Lineactual, '###,###,###.##', StrToFloat(mov[j, 6]), 4, 'Arial, normal, 8') else list.importe(75, list.Lineactual, '', StrToFloat(mov[j, 6]), 4, 'Arial, normal, 8');
                  if StrToFloat(mov[j,10]) = 0 then list.importe(85, list.Lineactual, '###,###,###.##', StrToFloat(mov[j,10]), 5, 'Arial, normal, 8') else list.importe(85, list.Lineactual, '', StrToFloat(mov[j,10]), 5, 'Arial, normal, 8');
                  if StrToFloat(mov[j, 7]) = 0 then list.importe(96, list.Lineactual, '###,###,###.##', StrToFloat(mov[j, 7]), 6, 'Arial, normal, 8') else list.importe(96, list.Lineactual, '', StrToFloat(mov[j, 7]), 6, 'Arial, normal, 8');
                  list.Linea(97, list.Lineactual, mov[j, 9], 7, 'Arial, normal, 8', salida, 'S');
                end;
                if (salida = 'X') then Begin
                  Inc(c1); l1 := Trim(IntToStr(c1));
                  excel.setString('a' + l1, 'a' + l1, '''' + utiles.sFormatoFecha(mov[j, 2]), 'Arial, normal, 8');
                  excel.setString('b' + l1, 'b' + l1, ncomp, 'Arial, normal, 8');
                  excel.setString('c' + l1, 'c' + l1, mov[j, 4], 'Arial, normal, 8');
                  excel.setReal('e' + l1, 'e' + l1, StrToFloat(mov[j, 5]), 'Arial, normal, 8');
                  excel.setReal('f' + l1, 'f' + l1, StrToFloat(mov[j, 6]), 'Arial, normal, 8');
                  excel.setReal('g' + l1, 'g' + l1, StrToFloat(mov[j, 10]), 'Arial, normal, 8');
                  excel.setReal('h' + l1, 'h' + l1, StrToFloat(mov[j, 7]), 'Arial, normal, 8');
                  excel.setString('i' + l1, 'i' + l1, mov[j, 9], 'Arial, normal, 8');
                end;
              end;
            end;
            // Acumulamos los pagos para obtener el saldo si el pago no corresponde al per�odo de gracia
            if mov[j, 8] = '2' then totales[2] := totales[2] + StrToFloat(mov[j, 5]);
            totales[5] := totales[5] + StrToFloat(mov[j, 7]);
            totales[6] := totales[6] + StrToFloat(mov[j,10]);
          end;
        end;
      end;

      if detcred.FieldByName('tipomov').AsInteger = 1 then Begin
        if not (ol) then Begin
          if not ir then Begin
            if (salida = 'P') or (salida = 'I') then Begin
              if (ref_c = 'S') and ( (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_dethist') ) then list.Linea(97, list.Lineactual, 'CR', 7, 'Arial, normal, 8', salida, 'S') else list.Linea(96, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
              if ref_u = 'S' then list.Linea(97, list.Lineactual, detcred.FieldByName('refinancia').AsString, 7, 'Arial, normal, 8', salida, 'S');
            end;
            if (salida = 'X') then Begin
              if (ref_c = 'S') and ( (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_dethist') ) then excel.setString('j' + l1, 'j' + l1, 'CR', 'Arial, normal, 8');
              if ref_u = 'S' then excel.setString('j' + l1, 'j' + l1, detcred.FieldByName('refinancia').AsString, 'Arial, normal, 8');
            end;
          end;
        end;
      end;

      if (detcred.TableName <> 'creditos_detrefcuotas') and (detcred.FieldByName('refinancia').AsString = 'S') then Begin
        if (detcred.TableName = 'creditos_det') or (detcred.TableName = 'creditos_dethist') then Begin
          if detcred.FieldByName('cuotasref').AsString <> idanter[9] then ref1.Add(detcred.FieldByName('items').AsString);
          idanter[9] := detcred.FieldByName('cuotasref').AsString;
        end;
        if detcred.TableName = 'creditos_detrefinanciados' then Begin
          if detcred.FieldByName('cuotasref').AsString <> idanter[10] then ref2.Add(detcred.FieldByName('items').AsString);
          idanter[10] := detcred.FieldByName('cuotasref').AsString;
        end;
      end;
    end;
    detcred.Next;
  end;

  SaldoCredito(salida);

  // Detalle de Indices ajustados
  if ajusteIndice then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, '*** Detalle de Ajustes por Indices ***', 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '  Fecha     Concepto', 1, 'Arial, cursiva, 8', salida, 'N');
    List.Linea(71, List.lineactual, 'Total', 2, 'Arial, cursiva, 8', salida, 'N');
    List.Linea(90, List.lineactual, 'I.Punit.', 3, 'Arial, cursiva, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

    tot[1] := 0; tot[2] := 0;
    detcred.First;
    while not detcred.Eof do Begin
      if detcred.FieldByName('tipomov').AsInteger = 1 then Begin
        // Para el Saldo Final  - 06/09/2007
        if detcred.FieldByName('saldocuota').AsFloat <> 0 then
          totales[9]  := totales[9] + (detcred.FieldByName('saldocuota').AsFloat - detcred.FieldByName('aporte').AsFloat)
        else
          totales[9]  := totales[9] + detcred.FieldByName('saldocuota').AsFloat;
      end;
      if detcred.FieldByName('tipomov').AsInteger = 2 then Begin
        list.Linea(0, 0, '  ' + utiles.sFormatoFecha(detcred.FieldByName('fechavto').AsString) + '  ' + detcred.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
        if not ExpresarEnPesos then Begin
          list.importe(75, list.Lineactual, '', detcred.FieldByName('total').AsFloat * detcred.FieldByName('indice').AsFloat, 2, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', detcred.FieldByName('interes').AsFloat * detcred.FieldByName('indice').AsFloat, 3, 'Arial, normal, 8');
        end else Begin
          list.importe(75, list.Lineactual, '', detcred.FieldByName('total').AsFloat, 2, 'Arial, normal, 8');
          list.importe(95, list.Lineactual, '', detcred.FieldByName('interes').AsFloat, 3, 'Arial, normal, 8');
        End;
        list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
        if not ExpresarEnPesos then Begin
          tot[1] := tot[1] + (detcred.FieldByName('total').AsFloat * detcred.FieldByName('indice').AsFloat);
          tot[2] := tot[2] + (detcred.FieldByName('interes').AsFloat * detcred.FieldByName('indice').AsFloat);
        end else Begin
          tot[1] := tot[1] + (detcred.FieldByName('total').AsFloat);
          tot[2] := tot[2] + (detcred.FieldByName('interes').AsFloat);
        End;
        totales[10] := detcred.FieldByName('indice').AsFloat;
      end;
      detcred.Next;
    end;

    if ((tot[1] + tot[2]) <> 0) then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(96, list.Lineactual, '', '---------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '  Total Ajustes:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', tot[1], 2, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', tot[2], 3, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');

      list.Linea(0, 0, '  Dif. por Ajustes:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '', tot[1] - totales[2], 2, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', tot[2] - totales[5], 3, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');

      list.Linea(0, 0, ' Saldo Pendiente = (' + utiles.FormatearNumero(FloatToStr(totales[9])) + ' * ' + utiles.FormatearNumero(FloatToStr(totales[10])) + ') = ' + utiles.FormatearNumero(FloatToStr(totales[9] * totales[10])), 1, 'Arial, cursiva, 8', salida, 'S');
    end;

  end;

  datosdb.QuitarFiltro(detcred);
end;

procedure TTCreditos.SaldoCredito(salida: char);
// Objetivo...: Listar Saldo Cr�dito
var
  fuente: String;
Begin
  if ir then fuente := 'Arial, cursiva, 8' else fuente := 'Arial, negrita, 8';
  if totales[1] > 0 then Begin
    if not ol then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        if not ir then list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');
        list.Linea(0, 0, 'Saldo Actual ->', 1, fuente, salida, 'N');
        list.importe(50, list.Lineactual, '', totales[1], 2, fuente);
        list.importe(63, list.Lineactual, '', totales[2], 3, fuente);
        //list.importe(75, list.Lineactual, '', totales[1] - totales[2], 4, fuente);
        list.importe(85, list.Lineactual, '', totales[6], 4, fuente);
        list.importe(96, list.Lineactual, '', totales[5], 5, fuente);
        list.Linea(96, list.Lineactual, '', 6, fuente, salida, 'S');
        if not ir then Begin
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end else
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, 'Saldo Actual ->', fuente);
        excel.setReal('d' + l1, 'd' + l1, totales[1], fuente);
        excel.setReal('e' + l1, 'e' + l1, totales[2], fuente);
        //excel.setReal('f' + l1, 'f' + l1, totales[1] - totales[2], fuente);
        excel.setReal('g' + l1, 'g' + l1, totales[6], fuente);
        excel.setReal('h' + l1, 'h' + l1, totales[5], fuente);
      end;
    end;
    totgral[1] := totgral[1] + totales[1];
    totgral[2] := totgral[2] + totales[2];
    totgral[5] := totgral[5] + totales[5];
    totgral[6] := totgral[6] + totales[6];
  end;
end;

{-------------------------------------------------------------------------------}

procedure TTCreditos.ListarResumenDePagosHistorico(listSel: TStringList; xfecha: String; disc_linea, xinfresumido: Boolean; salida: char);
// Objetivo...: Listar detalle cr�ditos historicos
Begin
  desconectar;
  credito_historico := True;
  creditos_cab := nil; creditos_dethist := nil; gastos_hist := nil; creditos_detrefinanciados := nil; creditos_detrefcuotas := nil;
  creditos_cab              := datosdb.openDB('creditos_cabhist', '');
  creditos_dethist          := datosdb.openDB('creditos_dethist', '');
  creditos_detrefinanciados := datosdb.openDB('creditos_dethistrefinanciados', '');
  creditos_detrefcuotas     := datosdb.openDB('creditos_dethistrefcuotas', '');
  creditos_cab.Open; creditos_dethist.Open; creditos_detrefinanciados.Open; creditos_detrefcuotas.Open;
  prestatario.conectar;
  ListarResumenDePagos(listSel, xfecha, disc_linea, xinfresumido, salida);
  creditos_cabhist.Close; creditos_dethist.Close; creditos_detrefinanciados.Close; creditos_detrefcuotas.Close;
  PresentarInforme;
  prestatario.desconectar;
  credito_historico := False;
  creditos_cab      := datosdb.openDB('creditos_cab', '');
  conectar;
end;

{-------------------------------------------------------------------------------}

procedure TTCreditos.ListCuotasAtrazadas(listSel: TStringList; xfecha, xcantmeses, xcp, xorden: String; disc_linea, listaJudiciales: Boolean; salida: char);
// Objetivo...: Listar cuotas atrazadas
var
  i, j: Integer; l, ld, lt, lc, tc5: Boolean;
  mc, ap: Real; ob, idanter1: String;
Begin
  datosdb.tranSQL('delete from totales_lineas');
  totales_lineas.Open;

  if (salida = 'P') or (salida = 'I') then Begin
    tfinal.Clear;
    list.altopag := 0; list.m := 0;
    list.IniciarTitulos;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    if listaJudiciales then List.Titulo(0, 0, ' Informe de Cuotas Atrasadas en V�a Judicial al ' + xfecha, 1, 'Arial, negrita, 14') else List.Titulo(0, 0, ' Informe de Cuotas Atrasadas al ' + xfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, '         ' + 'Fecha        Concepto', 1, 'Arial, cursiva, 8');
    List.Titulo(60, List.lineactual, 'Capital', 2, 'Arial, cursiva, 8');
    List.Titulo(70, List.lineactual, 'Aporte', 3, 'Arial, cursiva, 8');
    List.Titulo(80, List.lineactual, 'Total', 4, 'Arial, cursiva, 8');
    List.Titulo(92, List.lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
    fuente := 'Arial, negrita, 9';
    IniciarInforme(salida);
  end;
  if salida = 'T' then Begin
    IniciarInforme(salida);
    list.LineaTxt('', True);
    if listaJudiciales then List.LineaTxt(' Informe de Cuotas Atrasadas en V�a Judicial al ' + xfecha, True) else List.LineaTxt(' Informe de Cuotas Atrasadas al ' + xfecha, True);
    List.LineaTxt(' ', True);
    List.LineaTxt('  ' + 'Fecha     Concepto                    Capital     Aporte      Total      Saldo', True);
    List.LineaTxt('--------------------------------------------------------------------------------', True);
    List.LineaTxt(' ', True);
  end;
  if (salida = 'X') then begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 9.5);
    if listaJudiciales then List.Titulo(0, 0, ' Informe de Cuotas Atrasadas en V�a Judicial al ' + xfecha, 1, 'Arial, negrita, 14') else List.Titulo(0, 0, ' Informe de Cuotas Atrasadas al ' + xfecha, 1, 'Arial, negrita, 14');
    if listaJudiciales then excel.setString('a' + l1, 'a' + l1, 'Informe de Cuotas Atrasadas en V�a Judicial al ' + xfecha, 'Arial, negrita, 12') else excel.setString('a' + l1, 'a' + l1, 'Informe de Cuotas Atrasadas al ' + xfecha, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Fecha', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 37);
    excel.setString('b' + l1, 'b' + l1, 'Concepto', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 10);
    excel.setString('c' + l1, 'c' + l1, 'Capital', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 10);
    excel.setString('d' + l1, 'd' + l1, 'Aporte', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 10);
    excel.setString('e' + l1, 'e' + l1, 'Total', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('f' + l1, 'f' + l1, 10);
    excel.setString('f' + l1, 'f' + l1, 'Saldo', 'Arial, negrita, 10');
    Inc(c1);
    fuente := 'Arial, negrita, 10';
  end;

  if Length(Trim(xcp)) > 0 then Begin
    cpost.getDatos(xcp, xorden);
    if (salida = 'P') or (salida = 'I') then Begin
      List.Linea(0, 0, '  Localidad: ' + xcp + '-' + xorden + '   ' + cpost.localidad, 1, 'Arial, normal, 12', salida, 'S');
      list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt('Localidad: ' + xcp + '-' + xorden + '  ' + cpost.localidad, True);
      list.LineaTxt(' ', True);
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Localidad:', 'Arial, negrita, 10');
      excel.setString('b' + l1, 'b' + l1, xcp + '-' + xorden + '  ' + cpost.Localidad, 'Arial, negrita, 10');
    End;
  end;

  IniciarArreglosGenerales;
  total_fin := 0; totgral[1] := 0;  idanter[6] := ''; idanter[5] := '';
  For i := 0 to listSel.Count - 1 do Begin
    if Length(Trim(listSel.Strings[i])) = 0 then Break;

    idanter1 := idanter[5];
    IniciarArreglos;
    idanter[5] := idanter1;

    Codprest   := Copy(listSel.Strings[i], 1, 5);
    Expediente := Copy(listSel.Strings[i], 6, 4);

    getDatos(Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4));

    lt := True;
    if not listaJudiciales then    // Cr�ditos en V�a Judicial
      if ViaJudicial then lt := False else lt := True;
    if listaJudiciales then
      if ViaJudicial then lt := True else lt := False;

    lc := True;
    prestatario.getDatos(Copy(listSel.Strings[i], 1, 5));
    if Length(Trim(xcp)) > 0 then
      if (prestatario.codpost = xcp) and (prestatario.orden = xorden) then lc := True else lc := False;

    if (lc) then Begin
      { Creditos Normales }
      creditos_det.IndexFieldNames := 'Codprest;Expediente;Fechavto;Items';
      datosdb.Filtrar(creditos_det, 'codprest = ' + '''' + Copy(listSel.Strings[i], 1, 5) + '''' + ' and expediente = ' + '''' + Copy(listSel.Strings[i], 6, 4) + '''' + ' and tipomov = 1' + ' and saldocuota >= 0');

      if not ExpresarEnPesos then vindex := Indice_credito else vindex := 1;
      if vindex = 0 then vindex := 1;

      if creditos_det.RecordCount > 0 then Begin
        if Refinanciado <> 'S' then Begin
          while not creditos_det.Eof do Begin
            ld := False;   // Flag para las fechas de pago
            if Length(trim(detcred.FieldByName('fechapago').AsString)) = 0 then ld := True else
              if detcred.FieldByName('fechapago').AsString <= utiles.sExprFecha2000(xfecha) then ld := True;

            tc5 := False; ob := '';
            if ld then Begin
              credito.getDatos(Copy(listSel.Strings[i], 1, 5), Copy(listSel.Strings[i], 6, 4));
              if ((tipoCalculo = '5') or (credito.TipoCalculo = 'B')) and (creditos_det.FieldByName('amortizacion').AsFloat + creditos_det.FieldByName('aporte').AsFloat = 0) then Begin
                ld  := True;
                tc5 := True;
                ob  := '*';
              end;
            end;

            mc := 0;
            if (creditos_cab.FieldByName('tipocalculo').AsString = '5') and (creditos_det.FieldByName('aporte').AsFloat + creditos_det.FieldByName('total').AsFloat  = 0) then Begin
              credito.getDatos(creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString);
              mc := (((credito.Monto * tasainteresFlotante) * 0.01) / 12);
            end;

            if (ld) and not (ViaJudicial) and (lt) then Begin

              if creditos_det.FieldByName('refinancia').AsString <> 'S' then Begin
                if (creditos_det.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xfecha)) and (creditos_det.FieldByName('estado').AsString = 'I') and (creditos_det.FieldByName('tipomov').AsInteger = 1) then Begin
                  if not l then Begin
                    if disc_linea then Begin
                      if Copy(listSel.Strings[i], 10, 3) <> idanter[5] then Begin
                        idcredito := Copy(listSel.Strings[i], 10, 3);
                        TotalDeudaLinea(salida);
                        RupturaLinea(salida);
                        idanter[5] := Copy(listSel.Strings[i], 10, 3);
                      end;
                    end;
                    prestatario.getDatos(codprest);
                    if (salida = 'P') or (salida = 'I') then Begin
                      if lt then list.Linea(0, 0, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30) + ' - Tel.: ' + prestatario.Telefono + ' - ' + prestatario.localidad, 1, 'Arial, negrita, 8', salida, 'S') else
                        list.Linea(0, 0, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30) + '  (G.Judicial)', 1, 'Arial, negrita, 8', salida, 'S');
                    end;
                    if salida = 'T' then Begin
                      if lt then list.LineaTxt(codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30)+ ' - Tel.: ' + prestatario.Telefono + ' - ' + prestatario.localidad, True) else
                        list.LineaTxt(codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30) + '  (G.Judicial)', True);
                    end;
                    if salida = 'X' then begin
                      Inc(c1); l1 := Trim(IntToStr(c1));
                      if lt then excel.setString('a' + l1, 'a' + l1, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30), 'Arial, cursiva, 10') else
                        excel.setString('a' + l1, 'a' + l1, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30) + '  (G.Judicial)', 'Arial, cursiva, 10');
                      excel.setString('d' + l1, 'd' + l1, prestatario.localidad, 'Arial, cursiva, 10');
                      excel.setString('f' + l1, 'f' + l1, prestatario.Telefono, 'Arial, cursiva, 10');
                    end;

                    l := True;
                  end;
                  if not tc5 then ap := creditos_det.FieldByName('saldocuota').AsFloat * vindex else ap := ((monto * (tasaInteresFlotante * 0.01) / 12) * vindex) * StrToFloat(intervaloPG);
                  if (salida = 'P') or (salida = 'I') then Begin
                    list.Linea(0, 0, '         ' + utiles.sFormatoFecha(creditos_det.FieldByName('fechavto').AsString) + '  ' + creditos_det.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
                    if not tc5 then list.importe(65, list.Lineactual, '', creditos_det.FieldByName('amortizacion').AsFloat * vindex, 2, 'Arial, normal, 8') else list.importe(65, list.Lineactual, '', ap, 2, 'Arial, normal, 8');
                    list.importe(75, list.Lineactual, '', creditos_det.FieldByName('aporte').AsFloat * vindex, 3, 'Arial, normal, 8');
                    if not tc5 then  list.importe(85, list.Lineactual, '', creditos_det.FieldByName('total').AsFloat * vindex, 4, 'Arial, normal, 8') else list.importe(85, list.Lineactual, '', ap, 4, 'Arial, normal, 8');
                    list.importe(97, list.Lineactual, '', ap, 5, 'Arial, normal, 8');
                    list.Linea(97, list.Lineactual, ob, 6, 'Arial, normal, 8', salida, 'S');
                  end;
                  if salida = 'T' then Begin
                    list.LineaTxt('  ' + utiles.sFormatoFecha(creditos_det.FieldByName('fechavto').AsString) + '  ' + Copy(creditos_det.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_det.FieldByName('concepto').AsString)))), False);
                    if not tc5 then list.importeTxt(creditos_det.FieldByName('amortizacion').AsFloat * vindex, 11, 2, False) else list.importeTxt(ap, 11, 2, False);
                    list.importeTxt(creditos_det.FieldByName('aporte').AsFloat * vindex, 11, 2, False);
                    if not tc5 then list.importeTxt(creditos_det.FieldByName('total').AsFloat * vindex, 11, 2, False) else list.importeTxt(ap, 11, 2, False);
                    list.importeTxt(ap, 11, 2, False);
                    list.LineaTxt(ob, True);
                  end;
                  if salida = 'X' then Begin
                    Inc(c1); l1 := Trim(IntToStr(c1));
                    excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(creditos_det.FieldByName('fechavto').AsString), 'Arial, normal, 10');
                    excel.setString('b' + l1, 'b' + l1, creditos_det.FieldByName('concepto').AsString, 'Arial, normal, 10');
                    if not tc5 then excel.setReal('c' + l1, 'c' + l1, creditos_det.FieldByName('amortizacion').AsFloat * vindex, 'Arial, normal, 10') else excel.setReal('c' + l1, 'c' + l1, ap, 'Arial, normal, 10');
                    excel.setReal('d' + l1, 'd' + l1, creditos_det.FieldByName('aporte').AsFloat * vindex, 'Arial, normal, 10');
                    if not tc5 then  excel.setReal('e' + l1, 'e' + l1, creditos_det.FieldByName('total').AsFloat * vindex, 'Arial, normal, 10')  else excel.setReal('e' + l1, 'e' + l1, ap, 'Arial, normal, 10');
                    excel.setReal('f' + l1, 'f' + l1, ap, 'Arial, normal, 10');
                  End;

                  if not tc5 then totales[1] := totales[1] + (creditos_det.FieldByName('saldocuota').AsFloat* vindex) else totales[1] := totales[1] + ap;
                  if not tc5 then totales[2] := totales[2] + (creditos_det.FieldByName('amortizacion').AsFloat* vindex) else totales[2] := totales[2] + ap;
                  totales[3] := totales[3] + (creditos_det.FieldByName('aporte').AsFloat* vindex);
                  if not tc5 then totales[4] := totales[4] + (creditos_det.FieldByName('total').AsFloat* vindex) else totales[4] := totales[4] + ap;
                end;
              end;

            end else Begin

              // Listamos los que est�n en Gesti�n Judicial
              if (creditos_det.FieldByName('refinancia').AsString <> 'S') and (listaJudiciales) and (lt) then Begin

                if (creditos_det.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xfecha)) and (creditos_det.FieldByName('estado').AsString = 'I') and (creditos_det.FieldByName('tipomov').AsInteger = 1) then Begin
                  if not l then Begin
                    if disc_linea then Begin
                      if Copy(listSel.Strings[i], 10, 3) <> idanter[5] then Begin
                        idcredito := Copy(listSel.Strings[i], 10, 3);
                        TotalDeudaLinea(salida);
                        RupturaLinea(salida);
                        idanter[5] := Copy(listSel.Strings[i], 10, 3);
                      end;
                    end;
                    prestatario.getDatos(codprest);
                    if (salida = 'P') or (salida = 'I') then Begin
                      if not listaJudiciales then list.Linea(0, 0, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30), 1, 'Arial, negrita, 8', salida, 'S') else
                        list.Linea(0, 0, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30) + '  (G.Judicial)', 1, 'Arial, negrita, 8', salida, 'S');
                    end;
                    if salida = 'T' then Begin
                      if not listaJudiciales then list.LineaTxt(codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30), True) else
                        list.LineaTxt(codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30) + '  (G.Judicial)', True);
                    end;
                    if salida = 'X' then begin
                      Inc(c1); l1 := Trim(IntToStr(c1));
                      if not listaJudiciales then excel.setString('a' + l1, 'a' + l1, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30), 'Arial, cursiva, 10') else
                        excel.setString('a' + l1, 'a' + l1, codprest + '-' + expediente + '   ' + Copy(prestatario.nombre, 1, 30), 'Arial, cursiva, 10');
                      excel.setString('d' + l1, 'd' + l1, prestatario.localidad, 'Arial, cursiva, 10');
                      excel.setString('f' + l1, 'f' + l1, prestatario.Telefono, 'Arial, cursiva, 10');
                    end;
                    l := True;
                  end;
                  if not tc5 then ap := creditos_det.FieldByName('saldocuota').AsFloat * vindex else ap := ((monto * (tasaInteresFlotante * 0.01) / 12) * vindex) * StrToFloat(intervaloPG);
                  if (salida = 'P') or (salida = 'I') then Begin
                    list.Linea(0, 0, '         ' + utiles.sFormatoFecha(creditos_det.FieldByName('fechavto').AsString) + '  ' + creditos_det.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
                    if not tc5 then list.importe(65, list.Lineactual, '', creditos_det.FieldByName('amortizacion').AsFloat * vindex, 2, 'Arial, normal, 8') else list.importe(65, list.Lineactual, '', ap, 2, 'Arial, normal, 8');
                    list.importe(75, list.Lineactual, '', creditos_det.FieldByName('aporte').AsFloat * vindex, 3, 'Arial, normal, 8');
                    if not tc5 then  list.importe(85, list.Lineactual, '', creditos_det.FieldByName('total').AsFloat * vindex, 4, 'Arial, normal, 8') else list.importe(85, list.Lineactual, '', ap, 4, 'Arial, normal, 8');
                    list.importe(97, list.Lineactual, '', ap, 5, 'Arial, normal, 8');
                    list.Linea(97, list.Lineactual, ob, 6, 'Arial, normal, 8', salida, 'S');
                  end;
                  if salida = 'T' then Begin
                    list.LineaTxt('  ' + utiles.sFormatoFecha(creditos_det.FieldByName('fechavto').AsString) + '  ' + Copy(creditos_det.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_det.FieldByName('concepto').AsString)))), False);
                    if not tc5 then list.importeTxt(creditos_det.FieldByName('amortizacion').AsFloat * vindex, 11, 2, False) else list.importeTxt(ap, 11, 2, False);
                    list.importeTxt(creditos_det.FieldByName('aporte').AsFloat * vindex, 11, 2, False);
                    if not tc5 then list.importeTxt(creditos_det.FieldByName('total').AsFloat * vindex, 11, 2, False) else list.importeTxt(ap, 11, 2, False);
                    list.importeTxt(ap, 11, 2, False);
                    list.LineaTxt(ob, True);
                  end;
                  if salida = 'X' then begin
                    Inc(c1); l1 := Trim(IntToStr(c1));
                    excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(creditos_det.FieldByName('fechavto').AsString), 'Arial, normal, 10');
                    excel.setString('b' + l1, 'b' + l1, Copy(creditos_det.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_det.FieldByName('concepto').AsString)))), 'Arial, normal, 10');
                    if not tc5 then excel.setReal('c' + l1, 'c' + l1, creditos_det.FieldByName('amortizacion').AsFloat * vindex, 'Arial, negrita, 10') else excel.setReal('c' + l1, 'c' + l1, ap, 'Arial, normal, 10');
                    excel.setReal('d' + l1, 'd' + l1, creditos_det.FieldByName('aporte').AsFloat * vindex, 'Arial, negrita, 10');
                    if not tc5 then excel.setReal('e' + l1, 'e' + l1, creditos_det.FieldByName('total').AsFloat * vindex, 'Arial, negrita, 10') else excel.setReal('e' + l1, 'e' + l1, ap, 'Arial, normal, 10');
                    excel.setReal('e' + l1, 'e' + l1, ap, 'Arial, normal, 10');
                    excel.setString('f' + l1, 'f' + l1, ob, 'Arial, normal, 10');
                  end;
                  if not tc5 then totales[1] := totales[1] + (creditos_det.FieldByName('saldocuota').AsFloat* vindex) else totales[1] := totales[1] + ap;
                  if not tc5 then totales[2] := totales[2] + (creditos_det.FieldByName('amortizacion').AsFloat* vindex) else totales[2] := totales[2] + ap;
                  totales[3] := totales[3] + (creditos_det.FieldByName('aporte').AsFloat* vindex);
                  if not tc5 then totales[4] := totales[4] + (creditos_det.FieldByName('total').AsFloat* vindex) else totales[4] := totales[4] + ap;
                end;
              end;

              if Length(trim(detcred.FieldByName('fechapago').AsString)) = 0 then ld := True else
                if detcred.FieldByName('fechapago').AsString <= utiles.sExprFecha2000(xfecha) then ld := True;
                if ld then Begin
                  Inc(j);
                  //if j > 500 then utiles.msgError('Limite Exedido ...!');
                  if j > 500 then j := 1;
                  mov[j, 1] := utiles.sFormatoFecha(detcred.FieldByName('fechavto').AsString);
                  if detcred.FieldByName('codprest').AsString <> idanter[3] then Begin
                    prestatario.getDatos(detcred.FieldByName('codprest').AsString);
                    mov[j, 2] := prestatario.nombre;
                  end;
                  mov[j, 3] := detcred.FieldByName('concepto').AsString;
                  mov[j, 4] := utiles.FormatearNumero(FloatToStr(detcred.FieldByName('amortizacion').AsFloat * vindex));
                  if mc = 0 then mov[j, 5] := utiles.FormatearNumero(FloatToStr(detcred.FieldByName('aporte').AsFloat * vindex)) else
                    mov[j, 5] := utiles.FormatearNumero(FloatToStr(mc * vindex));
                  if mc = 0 then mov[j, 6] := utiles.FormatearNumero(FloatToStr(detcred.FieldByName('total').AsFloat * vindex)) else
                    mov[j, 6] := utiles.FormatearNumero(FloatToStr(mc * vindex));
                  mov[j, 7] := utiles.FormatearNumero(FloatToStr((mc + detcred.FieldByName('saldocuota').AsFloat) * vindex));
                  idanter[3] := detcred.FieldByName('codprest').AsString;

                end;
            end;
            creditos_det.Next;
          end;
          TotalDeuda(salida);
          l := False;
        end;
      end;
      datosdb.QuitarFiltro(creditos_det);

      { Creditos Refinanciados }
      if ref_c = 'S' then Begin

        l := False;
        if not creditos_detrefinanciados.Active then creditos_detrefinanciados.Open;
        creditos_detrefinanciados.IndexFieldNames := 'Codprest;Expediente;Fechavto;Items';
        datosdb.Filtrar(creditos_detrefinanciados, 'codprest = ' + '''' + Copy(listSel.Strings[i], 1, 5) + '''' + ' and expediente = ' + '''' + Copy(listSel.Strings[i], 6, 4) + '''' + ' and tipomov = 1' + ' and saldocuota > 0');

        if creditos_detrefinanciados.RecordCount > 0 then Begin

          while not creditos_detrefinanciados.Eof do Begin

            if creditos_detrefinanciados.FieldByName('refinancia').AsString <> 'S' then Begin

              if (creditos_detrefinanciados.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xfecha)) and (creditos_detrefinanciados.FieldByName('estado').AsString = 'I') and (creditos_detrefinanciados.FieldByName('tipomov').AsInteger = 1) then Begin

                mc := 0;
                if (creditos_cab.FieldByName('tipocalculo').AsString = '5') and (creditos_det.FieldByName('aporte').AsFloat + creditos_det.FieldByName('total').AsFloat  = 0) then Begin
                  credito.getDatos(creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString);
                  mc := (((credito.Monto * tasainteresFlotante) * 0.01) / 12);
                end;

                if not (l) and not (ViaJudicial) and not (listaJudiciales) then Begin
                  if not l then Begin
                    if disc_linea then Begin
                      if Copy(listSel.Strings[i], 10, 3) <> idanter[5] then Begin
                        idcredito := Copy(listSel.Strings[i], 10, 3);
                        TotalDeudaLinea(salida);
                        RupturaLinea(salida);
                        idanter[5] := Copy(listSel.Strings[i], 10, 3);
                      end;
                    end;

                    getDatos(creditos_detrefinanciados.FieldByName('codprest').AsString, creditos_detrefinanciados.FieldByName('expediente').AsString);
                    prestatario.getDatos(creditos_detrefinanciados.FieldByName('codprest').AsString);
                    if (salida = 'P') or (salida = 'I') then Begin
                      if lt then list.Linea(0, 0, creditos_detrefinanciados.FieldByName('codprest').AsString + '-' + creditos_detrefinanciados.FieldByName('expediente').AsString + '   ' + Copy(prestatario.nombre, 1, 30), 1, 'Arial, negrita, 8', salida, 'N') else
                        list.Linea(0, 0, creditos_detrefinanciados.FieldByName('codprest').AsString + '-' + creditos_detrefinanciados.FieldByName('expediente').AsString + '   ' + Copy(prestatario.nombre, 1, 30) + '  (G.Judicial)', 1, 'Arial, negrita, 8', salida, 'N');
                      list.Linea(50, list.Lineactual, '*** Cr�dito Refinanciado ***', 2, 'Arial, negrita, 8', salida, 'S');
                    end;
                    if salida = 'T' then Begin
                      if lt then list.LineaTxt(creditos_detrefinanciados.FieldByName('codprest').AsString + '-' + creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30), True) else
                        list.LineaTxt(creditos_detrefinanciados.FieldByName('codprest').AsString + '-' + creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30) + ' (G.Judicial)', True);
                      list.LineaTxt('*** Cr�dito Refinanciado ***', True);
                    end;
                    if salida = 'X' then begin
                      Inc(c1); l1 := Trim(IntToStr(c1));
                      excel.setString('a' + l1, 'a' + l1, '*** Cr�dito Refinanciado ***', 'Arial, negrita, 10');
                      Inc(c1); l1 := Trim(IntToStr(c1));
                      if lt then excel.setString('a' + l1, 'a' + l1, creditos_detrefinanciados.FieldByName('codprest').AsString + '-' + creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30), 'Arial, cursiva, 10') else
                        excel.setString('a' + l1, 'a' + l1, creditos_detrefinanciados.FieldByName('codprest').AsString + '-' + creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30) + ' (G.Judicial)', 'Arial, cursiva, 10');
                      excel.setString('d' + l1, 'd' + l1, prestatario.localidad, 'Arial, cursiva, 10');
                      excel.setString('f' + l1, 'f' + l1, prestatario.Telefono, 'Arial, cursiva, 10');
                    end;
                    l := True;
                  end;

                  if (salida = 'P') or (salida = 'I') then Begin
                    list.Linea(0, 0, '         ' + utiles.sFormatoFecha(creditos_detrefinanciados.FieldByName('fechavto').AsString) + '   ' + creditos_detrefinanciados.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
                    list.importe(65, list.Lineactual, '', creditos_detrefinanciados.FieldByName('amortizacion').AsFloat * vindex, 2, 'Arial, normal, 8');
                    list.importe(75, list.Lineactual, '', creditos_detrefinanciados.FieldByName('aporte').AsFloat * vindex, 3, 'Arial, normal, 8');
                    list.importe(85, list.Lineactual, '', creditos_detrefinanciados.FieldByName('total').AsFloat * vindex, 4, 'Arial, normal, 8');
                    list.importe(97, list.Lineactual, '', creditos_detrefinanciados.FieldByName('saldocuota').AsFloat * vindex, 5, 'Arial, normal, 8');
                    list.Linea(97, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
                  end;
                  if salida = 'T' then Begin
                    list.LineaTxt('  ' + utiles.sFormatoFecha(creditos_detrefinanciados.FieldByName('fechavto').AsString) + '  ' + Copy(creditos_detrefinanciados.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_detrefinanciados.FieldByName('concepto').AsString)))), False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('amortizacion').AsFloat * vindex, 11, 2, False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('aporte').AsFloat * vindex, 11, 2, False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('total').AsFloat * vindex, 11, 2, False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('saldocuota').AsFloat * vindex, 11, 2, True);
                  end;
                  if salida = 'X' then begin
                    Inc(c1); l1 := Trim(IntToStr(c1));
                    excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(creditos_detrefinanciados.FieldByName('fechavto').AsString), 'Arial, normal, 10');
                    excel.setString('b' + l1, 'b' + l1, Copy(creditos_detrefinanciados.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_detrefinanciados.FieldByName('concepto').AsString)))), 'Arial, normal, 10');
                    excel.setReal('c' + l1, 'c' + l1, creditos_detrefinanciados.FieldByName('amortizacion').AsFloat * vindex, 'Arial, normal, 10');
                    excel.setReal('d' + l1, 'd' + l1, creditos_detrefinanciados.FieldByName('aporte').AsFloat * vindex, 'Arial, normal, 10');
                    excel.setReal('e' + l1, 'e' + l1, creditos_detrefinanciados.FieldByName('total').AsFloat * vindex, 'Arial, normal, 10');
                    excel.setReal('f' + l1, 'f' + l1, creditos_detrefinanciados.FieldByName('saldocuota').AsFloat * vindex, 'Arial, normal, 10');
                  end;
                  totales[1] := totales[1] + (creditos_detrefinanciados.FieldByName('saldocuota').AsFloat* vindex);
                  totales[2] := totales[2] + (creditos_detrefinanciados.FieldByName('amortizacion').AsFloat* vindex);
                  totales[3] := totales[3] + (creditos_detrefinanciados.FieldByName('aporte').AsFloat* vindex);
                  totales[4] := totales[4] + (creditos_detrefinanciados.FieldByName('total').AsFloat* vindex);

                End;
              end;

              if listaJudiciales then Begin
                // -------------------------------------------------------------

                if (creditos_detrefinanciados.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xfecha)) and (creditos_detrefinanciados.FieldByName('estado').AsString = 'I') and (creditos_detrefinanciados.FieldByName('tipomov').AsInteger = 1) then Begin

                mc := 0;
                if (creditos_cab.FieldByName('tipocalculo').AsString = '5') and (creditos_det.FieldByName('aporte').AsFloat + creditos_det.FieldByName('total').AsFloat  = 0) then Begin
                  credito.getDatos(creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString);
                  mc := (((credito.Monto * tasainteresFlotante) * 0.01) / 12);
                end;

                if not (l) and (ViaJudicial) then Begin
                  if not l then Begin

                    if disc_linea then Begin
                      if Copy(listSel.Strings[i], 10, 3) <> idanter[5] then Begin
                        idcredito := Copy(listSel.Strings[i], 10, 3);
                        TotalDeudaLinea(salida);
                        RupturaLinea(salida);
                        idanter[5] := Copy(listSel.Strings[i], 10, 3);
                      end;
                    end;

                    getDatos(creditos_detrefinanciados.FieldByName('codprest').AsString, creditos_detrefinanciados.FieldByName('expediente').AsString);
                    prestatario.getDatos(creditos_detrefinanciados.FieldByName('codprest').AsString);
                    if (salida = 'P') or (salida = 'I') then Begin
                      if not listaJudiciales then list.Linea(0, 0, creditos_detrefinanciados.FieldByName('expediente').AsString + '   ' + Copy(prestatario.nombre, 1, 30), 1, 'Arial, negrita, 8', salida, 'N') else
                        list.Linea(0, 0, creditos_detrefinanciados.FieldByName('expediente').AsString + '   ' + Copy(prestatario.nombre, 1, 30) + '  (G.Judicial)', 1, 'Arial, negrita, 8', salida, 'N');
                      list.Linea(50, list.Lineactual, '*** Cr�dito Refinanciado ***', 2, 'Arial, negrita, 8', salida, 'S');
                    end;
                    if salida = 'T' then Begin
                      if not listaJudiciales then list.LineaTxt(creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30), True) else
                        list.LineaTxt(creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30) + ' (G.Judicial)', True);
                      list.LineaTxt('*** Cr�dito Refinanciado ***', True);
                    end;
                    if salida = 'X' then begin
                      Inc(c1); l1 := Trim(IntToStr(c1));
                      excel.setString('a' + l1, 'a' + l1, '*** Cr�dito Refinanciado ***', 'Arial, negrita, 10');
                      Inc(c1); l1 := Trim(IntToStr(c1));
                      if not listaJudiciales then excel.setString('a' + l1, 'a' + l1, creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30), 'Arial, cursiva, 10') else
                        excel.setString('a' + l1, 'a' + l1, creditos_detrefinanciados.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 30) + ' (G.Judicial)', 'Arial, cursiva, 10');
                      excel.setString('d' + l1, 'd' + l1, prestatario.localidad, 'Arial, cursiva, 10');
                      excel.setString('f' + l1, 'f' + l1, prestatario.Telefono, 'Arial, cursiva, 10');
                    end;
                    l := True;
                  end;
                  if (salida = 'P') or (salida = 'I') then Begin
                    list.Linea(0, 0, '         ' + utiles.sFormatoFecha(creditos_detrefinanciados.FieldByName('fechavto').AsString) + '   ' + creditos_detrefinanciados.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
                    list.importe(65, list.Lineactual, '', creditos_detrefinanciados.FieldByName('amortizacion').AsFloat * vindex, 2, 'Arial, normal, 8');
                    list.importe(75, list.Lineactual, '', creditos_detrefinanciados.FieldByName('aporte').AsFloat * vindex, 3, 'Arial, normal, 8');
                    list.importe(85, list.Lineactual, '', creditos_detrefinanciados.FieldByName('total').AsFloat * vindex, 4, 'Arial, normal, 8');
                    list.importe(97, list.Lineactual, '', creditos_detrefinanciados.FieldByName('saldocuota').AsFloat * vindex, 5, 'Arial, normal, 8');
                    list.Linea(97, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
                  end;
                  if salida = 'T' then Begin
                    list.LineaTxt('  ' + utiles.sFormatoFecha(creditos_detrefinanciados.FieldByName('fechavto').AsString) + '  ' + Copy(creditos_detrefinanciados.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_detrefinanciados.FieldByName('concepto').AsString)))), False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('amortizacion').AsFloat * vindex, 11, 2, False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('aporte').AsFloat * vindex, 11, 2, False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('total').AsFloat * vindex, 11, 2, False);
                    list.importeTxt(creditos_detrefinanciados.FieldByName('saldocuota').AsFloat * vindex, 11, 2, True);
                  end;
                  if salida = 'X' then begin
                    Inc(c1); l1 := Trim(IntToStr(c1));
                    excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(creditos_detrefinanciados.FieldByName('fechavto').AsString), 'Arial, normal, 10');
                    excel.setString('b' + l1, 'b' + l1, Copy(creditos_detrefinanciados.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_detrefinanciados.FieldByName('concepto').AsString)))), 'Arial, normal, 10');
                    excel.setReal('c' + l1, 'c' + l1, creditos_detrefinanciados.FieldByName('amortizacion').AsFloat * vindex, 'Arial, normal, 10');
                    excel.setReal('d' + l1, 'd' + l1, creditos_detrefinanciados.FieldByName('aporte').AsFloat * vindex, 'Arial, normal, 10');
                    excel.setReal('e' + l1, 'e' + l1, creditos_detrefinanciados.FieldByName('total').AsFloat * vindex, 'Arial, normal, 10');
                    excel.setReal('f' + l1, 'f' + l1, creditos_detrefinanciados.FieldByName('saldocuota').AsFloat * vindex, 'Arial, normal, 10');
                  end;
                  totales[1] := totales[1] + (creditos_detrefinanciados.FieldByName('saldocuota').AsFloat* vindex);
                  totales[2] := totales[2] + (creditos_detrefinanciados.FieldByName('amortizacion').AsFloat* vindex);
                  totales[3] := totales[3] + (creditos_detrefinanciados.FieldByName('aporte').AsFloat* vindex);
                  totales[4] := totales[4] + (creditos_detrefinanciados.FieldByName('total').AsFloat* vindex);
                end;
                end;

                //--------------------------------------------------------------

                if Length(trim(creditos_detrefinanciados.FieldByName('fechapago').AsString)) = 0 then ld := True else
                  if creditos_detrefinanciados.FieldByName('fechapago').AsString <= utiles.sExprFecha2000(xfecha) then ld := True;
                  if ld then Begin
                    Inc(j);
                    mov[j, 1] := utiles.sFormatoFecha(creditos_detrefinanciados.FieldByName('fechavto').AsString);
                    if creditos_detrefinanciados.FieldByName('codprest').AsString <> idanter[3] then Begin
                      prestatario.getDatos(creditos_detrefinanciados.FieldByName('codprest').AsString);
                      mov[j, 2] := prestatario.nombre;
                    end;
                    mov[j, 3] := creditos_detrefinanciados.FieldByName('concepto').AsString;
                    mov[j, 4] := utiles.FormatearNumero(FloatToStr(creditos_detrefinanciados.FieldByName('amortizacion').AsFloat * vindex));
                    if mc = 0 then mov[j, 5] := utiles.FormatearNumero(FloatToStr(creditos_detrefinanciados.FieldByName('aporte').AsFloat * vindex)) else
                      mov[j, 5] := utiles.FormatearNumero(FloatToStr(mc * vindex));
                    if mc = 0 then mov[j, 6] := utiles.FormatearNumero(FloatToStr(creditos_detrefinanciados.FieldByName('total').AsFloat * vindex)) else
                      mov[j, 6] := utiles.FormatearNumero(FloatToStr(mc * vindex));
                    mov[j, 7] := utiles.FormatearNumero(FloatToStr((mc + creditos_detrefinanciados.FieldByName('saldocuota').AsFloat) * vindex));
                    idanter[3] := creditos_detrefinanciados.FieldByName('codprest').AsString;
                  end;
              end;
            end;
            creditos_detrefinanciados.Next;
          end;
          TotalDeuda(salida);
          creditos_detrefinanciados.IndexFieldNames := 'Codprest;Expediente;Items;Recibo';
          l := False;
        end;
      end;

      { Creditos con Cuotas Refinanciadas }
      if ref_u = 'S' then Begin
        if not creditos_detrefcuotas.Active then creditos_detrefcuotas.Open;
        creditos_detrefcuotas.IndexFieldNames := 'Codprest;Expediente;Fechavto;Items';
        datosdb.Filtrar(creditos_detrefcuotas, 'codprest = ' + '''' + Copy(listSel.Strings[i], 1, 5) + '''' + ' and expediente = ' + '''' + Copy(listSel.Strings[i], 6, 4) + '''' + ' and tipomov = 1' + ' and saldocuota > 0');

        if creditos_detrefcuotas.RecordCount > 0 then Begin
          totales[1] := 0;
          while not creditos_detrefcuotas.Eof do Begin
            if creditos_detrefcuotas.FieldByName('refinancia').AsString <> 'S' then Begin
              if (creditos_detrefcuotas.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xfecha)) and (creditos_detrefcuotas.FieldByName('estado').AsString = 'I') and (creditos_detrefcuotas.FieldByName('tipomov').AsInteger = 1) then Begin

                mc := 0;
                ///if not datosdb.verificarSiExisteCampo(creditos_cabrefcuotas, 'tipocalculo') then utiles.msgError(creditos_cabrefcuotas.TableName + '   ' + creditos_cabrefcuotas.DatabaseName);
                ///if (creditos_cabrefcuotas.FieldByName('tipocalculo').AsString = '5') and (creditos_detrefcuotas.FieldByName('aporte').AsFloat + creditos_detrefcuotas.FieldByName('total').AsFloat  = 0) then Begin
                if (creditos_cab.FieldByName('tipocalculo').AsString = '5') and (creditos_detrefcuotas.FieldByName('aporte').AsFloat + creditos_detrefcuotas.FieldByName('total').AsFloat  = 0) then Begin
                  credito.getDatos(creditos_cabrefcuotas.FieldByName('codprest').AsString, creditos_cabrefcuotas.FieldByName('expediente').AsString);
                  mc := (((credito.Monto * tasainteresFlotante) * 0.01) / 12);
                end;

                if not ViaJudicial then Begin
                if not l then Begin

                  if disc_linea then Begin
                    if Copy(listSel.Strings[i], 10, 3) <> idanter[5] then Begin
                      idcredito := Copy(listSel.Strings[i], 10, 3);
                      TotalDeudaLinea(salida);
                      RupturaLinea(salida);
                      idanter[5] := Copy(listSel.Strings[i], 10, 3);
                    end;
                  end;

                  getDatos(creditos_detrefcuotas.FieldByName('codprest').AsString, creditos_detrefcuotas.FieldByName('expediente').AsString);
                  prestatario.getDatos(creditos_detrefcuotas.FieldByName('codprest').AsString);
                  if (salida = 'P') or (salida = 'I') then Begin
                    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
                    list.Linea(0, 0, '*** Cuotas Refinanciadas ***', 1, 'Arial, normal, 12', salida, 'S');
                    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
                  end;
                  if salida = 'T' then Begin
                    list.LineaTxt('', True);
                    list.LineaTxt('*** Cuotas Refinanciadas ***', True);
                    list.LineaTxt('', True);
                  end;
                  if salida = 'X' then begin
                    Inc(c1); l1 := Trim(IntToStr(c1));
                    excel.setString('a' + l1, 'a' + l1, '*** Cuotas Refinanciadas ***', 'Arial, negrita, 10');
                  end;
                  l := True;
                end;
                if (salida = 'P') or (salida = 'I') then Begin
                  list.Linea(0, 0, '         ' + utiles.sFormatoFecha(creditos_detrefcuotas.FieldByName('fechavto').AsString) + '   ' + creditos_detrefcuotas.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
                  list.importe(65, list.Lineactual, '', creditos_detrefcuotas.FieldByName('amortizacion').AsFloat * vindex, 2, 'Arial, normal, 8');
                  list.importe(75, list.Lineactual, '', creditos_detrefcuotas.FieldByName('aporte').AsFloat * vindex, 3, 'Arial, normal, 8');
                  list.importe(85, list.Lineactual, '', creditos_detrefcuotas.FieldByName('total').AsFloat * vindex, 4, 'Arial, normal, 8');
                  list.importe(97, list.Lineactual, '', creditos_detrefcuotas.FieldByName('saldocuota').AsFloat * vindex, 5, 'Arial, normal, 8');
                  list.Linea(97, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
                end;
                if salida = 'T' then Begin
                  list.LineaTxt('  ' + utiles.sFormatoFecha(creditos_detrefcuotas.FieldByName('fechavto').AsString) + '  ' + Copy(creditos_detrefcuotas.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_detrefcuotas.FieldByName('concepto').AsString)))), False);
                  list.importeTxt(creditos_detrefcuotas.FieldByName('amortizacion').AsFloat * vindex, 11, 2, False);
                  list.importeTxt(creditos_detrefcuotas.FieldByName('aporte').AsFloat * vindex, 11, 2, False);
                  list.importeTxt(creditos_detrefcuotas.FieldByName('total').AsFloat * vindex, 11, 2, False);
                  list.importeTxt(creditos_detrefcuotas.FieldByName('saldocuota').AsFloat * vindex, 11, 2, True);
                end;
                if salida = 'X' then begin
                  Inc(c1); l1 := Trim(IntToStr(c1));
                  excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(creditos_detrefcuotas.FieldByName('fechavto').AsString), 'Arial, normal, 10');
                  excel.setString('b' + l1, 'b' + l1, Copy(creditos_detrefcuotas.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(24 - (Length(TrimRight(creditos_detrefcuotas.FieldByName('concepto').AsString)))), 'Arial, normal, 10');
                  excel.setReal('c' + l1, 'c' + l1, creditos_detrefcuotas.FieldByName('amortizacion').AsFloat * vindex, 'Arial, normal, 10');
                  excel.setReal('d' + l1, 'd' + l1, creditos_detrefcuotas.FieldByName('aporte').AsFloat * vindex, 'Arial, normal, 10');
                  excel.setReal('e' + l1, 'e' + l1, creditos_detrefcuotas.FieldByName('total').AsFloat * vindex, 'Arial, normal, 10');
                  excel.setReal('f' + l1, 'f' + l1, creditos_detrefcuotas.FieldByName('saldocuota').AsFloat * vindex, 'Arial, normal, 10');
                end;
                totales[1] := totales[1] + (creditos_detrefcuotas.FieldByName('saldocuota').AsFloat* vindex);
                totales[2] := totales[2] + (creditos_detrefcuotas.FieldByName('amortizacion').AsFloat* vindex);
                totales[3] := totales[3] + (creditos_detrefcuotas.FieldByName('aporte').AsFloat* vindex);
                totales[4] := totales[4] + (creditos_detrefcuotas.FieldByName('total').AsFloat* vindex);
                end else Begin
                  if Length(trim(creditos_detrefcuotas.FieldByName('fechapago').AsString)) = 0 then ld := True else
                    if creditos_detrefcuotas.FieldByName('fechapago').AsString <= utiles.sExprFecha2000(xfecha) then ld := True;
                    if ld then Begin
                      Inc(j);
                      mov[j, 1] := utiles.sFormatoFecha(creditos_detrefcuotas.FieldByName('fechavto').AsString);
                      if creditos_detrefcuotas.FieldByName('codprest').AsString <> idanter[3] then Begin
                        prestatario.getDatos(creditos_detrefcuotas.FieldByName('codprest').AsString);
                        mov[j, 2] := prestatario.nombre;
                      end;
                      mov[j, 3] := creditos_detrefcuotas.FieldByName('concepto').AsString;
                      mov[j, 4] := utiles.FormatearNumero(FloatToStr(creditos_detrefcuotas.FieldByName('amortizacion').AsFloat * vindex));
                      if mc = 0 then mov[j, 5] := utiles.FormatearNumero(FloatToStr(creditos_detrefcuotas.FieldByName('aporte').AsFloat * vindex)) else
                        mov[j, 5] := utiles.FormatearNumero(FloatToStr(mc * vindex));
                      if mc = 0 then mov[j, 6] := utiles.FormatearNumero(FloatToStr(creditos_detrefcuotas.FieldByName('total').AsFloat * vindex)) else
                        mov[j, 6] := utiles.FormatearNumero(FloatToStr(mc * vindex));
                      mov[j, 7] := utiles.FormatearNumero(FloatToStr((mc + creditos_detrefcuotas.FieldByName('saldocuota').AsFloat) * vindex));
                      idanter[3] := creditos_detrefcuotas.FieldByName('codprest').AsString;
                    end;
                end;
              end;
            end;
            creditos_detrefcuotas.Next;
          end;
          TotalDeuda(salida);
          datosdb.QuitarFiltro(creditos_detrefcuotas);
          creditos_detrefcuotas.IndexFieldNames := 'Codprest;Expediente;Items;Recibo';
          l := False;
        end;
      end;
      creditos_det.IndexFieldNames := 'Codprest;Expediente;Items;Recibo';
    end;
  end;

  if disc_linea then TotalDeudaLinea(salida);

  if totgral[5] + totgral[6] + totgral[7] + totgral[8] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(65, list.Lineactual, '', totgral[5], 2, 'Arial, negrita, 9');
      list.importe(75, list.Lineactual, '', totgral[6], 3, 'Arial, negrita, 9');
      list.importe(85, list.Lineactual, '', totgral[7], 4, 'Arial, negrita, 9');
      list.importe(97, list.Lineactual, '', totgral[8], 5, 'Arial, negrita, 9');
      list.Linea(97, list.Lineactual, '', 6, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5, clBlue', salida, 'S');
      list.Linea(0, 0, '* Tasa Inter�s Flot.: ' + FloatToStr(tasaInteresFlotante) + ' %', 1, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt('', True);
      list.LineaTxt('TOTAL GENERAL:' + utiles.espacios(36 - (Length(TrimRight('TOTAL GENERAL:')))), False);
      list.importeTxt(totgral[5], 11, 2, False);
      list.importeTxt(totgral[6], 11, 2, False);
      list.importeTxt(totgral[7], 11, 2, False);
      list.importeTxt(totgral[8], 11, 2, False);
      list.LineaTxt('', True);
      list.LineaTxt('* Tasa Inter�s Flot.: ' + FloatToStr(tasaInteresFlotante) + ' %', True);
      List.LineaTxt('================================================================================', True);
      list.LineaTxt('', True);
    end;
    if salida = 'X' then begin
      Inc(c1); Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL GENERAL:', 'Arial, negrita, 10');
      excel.setReal('c' + l1, 'c' + l1, totgral[5], 'Arial, negrita, 10');
      excel.setReal('d' + l1, 'd' + l1, totgral[6], 'Arial, negrita, 10');
      excel.setReal('e' + l1, 'e' + l1, totgral[7], 'Arial, negrita, 10');
      excel.setReal('f' + l1, 'f' + l1, totgral[8], 'Arial, negrita, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '* Tasa Inter�s Flot.: ' + FloatToStr(tasaInteresFlotante) + ' %', 'Arial, negrita, 10');
      excel.setString('a2', 'a2', '', 'Arial, negrita, 10');
    end;

    total_fin := 0;
  end else
    list.Linea(0, 0, 'No hay datos para Listar', 1, 'Arial, normal, 9', salida, 'S');
  IniciarArreglosGenerales;

  datosdb.closeDB(totales_lineas);

  if salida = 'X' then excel.Visulizar;
end;

procedure TTCreditos.TotalDeuda(salida: char);
// Objetivo...: listar total adeudado
Begin
  if totales [1] > 0 then Begin
    list.Linea(0, 0, 'Total Adeudado:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(65, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 8');
    list.importe(75, list.Lineactual, '', totales[3], 3, 'Arial, negrita, 8');
    list.importe(85, list.Lineactual, '', totales[4], 4, 'Arial, negrita, 8');
    list.importe(97, list.Lineactual, '', totales[1], 5, 'Arial, negrita, 8');
    list.Linea(97, list.Lineactual, '', 6, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    total_fin := total_fin + totales[1];
    totgral[1] := totgral[1] + totales[2];
    totgral[2] := totgral[2] + totales[3];
    totgral[3] := totgral[3] + totales[4];
    totgral[4] := totgral[4] + totales[1];
  end;
end;

procedure TTCreditos.TotalDeudaLinea(salida: char);
// Objetivo...: listar total adeudado
Begin
  if totgral[1] + totgral[2] + totgral[3] + totgral[4] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Total Adeudado ' + categoria.Descrip + ':', 1, fuente, salida, 'N');
      list.importe(65, list.Lineactual, '', totgral[1], 2, fuente);
      list.importe(75, list.Lineactual, '', totgral[2], 3, fuente);
      list.importe(85, list.Lineactual, '', totgral[3], 4, fuente);
      list.importe(97, list.Lineactual, '', totgral[4], 5, fuente);
      list.Linea(97, list.Lineactual, '', 6, fuente, salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    end;
    if salida = 'T' then Begin
      list.LineaTxt('', True);
      list.LineaTxt('Total Adeudado ' + categoria.Descrip + ':' + utiles.espacios(36 - (Length(TrimRight('Total Adeudado ' + categoria.Descrip + ':')))), False);
      list.importeTxt(totgral[1], 11, 2, False);
      list.importeTxt(totgral[2], 11, 2, False);
      list.importeTxt(totgral[3], 11, 2, False);
      list.importeTxt(totgral[4], 11, 2, True);
      list.LineaTxt('', True);
      list.LineaTxt('--------------------------------------------------------------------------------', True);
      list.LineaTxt('', True);
    end;
    if salida = 'X' then begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Total Adeudado ' + categoria.Descrip + ':', 'Arial, negrita, 10');
      excel.setReal('c' + l1, 'c' + l1, totgral[1], 'Arial, negrita, 10');
      excel.setReal('d' + l1, 'd' + l1, totgral[2], 'Arial, negrita, 10');
      excel.setReal('e' + l1, 'e' + l1, totgral[3], 'Arial, negrita, 10');
      excel.setReal('f' + l1, 'f' + l1, totgral[4], 'Arial, negrita, 10');
    end;

    tfinal.Add(categoria.Items + FloatToStr(totgral[4]));

    if (datosdb.Buscar(totales_lineas, 'idlinea', categoria.Items)) then totales_lineas.edit else totales_lineas.append;
    totales_lineas.FieldByName('idlinea').AsString := categoria.Items;
    totales_lineas.FieldByName('total1').AsFloat   := totgral[4];
    totales_lineas.Post;

    totgral[5] := totgral[5] + totgral[1];
    totgral[6] := totgral[6] + totgral[2];
    totgral[7] := totgral[7] + totgral[3];
    totgral[8] := totgral[8] + totgral[4];
    totgral[1] := 0; totgral[2] := 0; totgral[3] := 0; totgral[4] := 0;
  end;
end;

{-------------------------------------------------------------------------------}

//------------------------------------------------------------------------------
procedure TTCreditos.ListarMontosACobrarBanco(xlocalidad: TStringList; xdfecha, xhfecha: String; salida: Char);
// Objetivo...: Listar Montos Cobrados por el Banco

procedure Listar(xestadocredito: String; xlocalidad: TStringList; salida: char);
var
  i, j: Integer;
  mc: Real;
  lc: Boolean;
Begin
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  list.Linea(0, 0, xestadocredito, 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

  rsql.Open;
  for i := 1 to xlocalidad.Count do Begin
     rsql.First; j := 0; idanter[1] := '';
     while not rsql.Eof do Begin
       prestatario.getDatos(rsql.FieldByName('codprest').AsString);
       if (Copy(xlocalidad.Strings[i-1] , 1, 4) = prestatario.codpost) and (Copy(xlocalidad.Strings[i-1], 5, 3) = prestatario.orden) and
         (Length(Trim(rsql.FieldByName('refcredito').AsString)) = 0) and (Length(Trim(rsql.FieldByName('cuotasref').AsString)) = 0) then Begin

         // Tratamiento de cr�ditos con tipo de calculo 5, tasa flotante
         lc := True;
         if ((rsql.FieldByName('tipocalculo').AsString <> '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('saldocuota').AsFloat = 0) then lc := False;
         if ((rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('saldocuota').AsFloat = 0) then lc := True;

         getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);
         if not ExpresarEnPesos then vindex := Indice_credito else vindex := 1;
         if vindex = 0 then vindex := 1;

         // Determinamos el tipo de indice a ultilizar para el c�lculo
         if {(Length(Trim(indicecalculo)) = 0) and} (Indice_credito <> 0) then Begin  // Solo afectamos a los que tienen indice
           vindex       := categoria.setIndice(rsql.FieldByName('idcredito').AsString, utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString));
           monto_indice := vindex;
           if vindex = 0 then Begin  // Si no se puede rastrear indice, asumimos el indice original
             vindex       := Indice_credito;
             monto_indice := Indice_credito;
           end;
         end;

         mc := 0;
         if ((rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('aporte').AsFloat + rsql.FieldByName('total').AsFloat  = 0) then Begin
            mc := (((credito.Monto * tasainteresFlotante) * 0.01) / 12);
         end;
         if ((rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('aporte').AsFloat + rsql.FieldByName('total').AsFloat  > 0) then Begin
            mc := ((rsql.FieldByName('saldo').AsFloat + rsql.FieldByName('total').AsFloat) * ((tasainteresFlotante * 0.01) / 12)) * StrToFloat(credito.Formapago);
         end;

         if j = 0 then Begin
           cpost.getDatos(prestatario.codpost, prestatario.orden);
           if i > 1 then Begin
             list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
             list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'S');
           end;
           list.Linea(0, 0, 'Localidad: ' + cpost.localidad, 1, 'Arial, negrita, 10', salida, 'S');
           list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
           j := 1;
         end;

         if rsql.FieldByName('idcredito').AsString <> idanter[1] then Begin
           categoria.getDatos(rsql.FieldByName('idcredito').AsString);
           list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
           list.Linea(0, 0, 'Linea de Cr�dito: ' + categoria.Descrip, 1, 'Arial, negrita, 9', salida, 'S');
           list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
           idanter[1] := rsql.FieldByName('idcredito').AsString;
         end;

         list.Linea(0, 0, ' ' + utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString), 1, 'Arial, normal, 8', salida, 'N');
         list.Linea(8, list.Lineactual, rsql.FieldByName('codprest').AsString + '-' + rsql.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 17), 2, 'Arial, normal, 8', salida, 'N');
         list.Linea(36, list.Lineactual, rsql.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
         if monto_indice = 0 then list.importe(55, list.Lineactual, '####.####', monto_indice, 4, 'Arial, normal, 8') else
           list.importe(55, list.Lineactual, '###0.0000', monto_indice, 4, 'Arial, normal, 8');
         list.importe(65, list.Lineactual, '', rsql.FieldByName('amortizacion').AsFloat * vindex, 5, 'Arial, normal, 8');
         if mc = 0 then list.importe(75, list.Lineactual, '', rsql.FieldByName('aporte').AsFloat * vindex, 6, 'Arial, normal, 8') else
           list.importe(75, list.Lineactual, '', mc * vindex, 6, 'Arial, normal, 8');
         if mc = 0 then list.importe(85, list.Lineactual, '', rsql.FieldByName('total').AsFloat * vindex, 7, 'Arial, normal, 8') else
           list.importe(85, list.Lineactual, '', (rsql.FieldByName('total').AsFloat + mc) * vindex, 7, 'Arial, normal, 8');
         if mc = 0 then list.importe(97, list.Lineactual, '', (mc + rsql.FieldByName('saldocuota').AsFloat) * vindex, 8, 'Arial, normal, 8') else
           list.importe(97, list.Lineactual, '', (rsql.FieldByName('saldocuota').AsFloat + mc) * vindex, 8, 'Arial, normal, 8');
         list.Linea(97, list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
       end;
       rsql.Next;
     end;
  end;
  rsql.Close; rsql.Free;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
end;

Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Montos a Cobrar en el Lapso ' + xdfecha + ' al ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha Vto.', 1, 'Arial, cursiva, 8');
  List.Titulo(9, list.Lineactual, 'Prestatario', 2, 'Arial, cursiva, 8');
  List.Titulo(35, list.Lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, 'Indice', 4, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'Capital', 5, 'Arial, cursiva, 8');
  List.Titulo(70, list.Lineactual, 'Aporte', 6, 'Arial, cursiva, 8');
  List.Titulo(80, list.Lineactual, 'Total', 7, 'Arial, cursiva, 8');
  List.Titulo(92, list.Lineactual, 'Saldo', 8, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  IniciarArreglos;
  rsql := datosdb.tranSQL('select creditos_det.*, creditos_cab.idcredito, creditos_cab.tipocalculo, creditos_cab.fecha as fechaotorgado from creditos_det, creditos_cab where '+
                          'creditos_det.codprest = creditos_cab.codprest and creditos_det.expediente = creditos_cab.expediente and ' +
                          'creditos_det.fechavto >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and creditos_det.fechavto <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' +
                          ' and creditos_det.estado = ' + '''' + 'I' + '''' + ' order by idcredito, fechavto, items');

  Listar('*** Cr�ditos en Curso ***', xlocalidad, salida);

  rsql := datosdb.tranSQL('select creditos_detrefinanciados.*, creditos_cabrefinanciados.idcredito, creditos_cabrefinanciados.tipocalculo, creditos_cabrefinanciados.fecha as fechaotorgado from creditos_detrefinanciados, creditos_cabrefinanciados where '+
                          'creditos_detrefinanciados.codprest = creditos_cabrefinanciados.codprest and creditos_detrefinanciados.expediente = creditos_cabrefinanciados.expediente and ' +
                          'creditos_detrefinanciados.fechavto >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and creditos_detrefinanciados.fechavto <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' +
                          ' and creditos_detrefinanciados.estado = ' + '''' + 'I' + '''' + ' order by idcredito, fechavto, items');

  Listar('*** Cr�ditos Refinanciados ***', xlocalidad, salida);

  rsql := datosdb.tranSQL('select creditos_detrefcuotas.*, creditos_cabrefcuotas.idcredito, creditos_cabrefcuotas.tipocalculo, creditos_cabrefcuotas.fecha as fechaotorgado from creditos_detrefcuotas, creditos_cabrefcuotas where '+
                          'creditos_detrefcuotas.codprest = creditos_cabrefcuotas.codprest and creditos_detrefcuotas.expediente = creditos_cabrefcuotas.expediente and ' +
                          'creditos_detrefcuotas.fechavto >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and creditos_detrefcuotas.fechavto <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' +
                          ' and creditos_detrefcuotas.estado = ' + '''' + 'I' + '''' + ' order by idcredito, fechavto, items');

  Listar('*** Cr�ditos con Cuotas Refinanciadas ***', xlocalidad, salida);

  list.FinList;
end;

//------------------------------------------------------------------------------

procedure TTCreditos.ListarMontosACobrar(listSel: TStringList; xdfecha, xhfecha, xcp, xorden: String; xjudiciales: Boolean; salida: Char);
// Objetivo...: Montos a Cobrar en el Mes
Begin
  list.IniciarTitulos; listdat := False;
  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Montos a Cobrar en el Lapso ' + xdfecha + ' al ' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    if not listResumen then Begin
      List.Titulo(0, 0, 'Fecha Vto.', 1, 'Arial, cursiva, 8');
      List.Titulo(9, list.Lineactual, 'Prestatario', 2, 'Arial, cursiva, 8');
      List.Titulo(35, list.Lineactual, 'Concepto', 3, 'Arial, cursiva, 8');
    end else Begin
      List.Titulo(0, 0, 'Linea de Cr�dito', 1, 'Arial, cursiva, 8');
      List.Titulo(9, list.Lineactual, '', 2, 'Arial, cursiva, 8');
      List.Titulo(35, list.Lineactual, '', 3, 'Arial, cursiva, 8');
    end;
    List.Titulo(50, list.Lineactual, 'Indice', 4, 'Arial, cursiva, 8');
    List.Titulo(60, list.Lineactual, 'Capital', 5, 'Arial, cursiva, 8');
    List.Titulo(70, list.Lineactual, 'Aporte', 6, 'Arial, cursiva, 8');
    List.Titulo(80, list.Lineactual, 'Total', 7, 'Arial, cursiva, 8');
    List.Titulo(92, list.Lineactual, 'Saldo', 8, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
    IniciarInforme(salida);
  end else Begin
    IniciarInforme(salida);
    list.LineaTxt('', True);
    List.LineaTxt(' Montos a Cobrar en el Lapso ' + xdfecha + ' al ' + xhfecha, True);
    List.LineaTxt(' ', True);
    if not listResumen then
      List.LineaTxt('Fecha Vto.  Prestatario     Concepto       Capital    Aporte     Total     Saldo', True)
    else
      List.LineaTxt('Linea de Credito                           Capital    Aporte     Total     Saldo', True);
    List.LineaTxt('--------------------------------------------------------------------------------', True);
    List.LineaTxt('', True);
  end;
 
  if Length(Trim(xcp)) > 0 then Begin
    cpost.getDatos(xcp, xorden);
    if salida <> 'T' then Begin
      list.Linea(0, 0, '  Localidad: ' + xcp + '-' + xorden + '   ' + cpost.localidad, 1, 'Arial, normal, 12', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else
      list.LineaTxt('Localidad: ' + xcp + '-' + xorden + '   ' + cpost.localidad, True);
  end;

  IniciarArreglos;
  totales[2] := 0;

  rsql := datosdb.tranSQL('select creditos_det.*, creditos_cab.idcredito, creditos_cab.tipocalculo, creditos_cab.fecha as fechaotorgado, creditos.idlinea from creditos_det, creditos_cab, creditos where '+
                          'creditos_det.codprest = creditos_cab.codprest and creditos_det.expediente = creditos_cab.expediente and creditos_cab.idcredito = creditos.items and saldocuota >= 0 order by idlinea, idcredito, codprest, expediente, fechavto');

  nroItems := 0;
  ListMontosACobrar(listsel, xdfecha, xhfecha, '', xcp, xorden, xjudiciales, salida);
  if listResumen then Begin
    ListarTotalEstadosCreditos(salida);
    ListarCreditosEnGestionJudicial(salida);
  end;

  idanter[14] := ' - Creditos Refinanciados';
  if listResumen then
    if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S') else list.LineaTxt('', True);

  rsql := datosdb.tranSQL('select creditos_detrefinanciados.*, creditos_cabrefinanciados.idcredito, creditos_cabrefinanciados.tipocalculo, creditos_cabrefinanciados.fecha as fechaotorgado, creditos.idlinea from creditos_detrefinanciados, creditos_cabrefinanciados, creditos ' +
                          ' where creditos_detrefinanciados.codprest = creditos_cabrefinanciados.codprest ' +
                          ' and creditos_detrefinanciados.expediente = creditos_cabrefinanciados.expediente and creditos_cabrefinanciados.idcredito = creditos.items and fechavto >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fechavto <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and saldocuota > 0 order by idlinea, idcredito, codprest, expediente, fechavto');
  ListMontosACobrar(listsel, xdfecha, xhfecha, '*** Cr�ditos Refinanciados ***', xcp, xorden, xjudiciales, salida);
  if listResumen then Begin
    ListarTotalEstadosCreditos(salida);
    ListarCreditosEnGestionJudicial(salida);
  end;

  idanter[14] := ' - Cuotas Refinanciadas';
  if listResumen then
    if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S') else list.LineaTxt('', True);
  rsql := datosdb.tranSQL('select creditos_detrefcuotas.*, creditos_cabrefcuotas.idcredito, creditos_cabrefcuotas.tipocalculo, creditos_cabrefcuotas.fecha as fechaotorgado, creditos.idlinea from creditos_detrefcuotas, creditos_cabrefcuotas, creditos '+
                          'where creditos_detrefcuotas.codprest = creditos_cabrefcuotas.codprest and ' +
                          ' creditos_detrefcuotas.expediente = creditos_cabrefcuotas.expediente and creditos_cabrefcuotas.idcredito = creditos.items and fechavto >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fechavto <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and saldocuota > 0 order by idlinea, idcredito, codprest, expediente, fechavto');
  ListMontosACobrar(listsel, xdfecha, xhfecha, '*** Cuotas Refinanciadas ***', xcp, xorden, xjudiciales, salida);
  if listResumen then Begin
    ListarTotalEstadosCreditos(salida);
    ListarCreditosEnGestionJudicial(salida);
  end;

  if listResumen then list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');

  if totgral[4] > 0 then Begin
    if tasaInteresFlotante > 0 then Begin
      if salida <> 'T' then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Tasa Interes Flot.: ' + FloatToStr(tasaInteresFlotante) + ' %', 1, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end else Begin
        list.LineaTxt('', True);
        list.LineaTxt('Tasa Interes Flot.: ' + FloatToStr(tasaInteresFlotante) + ' %', True);
        list.LineaTxt('', True);
      end;
    end;

    if salida <> 'T' then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(50, list.Lineactual, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(65, list.Lineactual, '', totgral[1], 2, 'Arial, negrita, 9');
      list.importe(75, list.Lineactual, '', totgral[2], 3, 'Arial, negrita, 9');
      list.importe(85, list.Lineactual, '', totgral[3], 4, 'Arial, negrita, 9');
      list.importe(97, list.Lineactual, '', totgral[4], 5, 'Arial, negrita, 9');
      list.Linea(97, list.Lineactual, '', 6, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt('', True);
      list.LineaTxt('TOTAL GENERAL:' + utiles.espacios(40 - (Length(TrimRight('TOTAL GENERAL:')))), False);
      list.importeTxt(totgral[1], 10, 2, False);
      list.importeTxt(totgral[2], 10, 2, False);
      list.importeTxt(totgral[3], 10, 2, False);
      list.importeTxt(totgral[4], 10, 2, True);
      list.LineaTxt('', True);
      List.LineaTxt('================================================================================', True);
    end;

    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    //ListarCreditosJJ(salida);
  end;

  IniciarArreglosGenerales;

  if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
end;

procedure TTCreditos.ListMontosACobrar(listSel: TStringList; xdfecha, xhfecha, xcriterio, xcp, xorden: String; xjudiciales: Boolean; salida: Char);
var
  l, ld, lc, vj, llj, listlinea, existmov, tc5: Boolean;
  lst: TStringList;
  j, i: Integer;
  mc: Real;
Begin
//  if expresarenpesos then utiles.msgError('pesos');

  rsql.Open;
  idanter[1] := ''; idanter[2] := ''; idanter[4] := ''; totales[1] := 0; i := 0; idanter[3] := '';
  if listSel = Nil then lst := Nil else Begin
    lst := TStringList.Create;
    for j := 1 to listSel.Count do lst.Add(Copy(listSel.Strings[j-1], 1, 9));
  end;

  while not rsql.Eof do Begin
    ld := False;   // Flag para las fechas de pago
    if Length(trim(rsql.FieldByName('fechapago').AsString)) = 0 then Begin
      if (rsql.FieldByName('fechavto').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xhfecha)) then ld := True;
    end else Begin
      if (rsql.FieldByName('fechapago').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fechapago').AsString <= utiles.sExprFecha2000(xhfecha)) then ld := True;
    end;

    // Creditos otorgados antes de la fecha de cierre del ejercicio
    if ld then Begin
      getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);
      if utiles.sExprFecha2000(credito.Fecha) <= utiles.sExprFecha2000(xhfecha) then ld := True else Begin
        ld := False;
        //utiles.msgError(rsql.FieldByName('codprest').AsString + '   ' + rsql.FieldByName('expediente').AsString);
      end;
    end;

    if ld then
      if Length(Trim(xcp)) > 0 then Begin
        prestatario.getDatos(rsql.FieldByName('codprest').AsString);
        if (prestatario.codpost = xcp) and (prestatario.orden = xorden) then ld := True else ld := False;
      end;

    // Tratamiento de cr�ditos con tipo de calculo 5, tasa flotante
    lc := True;
    if ((rsql.FieldByName('tipocalculo').AsString <> '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('saldocuota').AsFloat = 0) then lc := False;
    if ((rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) or (rsql.FieldByName('tipocalculo').AsString = 'B') and (rsql.FieldByName('saldocuota').AsFloat = 0) then lc := True;

    if (ld) and (lc) and (utiles.verificarItemsLista(lst, rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString)) then Begin
      getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);

      if vindex = 0 then vindex := 1;

      // Determinamos el tipo de indice a ultilizar para el c�lculo
      if (Length(Trim(indicecalculo)) = 0) and (Indice_credito <> 0) then Begin  // Solo afectamos a los que tienen indice
        vindex       := categoria.setIndice(rsql.FieldByName('idcredito').AsString, utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString));
        monto_indice := vindex;
        if vindex = 0 then Begin  // Si no se puede rastrear indice, asumimos el indice original
          vindex       := Indice_credito;
          monto_indice := Indice_credito;
        end;
      end;

      if Length(Trim(indicecalculo)) > 0 then Begin
        vindex       := categoria.setIndice(indicecalculo, utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString));
        monto_indice := vindex;
      end;

      if Indice_credito = 0 then monto_indice := 0;

      if indice_credito > vindex then Begin
        vindex       := indice_credito;
        monto_indice := indice_credito;
      end;

      if ExpresarEnPesos then vindex := Indice_credito else vindex := 1;

      // Tratamiento de cr�ditos con tipo de calculo 5, tasa flotante, para prorrateo de indice flotante
      tc5 := false;
      if (rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B') then Begin
        //monto_indice        := categoria.setIndiceTC('5', utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString));
        monto_indice        := credito.Aporte;  // 02/09/2008
        tasaInteresFlotante := monto_indice;
        tc5 := true;
      end;

      if vindex = 0 then vindex := 1;

      if (rsql.FieldByName('refinancia').AsString <> 'S') and (rsql.FieldByName('refcredito').AsString <> 'S') then Begin
        if rsql.FieldByName('estado').AsString = 'I' then Begin
           if rsql.FieldByName('idcredito').AsString <> idanter[1] then Begin

             if not listResumen then
               if (Length(Trim(xcriterio)) > 0) and (rsql.RecordCount > 0) and not (l) then Begin
                 if salida <> 'T' then Begin
                   list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
                   list.Linea(0, 0, xcriterio, 1, 'Arial, normal, 12', salida, 'S');
                   list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
                 end else Begin
                   list.LineaTxt('', True);
                   list.LineaTxt(xcriterio, True);
                   list.LineaTxt('', True);
                 end;

                 l := True;
                 idanter[1] := '';
               end;

             if existmov then
               if totales[4] > 0 then Begin
                 TotalLineaACobrar(salida);
                 totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0;
                 totales[9] := 0; totales[10] := 0; totales[11] := 0; totales[12] := 0;
               end;
             listlinea := True;
             existmov  := False;
           end;

        idanter[1]  := rsql.FieldByName('idcredito').AsString;

        vj := False;
        prestatario.getDatos(rsql.FieldByName('codprest').AsString);
        if (rsql.FieldByName('codprest').AsString <> idanter[2]) then Begin
          idanter[3] := Copy(prestatario.nombre, 1, 20);
          if credito.ViaJudicial then Begin
            idanter[3] := idanter[3] + ' - G.Jud.';
            vj := True; Inc(i);
          end;
        end else
          idanter[3] := '';

        mc := 0;
        credito.getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);
        if ((rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('aporte').AsFloat + rsql.FieldByName('total').AsFloat  = 0) then Begin
          mc := (((credito.Monto * tasainteresFlotante) * 0.01) / 12);
        end;
        if ((rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('aporte').AsFloat + rsql.FieldByName('total').AsFloat  > 0) then Begin
          mc := ((rsql.FieldByName('saldo').AsFloat + rsql.FieldByName('total').AsFloat) * ((tasainteresFlotante * 0.01) / 12)) * StrToFloat(credito.Formapago);
        end;

        //if not (vj) and not (credito.ViaJudicial) then Begin  // Los de via judicial quedan excluidos

        llj := False;
        if not (vj) and not (credito.ViaJudicial) then llj := True;
        if xjudiciales then
          if credito.ViaJudicial then llj := True else llj := False;

        //llj := True;

        if not listResumen then Begin
         //if not (vj) and not (credito.ViaJudicial) then Begin  // Los de via judicial quedan excluidos

         if llj then Begin

           if listlinea then Begin
             categoria.getDatos(rsql.FieldByName('idcredito').AsString);
             if not listResumen then Begin
               if salida <> 'T' then Begin
                 if (Length(Trim(idanter[1])) >= 0) or (Length(Trim(xcriterio)) > 0) and not (credito.ViaJudicial) then Begin
                   list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
                   list.Linea(0, 0, 'Linea:  ' + categoria.Items + '  ' + categoria.Descrip + ' - ' + categoria.DescripLinea, 1, 'Arial, negrita, 8', salida, 'S');
                   list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
                 end;
               end else Begin
                 if (Length(Trim(idanter[1])) > 0) or (Length(Trim(xcriterio)) = 0) then Begin
                   list.LineaTxt('', True);
                   list.LineaTxt('Linea:  ' + categoria.Items + '  ' + categoria.Descrip, True);
                   list.LineaTxt('', True);
                 end;
               end;
               idanter[10] := categoria.IdLinea;
             end;
           end;

           listlinea := False;
           existmov  := True;
           listdat   := True;

           if not ExpresarEnPesos then begin
             if not tc5 then vindex := 1; // Indice_credito;
           end;

           if salida <> 'T' then Begin
             list.Linea(0, 0, '   ' + utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString), 1, 'Arial, normal, 8', salida, 'N');
             list.Linea(9, list.Lineactual, idanter[3], 2, 'Arial, normal, 8', salida, 'N');
             list.Linea(35, list.Lineactual, rsql.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'N');
             if monto_indice = 0 then list.importe(55, list.Lineactual, '####.####', monto_indice, 4, 'Arial, normal, 8') else
               list.importe(55, list.Lineactual, '###0.0000', monto_indice, 4, 'Arial, normal, 8');
             list.importe(65, list.Lineactual, '', rsql.FieldByName('amortizacion').AsFloat * vindex, 5, 'Arial, normal, 8');
             if mc = 0 then list.importe(75, list.Lineactual, '', rsql.FieldByName('aporte').AsFloat * vindex, 6, 'Arial, normal, 8') else
               list.importe(75, list.Lineactual, '', mc * vindex, 6, 'Arial, normal, 8');
             if mc = 0 then list.importe(85, list.Lineactual, '', rsql.FieldByName('total').AsFloat * vindex, 7, 'Arial, normal, 8') else
               list.importe(85, list.Lineactual, '', (rsql.FieldByName('total').AsFloat + mc) * vindex, 7, 'Arial, normal, 8');
             if mc = 0 then list.importe(97, list.Lineactual, '', (mc + rsql.FieldByName('saldocuota').AsFloat) * vindex, 8, 'Arial, normal, 8') else
               list.importe(97, list.Lineactual, '', (rsql.FieldByName('saldocuota').AsFloat + mc) * vindex, 8, 'Arial, normal, 8');
             list.Linea(97, list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
           end else Begin
             list.LineaTxt(utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString) + ' ', False);
             list.LineaTxt(Copy(idanter[3], 1, 17) + utiles.espacios(18 - (Length(TrimRight(Copy(idanter[3], 1, 17))))), False);
             list.LineaTxt(Copy(rsql.FieldByName('concepto').AsString, 1, 13) + utiles.espacios(13 - (Length(TrimRight(Copy(rsql.FieldByName('concepto').AsString, 1, 13))))), False);
             list.importeTxt(rsql.FieldByName('amortizacion').AsFloat * vindex, 10, 2, False);
             if mc = 0 then list.importeTxt(rsql.FieldByName('aporte').AsFloat * vindex, 10, 2, False) else
               list.importeTxt(mc * vindex, 10, 2, False);
             if mc = 0 then list.importeTxt(rsql.FieldByName('total').AsFloat * vindex, 10, 2, False) else
               list.importeTxt((rsql.FieldByName('total').AsFloat + mc) * vindex, 10, 2, False);
             if mc = 0 then list.importeTxt((mc + rsql.FieldByName('saldocuota').AsFloat) * vindex, 10, 2, True) else
               list.importeTxt((mc + rsql.FieldByName('saldocuota').AsFloat) * vindex, 10, 2, True);
            end;

            totales[1] := totales[1] + ((rsql.FieldByName('saldocuota').AsFloat + mc) * vindex);
            totales[2] := totales[2] + (rsql.FieldByName('amortizacion').AsFloat * vindex);
            if mc = 0 then totales[3] := totales[3] + (rsql.FieldByName('aporte').AsFloat * vindex) else totales[3] := totales[3] + mc;
            totales[4] := totales[4] + ((rsql.FieldByName('total').AsFloat + mc) * vindex);

          end else Begin
            mov[i, 1] := utiles.sFormatoFecha(rsql.FieldByName('fechavto').AsString);
            mov[i, 2] := idanter[3];
            mov[i, 3] := rsql.FieldByName('concepto').AsString;
            mov[i, 4] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('amortizacion').AsFloat * vindex));
            if mc = 0 then mov[i, 5] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('aporte').AsFloat * vindex)) else
              mov[i, 5] := utiles.FormatearNumero(FloatToStr(mc * vindex));
            if mc = 0 then mov[i, 6] := utiles.FormatearNumero(FloatToStr(rsql.FieldByName('total').AsFloat * vindex)) else
              mov[i, 6] := utiles.FormatearNumero(FloatToStr(mc * vindex));
            mov[i, 7] := utiles.FormatearNumero(FloatToStr((mc + rsql.FieldByName('saldocuota').AsFloat) * vindex));
           end;
         end;

         idanter[2] := rsql.FieldByName('codprest').AsString;
       end;
     end;
    end;
    rsql.Next;
  end;

  rsql.Close; rsql.Free; rsql := Nil;
  if lst <> nil then lst.Destroy;

  TotalLineaACobrar(salida);
end;

procedure TTCreditos.TotalLineaACobrar(salida: Char);
var
  fuente: String;
Begin
  if listResumen then fuente := 'Arial, normal, 8' else fuente := 'Arial, negrita, 8';
  if not listResumen then idanter[14] := '';
  if totales[4] > 0 then Begin
    if salida <> 'T' then Begin
      if not listResumen then Begin
       list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
       list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if not listResumen then
        list.Linea(60, list.Lineactual, '-------------------------------------------------------------------------------------', 2, 'Arial, normal, 8', salida, 'S');
      if not listResumen then
        list.Linea(50, list.Lineactual, 'Total ' + categoria.Descrip, 1, fuente, salida, 'N')
       else
        list.Linea(50, list.Lineactual, categoria.Descrip + idanter[14], 1, fuente, salida, 'N');
      list.importe(65, list.Lineactual, '', totales[2], 2, fuente);
      list.importe(75, list.Lineactual, '', totales[3], 3, fuente);
      list.importe(85, list.Lineactual, '', totales[4], 4, fuente);
      list.importe(97, list.Lineactual, '', totales[1], 5, fuente);
      list.Linea(97, list.Lineactual, '', 6, fuente, salida, 'S');
      if not listResumen then Begin
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      end;
    end else Begin
      list.LineaTxt('', True);
      if not listResumen then
        list.LineaTxt('Total ' + categoria.Descrip + ':' + utiles.espacios(40 - (Length(TrimRight('Total ' + categoria.Descrip + ':')))), False)
      else
        list.LineaTxt(categoria.Descrip + idanter[14] + utiles.espacios(40 - (Length(TrimRight(categoria.Descrip + idanter[14])))), False);
      list.importeTxt(totales[2], 10, 2, False);
      list.importeTxt(totales[3], 10, 2, False);
      list.importeTxt(totales[4], 10, 2, False);
      list.importeTxt(totales[1], 10, 2, True);
      if not listResumen then
        List.LineaTxt('--------------------------------------------------------------------------------', True);
    end;
    totgral[1] := totgral[1] + totales[2];
    totgral[2] := totgral[2] + totales[3];
    totgral[3] := totgral[3] + totales[4];
    totgral[4] := totgral[4] + totales[1];
    totales[5] := totales[5] + totales[2];  // Para totales por normales / refinanciados
    totales[6] := totales[6] + totales[3];
    totales[7] := totales[7] + totales[4];
    totales[8] := totales[8] + totales[1];
  end;
  if listResumen then Begin
    if totales[9] > 0 then Begin
      Inc(nroItems);
      mov[nroItems, 1] := categoria.Descrip;
      mov[nroItems, 2] := utiles.FormatearNumero(FloatToStr(totales[9]));
      mov[nroItems, 3] := utiles.FormatearNumero(FloatToStr(totales[10]));
      mov[nroItems, 4] := utiles.FormatearNumero(FloatToStr(totales[11]));
      mov[nroItems, 5] := utiles.FormatearNumero(FloatToStr(totales[12]));
    end;
  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0;
  totales[9] := 0; totales[10] := 0; totales[11] := 0; totales[12] := 0;
end;

procedure TTCreditos.ListarCreditosEnGestionJudicial(salida: char);
var
  i: Integer;
Begin
  fuente := 'Arial, normal, 8';
  if nroItems > 0 then Begin
    For i := 1 to nroItems do Begin
      if salida <> 'T' then Begin
        list.Linea(0, 0, mov[i, 1] + ' - Gesti�n Judicial' + idanter[14], 1, fuente, salida, 'N');
        list.importe(65, list.Lineactual, '', StrToFloat(mov[i, 3]), 2, fuente);
        list.importe(75, list.Lineactual, '', StrToFloat(mov[i, 4]), 3, fuente);
        list.importe(85, list.Lineactual, '', StrToFloat(mov[i, 5]), 4, fuente);
        list.importe(97, list.Lineactual, '', StrToFloat(mov[i, 2]), 5, fuente);
        list.Linea(97, list.Lineactual, '', 6, fuente, salida, 'S');
      end else Begin
        list.LineaTxt(mov[i, 1] + ' - Gesti�n Judicial' + idanter[14] + utiles.espacios(40 - (Length(TrimRight(mov[i, 1] + ' - Gesti�n Judicial' + idanter[14])))), False);
        list.importeTxt(StrToFloat(mov[i, 3]), 10, 2, False);
        list.importeTxt(StrToFloat(mov[i, 4]), 10, 2, False);
        list.importeTxt(StrToFloat(mov[i, 5]), 10, 2, False);
        list.importeTxt(StrToFloat(mov[i, 2]), 10, 2, True);
        List.LineaTxt('--------------------------------------------------------------------------------', True);
      end;
      totales[5] := totales[5] + StrToFloat(mov[i, 3]);
      totales[6] := totales[6] + StrToFloat(mov[i, 4]);
      totales[7] := totales[7] + StrToFloat(mov[i, 5]);
      totales[8] := totales[8] + StrToFloat(mov[i, 2]);
    end;
  end;
  nroItems := 0;
  totgral[1] := totgral[1] + totales[5];
  totgral[2] := totgral[2] + totales[6];
  totgral[3] := totgral[3] + totales[7];
  totgral[4] := totgral[4] + totales[8];
  ListarTotalEstadosCreditos(salida);
end;

procedure TTCreditos.ListarTotalEstadosCreditos(salida: char);
Begin
  fuente := 'Arial, negrita, 8';
  if totales[5] > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(50, list.Lineactual, 'Subtotal:', 1, fuente, salida, 'N');
      list.importe(65, list.Lineactual, '', totales[5], 2, fuente);
      list.importe(75, list.Lineactual, '', totales[6], 3, fuente);
      list.importe(85, list.Lineactual, '', totales[7], 4, fuente);
      list.importe(97, list.Lineactual, '', totales[8], 5, fuente);
      list.Linea(97, list.Lineactual, '', 6, fuente, salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt('', True);
      list.LineaTxt('Subtotal:' + utiles.espacios(40 - (Length(TrimRight('Subtotal:')))), False);
      list.importeTxt(totales[5], 10, 2, False);
      list.importeTxt(totales[6], 10, 2, False);
      list.importeTxt(totales[7], 10, 2, False);
      list.importeTxt(totales[8], 10, 2, True);
      list.LineaTxt('', True);
    end;
  end;
  totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0;
end;

procedure TTCreditos.ListarCreditosJJ(salida: char);
var
  i: Integer;
Begin
  if salida <> 'T' then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, '*** Cr�ditos en Gesti�n Judicial ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt('', True);
    list.LineaTxt('*** Cr�ditos en Gesti�n Judicial ***', True);
    list.LineaTxt('', True);
  end;
  for i := 1 to 100 do Begin
    if Length(Trim(mov[i, 1])) = 0 then Break;
    if salida <> 'T' then Begin
      list.Linea(0, 0, '   ' + mov[i, 1], 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(9, list.Lineactual, mov[i, 2], 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(40, list.Lineactual, mov[i, 3], 3, 'Arial, normal, 8', salida, 'N');
      list.importe(65, list.Lineactual, '', StrToFloat(mov[i, 3]), 4, 'Arial, normal, 8');
      list.importe(75, list.Lineactual, '', StrToFloat(mov[i, 5]), 5, 'Arial, normal, 8');
      list.importe(85, list.Lineactual, '', StrToFloat(mov[i, 2]), 6, 'Arial, normal, 8');
      list.Linea(97, list.Lineactual, '', 8, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.LineaTxt(mov[i, 1] + ' ', False);
      list.LineaTxt(Copy(mov[i, 2], 1, 17) + utiles.espacios(18 - (Length(TrimRight(Copy(mov[i, 2], 1, 17))))), False);
      list.LineaTxt(Copy(mov[i, 3], 1, 13) + utiles.espacios(13 - (Length(TrimRight(Copy(mov[i, 3], 1, 13))))), False);
      list.importeTxt(StrToFloat(mov[i, 4]), 10, 2, False);
      list.importeTxt(StrToFloat(mov[i, 5]), 10, 2, False);
      list.importeTxt(StrToFloat(mov[i, 6]), 10, 2, False);
      list.importeTxt(StrToFloat(mov[i, 7]), 10, 2, True);
    end;
  end;
  if i > 0 then Begin
    if salida <> 'T' then list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    if salida = 'T' then list.LineaTxt('', True);
  end;
end;

function  TTCreditos.setSaldoCuotaRef(xcodprest, xexpediente: String): Real;
// Objetivo...: Saldo de creditos con cuotas refinanciadas
var
  d, p: Real;
  r: TQuery;
Begin
  r := datosdb.tranSQL('select sum(total) from creditos_detrefcuotas where codprest = ' + '"' + xcodprest + '"' + ' and expediente = ' + '"' + xexpediente + '"' + ' and tipomov = 1');
  r.Open;
  d := r.Fields[0].AsFloat;
  r.Close;
  r := datosdb.tranSQL('select sum(total) from creditos_detrefcuotas where codprest = ' + '"' + xcodprest + '"' + ' and expediente = ' + '"' + xexpediente + '"' + ' and tipomov = 2');
  r.Open;
  p := r.Fields[0].AsFloat;
  r.Close;
  Result := d - p;
end;

{-------------------------------------------------------------------------------}

procedure TTCreditos.ListarMontosACobrarResumen(listSel: TStringList; xdfecha, xhfecha, xcp, xorden: String; xjudiciales: Boolean; salida: Char);
Begin
  //ExpresarEnPesos := True;
  categoria.conectar;
  listResumen := False;
  ListarMontosACobrar(listSel, xdfecha, xhfecha, xcp, xorden, xjudiciales, salida);
  listResumen := False;
  categoria.desconectar;
  PresentarInforme;
end;
{-------------------------------------------------------------------------------}

procedure TTCreditos.ListarCreditosPorLocalidad(xlista: TStringList; xdfecha, xhfecha: String; salida: char);
var
  r: TQuery;
  i, n: Integer;
Begin
  c1 := 0;
  if salida <> 'X' then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Creditos Otorgados en el Lapso   ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
    List.Titulo(10, list.Lineactual, 'Expediente / Prestatario', 2, 'Arial, cursiva, 8');
    List.Titulo(90, list.Lineactual, 'Monto', 3, 'Arial, cursiva, 8');
    List.Titulo(96, list.Lineactual, 'Estado', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 9.5);
    excel.setString('a' + l1, 'a' + l1, 'Cr�ditos Otorgados en el Lapso: ' + xdfecha + ' - ' + xhfecha, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Fecha', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 37);
    excel.setString('b' + l1, 'b' + l1, 'Expediente / Prestatario', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 14);
    excel.setString('d' + l1, 'd' + l1, 'Monto', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 10);
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 14);
    excel.setString('e' + l1, 'e' + l1, 'Estado', 'Arial, negrita, 10');
    Inc(c1);
  end;

  IniciarArreglos;
  listdat := False;

  for i := 1 to xlista.Count do Begin
    municipio.getDatos(xlista.Strings[i-1]);

    rsql := setCreditosLocalidad(municipio.codpost, municipio.orden);
    rsql.Open; n := 0;

    while not rsql.Eof do Begin
      if (rsql.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
        if n = 0 then Begin
          cpost.getDatos(municipio.codpost, municipio.orden);
          if salida <> 'X' then Begin
            List.Linea(0, 0, 'Localidad: ' + cpost.localidad, 1, 'Arial, negrita, 9', salida, 'S');
            List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
          end else Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, 'Localidad: ' + cpost.localidad, 'Arial, negrita, 10');
          end;
        end;
        n := 1; listdat := True;

        if rsql.FieldByName('idcredito').AsString <> idanter[1] then Begin
          if totales[1] > 0 then FinalizarLinea(salida);
          categoria.getDatos(rsql.FieldByName('idcredito').AsString);
          if salida <> 'X' then Begin
            list.Linea(0, 0, 'Linea:  ' + categoria.Items + '  ' + categoria.Descrip, 1, 'Arial, negrita, 8', salida, 'N');
            list.Linea(70, list.Lineactual, categoria.DescripLinea, 2, 'Arial, negrita, 8', salida, 'S');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
          end else Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, 'Linea: ' + categoria.Items + '  ' + categoria.Descrip, 'Arial, negrita, 9');
            excel.setString('c' + l1, 'c' + l1, 'Linea: ' + categoria.DescripLinea, 'Arial, negrita, 9');
          end;
          idanter[1] := rsql.FieldByName('idcredito').AsString;
        end;
        if salida <> 'X' then Begin
          list.Linea(0, 0, utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + '   ' + rsql.FieldByName('codprest').AsString + '-' + rsql.FieldByName('expediente').AsString  + '  ' + rsql.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
          if (rsql.FieldByName('indice').AsFloat = 0) or (rsql.FieldByName('monto_real').AsFloat <> 0) then list.importe(95, list.Lineactual, '', rsql.FieldByName('monto_real').AsFloat, 2, 'Arial, normal, 8') else
            list.importe(95, list.Lineactual, '', rsql.FieldByName('monto').AsFloat * rsql.FieldByName('indice').AsFloat, 2, 'Arial, normal, 8');
          list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        end else Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '''' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString), 'Arial, normal, 8');
          excel.setString('b' + l1, 'b' + l1, rsql.FieldByName('codprest').AsString + '-' + rsql.FieldByName('expediente').AsString  + '  ' + rsql.FieldByName('nombre').AsString, 'Arial, normal, 8');
          if (rsql.FieldByName('indice').AsFloat = 0) or (rsql.FieldByName('monto_real').AsFloat <> 0) then excel.setReal('d' + l1, 'd' + l1, rsql.FieldByName('monto_real').AsFloat, 'Arial, normal, 8') else
            excel.setReal('d' + l1, 'd' + l1, rsql.FieldByName('monto').AsFloat * rsql.FieldByName('indice').AsFloat, 'Arial, normal, 8');
        end;
        if (rsql.FieldByName('indice').AsFloat = 0) or (rsql.FieldByName('monto_real').AsFloat <> 0) then totales[1] := totales[1] + rsql.FieldByName('monto_real').AsFloat else
          totales[1] := totales[1] + rsql.FieldByName('monto').AsFloat * (rsql.FieldByName('indice').AsFloat);
        totales[4] := totales[4] + 1;
        totales[6] := totales[6] + 1;
      end;
      rsql.Next;
    end;
    rsql.Close; rsql.Free;

    FinalizarLinea(salida);

    // ---- Cr�ditos Cancelados

    rsql := setCreditosCanceladosLocalidad(municipio.codpost, municipio.orden);
    rsql.Open; totales[1] := 0; idanter[1] := '';
    while not rsql.Eof do Begin
      if (rsql.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (rsql.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
        if rsql.FieldByName('idcredito').AsString <> idanter[1] then Begin
          if totales[1] > 0 then FinalizarLinea(salida) else
            if salida <> 'X' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
          categoria.getDatos(rsql.FieldByName('idcredito').AsString);
          if salida <> 'X' then Begin
            list.Linea(0, 0, 'Linea:  ' + categoria.Items + '  ' + categoria.Descrip, 1, 'Arial, negrita, 8', salida, 'N');
            list.Linea(70, list.Lineactual, categoria.DescripLinea, 2, 'Arial, negrita, 8', salida, 'S');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
          end else Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, 'Linea:  ' + categoria.Items + '  ' + categoria.Descrip, 'Arial, negrita, 9');
            excel.setString('c' + l1, 'c' + l1, categoria.DescripLinea, 'Arial, negrita, 9');
          end;
          idanter[1] := rsql.FieldByName('idcredito').AsString;
        end;
        if salida <> 'X' then Begin
          list.Linea(0, 0, '''' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString) + '   ' + rsql.FieldByName('codprest').AsString + '-' + rsql.FieldByName('expediente').AsString  + '  ' + rsql.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
          if (rsql.FieldByName('indice').AsFloat = 0) or (rsql.FieldByName('monto_real').AsFloat <> 0) then list.importe(95, list.Lineactual, '', rsql.FieldByName('monto_real').AsFloat, 2, 'Arial, normal, 8') else
            list.importe(95, list.Lineactual, '', rsql.FieldByName('monto').AsFloat * rsql.FieldByName('indice').AsFloat, 2, 'Arial, normal, 8');
          list.Linea(95, list.Lineactual, '  CANCELADO', 3, 'Arial, normal, 8', salida, 'S');
        end else Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString), 'Arial, normal, 8');
          excel.setString('b' + l1, 'b' + l1, rsql.FieldByName('codprest').AsString + '-' + rsql.FieldByName('expediente').AsString  + '  ' + rsql.FieldByName('nombre').AsString, 'Arial, normal, 8');
          if (rsql.FieldByName('indice').AsFloat = 0) or (rsql.FieldByName('monto_real').AsFloat <> 0) then excel.setReal('d' + l1, 'd' + l1, rsql.FieldByName('monto_real').AsFloat, 'Arial, normal, 8') else
            excel.setReal('d' + l1, 'd' + l1, rsql.FieldByName('monto').AsFloat * rsql.FieldByName('indice').AsFloat, 'Arial, normal, 8');
        end;

        if (rsql.FieldByName('indice').AsFloat = 0) or (rsql.FieldByName('monto_real').AsFloat <> 0) then totales[1] := totales[1] + rsql.FieldByName('monto_real').AsFloat else
          totales[1] := totales[1] + rsql.FieldByName('monto').AsFloat * (rsql.FieldByName('indice').AsFloat);

        totales[4] := totales[4] + 1;
        totales[6] := totales[6] + 1;
      end;
      rsql.Next;
    end;
    rsql.Close; rsql.Free;

    FinalizarLinea(salida);

    if totales[2] > 0 then Begin
      if salida <> 'X' then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
        list.Linea(0, 0, 'CANTIDAD/TOTAL LOCALIDAD ' + UpperCase(cpost.localidad) + ' : ', 1, 'Arial, negrita, 9', salida, 'N');
        list.importe(75, list.Lineactual, '######', totales[4], 2, 'Arial, negrita, 9');
        list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 9');
        list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
      end else Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, 'CANTIDAD/TOTAL LOCALIDAD ' + UpperCase(cpost.localidad) + ' : ', 'Arial, negrita, 9');
        excel.setReal('c' + l1, 'c' + l1, totales[4], 'Arial, negrita, 9');
        excel.setReal('d' + l1, 'd' + l1, totales[2], 'Arial, negrita, 9');
      end;
      totales[3] := totales[3] + totales[2];
      totales[5] := totales[5] + totales[4];
      totales[2] := 0; totales[4] := 0;
    end;
  end;

  if totales[3] > 0 then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL: ', 1, 'Arial, negrita, 10', salida, 'N');
      list.importe(75, list.Lineactual, '######', totales[5], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totales[3], 3, 'Arial, negrita, 10');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 10', salida, 'S');
    end else Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL GENERAL: ', 'Arial, negrita, 9');
      excel.setReal('c' + l1, 'c' + l1, totales[5], 'Arial, negrita, 9');
      excel.setReal('d' + l1, 'd' + l1, totales[3], 'Arial, negrita, 9');
      Inc(c1);
    end;
  end;

  if not (listdat) and ((salida = 'P') or (salida = 'I')) then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'X' then excel.Visulizar;
end;

procedure TTCreditos.FinalizarLinea(salida: char);
Begin
  if totales[1] > 0 then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(95, list.Lineactual, '', '-----------------------', 2, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Total Linea: ', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '######', totales[6], 2, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, negrita, 8');
      list.Linea(95, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'N');
    end else Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Total Linea: ', 'Arial, negrita, 9');
      excel.setReal('c' + l1, 'c' + l1, totales[6], 'Arial, negrita, 9');
      excel.setReal('d' + l1, 'd' + l1, totales[1], 'Arial, negrita, 9');
    end;
  end;
  totales[2] := totales[2] + totales[1];
  totales[1] := 0; totales[6] := 0;
end;

{-------------------------------------------------------------------------------}
procedure TTCreditos.ListarMontosCreditosCobrados(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Montos Cheques Cobrados
Begin
  if (salida = 'T') or (salida = 'I') then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Montos Cobrados Por Cr�ditos en el Lapso   ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Linea de Cr�dito', 1, 'Arial, cursiva, 8');
    List.Titulo(60, list.Lineactual, 'Capital', 2, 'Arial, cursiva, 8');
    List.Titulo(70, list.Lineactual, 'Aporte', 3, 'Arial, cursiva, 8');
    List.Titulo(78, list.Lineactual, 'Punitorios', 4, 'Arial, cursiva, 8');
    List.Titulo(88, list.Lineactual, 'Descuentos', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end;
  if salida = 'X' then Begin
    c1 := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 9.5);
    excel.setString('a' + l1, 'a' + l1, 'Montos Cobrados Por Cr�ditos en el Lapso   ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Linea de Cr�dito', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 37);
    excel.setString('b' + l1, 'b' + l1, 'Capital', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 14);
    excel.setString('d' + l1, 'd' + l1, 'Aporte', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 10);
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 14);
    excel.setString('e' + l1, 'e' + l1, 'Punitorios', 'Arial, negrita, 10');
    excel.setString('f' + l1, 'f' + l1, 'Descuentos', 'Arial, negrita, 10');
    Inc(c1);
  end;

  IniciarArreglos;
  IniciarArreglosGenerales;
  categoria.conectar;
  rsql := datosdb.tranSQL('select creditos_det.codprest, creditos_det.expediente, creditos_det.amortizacion, creditos_det.aporte, creditos_det.total, creditos_det.saldocuota, creditos_det.refcredito, creditos_det.cuotasref, '+
                          'creditos_det.estado, creditos_det.interes, creditos_det.descuento, creditos_det.tipomov, creditos_cab.idcredito from creditos_det, creditos_cab ' +
                          'where creditos_cab.codprest = creditos_det.codprest and creditos_cab.expediente = creditos_det.expediente and ' +
                          'fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by idcredito, codprest, expediente');
  ProcesarMontosCreditos('', salida);

  if (salida = 'T') or (salida = 'I') then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  rsql := datosdb.tranSQL('select creditos_detrefinanciados.codprest, creditos_detrefinanciados.expediente, creditos_detrefinanciados.amortizacion, creditos_detrefinanciados.aporte, creditos_detrefinanciados.total, creditos_detrefinanciados.saldocuota, ' +
                          'creditos_detrefinanciados.refcredito, creditos_detrefinanciados.cuotasref, creditos_detrefinanciados.estado, creditos_detrefinanciados.interes, creditos_detrefinanciados.descuento, creditos_detrefinanciados.tipomov, creditos_cab.idcredito from ' +
                          'creditos_detrefinanciados, creditos_cab where creditos_cab.codprest = creditos_detrefinanciados.codprest and creditos_cab.expediente = creditos_detrefinanciados.expediente and ' +
                          'fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by idcredito, codprest, expediente');

  if (salida = 'T') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, '*** Cr�ditos Refinanciados ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'X' then Begin
    Inc(c1); Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('A' + l1, 'A' + l1, '*** Cr�ditos Refinanciados ***', 'Arial, negrita, 12');
    Inc(c1);
  end;
  ProcesarMontosCreditos('- Creditos Refinanciados', salida);

  rsql := datosdb.tranSQL('select creditos_detrefcuotas.codprest, creditos_detrefcuotas.expediente, creditos_detrefcuotas.amortizacion, creditos_detrefcuotas.aporte, creditos_detrefcuotas.total, creditos_detrefcuotas.saldocuota, ' +
                          'creditos_detrefcuotas.refcredito, creditos_detrefcuotas.cuotasref, creditos_detrefcuotas.estado, creditos_detrefcuotas.interes, creditos_detrefcuotas.descuento, creditos_detrefcuotas.tipomov, creditos_cab.idcredito from ' +
                          'creditos_detrefcuotas, creditos_cab where creditos_cab.codprest = creditos_detrefcuotas.codprest and creditos_cab.expediente = creditos_detrefcuotas.expediente and ' +
                          'fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by idcredito, codprest, expediente');

  if (salida = 'T') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, '*** Cuotas Refinanciadas ***', 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'X' then Begin
    Inc(c1); Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('A' + l1, 'A' + l1, '*** Cuotas Refinanciadas ***', 'Arial, negrita, 12');
    Inc(c1);
  end;
  ProcesarMontosCreditos('- Cuotas Refinanciadas', salida);

  if totgral[6] > 0 then Begin
    if (salida = 'T') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(65, list.Lineactual, '', totgral[6], 2, 'Arial, negrita, 8');
      list.importe(75, list.Lineactual, '', totgral[7], 3, 'Arial, negrita, 8');
      list.importe(85, list.Lineactual, '', totgral[8], 4, 'Arial, negrita, 8');
      list.importe(97, list.Lineactual, '', totgral[9], 5, 'Arial, negrita, 8');
      list.Linea(0, 0, 'TOTAL COBROS:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(65, list.Lineactual, '', totgral[6] + totgral[7] + totgral[8] - totgral[9], 2, 'Arial, negrita, 8');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('A' + l1, 'A' + l1, 'TOTAL GENERAL:', 'Arial, negrita, 12');
      excel.setReal('B' + l1, 'B' + l1, totgral[6], 'Arial, negrita, 12');
      excel.setReal('C' + l1, 'C' + l1, totgral[7], 'Arial, negrita, 12');
      excel.setReal('D' + l1, 'D' + l1, totgral[8], 'Arial, negrita, 12');
      excel.setReal('E' + l1, 'E' + l1, totgral[9], 'Arial, negrita, 12');
      excel.setReal('F' + l1, 'F' + l1, totgral[6] + totgral[7] + totgral[8] - totgral[9], 'Arial, negrita, 12');
    end;
  end;

  categoria.desconectar;
  if (salida = 'T') or (salida = 'I') then PresentarInforme;
  if salida = 'X' then excel.Visulizar;
end;

procedure TTCreditos.ProcesarMontosCreditos(estado: String; salida: char);
// Objetivo...: Obtener montos cobrados en cr�ditos
var
  cpa, exa: String;
  indice: Real;
  yes: Boolean;
Begin
  rsql.Open;
  while not rsql.Eof do Begin
    if (rsql.FieldByName('codprest').AsString <> cpa) or (rsql.FieldByName('expediente').AsString <> exa) then Begin
      getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);
      cpa := rsql.FieldByName('codprest').AsString;
      exa := rsql.FieldByName('expediente').AsString;
      if Indice_credito > 0 then indice := Indice_credito else Indice := 1;
    end;

    yes := False;
    if (rsql.FieldByName('refcredito').AsString <> 'S') and (Length(Trim(rsql.FieldByName('cuotasref').AsString)) = 0) then yes := True;
    if estado = '- Cuotas Refinanciadas' then
      if (Length(Trim(rsql.FieldByName('cuotasref').AsString)) > 0) then yes := True;

    if rsql.FieldByName('idcredito').AsString <> idanter[1] then Begin
      LineaCobros(salida);
      idanter[1] := rsql.FieldByName('idcredito').AsString;
    end;

    if (yes) then Begin
      if (rsql.FieldByName('estado').AsString = 'P') and (rsql.FieldByName('tipomov').AsInteger = 1) then Begin
        totales[1] := totales[1] + (rsql.FieldByName('amortizacion').AsFloat * Indice);
        totales[2] := totales[2] + (rsql.FieldByName('aporte').AsFloat * Indice);
      end;
      if (rsql.FieldByName('tipomov').AsInteger = 2) then Begin
        totales[3] := totales[3] + rsql.FieldByName('interes').AsFloat;
        totales[4] := totales[4] + rsql.FieldByName('descuento').AsFloat;
      end;
    end;
    rsql.Next;
  end;
  LineaCobros(salida);

  rsql.Close; rsql.Free;

  if totgral[1] > 0 then Begin
    if (salida = 'T') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Sutotal:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(65, list.Lineactual, '', totgral[1], 2, 'Arial, negrita, 8');
      list.importe(75, list.Lineactual, '', totgral[2], 3, 'Arial, negrita, 8');
      list.importe(85, list.Lineactual, '', totgral[3], 4, 'Arial, negrita, 8');
      list.importe(97, list.Lineactual, '', totgral[4], 5, 'Arial, negrita, 8');
      list.Linea(97, list.Lineactual, '', 6, 'Arial, negrita, 8', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('A' + l1, 'A' + l1, 'Subtotal:', 'Arial, negrita, 12');
      excel.setReal('B' + l1, 'B' + l1, totgral[1], 'Arial, negrita, 12');
      excel.setReal('C' + l1, 'C' + l1, totgral[2], 'Arial, negrita, 12');
      excel.setReal('D' + l1, 'D' + l1, totgral[3], 'Arial, negrita, 12');
      excel.setReal('E' + l1, 'E' + l1, totgral[4], 'Arial, negrita, 12');
    end;

    totgral[6]  := totgral[6]  + totgral[1];
    totgral[7]  := totgral[7]  + totgral[2];
    totgral[8]  := totgral[8]  + totgral[3];
    totgral[9]  := totgral[9]  + totgral[4];
    totgral[10] := totgral[10] + totgral[5];

    totgral[1] := 0; totgral[2] := 0; totgral[3] := 0; totgral[4] := 0; totgral[5] := 0;
  end;
end;

procedure TTCreditos.LineaCobros(salida: char);
// Objetivo...: Listar Linea de Credito
Begin
  if totales[1] > 0 then Begin
    categoria.getDatos(idanter[1]);
    if (salida = 'T') or (salida = 'I') then Begin
      list.Linea(0, 0, categoria.Descrip, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(65, list.Lineactual, '', totales[1], 2, 'Arial, normal, 8');
      list.importe(75, list.Lineactual, '', totales[2], 3, 'Arial, normal, 8');
      list.importe(85, list.Lineactual, '', totales[3], 4, 'Arial, normal, 8');
      list.importe(97, list.Lineactual, '', totales[4], 5, 'Arial, normal, 8');
      list.Linea(97, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('A' + l1, 'A' + l1, categoria.Descrip, 'Arial, normal, 10');
      excel.setReal('B' + l1, 'B' + l1, totales[1], 'Arial, normal, 10');
      excel.setReal('C' + l1, 'C' + l1, totales[2], 'Arial, normal, 10');
      excel.setReal('D' + l1, 'D' + l1, totales[3], 'Arial, normal, 10');
      excel.setReal('E' + l1, 'E' + l1, totales[4], 'Arial, normal, 10');
    end;
  end;

  totgral[1] := totgral[1] + totales[1];
  totgral[2] := totgral[2] + totales[2];
  totgral[3] := totgral[3] + totales[3];
  totgral[4] := totgral[4] + totales[4];
  totgral[5] := totgral[5] + totales[5];

  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; //totales[5] := 0;
end;

{-------------------------------------------------------------------------------}

procedure TTCreditos.ListarMontosCaptitalAmortizaciones(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Montos Cheques Cobrados
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Montos de Capital y Amortizaciones en el Lapso   ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Linea de Cr�dito', 1, 'Arial, cursiva, 8');
  List.Titulo(70, list.Lineactual, 'Capital', 2, 'Arial, cursiva, 8');
  List.Titulo(80, list.Lineactual, 'Aporte', 3, 'Arial, cursiva, 8');
  List.Titulo(92, list.Lineactual, 'Total', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  IniciarArreglos;
  IniciarArreglosGenerales;
  categoria.conectar;
  rsql := datosdb.tranSQL('select creditos_det.codprest, creditos_det.expediente, creditos_det.amortizacion, creditos_det.aporte, creditos_det.total, creditos_det.saldocuota, creditos_det.refcredito, creditos_det.cuotasref, '+
                          'creditos_det.estado, creditos_det.interes, creditos_det.descuento, creditos_det.tipomov, creditos_det.saldo, creditos_cab.idcredito, creditos_cab.tipocalculo from creditos_det, creditos_cab ' +
                          'where creditos_cab.codprest = creditos_det.codprest and creditos_cab.expediente = creditos_det.expediente and ' +
                          'fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by idcredito, codprest, expediente');
  ProcesarMontosCapitalAmortizaciones('', salida);
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  rsql := datosdb.tranSQL('select creditos_detrefinanciados.codprest, creditos_detrefinanciados.expediente, creditos_detrefinanciados.amortizacion, creditos_detrefinanciados.aporte, creditos_detrefinanciados.total, creditos_detrefinanciados.saldocuota, ' +
                          'creditos_detrefinanciados.refcredito, creditos_detrefinanciados.cuotasref, creditos_detrefinanciados.estado, creditos_detrefinanciados.interes, creditos_detrefinanciados.descuento, creditos_detrefinanciados.tipomov, creditos_cab.idcredito, ' +
                          'creditos_cab.tipocalculo, creditos_detrefinanciados.saldo from creditos_detrefinanciados, creditos_cab where creditos_cab.codprest = creditos_detrefinanciados.codprest and creditos_cab.expediente = creditos_detrefinanciados.expediente and ' +
                          'fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by idcredito, codprest, expediente');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '*** Cr�ditos Refinanciados ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  ProcesarMontosCapitalAmortizaciones('- Creditos Refinanciados', salida);

  rsql := datosdb.tranSQL('select creditos_detrefcuotas.codprest, creditos_detrefcuotas.expediente, creditos_detrefcuotas.amortizacion, creditos_detrefcuotas.aporte, creditos_detrefcuotas.total, creditos_detrefcuotas.saldocuota, ' +
                          'creditos_detrefcuotas.refcredito, creditos_detrefcuotas.cuotasref, creditos_detrefcuotas.estado, creditos_detrefcuotas.interes, creditos_detrefcuotas.descuento, creditos_detrefcuotas.tipomov, creditos_cab.idcredito, ' +
                          'creditos_cab.tipocalculo, creditos_detrefcuotas.saldo from creditos_detrefcuotas, creditos_cab where creditos_cab.codprest = creditos_detrefcuotas.codprest and creditos_cab.expediente = creditos_detrefcuotas.expediente and ' +
                          'fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by idcredito, codprest, expediente');

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '*** Cuotas Refinanciadas ***', 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  ProcesarMontosCapitalAmortizaciones('- Cuotas Refinanciadas', salida);

  if totgral[6] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totgral[4], 2, 'Arial, negrita, 8');
    list.importe(85, list.Lineactual, '', totgral[5], 3, 'Arial, negrita, 8');
    list.importe(97, list.Lineactual, '', totgral[6], 4, 'Arial, negrita, 8');
  end;

  categoria.desconectar;
  PresentarInforme;
end;

procedure TTCreditos.ProcesarMontosCapitalAmortizaciones(estado: String; salida: char);
// Objetivo...: Obtener montos cobrados en cr�ditos
var
  cpa, exa: String;
  indice, mc: Real;
  yes: Boolean;
Begin
  rsql.Open;
  while not rsql.Eof do Begin
    if (rsql.FieldByName('codprest').AsString <> cpa) or (rsql.FieldByName('expediente').AsString <> exa) then Begin
      getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);
      cpa := rsql.FieldByName('codprest').AsString;
      exa := rsql.FieldByName('expediente').AsString;
      if Indice_credito > 0 then indice := Indice_credito else Indice := 1;
    end;

    yes := False;
    if (rsql.FieldByName('refcredito').AsString <> 'S') and (Length(Trim(rsql.FieldByName('cuotasref').AsString)) = 0) then yes := True;
    if estado = '- Cuotas Refinanciadas' then
      if (Length(Trim(rsql.FieldByName('cuotasref').AsString)) > 0) then yes := True;

    if rsql.FieldByName('idcredito').AsString <> idanter[1] then Begin
      LineaCapitalAmortizaciones(salida);
      idanter[1] := rsql.FieldByName('idcredito').AsString;
    end;

    if (rsql.FieldByName('tipomov').AsInteger = 1) then Begin
      mc := 0;
      if (rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B') and (rsql.FieldByName('aporte').AsFloat + rsql.FieldByName('total').AsFloat  = 0) then Begin
        credito.getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);
        mc := (((credito.Monto * tasainteresFlotante) * 0.01) / 12);
      end;
      if ((rsql.FieldByName('tipocalculo').AsString = '5') or (rsql.FieldByName('tipocalculo').AsString = 'B')) and (rsql.FieldByName('aporte').AsFloat + rsql.FieldByName('total').AsFloat  > 0) then Begin
        credito.getDatos(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString);
        mc := ((rsql.FieldByName('saldo').AsFloat + rsql.FieldByName('total').AsFloat) * ((tasainteresFlotante * 0.01) / 12)) * StrToFloat(credito.Formapago);
      end;

      totales[1] := totales[1] + (rsql.FieldByName('amortizacion').AsFloat * Indice);
      if mc = 0 then totales[2] := totales[2] + (rsql.FieldByName('aporte').AsFloat * Indice) else totales[2] := totales[2] + mc;
      totales[3] := totales[3] + ((rsql.FieldByName('total').AsFloat * Indice) + mc);
    end;

    rsql.Next;
  end;
  LineaCapitalAmortizaciones(salida);

  rsql.Close; rsql.Free;

  if totgral[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totgral[1], 2, 'Arial, negrita, 8');
    list.importe(85, list.Lineactual, '', totgral[2], 3, 'Arial, negrita, 8');
    list.importe(97, list.Lineactual, '', totgral[3], 4, 'Arial, negrita, 8');
    list.Linea(97, list.Lineactual, '', 6, 'Arial, negrita, 8', salida, 'S');

    totgral[4]  := totgral[4]  + totgral[1];
    totgral[5]  := totgral[5]  + totgral[2];
    totgral[6]  := totgral[6]  + totgral[3];

    totgral[1] := 0; totgral[2] := 0; totgral[3] := 0;
  end;
end;

procedure TTCreditos.LineaCapitalAmortizaciones(salida: char);
// Objetivo...: Listar Linea de Credito
Begin
  if totales[1] > 0 then Begin
    categoria.getDatos(idanter[1]);
    list.Linea(0, 0, categoria.Descrip, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(75, list.Lineactual, '', totales[1], 2, 'Arial, normal, 8');
    list.importe(85, list.Lineactual, '', totales[2], 3, 'Arial, normal, 8');
    list.importe(97, list.Lineactual, '', totales[3], 4, 'Arial, normal, 8');
    list.Linea(97, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  end;

  totgral[1] := totgral[1] + totales[1];
  totgral[2] := totgral[2] + totales[2];
  totgral[3] := totgral[3] + totales[3];

  totales[1] := 0; totales[2] := 0; totales[3] := 0;
end;

{-------------------------------------------------------------------------------}
procedure TTCreditos.ListarMontosACobrarHistoricos(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Montos A Cobrar Historicos
var
  r: TQuery;
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Montos Historicos de Capital y Amortizaciones en el Lapso   ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '   Expediente      Prestatario', 1, 'Arial, cursiva, 8');
  List.Titulo(55, list.Lineactual, 'Capital', 2, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Aporte', 3, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Aporte', 3, 'Arial, cursiva, 8');
  List.Titulo(83, list.Lineactual, 'Refin.', 4, 'Arial, cursiva, 8');
  List.Titulo(90, list.Lineactual, 'F.Otorg.', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  categoria.conectar;
  IniciarArreglos;

  rsql := datosdb.tranSQL('select creditos_det.codprest, creditos_det.expediente, creditos_det.amortizacion, creditos_det.aporte, creditos_det.fechavto, creditos_det.cuotasref, creditos_det.refcredito, creditos_det.estado, creditos_det.saldo, ' +
                          'creditos_cab.idcredito, creditos_cab.indice, creditos_cab.tipocalculo, creditos_cab.fecha from creditos_det, creditos_cab where creditos_cab.codprest = creditos_det.codprest and ' +
                          'creditos_cab.expediente = creditos_det.expediente and creditos_det.fechavto >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and creditos_det.fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' +
                          ' and creditos_det.tipomov = 1' + ' order by idcredito, codprest, expediente, fechavto');

  ListDetalleCreditos(categoria.IdLinea, xdesde, xhasta, 'Normal', salida);

  if totales[5] + totales[6] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(60, list.Lineactual, '', totales[5], 2, 'Arial, negrita, 9');
    list.importe(80, list.Lineactual, '', totales[6], 3, 'Arial, negrita, 9');
    list.Linea(90, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
  end;

  rsql.Close; rsql.Free;
  categoria.desconectar;
  list.FinList;
end;

procedure TTCreditos.ListDetalleCreditos(xlinea, xdfecha, xhfecha, tipo: String; salida: char);
// Objetivo...: Listar detalle de cr�ditos
var
  r: TQuery;
Begin
  rsql.Open;
  idanter[1] := rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString;
  while not rsql.Eof do Begin
    if rsql.FieldByName('fecha').AsString <= utiles.sExprFecha2000(fechatope) then Begin
      totales[10] := rsql.FieldByName('indice').AsFloat;
      if totales[10] = 0 then totales[10] := 1;
      if rsql.FieldByName('idcredito').AsString <> idanter[2] then Begin
        LineaExpediente(xdfecha, xhfecha, salida);    // anexada 24/10/05
        TotLineaMontosACobrarHistoricos(xdfecha, xhfecha, salida);
        categoria.getDatos(rsql.FieldByName('idcredito').AsString);
        list.Linea(0, 0, 'Linea: ' + rsql.FieldByName('idcredito').AsString + ' - ' + credito.Idcredito + '  ' + categoria.Descrip, 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        idanter[5] := rsql.FieldByName('idcredito').AsString;
        idanter[2] := rsql.FieldByName('idcredito').AsString;
      end;

      if rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString <> idanter[1] then LineaExpediente(xdfecha, xhfecha, salida);
      if (rsql.FieldByName('refcredito').AsString <> 'S') and (Length(Trim(rsql.FieldByName('cuotasref').AsString)) = 0) and (rsql.FieldByName('estado').AsString = 'I') then Begin
        totales[1] := totales[1] + (rsql.FieldByName('amortizacion').AsFloat * totales[10]);
        totales[2] := totales[2] + (rsql.FieldByName('aporte').AsFloat * totales[10]);
      end;
      idanter[1] := rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString;
      idanter[4] := utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString);
      if (rsql.FieldByName('estado').AsString = 'P') and (rsql.FieldByName('fechavto').AsString > utiles.sExprFecha2000(fechatope)) then idanter[6] := rsql.FieldByName('fechavto').AsString + '' + rsql.FieldByName('saldo').AsString;
    end;
    rsql.Next;
  end;
  rsql.Close;
  LineaExpediente(xdfecha, xhfecha, salida);
  TotLineaMontosACobrarHistoricos(xdfecha, xhfecha, salida);
end;

procedure TTCreditos.LineaExpediente(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Expediente
Begin
  if totales[1] + totales[2] > 0 then Begin
    // Creditos que tienen las cuotas saldadas posteriores a la fecha
    if Length(Trim(idanter[6])) > 0 then Begin
      totales[1] := 0; totales[2] := 0; totales[10] := 0;
      if Buscar(Copy(idanter[1], 1, 5), Copy(idanter[1], 6, 4)) then
        if (creditos_cab.FieldByName('tipoCalculo').AsString <> '5') then totales[10] := creditos_cab.FieldByName('indice').AsFloat;
      if totales[10] = 0 then totales[10] := 1;
      datosdb.Filtrar(detcred, 'codprest = ' + '''' + Copy(idanter[1], 1, 5) + '''' + ' and expediente = ' + '''' + Copy(idanter[1], 6, 4) + '''' + ' and estado = ' + '''' + 'I' + '''');
      detcred.First;
      while not detcred.Eof do Begin
        totales[1] := totales[1] + (detcred.FieldByName('amortizacion').AsFloat * totales[10]);
        totales[2] := totales[2] + (detcred.FieldByName('aporte').AsFloat * totales[10]);
        detcred.Next;
      end;
      datosdb.QuitarFiltro(detcred);
    end;
    prestatario.getDatos(Copy(idanter[1], 1, 5));
    list.Linea(0, 0, '   ' + Copy(idanter[1], 1, 5) + '-' + Copy(idanter[1], 6, 4) + '  ' + prestatario.nombre, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(60, list.Lineactual, '', totales[1], 2, 'Arial, normal, 8');
    list.importe(80, list.Lineactual, '', totales[2], 3, 'Arial, normal, 8');
    list.Linea(83, list.Lineactual, idanter[3], 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(90, list.Lineactual, idanter[4], 5, 'Arial, normal, 8', salida, 'N');
    if Length(Trim(idanter[6])) > 0 then list.Linea(96, list.Lineactual, ' *', 6, 'Arial, normal, 8', salida, 'S') else
      list.Linea(96, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');

    totales[3] := totales[3] + totales[1];
    totales[4] := totales[4] + totales[2];
  end;
  totales[1] := 0; totales[2] := 0;
  idanter[3] := ''; idanter[6] := '';
end;

procedure TTCreditos.TotLineaMontosACobrarHistoricos(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar total montos a cobrar
var
  r: TQuery;
Begin
  // Cr�ditos Refinanciados
  r := datosdb.tranSQL('select creditos_detrefinanciados.codprest, creditos_detrefinanciados.expediente, creditos_detrefinanciados.amortizacion, creditos_detrefinanciados.aporte, creditos_detrefinanciados.fechavto, ' +
                       'creditos_detrefinanciados.cuotasref, creditos_detrefinanciados.refcredito, creditos_cabrefinanciados.idcredito, creditos_cabrefinanciados.indice from creditos_detrefinanciados, creditos_cabrefinanciados where fechavto >= ' +
                       '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and tipomov = 1' + ' and creditos_detrefinanciados.codprest = ' +
                       'creditos_cabrefinanciados.codprest and creditos_cabrefinanciados.expediente = creditos_detrefinanciados.expediente ' +
                       ' and idcredito = ' + '''' + idanter[5] + '''' + ' order by codprest, expediente, fechavto');

  ProcesarCreditosRefinanciados(xdesde, xhasta, 'C.Ref.', r, salida);
  // Cr�ditos con Cuotas Refinanciadas
  r := datosdb.tranSQL('select creditos_detrefcuotas.codprest, creditos_detrefcuotas.expediente, creditos_detrefcuotas.amortizacion, creditos_detrefcuotas.aporte, creditos_detrefcuotas.fechavto, ' +
                       'creditos_detrefcuotas.cuotasref, creditos_detrefcuotas.refcredito, creditos_cabrefcuotas.idcredito, creditos_cabrefcuotas.indice from creditos_detrefcuotas, creditos_cabrefcuotas where fechavto >= ' +
                       '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechavto <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and tipomov = 1' + ' and creditos_detrefcuotas.codprest = ' +
                       'creditos_cabrefcuotas.codprest and creditos_cabrefcuotas.expediente = creditos_detrefcuotas.expediente ' +
                       ' and idcredito = ' + '''' + idanter[5] + '''' + ' order by codprest, expediente, fechavto');

  ProcesarCreditosRefinanciados(xdesde, xhasta, 'Cuot.Ref.', r, salida);

  if totales[3] + totales[4] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal Linea:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(60, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 8');
    list.importe(80, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 8');
    list.Linea(90, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    totales[5] := totales[5] + totales[3];
    totales[6] := totales[6] + totales[4];
    totales[3] := 0; totales[4] := 0;
  end;
end;

procedure TTCreditos.ProcesarCreditosRefinanciados(xdesde, xhasta, xtipo: String; r: TQuery; salida: char);
// Objetivo...: Listar Expediente
Begin
  idanter[3] := xtipo;
  r.Open; totales[1] := 0; totales[2] := 0;
  if r.FieldByName('indice').AsFloat > 0 then totales[10] := r.FieldByName('indice').AsFloat else totales[10] := 1;
  idanter[1] := r.FieldByName('codprest').AsString + r.FieldByName('expediente').AsString;
  while not r.Eof do Begin
    //if r.FieldByName('codprest').AsString = '00197' then utiles.msgError(r.FieldByName('amortizacion').AsString);
    if r.FieldByName('codprest').AsString + r.FieldByName('expediente').AsString <> idanter[1] then Begin
      LineaExpediente(xdesde, xhasta, salida);
      idanter[1] := r.FieldByName('codprest').AsString + r.FieldByName('expediente').AsString;
    end;
    totales[1] := totales[1] + (r.FieldByName('amortizacion').AsFloat * totales[10]);
    totales[2] := totales[2] + (r.FieldByName('aporte').AsFloat * totales[10]);
    r.Next;
  end;
  r.Close; r.Free;
  LineaExpediente(xdesde, xhasta, salida);
  totales[1] := 0; totales[2] := 0;
end;
{-------------------------------------------------------------------------------}

procedure TTCreditos.InfPresentarCredito(salida: Char);
// Objetivo...: Presentar Cr�dito
var
  l: TStringList;
Begin
  l := TStringList.Create;
  l.Add(codprest + expediente);
  NoPresentarSubtotales := True;
  ListarCreditosIndividuales(l, salida);
  NoPresentarSubtotales := False;
  l.Destroy;
end;

{-------------------------------------------------------------------------------}

procedure TTCreditos.ListTituloControles(xconcepto: String; salida: char);
// Objetivo...: Titulo Informes de Control
Begin
  infIniciado := True;
  if (salida = 'P') or (salida = 'I') then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Informe de Control - ' + xconcepto, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Expediente      Prestatario', 1, 'Arial, cursiva, 8');
    List.Titulo(36, List.lineactual, 'Concepto', 2, 'Arial, cursiva, 8');
    List.Titulo(65, List.lineactual, 'Monto', 3, 'Arial, cursiva, 8');
    List.Titulo(71, List.lineactual, 'Cuotas', 4, 'Arial, cursiva, 8');
    List.Titulo(78, List.lineactual, 'Categor�a', 5, 'Arial, cursiva, 8');
    if Copy(xconcepto, 1, 19) = 'Cr�ditos Cancelados' then List.Titulo(95, List.lineactual, 'F.Cancel.', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'T') then Begin
    List.LineaTxt(' ', True);
    List.LineaTxt(' Informe de Control - ' + xconcepto, True);
    List.LineaTxt(' ', True);
    if Copy(xconcepto, 1, 19) <> 'Cr�ditos Cancelados' then
      List.LineaTxt('Expediente      Prestatario           Concepto                     Monto Cuotas Categor�a', True)
    else
      List.LineaTxt('Expediente      Prestatario           Concepto                     Monto Cuotas Categor�a        F.Cancel.', True);
    List.LineaTxt(' ', True);
  end;
end;

procedure TTCreditos.ListDetalleInformesControl(salida: char);
// Objetivo...: Listar Detalle de Informes de Control
Begin
  rsql.Open; totales[1] := 0; totales[2] := 0;
  while not rsql.Eof do Begin
    prestatario.getDatos(rsql.FieldByName('codprest').AsString);
    categoria.getDatos(rsql.FieldByName('idcredito').AsString);
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, rsql.FieldByName('codprest').AsString + '-' + rsql.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 24), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(36, list.Lineactual, Copy(rsql.FieldByName('concepto').AsString,1 , 20), 2, 'Arial, normal, 8', salida, 'N');
      if datosdb.verificarSiExisteCampoSQL(rsql, 'monto_real') then
        list.importe(70, list.Lineactual, '', rsql.FieldByName('monto_real').AsFloat, 3, 'Arial, normal, 8')
      else
        list.importe(70, list.Lineactual, '', rsql.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');

      list.importe(76, list.Lineactual, '###', rsql.FieldByName('cantcuotas').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(78, list.Lineactual, Copy(categoria.Descrip, 1, 25), 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(95, list.Lineactual, utiles.sFormatoFecha(rsql.FieldByName('fechacancelacion').AsString), 6, 'Arial, normal, 8', salida, 'S');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt(rsql.FieldByName('codprest').AsString + '-' + rsql.FieldByName('expediente').AsString + '  ' + utiles.StringLongitudFija(Copy(prestatario.nombre, 1, 24), 25), False);
      list.LineaTxt(utiles.StringLongitudFija(rsql.FieldByName('concepto').AsString, 21), False);
      if datosdb.verificarSiExisteCampoSQL(rsql, 'monto_real') then
        list.importeTxt(rsql.FieldByName('monto_real').AsFloat, 12, 2, False)
      else
        list.importeTxt(rsql.FieldByName('monto').AsFloat, 12, 2, False);
      list.LineaTxt(' ', False);
      list.importeTxt(rsql.FieldByName('cantcuotas').AsFloat, 2, 0, False);
      list.LineaTxt(' ', False);
      list.LineaTxt(utiles.StringLongitudFija(categoria.Descrip, 25) + ' ', False);
      list.LineaTxt(utiles.sFormatoFecha(rsql.FieldByName('fechacancelacion').AsString), True);
    end;
    if datosdb.verificarSiExisteCampoSQL(rsql, 'monto_real') then totales[1] := totales[1] + rsql.FieldByName('monto_real').AsFloat else
      totales[1] := totales[1] + rsql.FieldByName('monto').AsFloat;
    totales[2] := totales[2] + 1;
    rsql.Next;
  end;
  rsql.Close; rsql.Free; rsql := Nil;
  if (salida = 'P') or (salida = 'I') then Begin
    List.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    List.Linea(0, 0, 'Total Cr�ditos:    ' + utiles.FormatearNumero(FloatToStr(totales[1])), 1, 'Arial, negrita, 8', salida, 'N');
    List.Linea(40, list.Lineactual, 'Cantidad de Cr�ditos:    ' + FloatToStr(totales[2]), 2, 'Arial, negrita, 8', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end;
  if (salida = 'T') then Begin
    List.LineaTxt('', True);
    List.LineaTxt('Total Cr�ditos:    ' + utiles.FormatearNumero(FloatToStr(totales[1])) + '   ', False);
    List.LineaTxt('Cantidad de Cr�ditos:    ' + FloatToStr(totales[2]), True);
  end;
end;

{===============================================================================}

procedure TTCreditos.ListCreditosOtorgados(xdesde, xhasta: String; salida: char);
// Objetivo...: Generar Informe de Cr�ditos Otorgados
Begin
  if not infIniciado then ListTituloControles('Cr�ditos Otorgados Lapso ' + xdesde + ' - ' + xhasta, salida);
  List.Linea(0, 0, 'Cr�ditos Otorgados', 1, 'Arial, negrita, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  rsql := datosdb.tranSQL('SELECT codprest, expediente, fecha, idcredito, cantcuotas, concepto, monto, monto_real FROM creditos_cab WHERE fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' ORDER BY fecha');
  ListDetalleInformesControl(salida);
end;

procedure TTCreditos.ListDetalleInformesCreditosRefinanciados(xdesde, xhasta: String; salida: char);
// Objetivo...: Generar Informe de Cr�ditos Otorgados
Begin
  if not infIniciado then ListTituloControles('Cr�ditos Refinanciados Lapso ' + xdesde + ' - ' + xhasta, salida);
  List.Linea(0, 0, 'Cr�ditos Refinanciados', 1, 'Arial, negrita, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  rsql := TQuery.Create(nil);
  rsql := datosdb.tranSQL('SELECT codprest, expediente, fecha, idcredito, cantcuotas, concepto, monto, fecha, fecharef FROM creditos_cab WHERE fecharef >= ' + '"' + utiles.sExprFecha2000(xdesde) + '"' + ' AND fecharef <= ' + '"' + utiles.sExprFecha2000(xhasta) + '"');
  ListDetalleInformesControl(salida);
end;

procedure TTCreditos.ListDetalleInformesCuotasRefinanciadas(xdesde, xhasta: String; salida: char);
// Objetivo...: Generar Informe de Cuotas Otorgadas
Begin
  if not infIniciado then ListTituloControles('Cr�ditos Cuotas Refin. Lapso ' + xdesde + ' - ' + xhasta, salida);
  List.Linea(0, 0, 'Cuotas Refinanciadas', 1, 'Arial, negrita, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  rsql := TQuery.Create(nil);
  rsql := datosdb.tranSQL('SELECT creditos_cabrefcuotas.codprest, creditos_cabrefcuotas.expediente, creditos_cabrefcuotas.fecha, creditos_cabrefcuotas.idcredito, creditos_cabrefcuotas.cantcuotas, creditos_cabrefcuotas.concepto, creditos_cabrefcuotas.fecha, ' +
                          ' creditos_detrefcuotas.total AS monto FROM creditos_cabrefcuotas, creditos_detrefcuotas WHERE creditos_cabrefcuotas.codprest = creditos_detrefcuotas.codprest AND creditos_cabrefcuotas.expediente = creditos_detrefcuotas.expediente AND fecharef >= ' + '"' +
                          ' utiles.sExprFecha2000(xdesde) ' + '"' + ' AND fecharef <= ' + '"' + utiles.sExprFecha2000(xhasta) + '"');
  ListDetalleInformesControl(salida);
end;

procedure TTCreditos.ListCreditosCancelados(xdesde, xhasta: String; salida: char);
// Objetivo...: Generar Informe de Cr�ditos Otorgados
Begin
  if not infIniciado then ListTituloControles('Cr�ditos Cancelados Lapso ' + xdesde + ' - ' + xhasta, salida);
  if (salida = 'P') or (salida = 'I') then Begin
    List.Linea(0, 0, 'Cr�ditos Cancelados', 1, 'Arial, negrita, 11', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  end;
  if (salida = 'T') then Begin
    List.LineaTxt('Cr�ditos Cancelados', True);
    List.LineaTxt('', True);
  end;
  rsql := TQuery.Create(nil);
  rsql := datosdb.tranSQL('SELECT codprest, expediente, fecha, idcredito, cantcuotas, concepto, monto, fecha, fecharef, fechacancelacion FROM creditos_cabhist WHERE fechacancelacion >= ' + '"' + utiles.sExprFecha2000(xdesde) + '"' + ' AND fechacancelacion <= ' + '"' + utiles.sExprFecha2000(xhasta) + '"');
  ListDetalleInformesControl(salida);
end;

{ ----------------------------------------------------------------------------- }

procedure TTCreditos.ListInformeExpedientesViaJudicial(salida: char);
// Objetivo...: Listar Cr�ditos en V�a Judicial
var
  r: TQuery;
  ll1, l2: Boolean;
Begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Listado de Expedientes en V�a Judicial', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, '     Prest/Epte.', 1, 'Arial, cursiva, 8');
    List.Titulo(12, List.lineactual, 'Prestatario', 2, 'Arial, cursiva, 8');
    List.Titulo(40, List.lineactual, 'Enviado', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(56, List.lineactual, 'Observaciones', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if salida = 'X' then Begin
    c1 := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 9.5);
    excel.setString('a' + l1, 'a' + l1, 'Listado de Expedientes en V�a Judicial', 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 12);
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Prest/Epte.', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 37);
    excel.setString('b' + l1, 'b' + l1, 'Prestatario', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 14);
    excel.setString('c' + l1, 'c' + l1, 'Enviado', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 10);
    excel.setString('d' + l1, 'd' + l1, 'Monto', 'Arial, negrita, 10');
    excel.setString('e' + l1, 'e' + l1, 'F.Mov.', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('f' + l1, 'f' + l1, 34);
    excel.setString('f' + l1, 'f' + l1, 'Observaciones', 'Arial, negrita, 10');
    Inc(c1);
  end;

  IniciarArreglos;
  municipio.conectar;

  r    := setExpedientesViaJudicial;
  rsql := municipio.setmunicipiosAlf;
  rsql.Open;
  r.Open;
  ll1 := False;
  while not rsql.Eof do Begin
    municipio.getDatos(rsql.FieldByName('id').AsString);

    r.First; idanter[1] := '';
    while not r.Eof do Begin
      prestatario.getDatos(r.FieldByName('codprest').AsString);
      if (prestatario.codpost = municipio.codpost) and (prestatario.orden = municipio.orden) then Begin

        if not ll1 then Begin
          if (salida = 'P') or (salida = 'I') then Begin
            if l2 then list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
            list.Linea(0, 0, 'Municipio/Comuna:   ' + municipio.codpost + '-' + municipio.orden + '  ' + municipio.nombre, 1, 'Arial, negrita, 9', salida, 'S');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
          end;
          if salida = 'X' then Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, 'Municipio/Comuna:   ' + municipio.codpost + '-' + municipio.orden + '  ' + municipio.nombre, 'Arial, negrita, 12');
          end;
          ll1 := True;
          l2  := True;
        end;

        if r.FieldByName('idcredito').AsString <> idanter[1] then Begin
          categoria.getDatos(r.FieldByName('idcredito').AsString);
          if Length(Trim(idanter[1])) > 0 then
            if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, '   ' + categoria.Items + '-' + categoria.Descrip, 1, 'Arial, negrita, 8', salida, 'S');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
          end;
          if salida = 'X' then Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, '   ' + categoria.Items + '-' + categoria.Descrip, 'Arial, negrita, 9');
          end;
          idanter[1] := r.FieldByName('idcredito').AsString;
        end;

        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '     ' + prestatario.codigo + '-' + r.FieldByName('expediente').AsString, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(12, list.Lineactual, Copy(prestatario.nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(40, list.Lineactual, utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 3, 'Arial, normal, 8', salida, 'N');
          list.importe(55, list.Lineactual, '', r.FieldByName('monto_real').AsFloat, 4, 'Arial, normal, 8');
        end;
        if salida = 'X' then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '     ' + prestatario.codigo + '-' + r.FieldByName('expediente').AsString, 'Arial, normal, 8');
          excel.setString('b' + l1, 'b' + l1, Copy(prestatario.nombre, 1, 30), 'Arial, normal, 8');
          excel.setString('c' + l1, 'c' + l1, '''' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 'Arial, normal, 8');
          excel.setReal('d' + l1, 'd' + l1, r.FieldByName('monto_real').AsFloat, 'Arial, normal, 8');
        end;
        ListarSeguimientoExpediente(prestatario.codigo, r.FieldByName('expediente').AsString, salida);
      end;
      r.Next;
    end;

    ll1 := False;
    rsql.Next;
  end;

  r.Close; r.Free;
  rsql.Close; rsql.Free;
  municipio.desconectar;

  if (salida = 'P') or (salida = 'I') then
    if l2 then list.FinList else utiles.msgError('No hay Expedientes en V�a Judicial ...!');
  if salida = 'X' then excel.Visulizar;
end;

//------------------------------------------------------------------------------

procedure TTCreditos.ListarGastosySelladosAdministrarivos(xdesde, xhasta: String; salida: char);
var
  comprobante: string;

procedure ListTotal(salida: char);
Begin
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', '----------------------------------------------------------------------------', 2, 'Arial, normal, 8');
  list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Total Linea:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(65, list.Lineactual, '', totales[7], 2, 'Arial, negrita, 9');
  list.importe(80, list.Lineactual, '', totales[3], 3, 'Arial, negrita, 9');
  list.importe(95, list.Lineactual, '', totales[4], 4, 'Arial, negrita, 9');
  list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  totales[5] := totales[5] + totales[3];
  totales[6] := totales[6] + totales[4];
  totales[8] := totales[8] + totales[7];
  totales[3] := 0; totales[4] := 0; totales[7] := 0;
end;

procedure ListarLinea(xcodprest: String; salida: char);
Begin
  prestatario.getDatos(Copy(idanter[2], 1, 5));
  getDatos(Copy(idanter[2], 1, 5), Copy(idanter[2], 6, 4));
  list.Linea(0, 0, '     ' + idanter[3] + '  ' + Copy(idanter[2], 1, 5) + '-' + Copy(idanter[2], 6, 4) + '   ' + copy(prestatario.nombre, 1, 25), 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(42, list.lineactual, comprobante, 2, 'Arial, normal, 8', salida, 'N');
  list.importe(70, list.Lineactual, '', monto_real, 3, 'Arial, normal, 8');
  list.importe(85, list.Lineactual, '', totales[1], 4, 'Arial, normal, 8');
  list.importe(95, list.Lineactual, '', totales[2], 5, 'Arial, normal, 8');
  list.Linea(95, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
  totales[3] := totales[3] + totales[1];
  totales[4] := totales[4] + totales[2];
  totales[7] := totales[7] + monto_real;
  totales[1] := 0; totales[2] := 0;
end;

Begin
  if (salida = 'I') or (salida = 'P') then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Listado de Sellados y Gastos Administrativos Lapso : ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, '     Fecha      Prest/Epte.     Prestatario', 1, 'Arial, cursiva, 8');
    List.Titulo(42, List.lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
    List.Titulo(60, List.lineactual, 'Monto Cr�dito', 3, 'Arial, cursiva, 8');
    List.Titulo(76, List.lineactual, 'G.Administ.', 4, 'Arial, cursiva, 8');
    List.Titulo(89, List.lineactual, 'Sellado', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  rsql := datosdb.tranSQL('select movgastoscreditos.*, creditos_cab.idcredito from movgastoscreditos, creditos_cab where movgastoscreditos.codprest = creditos_cab.codprest and movgastoscreditos.expediente = creditos_cab.expediente and ' +
                          ' movgastoscreditos.fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and movgastoscreditos.fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by idcredito, fecha, codprest, idgasto');

  rsql.Open; idanter[1] := ''; totales[1] := 0; totales[2] := 0; idanter[2] := ''; idanter[3] := ''; idanter[4] := ''; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0;
  idanter[2] := rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString;
  idanter[4] := rsql.FieldByName('idcredito').AsString;
  while not rsql.Eof do Begin
    if rsql.FieldByName('idcredito').AsString <> idanter[1] then Begin
      if (totales[3] + totales[4] <> 0) then ListTotal(salida);
      categoria.getDatos(rsql.FieldByName('idcredito').AsString);
      list.Linea(0, 0, 'Linea: ' + categoria.Descrip, 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      idanter[1] := rsql.FieldByName('idcredito').AsString;
    end;

    if (rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString) <> idanter[2] then ListarLinea(idanter[2], salida);
    idanter[2] := rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString;
    idanter[3] := utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString);
    if rsql.FieldByName('idgasto').AsString = '001' then totales[1] := rsql.FieldByName('monto').AsFloat;
    if rsql.FieldByName('idgasto').AsString = '002' then totales[2] := rsql.FieldByName('monto').AsFloat;
    idanter[4] := rsql.FieldByName('idcredito').AsString;
    if (length(trim(rsql.FieldByName('referencia').AsString)) > 0) then comprobante := rsql.FieldByName('referencia').AsString;

    rsql.Next;
  end;

  ListarLinea(idanter[2], salida);
  if (totales[3] + totales[4]) <> 0 then ListTotal(salida);

  if (totales[5] + totales[6]) <> 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(65, list.Lineactual, '', totales[8], 2, 'Arial, negrita, 9');
    list.importe(80, list.Lineactual, '', totales[5], 3, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', totales[6], 4, 'Arial, negrita, 9');
    list.Linea(95, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');
    totales[5] := 0; totales[6] := 0; totales[8] := 0;
  end else
    list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 12', salida, 'S');

  rsql.Close; rsql.Free;

  PresentarInforme;
end;

{ ----------------------------------------------------------------------------- }

procedure TTCreditos.ListarCreditosSaldados(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Aquellos Cr�ditos Saldados
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Cr�ditos Saldados Lapso : ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'F.Otor.', 1, 'Arial, cursiva, 8');
  List.Titulo(10, list.Lineactual, 'Prest/Epte.  Prestatario', 2, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'Monto Cr�dito', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  datosdb.Filtrar(creditos_cab, 'estado = ' + '''' + 'C' + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  creditos_cab.First; listdat := False;
  while not creditos_cab.Eof do Begin
    prestatario.getDatos(creditos_cab.FieldByName('codprest').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(creditos_cab.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, creditos_cab.FieldByName('codprest').AsString + '-' + creditos_cab.FieldByName('expediente').AsString + '  ' + prestatario.nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.Importe(95, list.Lineactual, '', creditos_cab.FieldByName('monto_real').AsFloat, 3, 'Arial, normal, 8');
    list.Linea(95, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    listdat := True;
    creditos_cab.Next;
  end;
  datosdb.QuitarFiltro(creditos_cab);
  if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 10', salida, 'S');
  list.FinList;
end;

{ ----------------------------------------------------------------------------- }

procedure TTCreditos.PresentarInforme;
// Objetivo...: Presentar Informe
Begin
  if tipoList <> 'T' then Begin
    list.FinList;
    list.altopag := 0; list.m := 0;
  end else list.FinalizarExportacion;
  infIniciado := False;
end;

procedure TTCreditos.ExportarInforme(xarchivo: String);
Begin
  list.ExportarInforme(dbs.DirSistema + '\attach\' + xarchivo + '.doc');
  infIniciado := False;
end;

procedure TTCreditos.FinalizarExportacionInforme;
Begin
  list.FinalizarExportacion;
end;


{*******************************************************************************}

procedure TTCreditos.TransferirHistorico(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Registro Hist�rico los datos ingresados
var
  refcredito, refcuota: String;
  segexpteshist, cheques_creditoshist: TTable;
Begin
  getDatos(xcodprest, xexpediente);
  refcredito := Refinanciado;
  refcuota   := RefinanciaCuota;

  creditos_cabhist := nil; creditos_dethist := nil; gastos_hist := nil;
  creditos_cabhist := datosdb.openDB('creditos_cabhist', '');
  creditos_dethist := datosdb.openDB('creditos_dethist', '');
  gastos_hist      := datosdb.openDB('movgastoscreditoshist', '');
  Refinanciado     := '';
  detcred          := creditos_det;   // Apuntadores de tablas

  cab_credito      := creditos_cab;
  cab_creditohist  := creditos_cabhist;
  det_creditos     := creditos_det;
  det_creditohist  := creditos_dethist;

  TransferirRegistrosAlHistorico(xcodprest, xexpediente);

  { Verificamos las refinanciaciones, para su transferencia }
  if refcredito = 'S' then TransferirHistorico_CreditoRefinanciado(xcodprest, xexpediente);
  if refcuota   = 'S' then TransferirHistorico_CreditoCuotasRefinanciadas(xcodprest, xexpediente);
  datosdb.closeDB(creditos_cab);
  if not creditos_cab.Active       then creditos_cab.Open;
  datosdb.closeDB(creditos_det);
  if not creditos_det.Active       then creditos_det.Open;

  { Transferencias Varias }

  // Transferencia de datos en v�a judicial
  segexpteshist := datosdb.openDB('segexpedienteshist', '');
  if BuscarItemsSeg(xcodprest, xexpediente, '001') then Begin
    while not segexptes.Eof do Begin
      if (segexptes.FieldByName('codprest').AsString <> xcodprest) or (segexptes.FieldByName('expediente').AsString <> xexpediente) then Break;
      if datosdb.Buscar(segexpteshist, 'codprest', 'expediente', 'items', segexptes.FieldByName('codprest').AsString, segexptes.FieldByName('expediente').AsString, segexptes.FieldByName('items').AsString) then segexpteshist.Edit else segexpteshist.Append;
      segexpteshist.FieldByName('codprest').AsString   := segexptes.FieldByName('codprest').AsString;
      segexpteshist.FieldByName('expediente').AsString := segexptes.FieldByName('expediente').AsString;
      segexpteshist.FieldByName('items').AsString      := segexptes.FieldByName('items').AsString;
      segexpteshist.FieldByName('fecha').AsString      := segexptes.FieldByName('fecha').AsString;
      segexpteshist.FieldByName('concepto').AsString   := segexptes.FieldByName('concepto').AsString;
      try
        segexpteshist.Post
       except
        segexpteshist.Cancel
      end;
      segexptes.Next;
    end;
  end;
  datosdb.tranSQL('delete from ' + segexptes.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  datosdb.closeDB(segexptes); segexptes.Open;
  datosdb.closedb(segexpteshist);

  // Transferencia de Cheques Entregados por Cr�ditos
  cheques_creditoshist := datosdb.openDB('cheques_creditoshist', '');
  datosdb.Filtrar(cheques_creditos, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  cheques_creditos.First;
  while not cheques_creditos.Eof do Begin
    if datosdb.Buscar(cheques_creditoshist, 'codprest', 'expediente', 'items', cheques_creditos.FieldByName('codprest').AsString, cheques_creditos.FieldByName('expediente').AsString, cheques_creditos.FieldByName('items').AsString) then
      cheques_creditoshist.Edit else cheques_creditoshist.Append;
    cheques_creditoshist.FieldByName('codprest').AsString   := cheques_creditos.FieldByName('codprest').AsString;
    cheques_creditoshist.FieldByName('expediente').AsString := cheques_creditos.FieldByName('expediente').AsString;
    cheques_creditoshist.FieldByName('items').AsString      := cheques_creditos.FieldByName('items').AsString;
    cheques_creditoshist.FieldByName('nrocheque').AsString  := cheques_creditos.FieldByName('nrocheque').AsString;
    cheques_creditoshist.FieldByName('codcta').AsString     := cheques_creditos.FieldByName('codcta').AsString;
    try
      cheques_creditoshist.Post
     except
      cheques_creditoshist.Cancel
    end;
    cheques_creditos.Next;
  end;
  datosdb.QuitarFiltro(cheques_creditos);
  datosdb.tranSQL('delete from ' + cheques_creditos.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  datosdb.closedb(cheques_creditos); cheques_creditos.Open;
  datosdb.closedb(cheques_creditoshist);

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Transfiriendo a Hist�rico Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.TransferirHistorico_CreditoRefinanciado(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Registro Hist�rico los datos ingresados, de los cr�ditos refinanciados
Begin
  creditos_cabhist := nil; creditos_dethist := nil;
  creditos_cabhist := datosdb.openDB('creditos_cabhistrefinanciados', '');
  creditos_dethist := datosdb.openDB('creditos_dethistrefinanciados', '');

  Refinanciado     := 'S';
  conectar_creditosRefinanciados;
  detcred          := creditos_detrefinanciados;      // Apuntadores de tablas

  cab_credito      := creditos_cabrefinanciados;
  cab_creditohist  := creditos_cabhist;
  det_creditos     := creditos_detrefinanciados;
  det_creditohist  := creditos_dethist;

  TransferirRegistrosAlHistorico(xcodprest, xexpediente);
  desconectar_creditosRefinanciados;
end;

procedure TTCreditos.TransferirHistorico_CreditoCuotasRefinanciadas(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Hist�rico el cr�dito con cuotas refinanciadas
Begin
  creditos_cabhist := nil; creditos_dethist := nil;
  creditos_cabhist := datosdb.openDB('creditos_cabhistrefcuotas', '');
  creditos_dethist := datosdb.openDB('creditos_dethistrefcuotas', '');

  RefinanciaCuota  := 'S';
  conectar_cuotasRefinanciadas;
  detcred          := creditos_detrefcuotas;      // Apuntadores de tablas

  cab_credito      := creditos_cabrefcuotas;
  cab_creditohist  := creditos_cabhist;
  det_creditos     := creditos_detrefcuotas;
  det_creditohist  := creditos_dethist;

  TransferirRegistrosAlHistorico(xcodprest, xexpediente);
  desconectar_cuotasRefinanciadas;
end;

function  TTCreditos.verificarSiExisteExpedienteHistorico(xcodprest, xexpediente: String): Boolean;
// Objetivo...: Verificar si Existe Expediente en registro historico
Begin
  creditos_cabhist.Open;
  if datosdb.Buscar(creditos_cabhist, 'Codprest', 'Expediente', xcodprest, xexpediente) then Begin
    Idcredito := creditos_cabhist.FieldByName('idcredito').AsString;
    credito_historico := True;
    Result := True;
  end else Begin
    Result := False;
    credito_historico := False;
  end;
  creditos_cabhist.Close;
end;

procedure TTCreditos.getDatosExpedienteHistorico(xcodprest, xexpediente: String);
// Objetivo...: Recuperar Instancia de Expediente Historico
Begin
  creditos_cabhist.Open;
  if datosdb.Buscar(creditos_cabhist, 'Codprest', 'Expediente', xcodprest, xexpediente) then Begin
    Fecha             := utiles.sFormatoFecha(creditos_cabhist.FieldByName('fecha').AsString);
    Idcredito         := creditos_cabhist.FieldByName('idcredito').AsString;
    Formapago         := creditos_cabhist.FieldByName('formapago').AsString;
    Cantcuotas        := utiles.sLlenarIzquierda(creditos_cabhist.FieldByName('cantcuotas').AsString, 2, '0');
    Pergracia         := creditos_cabhist.FieldByName('pergracia').AsString;
    Intervalopg       := creditos_cabhist.FieldByName('intervalopg').AsString;
    Concepto          := creditos_cabhist.FieldByName('concepto').AsString;
    Monto             := creditos_cabhist.FieldByName('monto').AsFloat;
    Entrega           := creditos_cabhist.FieldByName('entrega').AsFloat;
    Aporte            := creditos_cabhist.FieldByName('aporte').AsFloat;
    Indice_credito    := creditos_cabhist.FieldByName('indice').AsFloat;
    Interes           := creditos_cabhist.FieldByName('interes').AsFloat;
    InteresRef        := creditos_cabhist.FieldByName('interesRef').AsFloat;
    Refinanciado      := creditos_cabhist.FieldByName('refinancia').AsString;
    RefinanciaCuota   := creditos_cabhist.FieldByName('refcuotas').AsString;
    TipoIndice        := creditos_cabhist.FieldByName('tipoindice').AsString;
    TipoCalculo       := creditos_cabhist.FieldByName('tipocalculo').AsString;
    Fechappago        := utiles.sFormatoFecha(creditos_cabhist.FieldByName('fechappago').AsString);
    credito_historico := True;
  end else Begin
    Fecha := ''; Idcredito := ''; Formapago := ''; Cantcuotas := ''; pergracia := ''; concepto := ''; Monto := 0; Aporte := 0; Indice_credito := 0; Interes := 0; Refinanciado := ''; RefinanciaCuota := ''; interesRef := 0; Intervalopg := ''; TipoIndice := ''; TipoCalculo := ''; Fechappago := ''; Entrega := 0;
    credito_historico := False;
  end;
  Codprest   := xcodprest;
  Expediente := xexpediente;
  creditos_cabhist.Close;
end;

function TTCreditos.setCreditosHistoricos(xcodprest: String): TQuery;
// Objetivo...: Devolver los cr�ditos historicos para el expediente solicitado
Begin
  Result := datosdb.tranSQL('SELECT * FROM creditos_cabhist WHERE codprest = ' + '"' +  xcodprest + '"');
end;

function TTCreditos.setDetalleCreditosHistoricos(xcodprest, xexpediente: String): TQuery;
// Objetivo...: Devolver los cr�ditos historicos para el expediente solicitado
Begin
  Result := datosdb.tranSQL('SELECT * FROM creditos_dethist WHERE codprest = ' + '"' +  xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND tipomov = 1' + ' ORDER BY items');
end;

function TTCreditos.setExpedientesHistoricos: TQuery;
// Objetivo...: Devolver los cr�ditos historicos
Begin
  Result := datosdb.tranSQL('SELECT codprest, expediente, monto, indice FROM creditos_cabhist ORDER BY codprest, expediente');
end;

function TTCreditos.setExpedientesHistoricos(xcodprest: String): TQuery;
// Objetivo...: Devolver los cr�ditos historicos
Begin
  Result := datosdb.tranSQL('SELECT codprest, fecha, concepto, expediente, monto, indice FROM creditos_cabhist where codprest = ' + '''' + xcodprest + '''' + ' ORDER BY expediente');
end;

procedure TTCreditos.CancelarCredito(xcodprest, xexpediente, xfecha: String);
// Objetivo...: Marcar Cr�dito como cancelado
Begin
  datosdb.tranSQL('UPDATE creditos_cabhist SET cancelado = ' + '"' + 'S' + '"' + ', fechacancelacion = ' + '"' + utiles.sExprFecha2000(xfecha) + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
end;

procedure TTCreditos.DarDeBajaCredito(xcodprest, xexpediente, xfecha, xmotivobaja: String);
// Objetivo...: Marcar Cr�dito como cancelado
Begin
  datosdb.tranSQL('UPDATE creditos_cabhist SET cancelado = ' + '"' + 'B' + '"' + ', motivobaja = ' + '"' + xmotivobaja + '"' + ', fechacancelacion = ' + '"' + utiles.sExprFecha2000(xfecha) + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
end;

{*******************************************************************************}

procedure TTCreditos.TransferirRegistrosAlHistorico(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Registro Hist�rico los datos ingresados
var
  ec: Boolean;
Begin
  if datosdb.Buscar(cab_credito, 'Codprest', 'Expediente', xcodprest, xexpediente) then Begin
    cab_creditohist.Open; det_creditohist.Open;
    if gastos_hist <> Nil then gastos_hist.Open;
    if datosdb.Buscar(cab_creditohist, 'codprest', 'expediente', xcodprest, xexpediente) then cab_creditohist.Edit else cab_creditohist.Append;
    cab_creditohist.FieldByName('codprest').AsString    := xcodprest;
    cab_creditohist.FieldByName('expediente').AsString  := xexpediente;
    cab_creditohist.FieldByName('monto').AsFloat        := cab_credito.FieldByName('monto').AsFloat;
    cab_creditohist.FieldByName('entrega').AsFloat      := cab_credito.FieldByName('entrega').AsFloat;
    cab_creditohist.FieldByName('fecha').AsString       := cab_credito.FieldByName('fecha').AsString;
    cab_creditohist.FieldByName('idcredito').AsString   := cab_credito.FieldByName('idcredito').AsString;
    cab_creditohist.FieldByName('aporte').AsFloat       := cab_credito.FieldByName('aporte').AsFloat;
    cab_creditohist.FieldByName('formapago').AsString   := cab_credito.FieldByName('formapago').AsString;
    cab_creditohist.FieldByName('indice').AsFloat       := cab_credito.FieldByName('indice').AsFloat;
    cab_creditohist.FieldByName('tipoindice').AsString  := cab_credito.FieldByName('tipoindice').AsString;
    cab_creditohist.FieldByName('cantcuotas').AsString  := cab_credito.FieldByName('cantcuotas').AsString;
    cab_creditohist.FieldByName('pergracia').AsString   := cab_credito.FieldByName('pergracia').AsString;
    cab_creditohist.FieldByName('concepto').AsString    := cab_credito.FieldByName('concepto').AsString;
    cab_creditohist.FieldByName('interes').AsFloat      := cab_credito.FieldByName('interes').AsFloat;
    cab_creditohist.FieldByName('estado').AsString      := cab_credito.FieldByName('estado').AsString;
    cab_creditohist.FieldByName('refinancia').AsString  := cab_credito.FieldByName('refinancia').AsString;
    cab_creditohist.FieldByName('refcuotas').AsString   := cab_credito.FieldByName('refcuotas').AsString;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'fecharef', dbs.baseDat)         then cab_creditohist.FieldByName('fecharef').AsString := cab_credito.FieldByName('fecharef').AsString;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'fechacancelacion', dbs.baseDat) then cab_creditohist.FieldByName('fechacancelacion').AsString := cab_credito.FieldByName('fechacancelacion').AsString;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'intervalopg', dbs.baseDat) then cab_creditohist.FieldByName('intervalopg').AsString := cab_credito.FieldByName('intervalopg').AsString;
    cab_creditohist.FieldByName('tipocalculo').AsString := cab_credito.FieldByName('tipocalculo').AsString;
    cab_creditohist.FieldByName('fechappago').AsString  := cab_credito.FieldByName('fechappago').AsString;
    cab_creditohist.FieldByName('monto_real').AsFloat   := cab_credito.FieldByName('monto_real').AsFloat;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'indicecalculo', dbs.baseDat) then cab_creditohist.FieldByName('indicecalculo').AsString := cab_credito.FieldByName('indicecalculo').AsString; 
    try
      cab_creditohist.Post
     except
      cab_creditohist.Cancel
    end;

    ec := datosdb.verificarSiExisteCampo(det_creditohist.TableName, 'fecharef', dbs.baseDat);
    datosdb.Filtrar(det_creditos, 'codprest = ' + xcodprest + ' AND expediente = ' + xexpediente);
    det_creditos.First;
    while not det_creditos.Eof do Begin
      if datosdb.Buscar(det_creditohist, 'codprest', 'expediente', 'items', 'recibo', det_creditos.FieldByName('codprest').AsString, det_creditos.FieldByName('expediente').AsString, det_creditos.FieldByName('items').AsString, det_creditos.FieldByName('recibo').AsString) then det_creditohist.Edit else det_creditohist.Append;
      det_creditohist.FieldByName('codprest').AsString    := det_creditos.FieldByName('codprest').AsString;
      det_creditohist.FieldByName('expediente').AsString  := det_creditos.FieldByName('expediente').AsString;
      det_creditohist.FieldByName('items').AsString       := det_creditos.FieldByName('items').AsString;
      det_creditohist.FieldByName('recibo').AsString      := det_creditos.FieldByName('recibo').AsString;
      det_creditohist.FieldByName('concepto').AsString    := det_creditos.FieldByName('concepto').AsString;
      det_creditohist.FieldByName('amortizacion').AsFloat := det_creditos.FieldByName('amortizacion').AsFloat;
      det_creditohist.FieldByName('aporte').AsFloat       := det_creditos.FieldByName('aporte').AsFloat;
      det_creditohist.FieldByName('total').AsFloat        := det_creditos.FieldByName('total').AsFloat;
      det_creditohist.FieldByName('fechavto').AsString    := det_creditos.FieldByName('fechavto').AsString;
      det_creditohist.FieldByName('saldo').AsFloat        := det_creditos.FieldByName('saldo').AsFloat;
      det_creditohist.FieldByName('saldocuota').AsFloat   := det_creditos.FieldByName('saldocuota').AsFloat;
      det_creditohist.FieldByName('tipomov').AsInteger    := det_creditos.FieldByName('tipomov').AsInteger;
      det_creditohist.FieldByName('refpago').AsString     := det_creditos.FieldByName('refpago').AsString;
      det_creditohist.FieldByName('estado').AsString      := det_creditos.FieldByName('estado').AsString;
      det_creditohist.FieldByName('interes').AsFloat      := det_creditos.FieldByName('interes').AsFloat;
      det_creditohist.FieldByName('indice').AsFloat       := det_creditos.FieldByName('indice').AsFloat;
      det_creditohist.FieldByName('refinancia').AsString  := det_creditos.FieldByName('refinancia').AsString;
      if ec then det_creditohist.FieldByName('fecharef').AsString := det_creditos.FieldByName('fecharef').AsString;
      det_creditohist.FieldByName('cuotasref').AsString   := det_creditos.FieldByName('cuotasref').AsString;
      det_creditohist.FieldByName('refcredito').AsString  := det_creditos.FieldByName('refcredito').AsString;
      det_creditohist.FieldByName('descuento').AsFloat    := det_creditos.FieldByName('descuento').AsFloat;
      det_creditohist.FieldByName('tasaint').AsFloat      := det_creditos.FieldByName('tasaint').AsFloat;
      det_creditohist.FieldByName('montoint').AsFloat     := det_creditos.FieldByName('montoint').AsFloat;
      det_creditohist.FieldByName('fechapago').AsString   := det_creditos.FieldByName('fechapago').AsString;
      try
        det_creditohist.Post
       except
        det_creditohist.Cancel
      end;
      det_creditos.Next;
    end;

    datosdb.QuitarFiltro(det_creditos);

    datosdb.refrescar(cab_creditohist);
    datosdb.refrescar(det_creditohist);

    // Quitamos el expediente transferido
    datosdb.tranSQL('DELETE FROM ' + cab_credito.TableName  + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
    datosdb.tranSQL('DELETE FROM ' + det_creditos.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
    datosdb.refrescar(cab_credito);
    datosdb.refrescar(det_creditos);

    datosdb.closeDB(cab_creditohist);
    datosdb.closeDB(det_creditohist);

    // Transferimos los Gastos Administrativos
    if gastos_hist <> Nil then Begin
      rsql := datosdb.tranSQL('select * from ' + gastos.TableName + ' where codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
      rsql.Open;
      while not rsql.Eof do Begin
        if BuscarGasto(rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString, rsql.FieldByName('items').AsString) then gastos_hist.Edit else gastos_hist.Append;
        gastos_hist.FieldByName('codprest').AsString   := rsql.FieldByName('codprest').AsString;
        gastos_hist.FieldByName('expediente').AsString := rsql.FieldByName('expediente').AsString;
        gastos_hist.FieldByName('items').AsString      := rsql.FieldByName('items').AsString;
        gastos_hist.FieldByName('idgasto').AsString    := rsql.FieldByName('idgasto').AsString;
        gastos_hist.FieldByName('recibo').AsString     := rsql.FieldByName('recibo').AsString;
        gastos_hist.FieldByName('fecha').AsString      := rsql.FieldByName('fecha').AsString;
        gastos_hist.FieldByName('concepto').AsString   := rsql.FieldByName('concepto').AsString;
        gastos_hist.FieldByName('monto').AsFloat       := rsql.FieldByName('monto').AsFloat;
        gastos_hist.FieldByName('estado').AsString     := rsql.FieldByName('estado').AsString;
        try
          gastos_hist.Post
         except
          gastos_hist.Cancel
        end;
        rsql.Next;
      end;
      rsql.Close; rsql.Free;
      datosdb.closeDB(gastos_hist);

      datosdb.tranSQL('delete from ' + gastos.TableName + ' where codprest = ' + '"' + xcodprest + '"' + ' and expediente = ' + '"' + xexpediente + '"');
    end;
  end;
end;

{ ****************************************************************************** }

procedure TTCreditos.RecuperarHistorico(xcodprest, xexpediente: String);
// Objetivo...: Transferir del Registro Hist�rico al Original
var
  refcredito, refcuota: String;
  segexpteshist, cheques_creditoshist: TTable;
Begin
  creditos_cabhist := nil; creditos_dethist := nil; gastos_hist := nil;
  creditos_cabhist := datosdb.openDB('creditos_cabhist', '');
  creditos_dethist := datosdb.openDB('creditos_dethist', '');
  gastos_hist      := datosdb.openDB('movgastoscreditoshist', '');
  Refinanciado     := '';
  detcred          := creditos_det;   // Apuntadores de tablas

  cab_credito      := creditos_cab;
  cab_creditohist  := creditos_cabhist;
  det_creditos     := creditos_det;
  det_creditohist  := creditos_dethist;

  creditos_cabhist.Open;
  if datosdb.Buscar(creditos_cabhist, 'codprest', 'expediente', xcodprest, xexpediente) then Begin
    refcredito := creditos_cabhist.FieldByName('refinancia').AsString;
    refcuota   := creditos_cabhist.FieldByName('refcuotas').AsString;
  end else Begin
    refcredito := '';
    refcuota   := '';
  end;

  RecuperarRegistrosDelHistorico(xcodprest, xexpediente);

  { Verificamos las refinanciaciones, para su transferencia }
  if refcredito = 'S' then RecuperarHistorico_CreditoRefinanciado(xcodprest, xexpediente);  
  if refcuota   <> '' then RecuperarHistorico_CreditoCuotasRefinanciadas(xcodprest, xexpediente);
  datosdb.closeDB(creditos_cab);
  if not creditos_cab.Active       then creditos_cab.Open;
  datosdb.closeDB(creditos_det);
  if not creditos_det.Active       then creditos_det.Open;

  { Transferencias Varias }

  // Transferencia de datos en v�a judicial
  segexpteshist := datosdb.openDB('segexpedienteshist', '');
  if datosdb.Buscar(segexpteshist, 'codprest', 'expediente', 'items', xcodprest, xexpediente, '001') then Begin
    while not segexpteshist.Eof do Begin
      if (segexpteshist.FieldByName('codprest').AsString <> xcodprest) or (segexpteshist.FieldByName('expediente').AsString <> xexpediente) then Break;
      if datosdb.Buscar(segexptes, 'codprest', 'expediente', 'items', segexpteshist.FieldByName('codprest').AsString, segexpteshist.FieldByName('expediente').AsString, segexpteshist.FieldByName('items').AsString) then segexptes.Edit else segexptes.Append;
      segexptes.FieldByName('codprest').AsString   := segexpteshist.FieldByName('codprest').AsString;
      segexptes.FieldByName('expediente').AsString := segexpteshist.FieldByName('expediente').AsString;
      segexptes.FieldByName('items').AsString      := segexpteshist.FieldByName('items').AsString;
      segexptes.FieldByName('fecha').AsString      := segexpteshist.FieldByName('fecha').AsString;
      segexptes.FieldByName('concepto').AsString   := segexpteshist.FieldByName('concepto').AsString;
      try
        segexptes.Post
       except
        segexptes.Cancel
      end;
      segexpteshist.Next;
    end;
  end;
  datosdb.closeDB(segexptes); segexptes.Open;
  datosdb.tranSQL('delete from ' + segexpteshist.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  datosdb.closedb(segexpteshist);

  // Transferencia de Cheques Entregados por Cr�ditos
  cheques_creditoshist := datosdb.openDB('cheques_creditoshist', '');
  if datosdb.Buscar(cheques_creditoshist, 'codprest', 'expediente', xcodprest, xexpediente) then Begin
    if datosdb.Buscar(cheques_creditos, 'codprest', 'expediente', cheques_creditoshist.FieldByName('codprest').AsString, cheques_creditoshist.FieldByName('expediente').AsString) then cheques_creditos.Edit else cheques_creditos.Append;
    cheques_creditos.FieldByName('codprest').AsString   := cheques_creditoshist.FieldByName('codprest').AsString;
    cheques_creditos.FieldByName('expediente').AsString := cheques_creditoshist.FieldByName('expediente').AsString;
    cheques_creditos.FieldByName('nrocheque').AsString  := cheques_creditoshist.FieldByName('nrocheque').AsString;
    cheques_creditos.FieldByName('codcta').AsString     := cheques_creditoshist.FieldByName('codcta').AsString;
    try
      cheques_creditos.Post
     except
      cheques_creditos.Cancel
    end;
  end;
  datosdb.closedb(cheques_creditos); cheques_creditos.Open;
  datosdb.tranSQL('delete from ' + cheques_creditoshist.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  datosdb.closedb(cheques_creditoshist);

  // Transferencia de Cheques Entregados por Cr�ditos
  cheques_creditoshist := datosdb.openDB('cheques_creditoshist', '');
  cheques_creditoshist.Open;
  datosdb.Filtrar(cheques_creditoshist, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  cheques_creditoshist.First;
  while not cheques_creditoshist.Eof do Begin
    if datosdb.Buscar(cheques_creditos, 'codprest', 'expediente', 'items', cheques_creditoshist.FieldByName('codprest').AsString, cheques_creditoshist.FieldByName('expediente').AsString, cheques_creditoshist.FieldByName('items').AsString) then
      cheques_creditos.Edit else cheques_creditos.Append;
    cheques_creditos.FieldByName('codprest').AsString   := cheques_creditoshist.FieldByName('codprest').AsString;
    cheques_creditos.FieldByName('expediente').AsString := cheques_creditoshist.FieldByName('expediente').AsString;
    cheques_creditos.FieldByName('items').AsString      := cheques_creditoshist.FieldByName('items').AsString;
    cheques_creditos.FieldByName('nrocheque').AsString  := cheques_creditoshist.FieldByName('nrocheque').AsString;
    cheques_creditos.FieldByName('codcta').AsString     := cheques_creditoshist.FieldByName('codcta').AsString;
    try
      cheques_creditos.Post
     except
      cheques_creditos.Cancel
    end;
    cheques_creditoshist.Next;
  end;
  datosdb.QuitarFiltro(cheques_creditoshist);
  datosdb.tranSQL('delete from ' + cheques_creditoshist.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  datosdb.closedb(cheques_creditos); cheques_creditos.Open;
  datosdb.closedb(cheques_creditoshist);

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Restableciendo desde Hist�rico Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.RecuperarHistorico_CreditoRefinanciado(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Registro Hist�rico los datos ingresados, de los cr�ditos refinanciados
Begin
  creditos_cabhist := nil; creditos_dethist := nil;
  creditos_cabhist := datosdb.openDB('creditos_cabhistrefinanciados', '');
  creditos_dethist := datosdb.openDB('creditos_dethistrefinanciados', '');

  Refinanciado     := 'S';
  conectar_creditosRefinanciados;
  detcred          := creditos_detrefinanciados;      // Apuntadores de tablas

  cab_credito      := creditos_cabrefinanciados;
  cab_creditohist  := creditos_cabhist;
  det_creditos     := creditos_detrefinanciados;
  det_creditohist  := creditos_dethist;

  RecuperarRegistrosDelHistorico(xcodprest, xexpediente);
  desconectar_creditosRefinanciados;
end;

procedure TTCreditos.RecuperarHistorico_CreditoCuotasRefinanciadas(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Hist�rico el cr�dito con cuotas refinanciadas
Begin
  creditos_cabhist := nil; creditos_dethist := nil;
  creditos_cabhist := datosdb.openDB('creditos_cabhistrefcuotas', '');
  creditos_dethist := datosdb.openDB('creditos_dethistrefcuotas', '');

  RefinanciaCuota  := 'S';
  conectar_cuotasRefinanciadas;
  detcred          := creditos_detrefcuotas;      // Apuntadores de tablas

  cab_credito      := creditos_cabrefcuotas;
  cab_creditohist  := creditos_cabhist;
  det_creditos     := creditos_detrefcuotas;
  det_creditohist  := creditos_dethist;

  RecuperarRegistrosDelHistorico(xcodprest, xexpediente);
  desconectar_cuotasRefinanciadas;
end;

procedure TTCreditos.RegistrarObservacionHistorico(xcodprest, xexpediente, xobservacion: string);
begin
  if (datosdb.Buscar(obs_historico, 'codprest', 'expediente', xcodprest, expediente)) then obs_historico.Edit else obs_historico.Append;
  obs_historico.FieldByName('codprest').AsString      := xcodprest;
  obs_historico.FieldByName('expediente').AsString    := xexpediente;
  obs_historico.FieldByName('observaciones').AsString := xobservacion;
  try
    obs_historico.Post
   except
    obs_historico.Cancel;
  end;
end;

procedure TTCreditos.RegistrarObservacionCredito(xcodprest, xexpediente, xobservacion: string);
begin
  if (datosdb.Buscar(obs_credito, 'codprest', 'expediente', xcodprest, expediente)) then obs_credito.Edit else obs_credito.Append;
  obs_credito.FieldByName('codprest').AsString      := xcodprest;
  obs_credito.FieldByName('expediente').AsString    := xexpediente;
  obs_credito.FieldByName('observaciones').AsString := xobservacion;
  try
    obs_credito.Post
   except
    obs_credito.Cancel;
  end;
end;

function TTCreditos.getObservacionHistorico(xcodprest, xexpediente: string): string;
begin
  if (datosdb.Buscar(obs_historico, 'codprest', 'expediente', xcodprest, xexpediente)) then
    observacion_historico :=  obs_historico.FieldByName('observaciones').AsString
  else
    observacion_historico := '';
  result := observacion_historico;
end;

function TTCreditos.getObservacionCredito(xcodprest, xexpediente: string): string;
begin
  if (datosdb.Buscar(obs_credito, 'codprest', 'expediente', xcodprest, xexpediente)) then
    observacion_credito :=  obs_credito.FieldByName('observaciones').AsString
  else
    observacion_credito := '';
  result := observacion_credito;
end;

procedure TTCreditos.RecuperarRegistrosDelHistorico(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Registro Hist�rico los datos ingresados
var
  ec: Boolean;
Begin
  if datosdb.Buscar(cab_creditohist, 'Codprest', 'Expediente', xcodprest, xexpediente) then Begin
    cab_creditohist.Open; det_creditohist.Open; gastos_hist.Open;
    if datosdb.Buscar(cab_credito, 'codprest', 'expediente', xcodprest, xexpediente) then cab_credito.Edit else cab_credito.Append;
    cab_credito.FieldByName('codprest').AsString    := xcodprest;
    cab_credito.FieldByName('expediente').AsString  := xexpediente;
    cab_credito.FieldByName('monto').AsFloat        := cab_creditohist.FieldByName('monto').AsFloat;
    cab_credito.FieldByName('entrega').AsFloat      := cab_creditohist.FieldByName('entrega').AsFloat;
    cab_credito.FieldByName('fecha').AsString       := cab_creditohist.FieldByName('fecha').AsString;
    cab_credito.FieldByName('idcredito').AsString   := cab_creditohist.FieldByName('idcredito').AsString;
    cab_credito.FieldByName('aporte').AsFloat       := cab_creditohist.FieldByName('aporte').AsFloat;
    cab_credito.FieldByName('formapago').AsString   := cab_creditohist.FieldByName('formapago').AsString;
    cab_credito.FieldByName('indice').AsFloat       := cab_creditohist.FieldByName('indice').AsFloat;
    cab_credito.FieldByName('tipoindice').AsString  := cab_creditohist.FieldByName('tipoindice').AsString;
    cab_credito.FieldByName('cantcuotas').AsString  := cab_creditohist.FieldByName('cantcuotas').AsString;
    cab_credito.FieldByName('pergracia').AsString   := cab_creditohist.FieldByName('pergracia').AsString;
    cab_credito.FieldByName('intervalopg').AsString := cab_creditohist.FieldByName('intervalopg').AsString;
    cab_credito.FieldByName('concepto').AsString    := cab_creditohist.FieldByName('concepto').AsString;
    cab_credito.FieldByName('interes').AsFloat      := cab_creditohist.FieldByName('interes').AsFloat;
    cab_credito.FieldByName('estado').AsString      := cab_creditohist.FieldByName('estado').AsString;
    cab_credito.FieldByName('refinancia').AsString  := cab_creditohist.FieldByName('refinancia').AsString;
    cab_credito.FieldByName('refcuotas').AsString   := cab_creditohist.FieldByName('refcuotas').AsString;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'fecharef', dbs.baseDat)         then cab_credito.FieldByName('fecharef').AsString := cab_creditohist.FieldByName('fecharef').AsString;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'fechacancelacion', dbs.baseDat) then cab_credito.FieldByName('fechacancelacion').AsString := cab_creditohist.FieldByName('fechacancelacion').AsString;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'intervalopg', dbs.baseDat) then cab_credito.FieldByName('intervalopg').AsString := cab_creditohist.FieldByName('intervalopg').AsString;
    cab_credito.FieldByName('tipocalculo').AsString := cab_creditohist.FieldByName('tipocalculo').AsString;
    cab_credito.FieldByName('fechappago').AsString  := cab_creditohist.FieldByName('fechappago').AsString;
    cab_credito.FieldByName('monto_real').AsFloat   := cab_creditohist.FieldByName('monto_real').AsFloat;
    if datosdb.verificarSiExisteCampo(cab_creditohist.TableName, 'indicecalculo', dbs.baseDat) then cab_credito.FieldByName('indicecalculo').AsString := cab_creditohist.FieldByName('indicecalculo').AsString;
    try
      cab_credito.Post
     except
      cab_credito.Cancel
    end;

    ec := datosdb.verificarSiExisteCampo(det_creditohist.TableName, 'fecharef', dbs.baseDat);
    datosdb.Filtrar(det_creditohist, 'codprest = ' + xcodprest + ' AND expediente = ' + xexpediente);
    det_creditohist.First;
    while not det_creditohist.Eof do Begin
      if datosdb.Buscar(det_creditos, 'codprest', 'expediente', 'items', 'recibo', det_creditohist.FieldByName('codprest').AsString, det_creditohist.FieldByName('expediente').AsString, det_creditohist.FieldByName('items').AsString, det_creditohist.FieldByName('recibo').AsString) then det_creditos.Edit else det_creditos.Append;
      det_creditos.FieldByName('codprest').AsString    := det_creditohist.FieldByName('codprest').AsString;
      det_creditos.FieldByName('expediente').AsString  := det_creditohist.FieldByName('expediente').AsString;
      det_creditos.FieldByName('items').AsString       := det_creditohist.FieldByName('items').AsString;
      det_creditos.FieldByName('recibo').AsString      := det_creditohist.FieldByName('recibo').AsString;
      det_creditos.FieldByName('concepto').AsString    := det_creditohist.FieldByName('concepto').AsString;
      det_creditos.FieldByName('amortizacion').AsFloat := det_creditohist.FieldByName('amortizacion').AsFloat;
      det_creditos.FieldByName('aporte').AsFloat       := det_creditohist.FieldByName('aporte').AsFloat;
      det_creditos.FieldByName('total').AsFloat        := det_creditohist.FieldByName('total').AsFloat;
      det_creditos.FieldByName('fechavto').AsString    := det_creditohist.FieldByName('fechavto').AsString;
      det_creditos.FieldByName('saldo').AsFloat        := det_creditohist.FieldByName('saldo').AsFloat;
      det_creditos.FieldByName('saldocuota').AsFloat   := det_creditohist.FieldByName('saldocuota').AsFloat;
      det_creditos.FieldByName('tipomov').AsInteger    := det_creditohist.FieldByName('tipomov').AsInteger;
      det_creditos.FieldByName('refpago').AsString     := det_creditohist.FieldByName('refpago').AsString;
      det_creditos.FieldByName('estado').AsString      := det_creditohist.FieldByName('estado').AsString;
      det_creditos.FieldByName('interes').AsFloat      := det_creditohist.FieldByName('interes').AsFloat;
      det_creditos.FieldByName('indice').AsFloat       := det_creditohist.FieldByName('indice').AsFloat;
      det_creditos.FieldByName('refinancia').AsString  := det_creditohist.FieldByName('refinancia').AsString;
      if ec then det_creditos.FieldByName('fecharef').AsString := det_creditohist.FieldByName('fecharef').AsString;
      det_creditos.FieldByName('cuotasref').AsString   := det_creditohist.FieldByName('cuotasref').AsString;
      det_creditos.FieldByName('refcredito').AsString  := det_creditohist.FieldByName('refcredito').AsString;
      det_creditos.FieldByName('descuento').AsFloat    := det_creditohist.FieldByName('descuento').AsFloat;
      det_creditos.FieldByName('tasaint').AsFloat      := det_creditohist.FieldByName('tasaint').AsFloat;
      det_creditos.FieldByName('montoint').AsFloat     := det_creditohist.FieldByName('montoint').AsFloat;
      det_creditos.FieldByName('fechapago').AsString   := det_creditohist.FieldByName('fechapago').AsString;
      try
        det_creditos.Post
       except
        det_creditos.Cancel
      end;
      det_creditohist.Next;
    end;

    datosdb.QuitarFiltro(det_creditohist);

    datosdb.refrescar(cab_credito);
    datosdb.refrescar(det_creditohist);

    { Quitamos el expediente transferido }
    datosdb.tranSQL('DELETE FROM ' + cab_creditohist.TableName  + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
    datosdb.tranSQL('DELETE FROM ' + det_creditohist.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
    datosdb.refrescar(cab_creditohist);
    datosdb.refrescar(det_creditohist);

    datosdb.closeDB(cab_creditohist);
    datosdb.closeDB(det_creditohist);

    { Transferimos los Gastos Administrativos }
    rsql := datosdb.tranSQL('select * from ' + gastos_hist.TableName + ' where codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
    rsql.Open;
    while not rsql.Eof do Begin
      if datosdb.Buscar(gastos, 'codprest', 'expediente', 'items', rsql.FieldByName('codprest').AsString, rsql.FieldByName('expediente').AsString, rsql.FieldByName('items').AsString) then gastos.Edit else gastos.Append;
      gastos.FieldByName('codprest').AsString   := rsql.FieldByName('codprest').AsString;
      gastos.FieldByName('expediente').AsString := rsql.FieldByName('expediente').AsString;
      gastos.FieldByName('items').AsString      := rsql.FieldByName('items').AsString;
      gastos.FieldByName('idgasto').AsString    := rsql.FieldByName('idgasto').AsString;
      gastos.FieldByName('recibo').AsString     := rsql.FieldByName('recibo').AsString;
      gastos.FieldByName('fecha').AsString      := rsql.FieldByName('fecha').AsString;
      gastos.FieldByName('concepto').AsString   := rsql.FieldByName('concepto').AsString;
      gastos.FieldByName('monto').AsFloat       := rsql.FieldByName('monto').AsFloat;
      try
        gastos.Post
       except
        gastos.Cancel
      end;
      rsql.Next;
    end;
    rsql.Close; rsql.Free;
    datosdb.closeDB(gastos_hist);

    datosdb.tranSQL('delete from ' + gastos_hist.TableName + ' where codprest = ' + '"' + xcodprest + '"' + ' and expediente = ' + '"' + xexpediente + '"');
  end;
end;

{******************************************************************************}

function TTCreditos.setMontoInteresesPunitorios(xfechaInicial, xfechaActual: String; xmonto, xindice, xinteres: Real): Real;
// objetivo...: Devolver Monto Intereses Punitorios
var
  t: Real; tdias: Integer;
Begin
  //utiles.msgError(floattostr(xmonto));
  t := StrToFloat(utiles.FormatearNumero(FloatToStr((xinteres * 0.01) / 360), '#0.0000'));
  tdias := StrToInt(utiles.RestarFechas(xfechaActual, xfechaInicial));
  Result := xmonto * (tdias * t);
end;

function TTCreditos.setCreditosPrestatario(xcodprest: String): TQuery;
// Objetivo...: Devolver un sert con los creditos del prestatario
Begin
  Result := datosdb.tranSQL('select * from creditos_cab where codprest = ' + '"' + xcodprest + '"' + ' order by idcredito, expediente');
end;

function TTCreditos.setCreditosLocalidad(xcp, xorden: String): TQuery;
// Objetivo...: Recuperar los creditos de una localidad
Begin
  Result := datosdb.tranSQL('select creditos_cab.codprest, creditos_cab.expediente, creditos_cab.fecha, creditos_cab.monto, creditos_cab.indice, creditos_cab.idcredito, creditos_cab.monto_real, prestatarios.nombre, creditos.items, creditos.idlinea, prestatarios.cp ' +
                            'from creditos_cab, prestatarios, creditos where creditos_cab.codprest = prestatarios.codprest and creditos_cab.idcredito = creditos.items and prestatarios.cp = ' + '"' + xcp + '"' + ' and prestatarios.orden = ' + '"' + xorden + '"' +
                            ' order by cp, orden, idlinea, idcredito, codprest, expediente');
end;

function TTCreditos.setCreditosCanceladosLocalidad(xcp, xorden: String): TQuery;
// Objetivo...: Recuperar los creditos de una localidad
Begin
  Result := datosdb.tranSQL('select creditos_cabhist.codprest, creditos_cabhist.expediente, creditos_cabhist.fecha, creditos_cabhist.monto, creditos_cabhist.indice, creditos_cabhist.idcredito, creditos_cabhist.monto_real, prestatarios.nombre, creditos.items, ' +
                            'creditos.idlinea, prestatarios.cp from creditos_cabhist, prestatarios, creditos where creditos_cabhist.codprest = prestatarios.codprest and creditos_cabhist.idcredito = creditos.items and prestatarios.cp = ' + '"' + xcp + '"' +
                            ' and prestatarios.orden = ' + '"' + xorden + '"' + ' order by idlinea, idcredito, codprest, expediente');
end;

{ Refinanciaciones  ************************************************************}

procedure TTCreditos.GuardarRefinanciacion(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xtipoindice, xtipocalculo: String; xmonto, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xinteresRef, xmonto_real: Real; xcantitems: Integer);
// Objetivo...: Guardar datos en tabla de persistencia
Begin
  if xitems = '001' then Begin
    conectar_creditosRefinanciados;
    if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', xcodprest, xexpediente) then creditos_cabrefinanciados.Edit else creditos_cabrefinanciados.Append;
    creditos_cabrefinanciados.FieldByName('codprest').AsString    := xcodprest;
    creditos_cabrefinanciados.FieldByName('expediente').AsString  := xexpediente;
    creditos_cabrefinanciados.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
    creditos_cabrefinanciados.FieldByName('idcredito').AsString   := xidcredito;
    creditos_cabrefinanciados.FieldByName('formapago').AsString   := xformapago;
    creditos_cabrefinanciados.FieldByName('cantcuotas').AsString  := xcantcuotas;
    creditos_cabrefinanciados.FieldByName('pergracia').AsString   := xpergracia;
    creditos_cabrefinanciados.FieldByName('concepto').AsString    := xconcepto;
    creditos_cabrefinanciados.FieldByName('monto').AsFloat        := xmonto;
    creditos_cabrefinanciados.FieldByName('indice').AsFloat       := xindice;
    creditos_cabrefinanciados.FieldByName('tipoindice').AsString  := xtipoindice;
    creditos_cabrefinanciados.FieldByName('tipocalculo').AsString := xtipocalculo;
    creditos_cabrefinanciados.FieldByName('aporte').AsFloat       := xaporte;
    creditos_cabrefinanciados.FieldByName('interes').AsFloat      := xinteres;
    creditos_cabrefinanciados.FieldByName('estado').AsString      := 'I';
    creditos_cabrefinanciados.FieldByName('monto_real').AsFloat   := xmonto_real;
    try
      creditos_cabrefinanciados.Post
     except
      creditos_cabrefinanciados.Cancel
    end;
    RefinanciarCredito(xcodprest, xexpediente);
    { Registramos la Fecha de Refinanciaci�n }
    if datosdb.Buscar(creditos_cab, 'Codprest', 'Expediente', xcodprest, xexpediente) then Begin
      creditos_cab.Edit;
      creditos_cab.FieldByName('fecharef').AsString  := utiles.sExprFecha2000(utiles.setFechaActual);
      creditos_cab.FieldByName('interesRef').AsFloat := xinteresRef;
      try
        creditos_cab.Post
       except
        creditos_cab.Cancel
      end;
      // Marcamos las Cuotas Refinanciadas
      datosdb.tranSQL('update creditos_det set refcredito = ' + '"' + 'S' + '"' + ' where codprest = ' + '"' + xcodprest + '"' + ' and expediente = ' + '"' + xexpediente + '"' + ' and saldocuota > 0');
    end;
  end;
  if datosdb.Buscar(creditos_detrefinanciados, 'codprest', 'expediente', 'items', 'recibo', xcodprest, xexpediente, xitems, '-') then creditos_detrefinanciados.Edit else creditos_detrefinanciados.Append;
  creditos_detrefinanciados.FieldByName('codprest').AsString    := xcodprest;
  creditos_detrefinanciados.FieldByName('expediente').AsString  := xexpediente;
  creditos_detrefinanciados.FieldByName('items').AsString       := xitems;
  creditos_detrefinanciados.FieldByName('recibo').AsString      := '-';
  creditos_detrefinanciados.FieldByName('fechavto').AsString    := utiles.sExprFecha2000(xfechavto);
  creditos_detrefinanciados.FieldByName('concepto').AsString    := xconceptoitems;
  creditos_detrefinanciados.FieldByName('amortizacion').AsFloat := xamortizacion;
  creditos_detrefinanciados.FieldByName('aporte').AsFloat       := xaportec;
  creditos_detrefinanciados.FieldByName('total').AsFloat        := xtotal;
  creditos_detrefinanciados.FieldByName('saldo').AsFloat        := xsaldo;
  creditos_detrefinanciados.FieldByName('saldocuota').AsFloat   := xtotal;
  creditos_detrefinanciados.FieldByName('tipomov').AsInteger    := 1;
  creditos_detrefinanciados.FieldByName('estado').AsString      := 'I';
  try
    creditos_detrefinanciados.Post
   except
    creditos_detrefinanciados.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then AjustarNroItemsRefinanciacion(xcodprest, xexpediente, xcantitems);

  datosdb.closedb(creditos_cabrefinanciados); creditos_cabrefinanciados.Open;
  datosdb.closedb(creditos_detrefinanciados); creditos_detrefinanciados.Open;
  datosdb.closedb(creditos_det); creditos_det.Open;

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Refinanciaci�n Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AjustarNroItemsRefinanciacion(xcodprest, xexpediente: String; xcantitems: Integer);
// Objetivo...: Ajustar Numero de Items
Begin
  desconectar_creditosRefinanciados;
  datosdb.tranSQL('DELETE FROM ' + creditos_detrefinanciados.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '"');
end;

procedure TTCreditos.RefinanciarCredito(xcodprest, xexpediente: String);
// Objetivo...: Regfinanciar Cr�dito
Begin
  if Buscar(xcodprest, xexpediente) then Begin
    creditos_cab.Edit;
    creditos_cab.FieldByName('refinancia').AsString := 'S';
    try
      creditos_cab.Post
     except
      creditos_det.Cancel
    end;
  end;
  datosdb.refrescar(creditos_cab);
end;

function TTCreditos.verificarSiElCreditoTieneCuotasRefinanciadas(xcodprest, xexpediente: String): Boolean;
// Objetivo...: verificar si el credito tiene cuotas refinanciadas
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT codprest FROM creditos_detrefinanciados WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND refinancia = ' + '"' + 'S' + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

procedure TTCreditos.AnularRefinanciacionCredito(xcodprest, xexpediente: String);
// Objetivo...: Anular refinanciaci�n del cr�dito
Begin
  getDatos(xcodprest, xexpediente);
  ActivarTP;

  datosdb.tranSQL('DELETE FROM creditos_cabrefinanciados WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
  datosdb.tranSQL('DELETE FROM creditos_detrefinanciados WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
  // Quitamos la marca de refinanciado al cr�dito original
  Refinanciado := '';
  if Buscar(xcodprest, xexpediente) then Begin
    creditos_cab.Edit;
    creditos_cab.FieldByName('refinancia').AsString := '';
    creditos_cab.FieldByName('interesRef').AsFloat  := 0;
    try
      creditos_cab.Post
     except
      creditos_cab.Cancel
    end;
  end;

  datosdb.tranSQL('UPDATE creditos_det SET refcredito = ' + '"' + '' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Anulando Refinanciaci�n Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.getDatosCreditoRefinanciado(xcodprest, xexpediente: String);
// Objetivo...: Recuperar datos credito refinanciado
Begin
  if datosdb.Buscar(creditos_cabrefinanciados, 'codprest', 'expediente', xcodprest, xexpediente) then Begin
    monto          := creditos_cabrefinanciados.FieldByName('monto').AsFloat;
    indice_credito := creditos_cabrefinanciados.FieldByName('indice').AsFloat;
    fecha          := utiles.sFormatoFecha(creditos_cabrefinanciados.FieldByName('fecha').AsString);
  end else Begin
    monto := 0; indice_credito := 0; fecha := '';
  end;
end;

{-------------------------------------------------------------------------------}
procedure TTCreditos.GuardarRefinanciacionCuota(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xtipoindice, xintervalopg, xtipocalculo, xfechappago: String; xmonto, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xmonto_real: Real; xcantitems: Integer; xNroCuotaRefinanciarInicial, xNroCuotaRefinanciarFinal: String);
// Objetivo...: Guardar datos en tabla de persistencia
var
  i: Integer;
Begin
  if xitems = '001' then Begin
    conectar_cuotasRefinanciadas;
    if datosdb.Buscar(creditos_cabrefcuotas, 'codprest', 'expediente', xcodprest, xexpediente) then creditos_cabrefcuotas.Edit else creditos_cabrefcuotas.Append;
    creditos_cabrefcuotas.FieldByName('codprest').AsString    := xcodprest;
    creditos_cabrefcuotas.FieldByName('expediente').AsString  := xexpediente;
    creditos_cabrefcuotas.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
    creditos_cabrefcuotas.FieldByName('idcredito').AsString   := xidcredito;
    creditos_cabrefcuotas.FieldByName('formapago').AsString   := xformapago;
    creditos_cabrefcuotas.FieldByName('cantcuotas').AsString  := xcantcuotas;
    creditos_cabrefcuotas.FieldByName('pergracia').AsString   := xpergracia;
    creditos_cabrefcuotas.FieldByName('concepto').AsString    := xconcepto;
    creditos_cabrefcuotas.FieldByName('monto').AsFloat        := xmonto;
    creditos_cabrefcuotas.FieldByName('indice').AsFloat       := xindice;
    creditos_cabrefcuotas.FieldByName('tipoindice').AsString  := xtipoindice;
    creditos_cabrefcuotas.FieldByName('aporte').AsFloat       := xaporte;
    creditos_cabrefcuotas.FieldByName('interes').AsFloat      := xinteres;
    creditos_cabrefcuotas.FieldByName('estado').AsString      := 'I';
    creditos_cabrefcuotas.FieldByName('tipocalculo').AsString := xtipocalculo;
    creditos_cabrefcuotas.FieldByName('intervaloPG').AsString := xintervalopg;
    creditos_cabrefcuotas.FieldByName('fechappago').AsString  := utiles.sExprFecha2000(xfechappago);
    creditos_cabrefcuotas.FieldByName('monto_real').AsFloat   := xmonto_real;
    try
      creditos_cabrefcuotas.Post
     except
      creditos_cabrefcuotas.Cancel
    end;
    for i := StrToInt(xNroCuotaRefinanciarInicial) to StrToInt(xNroCuotaRefinanciarFinal) do   // Marcamos las cuotas que se refinancian
       RefinanciarCuota(xcodprest, xexpediente, utiles.sLlenarIzquierda(IntToStr(i), 3, '0'), xNroCuotaRefinanciarInicial, xNroCuotaRefinanciarFinal);
  end;
  if datosdb.Buscar(creditos_detrefcuotas, 'codprest', 'expediente', 'items', 'recibo', xcodprest, xexpediente, xitems, '-') then creditos_detrefcuotas.Edit else creditos_detrefcuotas.Append;
  creditos_detrefcuotas.FieldByName('codprest').AsString    := xcodprest;
  creditos_detrefcuotas.FieldByName('expediente').AsString  := xexpediente;
  creditos_detrefcuotas.FieldByName('items').AsString       := xitems;
  creditos_detrefcuotas.FieldByName('recibo').AsString      := '-';
  creditos_detrefcuotas.FieldByName('fechavto').AsString    := utiles.sExprFecha2000(xfechavto);
  creditos_detrefcuotas.FieldByName('concepto').AsString    := xconceptoitems;
  creditos_detrefcuotas.FieldByName('amortizacion').AsFloat := xamortizacion;
  creditos_detrefcuotas.FieldByName('aporte').AsFloat       := xaportec;
  creditos_detrefcuotas.FieldByName('total').AsFloat        := xtotal;
  creditos_detrefcuotas.FieldByName('saldo').AsFloat        := xsaldo;
  creditos_detrefcuotas.FieldByName('saldocuota').AsFloat   := xtotal;
  creditos_detrefcuotas.FieldByName('tipomov').AsInteger    := 1;
  creditos_detrefcuotas.FieldByName('estado').AsString      := 'I';
  if xNroCuotaRefinanciarInicial <> xNroCuotaRefinanciarFinal then creditos_detrefcuotas.FieldByName('refinancia').AsString  := xNroCuotaRefinanciarInicial + '-' + xNroCuotaRefinanciarFinal else     // Registramos el Nro. de cuota que se esta refinanciando
    creditos_detrefcuotas.FieldByName('refinancia').AsString  := xNroCuotaRefinanciarInicial;
  creditos_detrefcuotas.FieldByName('fecharef').AsString    := utiles.sExprFecha2000(utiles.setFechaActual); // Fecha de Refinanciaci�n
  creditos_detrefcuotas.FieldByName('cuotasref').AsString   := xNroCuotaRefinanciarInicial + '-' + xNroCuotaRefinanciarFinal;
  try
    creditos_detrefcuotas.Post
   except
    creditos_detrefcuotas.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then AjustarNroItemsRefCuotas(xcodprest, xexpediente, xcantitems);
  datosdb.refrescar(creditos_cabrefcuotas);
  datosdb.refrescar(creditos_detrefcuotas);

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Guardando Refinanciaci�n Cuotas Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.AjustarNroItemsRefCuotas(xcodprest, xexpediente: String; xcantitems: Integer);
// Objetivo...: Ajustar Numero de Items
Begin
  desconectar_cuotasRefinanciadas;
  datosdb.tranSQL('DELETE FROM ' + creditos_detrefcuotas.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '"');
end;

procedure TTCreditos.RefinanciarCuota(xcodprest, xexpediente, xNroCuotaRefinanciar, xNroCuotaRefinanciarInicial, xNroCuotaRefinanciarFinal: String);
// Objetivo...: Regfinanciar Cr�dito
Begin
  if Buscar(xcodprest, xexpediente) then Begin
    creditos_cab.Edit;
    creditos_cab.FieldByName('refcuotas').AsString := 'S';
    try
      creditos_cab.Post
     except
      creditos_det.Cancel
    end;
  end;
  datosdb.refrescar(creditos_cab);

  // Marcamos la Cuota a Refinanciar
  if Refinanciado = ''  then datosdb.tranSQL('UPDATE creditos_det SET refinancia = ' + '"' + 'S' + '"' + ', cuotasref = ' + '"' + xNroCuotaRefinanciarInicial + '-' + xNroCuotaRefinanciarFinal + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items = ' + '"' + xNroCuotaRefinanciar + '"' + ' AND tipomov = ' + '"' + '1' + '"');  // Se marca sobre el plan original
  if Refinanciado = 'S' then datosdb.tranSQL('UPDATE creditos_detrefinanciados SET refinancia = ' + '"' + 'S' + '"' + ', cuotasref = ' + '"' + xNroCuotaRefinanciarInicial + '-' + xNroCuotaRefinanciarFinal + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items = ' + '"' + xNroCuotaRefinanciar + '"' + ' AND tipomov = ' + '"' + '1' + '"'); // Se marca sobre el plan refinanciado
end;

function TTCreditos.setItemsCuotaRefinanciada(xcodprest, xexpediente, xnrocuota: String): TQuery;
// Objetivo...: Devolver Items Cuotas Refinanciadas
Begin
  if datosdb.Buscar(creditos_cabrefcuotas, 'codprest', 'expediente', xcodprest, xexpediente) then Begin
    tipoCalculo := creditos_cabrefcuotas.FieldByName('tipocalculo').AsString;
    intervaloPG := utiles.sLlenarIzquierda(creditos_cabrefcuotas.FieldByName('intervaloPG').AsString, 2, '0');
    fechappago  := utiles.sFormatoFecha(creditos_cabrefcuotas.FieldByName('fechappago').AsString);
    cantcuotas  := utiles.sLlenarIzquierda(creditos_cabrefcuotas.FieldByName('cantcuotas').AsString, 2, '0');
    formapago   := utiles.sLlenarIzquierda(creditos_cabrefcuotas.FieldByName('formapago').AsString, 2, '0');
  end;
  Result := datosdb.tranSQL('SELECT * FROM ' + creditos_detrefcuotas.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + xnrocuota + '"' + ' AND tipomov = 1');
end;

function TTCreditos.verificarSiLaCuotaRefinanciadaTienePagos(xcodprest, xexpediente, xnrocuota: String): Boolean;
// Objetivo...: verificar que la cuota no tenga pagos imputados
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT codprest FROM ' + creditos_detrefcuotas.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND Refinancia = ' + '"' + xnrocuota + '"' + ' AND tipomov = 2');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function TTCreditos.verificarSiLaCuotaRefinanciadaEstaSaldada(xcodprest, xexpediente, xnrocuota: String): Boolean;
// Objetivo...: verificar si la cuota esta saldada
var
  r: TQuery;
  l: Boolean;
Begin
  l := True;
  r := datosdb.tranSQL('SELECT cuotasref, estado, tipomov FROM ' + creditos_detrefcuotas.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + xnrocuota + '"' + ' AND tipomov = 1');
  r.Open;
  while not r.Eof do Begin
    if r.FieldByName('estado').AsString <> 'P' then Begin
      l := False;
      Break;
    End;
    r.Next;
  End;  
  r.Close; r.Free;

  // Si resulta verdadero, significa que no hay mas cuotas por pagar
  if l then Begin
    // Actualizamos
    datosdb.tranSQL('UPDATE creditos_det set estado = ' + '"' + 'P' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + xnrocuota + '"' + ' AND tipomov = 1');
  End else Begin
    datosdb.tranSQL('UPTATE creditos_det set estado = ' + '"' + 'I' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + xnrocuota + '"' + ' AND tipomov = 1');
  End;
  Result := l;
end;

procedure TTCreditos.AnularRefinanciacionCuota(xcodprest, xexpediente, xnrocuota: String);
// Objetivo...: Anular Refinanciaci�n de Cuota
var
  r: TQuery; ci, cf: String;
Begin
  getDatos(xcodprest, xexpediente);
  ActivarTP;

  { Extraemos las cuotas que fueron refinanciadas, desde - hasta }
  if ref_c = '' then r := datosdb.tranSQL('SELECT cuotasref FROM creditos_det WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items = ' + '"' + xnrocuota + '"' + ' AND recibo = ' + '"' + '-' + '"') else   // Creditos Normales
    r := datosdb.tranSQL('SELECT cuotasref FROM creditos_detrefinanciados WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items = ' + '"' + xnrocuota + '"' + ' AND recibo = ' + '"' + '-' + '"');     // Creditos Refinanciados
  r.Open;
  ci := Copy(r.FieldByName('cuotasref').AsString, 1, 3);
  cf := Copy(r.FieldByName('cuotasref').AsString, 5, 3);
  r.Close; r.Free;

  datosdb.tranSQL('DELETE FROM ' + creditos_cabrefcuotas.TableName + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
  datosdb.closeDB(creditos_cabrefcuotas); creditos_cabrefcuotas.Open;
  { Quitamos la marca que determina que el cr�dito fue refinanciado }
  if Length(Trim(cf)) = 0 then Begin    // solo hay 1 cuota refinanciada
    if Refinanciado = ''  then datosdb.tranSQL('UPDATE creditos_det SET refinancia = ' + '"' + '' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items = ' + '"' + xnrocuota + '"' + ' AND tipomov = ' + '"' + '1' + '"');  // Se marca sobre el plan original
    if Refinanciado = 'S' then datosdb.tranSQL('UPDATE creditos_detrefinanciados SET refinancia = ' + '"' + '' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND items = ' + '"' + xnrocuota + '"' + ' AND tipomov = ' + '"' + '1' + '"'); // Se marca sobre el plan refinanciado
    datosdb.tranSQL('DELETE FROM creditos_detrefcuotas WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + ci + '-' + cf + '"');
    datosdb.closeDB(creditos_detrefcuotas); creditos_detrefcuotas.Open;
  end else Begin
    if Refinanciado = ''  then datosdb.tranSQL('UPDATE creditos_det SET refinancia = ' + '"' + '' + '"' + ', cuotasref = ' + '"' + '' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref >= ' + '"' + ci + '-' + cf + '"' + ' AND tipomov = ' + '"' + '1' + '"');  // Se marca sobre el plan original
    if Refinanciado = 'S' then datosdb.tranSQL('UPDATE creditos_detrefinanciados SET refinancia = ' + '"' + '' + '"' + ', cuotasref = ' + '"' + '' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + ci + '-' + cf + '"' + ' AND tipomov = ' + '"' + '1' + '"'); // Se marca sobre el plan refinanciado
    datosdb.tranSQL('DELETE FROM creditos_detrefcuotas WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"' + ' AND cuotasref = ' + '"' + ci + '-' + cf + '"');
    datosdb.closeDB(creditos_detrefcuotas); creditos_detrefcuotas.Open;
  end;

  { Verificamos si queda alguna cuota refinanciada, si no queda ninguna, quitamos la marca en el Cr�dito Original }
  r := datosdb.tranSQL('SELECT * FROM creditos_detrefcuotas WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');
  r.Open;
  if r.RecordCount = 0 then datosdb.tranSQL('UPDATE creditos_cab SET refcuotas = ' + '"' + '' + '"' + ', refinancia = ' + '"' + '' + '"' + ' WHERE codprest = ' + '"' + xcodprest + '"' + ' AND expediente = ' + '"' + xexpediente + '"');  // Anulamos, en el credito original, la Ref. de Cuotas
  r.Close; r.Free;

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Anulando Refinanciaci�n Cuota ' + xcodprest + '-' + xexpediente + '  ' + xnrocuota);
end;

{*******************************************************************************}

procedure TTCreditos.InfNivelCreditos(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar esta�sticas cr�ditos
var
  b1: Boolean;
  i: Integer;
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Estad�stica de Creditos - Lapso:  ' + xdfecha + ' al ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  List.Titulo(5, list.Lineactual, 'Concepto', 2, 'Arial, cursiva, 8');
  List.Titulo(89, list.Lineactual, 'Monto', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  IniciarArreglos;

  rsql := categoria.setCategoriasPorLinea;
  rsql.Open;
  for i := 1 to cantitems do Begin
    totales[i] := 0; totgral[i] := 0; totfin[i] := 0;
  end;

  while not rsql.Eof do Begin
    // Inicio de arreglos
    b1 := False;
    totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0; totales[12] := 0; totales[13] := 0; totales[14] := 0;
    idanter[2] := '';

    // Creditos Otorgados
    datosdb.Filtrar(creditos_cab, 'fecha >= ' + utiles.sExprFecha(xdfecha) + ' and fecha <= ' + utiles.sExprFecha2000(xhfecha) + ' and idcredito = ' + rsql.FieldByName('items').AsString);
    creditos_cab.First;
    while not creditos_cab.Eof do Begin
      totales[1] := totales[1] + 1;
      if creditos_cab.FieldByName('indice').AsFloat = 0 then totales[2] := totales[2] + creditos_cab.FieldByName('monto').AsFloat else totales[2] := totales[2] + (creditos_cab.FieldByName('monto').AsFloat * creditos_cab.FieldByName('indice').AsFloat);
      creditos_cab.Next;
    end;
    datosdb.QuitarFiltro(creditos_cab);

    // Creditos Impagos - Normales
    datosdb.Filtrar(detcred, 'fechavto >= ' + utiles.sExprFecha(xdfecha) + ' and fechavto <= ' + utiles.sExprFecha2000(xhfecha) + ' and estado = ' + '''' + 'I' + '''' + ' and tipomov = 1');
    detcred.First; idanter[2] := '';
    while not detcred.Eof do Begin
      if (detcred.FieldByName('refinancia').AsString <> 'S') and (detcred.FieldByName('refcredito').AsString <> 'S') and (Length(Trim(detcred.FieldByName('cuotasref').AsString)) = 0) then Begin
        Buscar(detcred.FieldByName('codprest').AsString, detcred.FieldByName('expediente').AsString);
        if creditos_cab.FieldByName('idcredito').AsString = rsql.FieldByName('items').AsString then Begin
          if detcred.FieldByName('codprest').AsString <> idanter[2] then
            if detcred.FieldByName('saldocuota').AsFloat > 0 then totales[7] := totales[7] + 1;

          if creditos_cab.FieldByName('indice').AsFloat = 0 then totales[8] := totales[8] + detcred.FieldByName('saldocuota').AsFloat else totales[8] := totales[8] + (detcred.FieldByName('saldocuota').AsFloat * creditos_cab.FieldByName('indice').AsFloat);
        end;
        idanter[2] := detcred.FieldByName('codprest').AsString;
      end;
      detcred.Next;
    end;
    datosdb.QuitarFiltro(detcred);

    // Creditos Refinanciados
    conectar_creditosRefinanciados;
    datosdb.Filtrar(creditos_cabrefinanciados, 'fecha >= ' + utiles.sExprFecha(xdfecha) + ' and fecha <= ' + utiles.sExprFecha2000(xhfecha) + ' and idcredito = ' + rsql.FieldByName('items').AsString);
    creditos_cabrefinanciados.First;
    while not creditos_cabrefinanciados.Eof do Begin
      totales[3] := totales[3] + 1;
      if creditos_cab.FieldByName('indice').AsFloat = 0 then totales[4] := totales[4] + creditos_cabrefinanciados.FieldByName('monto').AsFloat else totales[4] := totales[4] + (creditos_cabrefinanciados.FieldByName('monto').AsFloat * creditos_cabrefinanciados.FieldByName('indice').AsFloat);
      creditos_cabrefinanciados.Next;
    end;
    datosdb.QuitarFiltro(creditos_cabrefinanciados);

    // Creditos Impagos - Refinanciados
    creditos_detrefinanciados.IndexFieldNames := 'Codprest;Expediente;Fechavto;Items';
    datosdb.Filtrar(creditos_detrefinanciados, 'fechavto >= ' + utiles.sExprFecha(xdfecha) + ' and fechavto <= ' + utiles.sExprFecha2000(xhfecha) + ' and estado = ' + '''' + 'I' + '''');
    creditos_detrefinanciados.First; idanter[2] := '';
    while not creditos_detrefinanciados.Eof do Begin
      if creditos_detrefinanciados.FieldByName('codprest').AsString <> idanter[2] then getDatos(creditos_detrefinanciados.FieldByName('codprest').AsString, creditos_detrefinanciados.FieldByName('expediente').AsString);
      if creditos_cabrefinanciados.FieldByName('idcredito').AsString = rsql.FieldByName('items').AsString then Begin
        if creditos_detrefinanciados.FieldByName('codprest').AsString <> idanter[2] then totales[9] := totales[9] + 1;
        if Indice_credito = 0 then totales[10] := totales[10] + creditos_detrefinanciados.FieldByName('saldocuota').AsFloat else totales[10] := totales[10] + (creditos_detrefinanciados.FieldByName('saldocuota').AsFloat * Indice_credito);
        idanter[2] := creditos_detrefinanciados.FieldByName('codprest').AsString;
      end;
      creditos_detrefinanciados.Next;
    end;
    datosdb.QuitarFiltro(creditos_detrefinanciados);
    creditos_detrefinanciados.IndexFieldNames := 'Codprest;Expediente;Items;Recibo';
    desconectar_creditosRefinanciados;

    // Creditos Refinanciados a Nivel Cuota
    conectar_cuotasRefinanciadas;
    datosdb.Filtrar(creditos_cabrefcuotas, 'fecha >= ' + utiles.sExprFecha(xdfecha) + ' and fecha <= ' + utiles.sExprFecha2000(xhfecha) + ' and idcredito = ' + rsql.FieldByName('items').AsString);
    creditos_cabrefcuotas.First;
    while not creditos_cabrefcuotas.Eof do Begin
      totales[5] := totales[5] + 1;
      if creditos_cabrefcuotas.FieldByName('indice').AsFloat = 0 then totales[6] := totales[6] + creditos_cabrefcuotas.FieldByName('monto').AsFloat else totales[6] := totales[6] + (creditos_cabrefcuotas.FieldByName('monto').AsFloat * creditos_cabrefcuotas.FieldByName('indice').AsFloat);
      creditos_cabrefcuotas.Next;
    end;
    datosdb.QuitarFiltro(creditos_cabrefcuotas);

    // Creditos Impagos - Refinanciados a Nivel Cuota
    creditos_detrefcuotas.IndexFieldNames := 'Codprest;Expediente;Fechavto;Items';
    datosdb.Filtrar(creditos_detrefcuotas, 'fechavto >= ' + utiles.sExprFecha(xdfecha) + ' and fechavto <= ' + utiles.sExprFecha2000(xhfecha) + ' and estado = ' + '''' + 'I' + '''');
    creditos_detrefcuotas.First; idanter[2] := '';
    while not creditos_detrefcuotas.Eof do Begin
      if creditos_detrefcuotas.FieldByName('codprest').AsString <> idanter[2] then getDatos(creditos_detrefcuotas.FieldByName('codprest').AsString, creditos_detrefcuotas.FieldByName('expediente').AsString);
      if creditos_cabrefcuotas.FieldByName('idcredito').AsString = rsql.FieldByName('items').AsString then Begin
        if creditos_detrefcuotas.FieldByName('codprest').AsString <> idanter[2] then totales[11] := totales[11] + 1;
        if creditos_cabrefcuotas.FieldByName('indice').AsFloat = 0 then totales[12] := totales[12] + creditos_detrefcuotas.FieldByName('saldocuota').AsFloat else totales[12] := totales[12] + (creditos_detrefcuotas.FieldByName('saldocuota').AsFloat * indice_credito);
        idanter[2] := creditos_detrefcuotas.FieldByName('codprest').AsString;
      end;
      creditos_detrefcuotas.Next;
    end;
    datosdb.QuitarFiltro(creditos_detrefcuotas);
    creditos_detrefcuotas.IndexFieldNames := 'Codprest;Expediente;Items;Recibo';

    desconectar_cuotasRefinanciadas;

    // Cr�ditos Cancelados
    creditos_cabhist.Open;
    datosdb.Filtrar(creditos_cabhist, 'fecha >= ' + utiles.sExprFecha(xdfecha) + ' and fecha <= ' + utiles.sExprFecha2000(xhfecha) + ' and cancelado <> ' + '''' + 'S' + '''');
    creditos_cabhist.First;
    while not creditos_cabhist.Eof do Begin
      if creditos_cabhist.FieldByName('idcredito').AsString = rsql.FieldByName('items').AsString then Begin
        totales[13] := totales[13] + 1;
        if creditos_cabhist.FieldByName('indice').AsFloat = 0 then totales[14] := totales[14] + creditos_cabhist.FieldByName('monto').AsFloat else totales[14] := totales[14] + (creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat);
      end;
      creditos_cabhist.Next;
    end;
    creditos_cabhist.Close;

    if totales[1] > 0 then Begin
      categoria.getDatos(rsql.FieldByName('items').AsString);

      if rsql.FieldByName('idlinea').AsString <> idanter[3] then Begin
        if totfin[1] > 0 then Begin
          TotalPorLinea(salida);
          list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
        end;
        list.Linea(0, 0, 'Categor�a:  ' +  categoria.IdLinea + ' - ' + UpperCase(categoria.DescripLinea), 1, 'Arial, negrita, 10', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
        idanter[3] := rsql.FieldByName('idlinea').AsString;
        idanter[4] := categoria.DescripLinea;
      end;

      list.Linea(0, 0, '     Linea:  ' + categoria.Items + '  ' + categoria.Descrip, 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'N');

      list.Linea(0, 0, '     CREDITOS OTORGADOS:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[1] + totales[13], 2, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totales[2] + totales[14], 3, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    end;

    if (totales[3] > 0) or (totales[5] > 0) then Begin
      list.Linea(0, 0, '     CREDITOS REFINANCIADOS:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[3] + totales[5], 2, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totales[4] + totales[6], 3, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    end;

    if totales[3] > 0 then Begin
      list.Linea(0, 0, utiles.espacios(15) + 'Refinanciaci�n Cr�dito:', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[3], 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[4], 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    end;

    if totales[5] > 0 then Begin
      list.Linea(0, 0, utiles.espacios(15) + 'Refinanciaci�n Cuotas:', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[5], 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[6], 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    end;

    if (totales[7] > 0) or (totales[9] > 0) or (totales[11] > 0) then Begin
      list.Linea(0, 0, '     CREDITOS IMPAGOS:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[7] + totales[9] + totales[11], 2, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totales[8] + totales[10] + totales[12], 3, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    end;

    if totales[7] > 0 then Begin
      list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Normales:', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[7], 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[8], 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    end;

    if totales[9] > 0 then Begin
      list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Refinanciados:', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[9], 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[10], 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    end;

    if totales[11] > 0 then Begin
      list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Refinanciaci�n a Nivel Cuota:', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[11], 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[12], 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    end;

    if totales[13] > 0 then Begin
      list.Linea(0, 0, '     CREDITOS CANCELADOS:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(75, list.Lineactual, '#####', totales[13], 2, 'Arial, negrita, 8');
      list.importe(95, list.Lineactual, '', totales[14], 3, 'Arial, negrita, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
    end;
    //--------------------------------------------------------------------------------------

    if totales[1] > 0 then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'N');

    totgral[1]  := totgral[1]  + totales[1];
    totgral[2]  := totgral[2]  + totales[2];
    totgral[3]  := totgral[3]  + totales[3];
    totgral[4]  := totgral[4]  + totales[4];
    totgral[5]  := totgral[5]  + totales[5];
    totgral[6]  := totgral[6]  + totales[6];
    totgral[7]  := totgral[7]  + totales[7];
    totgral[8]  := totgral[8]  + totales[8];
    totgral[9]  := totgral[9]  + totales[9];
    totgral[10] := totgral[10] + totales[10];
    totgral[11] := totgral[11] + totales[11];
    totgral[12] := totgral[12] + totales[12];
    totgral[13] := totgral[13] + totales[13];
    totgral[14] := totgral[14] + totales[14];

    totfin[1]  := totfin[1]  + totales[1];
    totfin[2]  := totfin[2]  + totales[2];
    totfin[3]  := totfin[3]  + totales[3];
    totfin[4]  := totfin[4]  + totales[4];
    totfin[5]  := totfin[5]  + totales[5];
    totfin[6]  := totfin[6]  + totales[6];
    totfin[7]  := totfin[7]  + totales[7];
    totfin[8]  := totfin[8]  + totales[8];
    totfin[9]  := totfin[9]  + totales[9];
    totfin[10] := totfin[10] + totales[10];
    totfin[11] := totfin[11] + totales[11];
    totfin[12] := totfin[12] + totales[12];
    totfin[13] := totfin[13] + totales[13];
    totfin[14] := totfin[14] + totales[14];

    rsql.Next;
  end;

  rsql.Close; rsql.Free;

  TotalPorLinea(salida);

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 12', salida, 'S');

  list.Linea(0, 0, '*** TOTALES FINALES ***', 1, 'Arial, negrita, 10', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '     CREDITOS OTORGADOS:', 1, 'Arial, negrita, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[1] + totgral[13], 2, 'Arial, negrita, 10');
  list.importe(95, list.Lineactual, '', totgral[2] + totgral[14], 3, 'Arial, negrita, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 10', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '     CREDITOS REFINANCIADOS:', 1, 'Arial, negrita, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[3] + totgral[5], 2, 'Arial, negrita, 10');
  list.importe(95, list.Lineactual, '', totgral[4] + totgral[6], 3, 'Arial, negrita, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 10', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Refinanciados:', 1, 'Arial, normal, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[3], 2, 'Arial, normal, 10');
  list.importe(95, list.Lineactual, '', totgral[4], 3, 'Arial, normal, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Refinanciados - en Cuotas:', 1, 'Arial, normal, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[5], 2, 'Arial, normal, 10');
  list.importe(95, list.Lineactual, '', totgral[6], 3, 'Arial, normal, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '     CREDITOS IMPAGOS:', 1, 'Arial, negrita, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[7] + totgral[9] + totgral[11], 2, 'Arial, negrita, 10');
  list.importe(95, list.Lineactual, '', totgral[8] + totgral[10] + totgral[12], 3, 'Arial, negrita, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 10', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Normales:', 1, 'Arial, normal, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[7], 2, 'Arial, normal, 10');
  list.importe(95, list.Lineactual, '', totgral[8], 3, 'Arial, normal, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Refinanciados:', 1, 'Arial, normal, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[9], 2, 'Arial, normal, 10');
  list.importe(95, list.Lineactual, '', totgral[10], 3, 'Arial, normal, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Refinanciaci�n a Nivel Cuota:', 1, 'Arial, normal, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[11], 2, 'Arial, normal, 10');
  list.importe(95, list.Lineactual, '', totgral[12], 3, 'Arial, normal, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '     CREDITOS CANCELADOS:', 1, 'Arial, negrita, 10', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totgral[13], 2, 'Arial, negrita, 10');
  list.importe(95, list.Lineactual, '', totgral[14], 3, 'Arial, negrita, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 10', salida, 'S');

  list.FinList;
end;

procedure TTCreditos.TotalPorLinea(salida: char);
// Objetivo...: Listar Total por Linea
var
  i: Integer;
Begin
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 12', salida, 'S');

  list.Linea(0, 0, '*** TOTAL  ' + UpperCase(idanter[4]), 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, '     CREDITOS OTORGADOS:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[1] + totfin[13], 2, 'Arial, negrita, 9');
  list.importe(95, list.Lineactual, '', totfin[2] + totfin[14], 3, 'Arial, negrita, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '     CREDITOS REFINANCIADOS:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[3] + totfin[5], 2, 'Arial, negrita, 9');
  list.importe(95, list.Lineactual, '', totfin[4] + totfin[6], 3, 'Arial, negrita, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Refinanciados:', 1, 'Arial, normal, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[3], 2, 'Arial, normal, 9');
  list.importe(95, list.Lineactual, '', totfin[4], 3, 'Arial, normal, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Refinanciados - en Cuotas:', 1, 'Arial, normal, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[5], 2, 'Arial, normal, 9');
  list.importe(95, list.Lineactual, '', totfin[6], 3, 'Arial, normal, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '     CREDITOS IMPAGOS:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[7] + totfin[9] + totfin[11], 2, 'Arial, negrita, 9');
  list.importe(95, list.Lineactual, '', totfin[8] + totfin[10] + totfin[12], 3, 'Arial, negrita, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Normales:', 1, 'Arial, normal, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[7], 2, 'Arial, normal, 9');
  list.importe(95, list.Lineactual, '', totfin[8], 3, 'Arial, normal, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Refinanciados:', 1, 'Arial, normal, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[9], 2, 'Arial, normal, 9');
  list.importe(95, list.Lineactual, '', totfin[10], 3, 'Arial, normal, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, utiles.espacios(15) + 'Cr�ditos Impagos - Refinanciaci�n a Nivel Cuota:', 1, 'Arial, normal, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[11], 2, 'Arial, normal, 9');
  list.importe(95, list.Lineactual, '', totfin[12], 3, 'Arial, normal, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');

  list.Linea(0, 0, '     CREDITOS CANCELADOS:', 1, 'Arial, negrita, 9', salida, 'N');
  list.importe(75, list.Lineactual, '#####', totfin[13], 2, 'Arial, negrita, 9');
  list.importe(95, list.Lineactual, '', totfin[14], 3, 'Arial, negrita, 9');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  for i := 1 to cantitems do totfin[i] := 0;
end;

procedure TTCreditos.InfCreditosOtorgadosPorLinea(xdfecha, xhfecha: String; xlista: TStringList; salida, xmodo: char);
// Objetivo...: Listado de Cr�ditos por Linea
// xmodo: 1. Todos / 2. Historicos / 3. Vigentes

var
  b1, ldat: Boolean;
  i, p: Integer;
  t: TQuery;
  estado, lin: String;
  l: TStringList;
  creditos_chequeshist: TTable;
Begin
  tipoList := salida;
  c1 := 0;

  t1_linea := TStringList.Create; t2_linea := TStringList.Create; t3_linea := TStringList.Create;

  lin := utiles.sLlenarIzquierda(lin, 80, '-');
  if salida = 'I' then list.ImprimirHorizontal;
  if salida = 'T' then list.IniciarImpresionModoTexto;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Cr�ditos Otorgados por Linea - Per�odo: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Expediente', 1, 'Arial, cursiva, 8');
    List.Titulo(13, list.Lineactual, 'Nombre del Prestatario', 2, 'Arial, cursiva, 8');
    List.Titulo(35, list.Lineactual, 'C.U.I.T.', 3, 'Arial, cursiva, 8');
    List.Titulo(45, list.Lineactual, 'Localidad', 4, 'Arial, cursiva, 8');
    List.Titulo(65, list.Lineactual, 'Nro. Cheque', 5, 'Arial, cursiva, 8');
    List.Titulo(80, list.Lineactual, 'Cuenta Bancaria', 6, 'Arial, cursiva, 8');
    List.Titulo(117, list.Lineactual, 'Entregado', 7, 'Arial, cursiva, 8');
    List.Titulo(133, list.Lineactual, 'Monto', 8, 'Arial, cursiva, 8');
    List.Titulo(138, list.Lineactual, 'Estado', 9, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if salida = 'X' then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 9.5);
    excel.setString('a' + l1, 'a' + l1, 'Cr�ditos Otorgados por Linea - Per�odo: ' + xdfecha + ' - ' + xhfecha, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Expediente', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 32);
    excel.setString('b' + l1, 'b' + l1, 'Nombre del Prestatario', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 11);
    excel.setString('c' + l1, 'c' + l1, 'C.U.I.T.', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 22);
    excel.setString('d' + l1, 'd' + l1, 'Localidad', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 11);
    excel.setString('e' + l1, 'e' + l1, 'Nro.Cheque', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('f' + l1, 'f' + l1, 22);
    excel.setString('f' + l1, 'f' + l1, 'Cuenta Bancaria', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('g' + l1, 'g' + l1, 9);
    excel.setString('g' + l1, 'g' + l1, 'Entregado', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('h' + l1, 'h' + l1, 12);
    excel.setString('h' + l1, 'h' + l1, 'Monto', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('i' + l1, 'i' + l1, 10);
    excel.setString('i' + l1, 'i' + l1, 'Estado', 'Arial, negrita, 10');
  end;
  if (salida = 'T') then Begin
    IniciarInforme(salida);
    List.LineaTxt(' ', True);
    List.LineaTxt('Cr�ditos Otorgados por Linea - Per�odo: ' + xdfecha + ' - ' + xhfecha, True);
    List.LineaTxt(' ', True);
    List.LineaTxt('Expediente   Nombre del Prestatario         Localidad                Nro. Cheque  Cuenta Bancaria             Entregado   Monto  Estado', True);
    List.LineaTxt(lin, True);
    List.LineaTxt(' ', True);
  end;

  IniciarArreglos;

  creditos_chequeshist := datosdb.openDB('cheques_creditoshist', '');
  creditos_chequeshist.Open;

  rsql := categoria.setCategoriasPorLinea;
  rsql.Open;
  for i := 1 to cantitems do Begin
    totales[i] := 0; totgral[i] := 0;
  end;

  while not rsql.Eof do Begin
    if utiles.verificarItemsLista(xlista, rsql.FieldByName('items').AsString) then Begin
    categoria.getDatos(rsql.FieldByName('items').AsString);
    if rsql.FieldByName('idlinea').AsString <> idanter[1] then Begin
      TotalCreditosRubro(salida);
      if categoria.Nivel <> idanter[4] then Begin
        TotalCreditosNivel(salida);
        if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        if (salida = 'T') then list.LineaTxt('', True);
        if salida = 'X' then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '');
        end;
        if categoria.Nivel = '1' then idanter[5] := 'CREDITOS FINANCIADOS POR LA ASOCIACI�N';
        if categoria.Nivel = '2' then idanter[5] := 'CREDITOS FINANCIADOS POR LA PROVINCIA';
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, idanter[5], 1, 'Arial, negrita, 11', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end;
        if salida = 'X' then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, idanter[5], 'Arial, negrita, 10');
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '');
        end;
        if salida = 'T' then Begin
          list.LineaTxt(idanter[5], True);
          list.LineaTxt('', True);
        end;
      end;
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        list.Linea(0, 0, rsql.FieldByName('items').AsString + ' - ' + UpperCase(categoria.DescripLinea), 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
      end;
      if salida = 'X' then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, '');
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, rsql.FieldByName('items').AsString + ' - ' + UpperCase(categoria.DescripLinea), 'Arial, negrita, 10');
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, '');
      end;
      if (salida = 'T') then Begin
        list.LineaTxt('', True);
        list.LineaTxt(rsql.FieldByName('items').AsString + ' - ' + UpperCase(categoria.DescripLinea), True);
        list.LineaTxt('', True);
      end;

      idanter[1] := rsql.FieldByName('idlinea').AsString;
      idanter[3] := categoria.DescripLinea;
      idanter[4] := categoria.Nivel;
    end;
    if rsql.FieldByName('items').AsString <> idanter[2] then Begin
      // Cr�ditos Vigentes
      if (xmodo = '1') or (xmodo = '3') then Begin    // Todos los cr�ditos
      datosdb.Filtrar(creditos_cab, 'idcredito = ' + rsql.FieldByName('items').AsString);
      creditos_cab.First; totales[1] := 0; totales[2] := 0;
      while not creditos_cab.Eof do Begin
        if (creditos_cab.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (creditos_cab.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
          estado := ''; ldat := True;
          if creditos_cab.FieldByName('refinancia').AsString = 'S' then estado := 'CRE.REF.';
          if creditos_cab.FieldByName('refcuotas').AsString = 'S' then // Si esta con cuotas refinanciadas y tiene saldo lo marcamos
            if setSaldoCuotaRef(creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString) > 0 then estado := 'CUO.REF.';

          if datosdb.Buscar(exptesjudiciales, 'codprest', 'expediente', creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString) then estado := 'GES.JUD.';

          if totales[1] = 0 then Begin
            TotalCreditosLinea(salida);
            if (salida = 'P') or (salida = 'I') then Begin
              list.Linea(0, 0, '   ' + categoria.Items + ' - ' + categoria.Descrip, 1, 'Arial, negrita, 8', salida, 'S');
              list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
            end;
            if salida = 'X' then Begin
              Inc(c1); l1 := Trim(IntToStr(c1));
              excel.setString('a' + l1, 'a' + l1, '   ' + categoria.Items + ' - ' + categoria.Descrip, 'Arial, negrita, 10');
              Inc(c1); l1 := Trim(IntToStr(c1));
              excel.setString('a' + l1, 'a' + l1, '');
            end;
            if (salida = 'T') then Begin
              list.LineaTxt(categoria.Items + ' - ' + categoria.Descrip, True);
              list.LineaTxt('', True);
            end;
            idanter[2] := rsql.FieldByName('items').AsString;
          end;

          l := setChequesCredito(creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString);
          prestatario.getDatos(creditos_cab.FieldByName('codprest').AsString);

          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(3, list.Lineactual, creditos_cab.FieldByName('codprest').AsString + ' - ' + creditos_cab.FieldByName('expediente').AsString, 2, 'Arial, normal, 8', salida, 'N');
            list.Linea(13, list.Lineactual, Copy(prestatario.nombre, 1, 20), 3, 'Arial, normal, 8', salida, 'N');
            list.Linea(35, list.Lineactual, prestatario.Cuit, 4, 'Arial, normal, 8', salida, 'N');
            list.Linea(47, list.Lineactual, Copy(prestatario.localidad, 1, 25), 5, 'Arial, normal, 8', salida, 'N');

            if l.Count > 0 then Begin  // Lanzamos el primer cheque
              i := 1;
              p := Pos(';1', l.Strings[i-1]);
              planctas.getDatos(Copy(l.Strings[i-1], p+2, 12));
              list.Linea(65, list.Lineactual, Copy(l.Strings[i-1], 3, p-3), 6, 'Arial, normal, 8', salida, 'N');
              list.Linea(80, list.Lineactual, planctas.cuenta, 7, 'Arial, normal, 8', salida, 'N');
            end else Begin
              list.Linea(65, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'N');
              list.Linea(80, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'N');
            end;

            list.Linea(117, list.Lineactual, utiles.sFormatoFecha(creditos_cab.FieldByName('fecha').AsString), 8, 'Arial, normal, 8', salida, 'N');
            if (creditos_cab.FieldByName('indice').AsFloat = 0) or (creditos_cab.FieldByName('monto_real').AsFloat <> 0) then list.importe(137, list.Lineactual, '', creditos_cab.FieldByName('monto_real').AsFloat, 9, 'Arial, normal, 8') else
              list.importe(137, list.Lineactual, '', creditos_cab.FieldByName('monto').AsFloat * creditos_cab.FieldByName('indice').AsFloat, 9, 'Arial, normal, 8');
            list.Linea(138, list.Lineactual, estado, 10, 'Arial, normal, 8', salida, 'S');

            // Revisamos si hay mas de un cheque
            if l.Count > 1 then Begin   // Lanzamos el resto de los cheques
              For i := 2 to l.Count do Begin
                p := Pos(';1', l.Strings[i-1]);
                planctas.getDatos(Copy(l.Strings[i-1], p+2, 12));
                list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
                list.Linea(65, list.Lineactual, Copy(l.Strings[i-1], 3, p-3), 2, 'Arial, normal, 8', salida, 'N');
                list.Linea(80, list.Lineactual, planctas.cuenta, 3, 'Arial, normal, 8', salida, 'N');
                list.Linea(85, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
              end;
            end;

          end;
          if salida = 'X' then Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, creditos_cab.FieldByName('codprest').AsString + ' - ' + creditos_cab.FieldByName('expediente').AsString, 'Arial, normal, 8');
            excel.setString('b' + l1, 'b' + l1, Copy(prestatario.nombre, 1, 20), 'Arial, normal, 8');
            excel.setString('c' + l1, 'c' + l1, prestatario.cuit, 'Arial, normal, 8');
            excel.setString('d' + l1, 'd' + l1, prestatario.localidad, 'Arial, normal, 8');

            if l.Count > 0 then Begin  // Lanzamos el primer cheque
              i := 1;
              p := Pos(';1', l.Strings[i-1]);
              planctas.getDatos(Copy(l.Strings[i-1], p+2, 12));
              excel.setString('e' + l1, 'e' + l1, Copy(l.Strings[i-1], 3, p-3), 'Arial, normal, 8');
              excel.setString('f' + l1, 'f' + l1, planctas.cuenta, 'Arial, normal, 8');
            end;

            excel.setString('g' + l1, 'g' + l1, '''' + utiles.sFormatoFecha(creditos_cab.FieldByName('fecha').AsString), 'Arial, normal, 8');
            if (creditos_cab.FieldByName('indice').AsFloat = 0) or (creditos_cab.FieldByName('monto_real').AsFloat <> 0) then excel.setReal('h' + l1, 'h' + l1, creditos_cab.FieldByName('monto_real').AsFloat, 'Arial, normal, 8') else
              excel.setReal('h' + l1, 'h' + l1, creditos_cab.FieldByName('monto').AsFloat * creditos_cab.FieldByName('indice').AsFloat, 'Arial, normal, 8');
            excel.setString('i' + l1, 'i' + l1, estado, 'Arial, normal, 8');

            // Revisamos si hay mas de un cheque
            if l.Count > 1 then Begin   // Lanzamos el resto de los cheques
              For i := 2 to l.Count do Begin
                Inc(c1); l1 := Trim(IntToStr(c1));
                p := Pos(';1', l.Strings[i-1]);
                planctas.getDatos(Copy(l.Strings[i-1], p+2, 12));
                list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
                excel.setString('d' + l1, 'd' + l1, Copy(l.Strings[i-1], 3, p-3), 'Arial, normal, 8');
                excel.setString('e' + l1, 'e' + l1, planctas.cuenta, 'Arial, normal, 8');
              end;
            end;

            if Length(Trim(r1)) = 0 then r1 := 'h' + l1;
            r2 := 'h' + l1;
          end;

          if (salida = 'T') then Begin
            list.LineaTxt('', True);
            list.LineaTxt(creditos_cab.FieldByName('codprest').AsString + ' - ' + creditos_cab.FieldByName('expediente').AsString + ' ', False);
            list.LineaTxt(utiles.StringLongitudFija(Copy(prestatario.nombre, 1, 20), 30), False);
            list.LineaTxt(utiles.StringLongitudFija(Copy(prestatario.localidad, 1, 25), 25), False);

            if l.Count > 0 then Begin  // Lanzamos el primer cheque
              i := 1;
              p := Pos(';1', l.Strings[i-1]);
              planctas.getDatos(Copy(l.Strings[i-1], p+2, 12));
              list.LineaTxt(Copy(l.Strings[i-1], 3, p-3) + ' ', False);
              list.LineaTxt(utiles.StringLongitudFija(planctas.cuenta, 30), False);
            end else Begin
              list.LineaTxt('     ', False);
              list.LineaTxt(utiles.espacios(30), False);
            end;

            list.LineaTxt(utiles.sFormatoFecha(creditos_cab.FieldByName('fecha').AsString), False);
            if (creditos_cab.FieldByName('indice').AsFloat = 0) or (creditos_cab.FieldByName('monto_real').AsFloat <> 0) then list.importeTxt(creditos_cab.FieldByName('monto_real').AsFloat, 12, 2, False) else
              list.importeTxt(creditos_cab.FieldByName('monto').AsFloat * creditos_cab.FieldByName('indice').AsFloat, 12, 2, False);
            list.LineaTxt(estado, True);

            // Revisamos si hay mas de un cheque
            if l.Count > 1 then Begin   // Lanzamos el resto de los cheques
              For i := 2 to l.Count do Begin
                p := Pos(';1', l.Strings[i-1]);
                planctas.getDatos(Copy(l.Strings[i-1], p+2, 12));
                list.LineaTxt('', True);
                list.LineaTxt(Copy(l.Strings[i-1], 3, p-3), False);
                list.LineaTxt(utiles.StringLongitudFija(planctas.cuenta, 30), False);
                list.LineaTxt('', True);
              end;
            end;

          end;

          totales[1] := totales[1] + 1;
          if (creditos_cab.FieldByName('indice').AsFloat = 0) or (creditos_cab.FieldByName('monto_real').AsFloat <> 0) then totales[2] := totales[2] + creditos_cab.FieldByName('monto_real').AsFloat else totales[2] := totales[2] + (creditos_cab.FieldByName('monto').AsFloat * creditos_cab.FieldByName('indice').AsFloat);
        end;
        creditos_cab.Next;
      end;
      datosdb.QuitarFiltro(creditos_cab);
      end;

      if xmodo <> '3' then Begin
      creditos_cabhist.Open;
      datosdb.Filtrar(creditos_cabhist, 'idcredito = ' + rsql.FieldByName('items').AsString);
      creditos_cabhist.First; totales[3] := 0; totales[4] := 0;
      while not creditos_cabhist.Eof do Begin
        if (creditos_cabhist.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (creditos_cabhist.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
          estado := 'CANCELADO';
          if (creditos_cabhist.FieldByName('cancelado').AsString = 'B') then estado := 'BAJA ' + utiles.sFormatoFecha(creditos_cabhist.FieldByName('fechacancelacion').AsString);
          ldat := True;
          if totales[1] + totales[3] = 0 then Begin
            TotalCreditosLinea(salida);
            if (salida = 'P') or (salida = 'I') then Begin
              list.Linea(0, 0, '   ' + categoria.Items + ' - ' + categoria.Descrip, 1, 'Arial, negrita, 8', salida, 'S');
              list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
            end;
            if salida = 'X' then Begin
              Inc(c1); l1 := Trim(IntToStr(c1));
              excel.setString('a' + l1, 'a' + l1, '   ' + categoria.Items + ' - ' + categoria.Descrip, 'Arial, negrita, 10');
              Inc(c1); l1 := Trim(IntToStr(c1));
              excel.setString('a' + l1, 'a' + l1, ' ');
            end;
            if (salida = 'T') then Begin
              list.LineaTxt(categoria.Items + ' - ' + utiles.StringLongitudFija(categoria.Descrip, 30), True);
              list.LineaTxt('', True);
            end;
            idanter[2] := rsql.FieldByName('items').AsString;
          end;

          prestatario.getDatos(creditos_cabhist.FieldByName('codprest').AsString);

          // revisar
          if datosdb.Buscar(creditos_chequeshist, 'codprest', 'expediente', creditos_cabhist.FieldByName('codprest').AsString, creditos_cabhist.FieldByName('expediente').AsString) then Begin
            Nrocheque := creditos_chequeshist.FieldByName('nrocheque').AsString;
            Codcta    := creditos_chequeshist.FieldByName('codcta').AsString;
          end else Begin
            Nrocheque := ''; Codcta := '';
          end;
          planctas.getDatos(codcta);

          if (salida = 'P') or (salida = 'I') then Begin
            list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
            list.Linea(3, list.Lineactual, creditos_cabhist.FieldByName('codprest').AsString + ' - ' + creditos_cabhist.FieldByName('expediente').AsString, 2, 'Arial, normal, 8', salida, 'N');
            list.Linea(13, list.Lineactual, Copy(prestatario.nombre, 1, 20), 3, 'Arial, normal, 8', salida, 'N');
            list.Linea(35, list.Lineactual, prestatario.Cuit, 4, 'Arial, normal, 8', salida, 'N');
            list.Linea(47, list.Lineactual, Copy(prestatario.localidad, 1, 25), 5, 'Arial, normal, 8', salida, 'N');
            list.Linea(65, list.Lineactual, Nrocheque, 6, 'Arial, normal, 8', salida, 'N');
            list.Linea(80, list.Lineactual, planctas.cuenta, 7, 'Arial, normal, 8', salida, 'N');
            list.Linea(117, list.Lineactual, utiles.sFormatoFecha(creditos_cabhist.FieldByName('fecha').AsString), 8, 'Arial, normal, 8', salida, 'N');

            if creditos_cabhist.FieldByName('indice').AsFloat = 0 {) or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0)} then list.importe(137, list.Lineactual, '', creditos_cabhist.FieldByName('monto').AsFloat, 9, 'Arial, normal, 8') else
              list.importe(137, list.Lineactual, '', creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat, 9, 'Arial, normal, 8');
            list.Linea(138, list.Lineactual, estado, 10, 'Arial, normal, 8', salida, 'S');
            if (copy(estado, 1, 4) = 'BAJA') then
              list.Linea(0, 0, '        ' + creditos_cabhist.FieldByName('motivobaja').AsString, 1, 'Arial, cursiva, 8', salida, 'S');
          end;
          if salida = 'X' then Begin
            Inc(c1); l1 := Trim(IntToStr(c1));
            excel.setString('a' + l1, 'a' + l1, creditos_cabhist.FieldByName('codprest').AsString + ' - ' + creditos_cabhist.FieldByName('expediente').AsString, 'Arial, normal, 8');
            excel.setString('b' + l1, 'b' + l1, Copy(prestatario.nombre, 1, 20), 'Arial, normal, 8');
            excel.setString('c' + l1, 'c' + l1, prestatario.cuit, 'Arial, normal, 8');
            excel.setString('d' + l1, 'd' + l1, prestatario.localidad, 'Arial, normal, 8');
            excel.setString('e' + l1, 'e' + l1, Nrocheque, 'Arial, normal, 8');
            excel.setString('f' + l1, 'f' + l1, planctas.cuenta, 'Arial, normal, 8');
            excel.setString('g' + l1, 'g' + l1, '''' + utiles.sFormatoFecha(creditos_cabhist.FieldByName('fecha').AsString), 'Arial, normal, 8');
            if creditos_cabhist.FieldByName('indice').AsFloat = 0 then excel.setReal('h' + l1, 'h' + l1, creditos_cabhist.FieldByName('monto').AsFloat, 'Arial, normal, 8') else
              excel.setReal('h' + l1, 'h' + l1, creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat, 'Arial, normal, 8');
            excel.setString('i' + l1, 'i' + l1, estado, 'Arial, normal, 8');

            if (copy(estado, 1, 4) = 'BAJA') then begin
              Inc(c1); l1 := Trim(IntToStr(c1));
              excel.setString('a' + l1, 'a' + l1, creditos_cabhist.FieldByName('motivobaja').AsString, 'Arial, normal, 8');
            end;

            if Length(Trim(r1)) = 0 then r1 := 'h' + l1;
            r2 := 'h' + l1;
          end;
          if salida = 'T' then Begin
            list.LineaTxt('', False);
            list.LineaTxt(creditos_cabhist.FieldByName('codprest').AsString + ' - ' + creditos_cabhist.FieldByName('expediente').AsString, False);
            list.LineaTxt(utiles.StringLongitudFija(Copy(prestatario.nombre, 1, 20), 30), False);
            list.LineaTxt(utiles.StringLongitudFija(Copy(prestatario.localidad, 1, 25), 25), False);
            list.LineaTxt(utiles.StringLongitudFija(Nrocheque, 12), False);
            list.LineaTxt(utiles.StringLongitudFija(planctas.cuenta, 30), False);
            list.LineaTxt(utiles.sFormatoFecha(creditos_cabhist.FieldByName('fecha').AsString), False);

            if (creditos_cabhist.FieldByName('indice').AsFloat = 0) {or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0)} then list.importeTxt(creditos_cabhist.FieldByName('monto').AsFloat, 12, 2, True) else
              list.importeTxt(creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat, 12, 10, True);
          end;

          totales[3] := totales[3] + 1;
          if (creditos_cabhist.FieldByName('indice').AsFloat = 0) {or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0)} then totales[4] := totales[4] + creditos_cabhist.FieldByName('monto').AsFloat else totales[4] := totales[4] + (creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat);
        end;
        creditos_cabhist.Next;
      end;
      datosdb.QuitarFiltro(creditos_cabhist);
      datosdb.closeDB(creditos_cabhist);
      end;

      TotalCreditosLinea(salida);
      end;
    end;

    rsql.Next;
  end;

  TotalCreditosRubro(salida);
  TotalCreditosNivel(salida);

  // Cr�ditos Cancelados por Anticipado

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, 'Cr�ditos Anulados', 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if salida = 'X' then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Cr�ditos Anulados');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt('', True);
    list.LineaTxt('Cr�ditos Anulados', True);
    list.LineaTxt('', True);
  end;
      
  creditos_cabhist.Open;
  datosdb.Filtrar(creditos_cabhist, 'fechacancelacion >= ' + '''' + utiles.sExprFecha(xdfecha) + '''' + ' and fechacancelacion <= ' + '''' + utiles.sExprFecha(xhfecha) + '''' + ' and cancelado = ' + '''' + 'S' + '''');
  creditos_cabhist.First; totales[3] := 0; totales[4] := 0;
  while not creditos_cabhist.Eof do Begin
    if utiles.verificarItemsLista(xlista, creditos_cabhist.FieldByName('idcredito').AsString) then Begin
      estado := 'ANULADO'; ldat := True;
      if totales[1] + totales[3] = 0 then Begin
        categoria.getDatos(creditos_cabhist.FieldByName('idcredito').AsString);
        TotalCreditosLinea(salida);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '   ' + categoria.Items + ' - ' + categoria.Descrip, 1, 'Arial, negrita, 8', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
        end;
        if (salida = 'X') then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '   ' + categoria.Items + ' - ' + categoria.Descrip, 'Arial, negrita, 10');
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, ' ');
        end;
        if (salida = 'T') then Begin
          list.LineaTxt('   ' + categoria.Items + ' - ' + categoria.Descrip, True);
          list.LineaTxt('', True);
        end;

        idanter[2] := rsql.FieldByName('items').AsString;
      end;

      prestatario.getDatos(creditos_cabhist.FieldByName('codprest').AsString);
      if datosdb.Buscar(creditos_chequeshist, 'codprest', 'expediente', creditos_cabhist.FieldByName('codprest').AsString, creditos_cabhist.FieldByName('expediente').AsString) then Begin
        Nrocheque := creditos_chequeshist.FieldByName('nrocheque').AsString;
        Codcta    := creditos_chequeshist.FieldByName('codcta').AsString;
      end else Begin
        Nrocheque := ''; Codcta := '';
      end;
      planctas.getDatos(codcta);

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(3, list.Lineactual, creditos_cabhist.FieldByName('codprest').AsString + ' - ' + creditos_cabhist.FieldByName('expediente').AsString, 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(13, list.Lineactual, Copy(prestatario.nombre, 1, 30), 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(35, list.Lineactual, prestatario.cuit, 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(47, list.Lineactual, Copy(prestatario.localidad, 1, 25), 5, 'Arial, normal, 8', salida, 'N');
        list.Linea(65, list.Lineactual, Nrocheque, 6, 'Arial, normal, 8', salida, 'N');
        list.Linea(80, list.Lineactual, planctas.cuenta, 7, 'Arial, normal, 8', salida, 'N');
        list.Linea(117, list.Lineactual, utiles.sFormatoFecha(creditos_cabhist.FieldByName('fecha').AsString), 8, 'Arial, normal, 8', salida, 'N');

        if (creditos_cabhist.FieldByName('indice').AsFloat = 0) or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0) then list.importe(137, list.Lineactual, '', creditos_cabhist.FieldByName('monto_real').AsFloat, 9, 'Arial, normal, 8') else
          list.importe(137, list.Lineactual, '', creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat, 9, 'Arial, normal, 8');
        list.Linea(138, list.Lineactual, estado, 10, 'Arial, normal, 8', salida, 'S');
      end;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, creditos_cabhist.FieldByName('codprest').AsString + ' - ' + creditos_cabhist.FieldByName('expediente').AsString, 'Arial, normal, 8');
        excel.setString('b' + l1, 'b' + l1, Copy(prestatario.nombre, 1, 30), 'Arial, normal, 8');
        excel.setString('c' + l1, 'c' + l1, prestatario.cuit, 'Arial, normal, 8');
        excel.setString('d' + l1, 'd' + l1, prestatario.localidad, 'Arial, normal, 8');
        excel.setString('e' + l1, 'e' + l1, Nrocheque, 'Arial, normal, 8');
        excel.setString('f' + l1, 'f' + l1, planctas.cuenta, 'Arial, normal, 8');
        excel.setString('g' + l1, 'g' + l1, '''' + utiles.sFormatoFecha(creditos_cabhist.FieldByName('fecha').AsString), 'Arial, normal, 8');
        if creditos_cabhist.FieldByName('indice').AsFloat = 0 then excel.setReal('h' + l1, 'h' + l1, creditos_cabhist.FieldByName('monto').AsFloat, 'Arial, normal, 8') else
          excel.setReal('h' + l1, 'h' + l1, creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat, 'Arial, normal, 8');
        excel.setString('i' + l1, 'i' + l1, estado, 'Arial, normal, 8');
        if Length(Trim(r1)) = 0 then r1 := 'h' + l1;
        r2 := 'h' + l1;
      end;
      if (salida = 'T') then Begin
        list.LineaTxt('', True);
        list.LineaTxt(creditos_cabhist.FieldByName('codprest').AsString + ' - ' + creditos_cabhist.FieldByName('expediente').AsString + ' ', False);
        list.LineaTxt(utiles.StringLongitudFija(Copy(prestatario.nombre, 1, 30), 31),False);
        list.LineaTxt(utiles.StringLongitudFija(Copy(prestatario.localidad, 1, 25), 26), False);
        list.LineaTxt(utiles.StringLongitudFija(Nrocheque, 8), False);
        list.LineaTxt(planctas.cuenta + ' ', False);
        list.LineaTxt(utiles.sFormatoFecha(creditos_cabhist.FieldByName('fecha').AsString), False);

        if (creditos_cabhist.FieldByName('indice').AsFloat = 0) or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0) then list.importetxt(creditos_cabhist.FieldByName('monto_real').AsFloat, 12, 2, False) else
          list.importetxt(creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat, 12, 2, False);
        list.LineaTxt('', True);
      end;

      totgral[5] := totgral[5] - 1;
      if (creditos_cabhist.FieldByName('indice').AsFloat = 0) or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0) then totgral[6] := totgral[6] - creditos_cabhist.FieldByName('monto_real').AsFloat else totgral[6] := totgral[6] - (creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat);
    end;
    creditos_cabhist.Next;
  end;
  datosdb.QuitarFiltro(creditos_cabhist);
  datosdb.closeDB(creditos_cabhist);

  if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  if ldat {totgral[5] + totgral[6] > 0} then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(137, list.Lineactual, '#######################################', '--------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 11', salida, 'N');
      list.importe(110, list.Lineactual, '#####', totgral[5] + totgral[7], 2, 'Arial, negrita, 11');
      list.importe(137, list.Lineactual, '', totgral[6] + totgral[8], 3, 'Arial, negrita, 11');
      list.Linea(138, list.Lineactual, '', 4, 'Arial, negrita, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('h' + l1, 'h' + l1, '''' + '----------------------', 'Arial, normal, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL GENERAL:', 'Arial, negrita, 10');
      excel.setReal('e' + l1, 'e' + l1, totgral[5] + totgral[7], 'Arial, negrita, 10');
      excel.setReal('h' + l1, 'h' + l1, totgral[6] + totgral[8], 'Arial, negrita, 10');
    end;
    if (salida = 'T') then Begin
      list.lineatxt(utiles.espacios(105) + '--------------------------', True);
      list.LineaTxt(utiles.StringLongitudFija('TOTAL GENERAL:', 107), False);
      list.importeTxt(totgral[5] + totgral[7], 10, 2, False);
      list.importeTxt(totgral[6] + totgral[8], 12, 2, True);
      list.LineaTxt('', True);
    end;

  end;

  rsql.Close; rsql.Free;
  datosdb.closeDB(creditos_chequeshist);

  if (salida = 'P') or (salida = 'I') then Begin
    list.FinList;
    if salida = 'I' then list.ImprimirVetical;
  end;
  if salida = 'X' then excel.Visulizar;
  if salida = 'T' then PresentarInforme;
end;

procedure TTCreditos.TotalCreditosLinea(salida: char);
// Objetivo...: Listar Total Cr�ditos
Begin
  if totales[1] + totales[3] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(137, list.Lineactual, '#######################################', '--------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(138, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '   Total ' + categoria.Descrip + ':', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(110, list.Lineactual, '####', totales[1] + totales[3], 2, 'Arial, negrita, 8');
      list.importe(137, list.Lineactual, '', totales[2] + totales[4], 3, 'Arial, negrita, 8');
      list.Linea(138, list.Lineactual, '', 4, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('h' + l1, 'h' + l1, '''' + '-----------------------------', 'Arial, normal, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '   Total ' + categoria.Descrip + ':', 'Arial, negrita, 10');
      excel.setFormulaArray('h' + l1, 'h' + l1, '=suma(' + r1 + '..' + r2 + ')', 'Arial, negrita, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt('', True);
      list.lineaTxt(utiles.espacios(105) + '--------------------------', True);
      list.LineaTxt(utiles.StringLongitudFija('   Total ' + categoria.Descrip + ':', 107), False);
      list.importeTxt(totales[1] + totales[3], 10, 0, False);
      list.importeTxt(totales[2] + totales[4], 12, 2, True);
      list.LineaTxt('', True);
    end;

    totgral[1] := totgral[1] + totales[1];
    totgral[2] := totgral[2] + totales[2];
    totgral[3] := totgral[3] + totales[3];
    totgral[4] := totgral[4] + totales[4];

    t1_linea.Add(categoria.Items);
    t2_linea.Add(FloatToStr(totales[1] + totales[3]));
    t3_linea.Add(FloatToStr(totales[2] + totales[4]));

  end;
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0;
  r1 := ''; r2 := '';
end;

procedure TTCreditos.TotalCreditosRubro(salida: char);
// Objetivo...: Listar Total Cr�ditos
Begin
  if totgral[1] + totgral[3] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(137, list.Lineactual, '#######################################', '--------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(138, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, '   Total ' + idanter[3] + ':', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(110, list.Lineactual, '####', totgral[1] + totgral[3], 2, 'Arial, negrita, 9');
      list.importe(137, list.Lineactual, '', totgral[2] + totgral[4], 3, 'Arial, negrita, 9');
      list.Linea(138, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('d' + l1, 'd' + l1, '''' + '-----------------------------', 'Arial, normal, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '   Total ' + idanter[3] + ':', 'Arial, negrita, 10');
      excel.setReal('e' + l1, 'e' + l1, totgral[1] + totgral[3], 'Arial, negrita, 10');
      excel.setReal('h' + l1, 'h' + l1, totgral[2] + totgral[4], 'Arial, negrita, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt('', True);
      list.LineaTxt(utiles.espacios(105) + '-------------------------', True);
      list.Lineatxt(utiles.stringLongitudFija('   Total ' + idanter[3] + ':', 107), False);
      list.importeTxt(totgral[1] + totgral[3], 10, 0, False);
      list.importeTxt(totgral[2] + totgral[4], 12, 2, True);
      list.LineaTxt('', True);
    end;
  end;

  totgral[5] := totgral[5] + totgral[1];
  totgral[6] := totgral[6] + totgral[2];
  totgral[7] := totgral[7] + totgral[3];
  totgral[8] := totgral[8] + totgral[4];

  totgral[10] := totgral[10] + totgral[1];
  totgral[11] := totgral[11] + totgral[2];
  totgral[12] := totgral[12] + totgral[3];
  totgral[13] := totgral[13] + totgral[4];

  totgral[1] := 0; totgral[2] := 0; totgral[3] := 0; totgral[4] := 0;
end;

procedure TTCreditos.TotalCreditosLineaResumen(salida: char);
// Objetivo...: Listar Total Cr�ditos
Begin
  if totales[1] + totales[3] > 0 then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, categoria.Descrip, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(60, list.Lineactual, '####', totales[1] + totales[3], 2, 'Arial, normal, 8');
      list.importe(95, list.Lineactual, '', totales[2] + totales[4], 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
    end else Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '    ' + categoria.Descrip + ':', 'Arial, normal, 10');
      excel.setReal('b' + l1, 'b' + l1, totales[1] + totales[3], 'Arial, normal, 10');
      excel.setReal('c' + l1, 'c' + l1, totales[2] + totales[4], 'Arial, normal, 10');
    end;
  end;
  totgral[1] := totgral[1] + totales[1];
  totgral[2] := totgral[2] + totales[2];
  totgral[3] := totgral[3] + totales[3];
  totgral[4] := totgral[4] + totales[4];
  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0;
  r1 := ''; r2 := '';
end;

procedure TTCreditos.TotalCreditosRubroResumen(salida: char);
// Objetivo...: Listar Total Cr�ditos
Begin
  if totgral[1] + totgral[3] > 0 then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Total ' + idanter[3] + ':', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(60, list.Lineactual, '####', totgral[1] + totgral[3], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totgral[2] + totgral[4], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end else Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Total ' + idanter[3] + ':', 'Arial, negrita, 10');
      excel.setReal('b' + l1, 'b' + l1, totgral[1] + totgral[3], 'Arial, negrita, 10');
      excel.setReal('c' + l1, 'c' + l1, totgral[2] + totgral[4], 'Arial, negrita, 10');
    end;
  end;
  totgral[5] := totgral[5] + totgral[1];
  totgral[6] := totgral[6] + totgral[2];
  totgral[7] := totgral[7] + totgral[3];
  totgral[8] := totgral[8] + totgral[4];

  totgral[10] := totgral[10] + totgral[1];
  totgral[11] := totgral[11] + totgral[2];
  totgral[12] := totgral[12] + totgral[3];
  totgral[13] := totgral[13] + totgral[4];

  totgral[1] := 0; totgral[2] := 0; totgral[3] := 0; totgral[4] := 0;
end;

procedure TTCreditos.TotalCreditosNivel(salida: char);
// Objetivo...: Listar Total Nivel Cr�ditos
Begin
  if totgral[10] + totgral[12] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(137, list.Lineactual, '#######################################', '--------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(138, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, 'TOTAL ' + idanter[5] + ':', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(110, list.Lineactual, '####', totgral[10] + totgral[12], 2, 'Arial, negrita, 9');
      list.importe(137, list.Lineactual, '', totgral[11] + totgral[13], 3, 'Arial, negrita, 9');
      list.Linea(128, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('d' + l1, 'd' + l1, '''' + '-----------------------------', 'Arial, normal, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '   TOTAL ' + idanter[5] + ':', 'Arial, negrita, 10');
      excel.setReal('e' + l1, 'e' + l1, totgral[10] + totgral[12], 'Arial, negrita, 10');
      excel.setReal('h' + l1, 'h' + l1, totgral[11] + totgral[13], 'Arial, negrita, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '');
    end;
    if (salida = 'T') then Begin
      list.LineaTxt('', True);
      list.LineaTxt(utiles.espacios(105) + '-------------------------------', True);
      list.LineaTxt(utiles.stringLongitudfija('TOTAL ' + idanter[5] + ':', 107), False);
      list.importeTxt(totgral[10] + totgral[12], 10, 2, False);
      list.importeTxt(totgral[11] + totgral[13], 12, 2, True);
      list.LineaTxt('', True);
    end;
  end;
  totgral[10] := 0; totgral[11] := 0; totgral[12] := 0; totgral[13] := 0;
end;

procedure TTCreditos.TotalCreditosNivelResumen(salida: char);
// Objetivo...: Listar Total Nivel Cr�ditos
Begin
  if totgral[10] + totgral[12] > 0 then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'TOTAL ' + idanter[5] + ':', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(60, list.Lineactual, '####', totgral[10] + totgral[12], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totgral[11] + totgral[13], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end else Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL ' + idanter[5] + ':', 'Arial, negrita, 10');
      excel.setReal('b' + l1, 'b' + l1, totgral[10] + totgral[12], 'Arial, negrita, 10');
      excel.setReal('c' + l1, 'c' + l1, totgral[11] + totgral[13], 'Arial, negrita, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, '');
    end;
  end;
  totgral[10] := 0; totgral[11] := 0; totgral[12] := 0; totgral[13] := 0;
end;

//------------------------------------------------------------------------------

procedure TTCreditos.InfCreditosOtorgadosPorLineaResumen(xdfecha, xhfecha: String; xlista: TStringList; salida: char);
// Objetivo...: Listado de Cr�ditos por Linea
var
  b1: Boolean;
  i, p: Integer;
  t: TQuery;
  estado: String;
  l: TStringList;
  creditos_chequeshist: TTable;
Begin
  c1 := 0;
  if salida <> 'X' then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Resumen Cr�ditos Otorgados por Linea - Per�odo: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Linea de Cr�dito', 1, 'Arial, cursiva, 8');
    List.Titulo(55, list.Lineactual, 'Cantidad', 2, 'Arial, cursiva, 8');
    List.Titulo(90, list.Lineactual, 'Monto', 3, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 50);
    excel.setString('a' + l1, 'a' + l1, 'Resumen Cr�ditos Otorgados por Linea - Per�odo: ' + xdfecha + ' - ' + xhfecha, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Linea de Cr�dito', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 15);
    excel.setString('b' + l1, 'b' + l1, 'Cantidad', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 17);
    excel.setString('c' + l1, 'c' + l1, 'Monto', 'Arial, negrita, 10');
  end;

  IniciarArreglos;

  creditos_chequeshist := datosdb.openDB('cheques_creditoshist', '');
  creditos_chequeshist.Open;

  rsql := categoria.setCategoriasPorLinea;
  rsql.Open;
  for i := 1 to cantitems do Begin
    totales[i] := 0; totgral[i] := 0;
  end;

  while not rsql.Eof do Begin
    if utiles.verificarItemsLista(xlista, rsql.FieldByName('items').AsString) then Begin
    categoria.getDatos(rsql.FieldByName('items').AsString);
    if rsql.FieldByName('idlinea').AsString <> idanter[1] then Begin
      TotalCreditosRubroResumen(salida);
      if categoria.Nivel <> idanter[4] then Begin
        TotalCreditosNivelResumen(salida);
        if salida <> 'X' then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S') else Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '');
        end;
        if categoria.Nivel = '1' then idanter[5] := 'CREDITOS FINANCIADOS POR LA ASOCIACI�N';
        if categoria.Nivel = '2' then idanter[5] := 'CREDITOS FINANCIADOS POR LA PROVINCIA';
        if salida <> 'X' then Begin
          list.Linea(0, 0, idanter[5], 1, 'Arial, negrita, 11', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        end else Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, idanter[5], 'Arial, negrita, 10');
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '');
        end;
      end;
      if salida <> 'X' then Begin
        list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
        list.Linea(0, 0, rsql.FieldByName('items').AsString + ' - ' + UpperCase(categoria.DescripLinea), 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
      end else Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, rsql.FieldByName('items').AsString + ' - ' + UpperCase(categoria.DescripLinea), 'Arial, negrita, 10');
      end;
      idanter[1] := rsql.FieldByName('idlinea').AsString;
      idanter[3] := categoria.DescripLinea;
      idanter[4] := categoria.Nivel;
    end;
    if rsql.FieldByName('items').AsString <> idanter[2] then Begin
      // Cr�ditos Vigentes
      datosdb.Filtrar(creditos_cab, 'idcredito = ' + rsql.FieldByName('items').AsString);
      creditos_cab.First; totales[1] := 0; totales[2] := 0;
      while not creditos_cab.Eof do Begin
        if (creditos_cab.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (creditos_cab.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
          estado := '';
          if creditos_cab.FieldByName('refinancia').AsString = 'S' then estado := 'CRE.REF.';
          if creditos_cab.FieldByName('refcuotas').AsString = 'S' then // Si esta con cuotas refinanciadas y tiene saldo lo marcamos
            if setSaldoCuotaRef(creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString) > 0 then estado := 'CUO.REF.';

          if datosdb.Buscar(exptesjudiciales, 'codprest', 'expediente', creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString) then estado := 'GES.JUD.';

          if totales[1] = 0 then Begin
            TotalCreditosLineaResumen(salida);
            idanter[2] := rsql.FieldByName('items').AsString;
          end;

          l := setChequesCredito(creditos_cab.FieldByName('codprest').AsString, creditos_cab.FieldByName('expediente').AsString);
          prestatario.getDatos(creditos_cab.FieldByName('codprest').AsString);

          totales[1] := totales[1] + 1;
          if (creditos_cab.FieldByName('indice').AsFloat = 0) or (creditos_cab.FieldByName('monto_real').AsFloat <> 0) then totales[2] := totales[2] + creditos_cab.FieldByName('monto_real').AsFloat else totales[2] := totales[2] + (creditos_cab.FieldByName('monto').AsFloat * creditos_cab.FieldByName('indice').AsFloat);
        end;
        creditos_cab.Next;
      end;
      datosdb.QuitarFiltro(creditos_cab);

      creditos_cabhist.Open;
      datosdb.Filtrar(creditos_cabhist, 'idcredito = ' + rsql.FieldByName('items').AsString);
      creditos_cabhist.First; totales[3] := 0; totales[4] := 0;
      while not creditos_cabhist.Eof do Begin
        if (creditos_cabhist.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (creditos_cabhist.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
          if (creditos_cabhist.FieldByName('estado').AsString = 'C') then estado := 'CANCELADO';
          if (creditos_cabhist.FieldByName('estado').AsString = 'B') then estado := 'BAJA';
          if totales[1] + totales[3] = 0 then Begin
            TotalCreditosLineaResumen(salida);
            idanter[2] := rsql.FieldByName('items').AsString;
          end;

          prestatario.getDatos(creditos_cabhist.FieldByName('codprest').AsString);

          // revisar
          if datosdb.Buscar(creditos_chequeshist, 'codprest', 'expediente', creditos_cabhist.FieldByName('codprest').AsString, creditos_cabhist.FieldByName('expediente').AsString) then Begin
            Nrocheque := creditos_chequeshist.FieldByName('nrocheque').AsString;
            Codcta    := creditos_chequeshist.FieldByName('codcta').AsString;
          end else Begin
            Nrocheque := ''; Codcta := '';
          end;
          planctas.getDatos(codcta);

          totales[3] := totales[3] + 1;
          if (creditos_cabhist.FieldByName('indice').AsFloat = 0) or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0) then totales[4] := totales[4] + creditos_cabhist.FieldByName('monto_real').AsFloat else totales[4] := totales[4] + (creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat);
        end;
        creditos_cabhist.Next;
      end;
      datosdb.QuitarFiltro(creditos_cabhist);
      datosdb.closeDB(creditos_cabhist);

      TotalCreditosLineaResumen(salida);
    end;

    end;

    rsql.Next;

  end;

  // Creditos Cancelados
  creditos_cabhist.Open;
  datosdb.Filtrar(creditos_cabhist, 'fechacancelacion >= ' + '''' + utiles.sExprFecha(xdfecha) + '''' + ' and fechacancelacion <= ' + '''' + utiles.sExprFecha(xhfecha) + '''' + ' and cancelado = ' + '''' + 'S' + '''');
  creditos_cabhist.First; totales[3] := 0; totales[4] := 0;
  while not creditos_cabhist.Eof do Begin
    totgral[5] := totgral[5] - 1;
    if (creditos_cabhist.FieldByName('indice').AsFloat = 0) or (creditos_cabhist.FieldByName('monto_real').AsFloat <> 0) then totgral[6] := totgral[6] - creditos_cabhist.FieldByName('monto_real').AsFloat else totgral[6] := totgral[6] - (creditos_cabhist.FieldByName('monto').AsFloat * creditos_cabhist.FieldByName('indice').AsFloat);
    creditos_cabhist.Next;
  end;
  datosdb.QuitarFiltro(creditos_cabhist);
  datosdb.closeDB(creditos_cabhist);

  TotalCreditosRubroResumen(salida);
  TotalCreditosNivelResumen(salida);

  if totgral[5] + totgral[6] > 0 then Begin
    if salida <> 'X' then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(60, list.Lineactual, '###############', '---------------', 2, 'Arial, normal, 8');
      list.derecha(95, list.Lineactual, '#######################################', '--------------------------------------', 3, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 11', salida, 'N');
      list.importe(60, list.Lineactual, '#####', totgral[5] + totgral[7], 2, 'Arial, negrita, 11');
      list.importe(95, list.Lineactual, '', totgral[6] + totgral[8], 3, 'Arial, negrita, 11');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
    end else Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL GENERAL:', 'Arial, negrita, 10');
      excel.setReal('b' + l1, 'b' + l1, totgral[5] + totgral[7], 'Arial, negrita, 10');
      excel.setReal('c' + l1, 'c' + l1, totgral[6] + totgral[8], 'Arial, negrita, 10');
    end;
  end;

  rsql.Close; rsql.Free;
  datosdb.closeDB(creditos_chequeshist);

  if salida <> 'X' then list.FinList else excel.Visulizar;
  if salida = 'I' then list.ImprimirVetical;
end;

//------------------------------------------------------------------------------

procedure TTCreditos.InfDetalleCuotasCreditos(xlista: TStringList; xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listado de Cr�ditos por Linea
var
  i: Integer;
  l: Boolean;
Begin
  ol := True;
  desdeFecha := xdfecha;
  ListarResumenDePagos(xlista, xhfecha, True,ir, salida);
  ol := False;
  IniciarArreglos;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Totales Cobrados por Linea - Per�odo: ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
    List.Titulo(1, list.Lineactual, 'Descripci�n de la L�nea', 2, 'Arial, cursiva, 8');
    List.Titulo(50, list.Lineactual, 'Total a Cobrar', 3, 'Arial, cursiva, 8');
    List.Titulo(70, list.Lineactual, 'Total Cobrado', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if salida = 'X' then Begin
    c1 := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Totales Cobrados por Linea - Per�odo: ' + xdfecha + ' - ' + xhfecha, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 35);
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 20);
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 20);
    excel.setString('a' + l1, 'a' + l1, 'Descripci�n de la Linea', 'Arial, negrita, 10');
    excel.setString('b' + l1, 'b' + l1, 'Total a Cobrar', 'Arial, negrita, 10');
    excel.setString('c' + l1, 'c' + l1, 'Total Cobrado', 'Arial, negrita, 10');
  end;

  rsql := categoria.setCategoriasPorLinea;
  rsql.Open;
  totgral[1] := 0; totgral[2] := 0;

  while not rsql.Eof do Begin
    for i := 1 to lcuotas do Begin
     if tcuotas[i, 1] = rsql.FieldByName('items').AsString then Begin
       if rsql.FieldByName('idlinea').AsString <> idanter[1] then Begin
         TotalLineaDetalleCuotas(salida);
         categoria.getDatosLinea(rsql.FieldByName('idlinea').AsString);
         if (salida = 'P') or (salida = 'I') then Begin
           list.Linea(0, 0, categoria.DescripLinea, 1, 'Arial, negrita, 9', salida, 'S');
           list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
         end;
         if salida = 'X' then Begin
           Inc(c1); l1 := Trim(IntToStr(c1));
           excel.setString('a' + l1, 'a' + l1, categoria.DescripLinea, 'Arial, negrita, 10');
         end;
         idanter[1] := rsql.FieldByName('idlinea').AsString;
         idanter[2] := categoria.DescripLinea;
       end;

       if (salida = 'P') or (salida = 'I') then Begin
         list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
         list.Linea(5, list.Lineactual, tcuotas[i, 1] + ' - ' + tcuotas[i, 2], 2, 'Arial, normal, 8', salida, 'N');
         list.importe(60, list.Lineactual, '', StrToFloat(tcuotas[i, 3]), 3, 'Arial, normal, 8');
         list.importe(80, list.Lineactual, '', StrToFloat(tcuotas[i, 4]), 4, 'Arial, normal, 8');
         list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
       end;
       if salida = 'X' then Begin
         Inc(c1); l1 := Trim(IntToStr(c1));
         excel.setString('a' + l1, 'a' + l1, tcuotas[i, 1] + ' - ' + tcuotas[i, 2], 'Arial, normal, 10');
         excel.setReal('b' + l1, 'b' + l1, StrToFloat(tcuotas[i, 3]), 'Arial, normal, 10');
         excel.setReal('c' + l1, 'c' + l1, StrToFloat(tcuotas[i, 4]), 'Arial, normal, 10');
       end;

       totales[1] := totales[1] + StrToFloat(tcuotas[i, 3]);
       totales[2] := totales[2] + StrToFloat(tcuotas[i, 4]);
     end;
    end;

    rsql.Next;
  end;

  TotalLineaDetalleCuotas(salida);

  if totgral[1] + totgral[2] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(81, list.Lineactual, '###########################################################', '--------------------------------------------------------------', 2, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(60, list.Lineactual, '', totgral[1], 2, 'Arial, negrita, 9');
      list.importe(80, list.Lineactual, '', totgral[2], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL GENERAL:', 'Arial, negrita, 10');
      excel.setReal('b' + l1, 'b' + l1, totgral[1], 'Arial, negrita, 10');
      excel.setReal('c' + l1, 'c' + l1, totgral[2], 'Arial, negrita, 10');
    end;
  end;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if salida = 'X' then excel.Visulizar;
end;

procedure TTCreditos.TotalLineaDetalleCuotas(salida: char);
Begin
  if totales[1] + totales[2] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
      list.derecha(81, list.Lineactual, '###########################################################', '--------------------------------------------------------------', 2, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, 'TOTAL ' + idanter[2] + ':', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(60, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 9');
      list.importe(80, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'TOTAL ' + idanter[2] + ':', 'Arial, negrita, 10');
      excel.setReal('b' + l1, 'b' + l1, totales[1], 'Arial, negrita, 10');
      excel.setReal('c' + l1, 'c' + l1, totales[2], 'Arial, negrita, 10');
    end;

    totgral[1] := totgral[1] + totales[1];
    totgral[2] := totgral[2] + totales[2];
    totales[1] := 0; totales[2] := 0;
  end;
end;

procedure TTCreditos.InfMorosidadPorLinea(xdfecha, xhfecha: String; excluirhistorico: Boolean; salida: char);
// Objetivo...: Listado de Morosidad de Cr�ditos por Linea
var
  b1: Boolean;
  i, j: Integer;
  t: TQuery;
  l, l1: TStringList;
Begin
  IniciarArreglos;
  For i := 1 to 10 do totales[i] := 0;
  // Obtener los totales de deudas por Linea
  rsql := credito.setExpedientes;
  t := categoria.setCategorias;
  l := TStringList.Create;
  t.Open; rsql.Open;
  while not t.Eof do Begin
    rsql.First;
    while not rsql.Eof do Begin
      if t.FieldByName('items').AsString = rsql.FieldByName('idcredito').AsString then
        l.Add(rsql.FieldByName('codprest').AsString + rsql.FieldByName('expediente').AsString + rsql.FieldByName('idcredito').AsString);
      rsql.Next;
    end;
    t.Next;
  end;
  t.Close; t.Free;
  rsql.Close; rsql.Free;

  // Recolectamos los totales
  if not excluirhistorico then InfCreditosOtorgadosPorLinea(xdfecha, xhfecha, Nil, 'N', '1') else
    InfCreditosOtorgadosPorLinea(xdfecha, xhfecha, Nil, 'N', '3');
  list.FinList;

  ListCuotasAtrazadas(l, xhfecha, '1', '', '', True, False, 'N');
  list.FinList;

  IniciarArreglos;
  list.Setear(salida); list.altopag := 0; list.m := 0;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Porcentaje de Morosidad por Linea - Lapso: ' + xdfecha + '  -  ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  List.Titulo(1, list.Lineactual, 'Descripci�n de la Linea', 2, 'Arial, cursiva, 8');
  List.Titulo(47, list.Lineactual, 'Cant.', 3, 'Arial, cursiva, 8');
  List.Titulo(54, list.Lineactual, 'Monto Otorgado', 4, 'Arial, cursiva, 8');
  List.Titulo(73, list.Lineactual, 'Cuotas Atrasadas', 5, 'Arial, cursiva, 8');
  List.Titulo(89, list.Lineactual, 'Morosidad', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  rsql := categoria.setCategoriasPorLinea;
  rsql.Open;
  for i := 1 to cantitems do Begin
    totales[i] := 0; totgral[i] := 0;
  end;
  idanter[3] := xhfecha; idanter[1] := '';

  while not rsql.Eof do Begin
    categoria.getDatos(rsql.FieldByName('items').AsString);
    if rsql.FieldByName('idlinea').AsString <> idanter[1] then Begin
      if (Length(Trim(idanter[1])) > 0) then TotalMorosidadRubro(salida);
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, rsql.FieldByName('items').AsString + ' - ' + UpperCase(categoria.DescripLinea), 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      idanter[1] := rsql.FieldByName('idlinea').AsString;
      idanter[3] := categoria.DescripLinea;
    end;
    if rsql.FieldByName('items').AsString <> idanter[2] then Begin
      // Prorrateamos los montos totales
      totales[1] := 0; totales[2] := 0;
      for j := 1 to t1_linea.Count do Begin
        if (rsql.FieldByName('items').AsString = t1_linea.Strings[j-1]) then Begin
          totales[1] := StrToFloat(t2_linea.Strings[j-1]);
          totales[2] := StrToFloat(t3_linea.Strings[j-1]);
          idanter[2] := rsql.FieldByName('items').AsString;
          Break;
        end;
      end;
      TotalMorosidadLinea(rsql.FieldByName('items').AsString, salida);
    end;

    rsql.Next;
  end;

  TotalMorosidadRubro(salida);

  if totgral[5] + totgral[6] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'S');
    list.Linea(0, 0, 'TOTAL GENERAL:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(50, list.Lineactual, '#####', totgral[4], 2, 'Arial, negrita, 9');
    list.importe(65, list.Lineactual, '', totgral[5], 3, 'Arial, negrita, 9');
    list.importe(85, list.Lineactual, '', totgral[6], 4, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', (totgral[6] / totgral[5]) * 100, 5, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '%', 6, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
  end;

  rsql.Close; rsql.Free;

  tfinal.Clear; l.Destroy;
  t1_linea.Clear; t1_linea.Destroy;
  t2_linea.Clear; t2_linea.Destroy;
  t3_linea.Clear; t3_linea.Destroy;

  list.FinList;
end;

procedure TTCreditos.TotalMorosidadLinea(xidanter: String; salida: char);
// Objetivo...: Listar Morosidad Linea
var
  i: Integer;
Begin

  For i := 1 to tfinal.Count do Begin  // Recupera el Monto Adeudado
    if Copy(tfinal.Strings[i-1], 1, 3) = xidanter then Begin
      totales[3] := StrToFloat(Trim(Copy(tfinal.Strings[i-1], 4, 20)));
      Break;
    end;
  end;

  if totales[1] > 0 then Begin
    categoria.getDatos(idanter[2]);
    list.Linea(0, 0, '   ' + categoria.Descrip, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(50, list.Lineactual, '####', totales[1], 2, 'Arial, normal, 8');
    list.importe(65, list.Lineactual, '', totales[2], 3, 'Arial, normal, 8');
    list.importe(85, list.Lineactual, '', totales[3], 4, 'Arial, normal, 8');
    if totales[3] = 0 then list.importe(95, list.Lineactual, '####', 0, 5, 'Arial, normal, 8');
    if totales[3] > totales[2] then list.importe(95, list.Lineactual, '', 100, 5, 'Arial, normal, 8');
    if totales[3] < totales[2] then list.importe(95, list.Lineactual, '', (totales[3] / totales[2]) * 100, 5, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, '%', 6, 'Arial, negrita, 8', salida, 'S');
    totgral[1] := totgral[1] + totales[1];
    totgral[2] := totgral[2] + totales[2];
    totgral[3] := totgral[3] + totales[3];
    totales[1] := 0; totales[2] := 0; totales[3] := 0;
  end;
end;

procedure TTCreditos.TotalMorosidadRubro(salida: char);
// Objetivo...: Listar Morosidad Linea
Begin
  if totgral[1] >= 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'TOTAL ' + idanter[3], 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(50, list.Lineactual, '#####', totgral[1], 2, 'Arial, negrita, 9');
    list.importe(65, list.Lineactual, '', totgral[2], 3, 'Arial, negrita, 9');
    list.importe(85, list.Lineactual, '', totgral[3], 4, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'S');
    totgral[4] := totgral[4] + totgral[1];
    totgral[5] := totgral[5] + totgral[2];
    totgral[6] := totgral[6] + totgral[3];
    totgral[1] := 0; totgral[2] := 0; totgral[3] := 0;
  end;
end;

{ ***************************************************************************** }
procedure TTCreditos.MarcarExpedienteViaJudicial(xcodprest, xexpediente, xfecha, xestudio, xconcepto: String);
// Objetivo...: Expedientes en V�a Judicial
Begin
  if datosdb.Buscar(exptesjudiciales, 'codprest', 'expediente', xcodprest, xexpediente) then exptesjudiciales.Edit else exptesjudiciales.Append;
  exptesjudiciales.FieldByName('codprest').AsString   := xcodprest;
  exptesjudiciales.FieldByName('expediente').AsString := xexpediente;
  exptesjudiciales.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  exptesjudiciales.FieldByName('estudio').AsString    := xestudio;
  exptesjudiciales.FieldByName('concepto').AsString   := xconcepto;
  try
    exptesjudiciales.Post
   except
    exptesjudiciales.Cancel
  end;
  datosdb.refrescar(exptesjudiciales);

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Transfiriendo a Judiciales Expte. ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.RecuperarExpedienteViaJudicial(xcodprest, xexpediente: String);
// Objetivo...: recuperar Expediente en V�a Judicial
Begin
  if datosdb.Buscar(exptesjudiciales, 'codprest', 'expediente', xcodprest, xexpediente) then exptesjudiciales.Delete;
end;

function TTCreditos.setExpedientesViaJudicial: TQuery;
// Objetivo...: Devolver un set con los Expedientes en V�a Judicial
Begin
  Result := datosdb.tranSQL('select exp_judiciales.*, creditos_cab.idcredito, creditos_cab.monto_real from exp_judiciales, creditos_cab ' +
                            'where creditos_cab.codprest = exp_judiciales.codprest and creditos_cab.expediente = exp_judiciales.expediente order by idcredito, codprest, expediente');
end;

function    TTCreditos.BuscarCobro(xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar un cobro
Begin
  if distribucioncobros.IndexFieldNames <> 'sucursal;numero' then distribucioncobros.IndexFieldNames := 'sucursal;numero';
  Result := datosdb.Buscar(distribucioncobros, 'sucursal', 'numero', xsucursal, xnumero);
end;

procedure   TTCreditos.RegistrarCobro(xsucursal, xnumero, xexpediente, xfecha: String; xefectivo, xcheque: Real);
// Objetivo...: Registrar Cobros
Begin
  if BuscarCobro(xsucursal, xnumero) then distribucioncobros.Edit else distribucioncobros.Append;
  distribucioncobros.FieldByName('sucursal').AsString   := xsucursal;
  distribucioncobros.FieldByName('numero').AsString     := xnumero;
  if Length(Trim(xfecha)) = 8       then distribucioncobros.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  distribucioncobros.FieldByName('expediente').AsString := xexpediente;
  distribucioncobros.FieldByName('efectivo').AsFloat    := xefectivo;
  distribucioncobros.FieldByName('cheques').AsFloat     := xcheque;
  try
    distribucioncobros.Post
   except
    distribucioncobros.Cancel
  end;
  datosdb.refrescar(distribucioncobros);

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Distribuci�n Expte. ' + xexpediente);
end;

procedure   TTCreditos.getDatosCobro(xsucursal, xnumero: String);
// Objetivo...: Recuperar los datos de un cobro
Begin
  if BuscarCobro(xsucursal, xnumero) then Begin
    efectivo    := distribucioncobros.FieldByName('efectivo').AsFloat;
    cheques     := distribucioncobros.FieldByName('cheques').AsFloat;
    ccodprest   := Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 5);
    cexpediente := Copy(distribucioncobros.FieldByName('expediente').AsString, 7, 4);
    Fechacobro  := utiles.sFormatoFecha(distribucioncobros.FieldByName('fecha').AsString);
  end else Begin
    ccodprest := ''; cexpediente := ''; fechaCobro := '';
    efectivo := 0; cheques := 0;
  end;
end;

procedure   TTCreditos.BorrarCobro(xsucursal, xnumero: String);
// Objetivo...: Borrar un cobro
Begin
  if BuscarCobro(xsucursal, xnumero) then
    if BuscarReciboCobro(xsucursal, xnumero, '01') then Begin
      distribucioncobros.Delete;
      datosdb.closeDB(distribucioncobros); distribucioncobros.Open;
      // Borramos los registros vinculados
      datosdb.tranSQL('delete from recibos_detalle where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"');
      datosdb.closeDB(recibos_detalle); recibos_detalle.Open;
      datosdb.tranSQL('delete from cheques_mov where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"');
      datosdb.closeDB(cheques_mov); cheques_mov.Open;
      logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Borrando Cobro Cr�dito ' + xsucursal + '-' + xnumero);
    end;
end;

function TTCreditos.BuscarReciboCobro(xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: registrar recibos de pago
Begin
  if recibos_detalle.IndexFieldNames <> 'sucursal;numero;items' then recibos_detalle.IndexFieldNames := 'sucursal;numero;items';
  Result := datosdb.Buscar(recibos_detalle, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems);
end;

procedure TTCreditos.RegistrarRecibo(xsucursal, xnumero, xitems, xconcepto, xidc, xtipo, xsucrec, xnumrec, xfecha, xmodo, xtipomov: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: registrar recibos de pago
Begin
  if BuscarReciboCobro(xsucursal, xnumero, xitems) then recibos_detalle.Edit else recibos_detalle.Append;
  recibos_detalle.FieldByName('sucursal').AsString := xsucursal;
  recibos_detalle.FieldByName('numero').AsString   := xnumero;
  recibos_detalle.FieldByName('items').AsString    := xitems;
  recibos_detalle.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  recibos_detalle.FieldByName('concepto').AsString := xconcepto;
  recibos_detalle.FieldByName('idc').AsString      := xidc;
  recibos_detalle.FieldByName('tipo').AsString     := xtipo;
  recibos_detalle.FieldByName('sucrec').AsString   := xsucrec;
  recibos_detalle.FieldByName('numrec').AsString   := xnumrec;
  recibos_detalle.FieldByName('modo').AsString     := xmodo;
  recibos_detalle.FieldByName('tipomov').AsString  := xtipomov;
  recibos_detalle.FieldByName('monto').AsFloat     := xmonto;
  try
    recibos_detalle.Post
   except
    recibos_detalle.Cancel
  end;
  if utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') = xitems then datosdb.tranSQL('delete from recibos_detalle where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') + '"');

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Recibo ' + xtipo + '  ' + xsucrec + '-' + xnumrec);
end;

function  TTCreditos.setRecibosPago(xsucursal, xnumero: String): TQuery;
// Objetivo...: Recuperar recibos de pago
Begin
  Result := datosdb.tranSQL('select * from recibos_detalle where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' order by items');
end;

function  TTCreditos.setRecibosManualesExpediente(xcodprest, xexpediente: String): TQuery;
// Objetivo...: Recuperar recibos de un expediente
Begin
  Result := datosdb.tranSQL('select * from distribucioncobros where expediente = ' + '"' + xcodprest + '-' + xexpediente + '"' + ' order by fecha');
end;

function  TTCreditos.BuscarReciboPorNumeroImpresion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar Recibo de Pago
Begin
  Anulado := '';
  recibos_detalle.IndexFieldNames := 'Idc;tipo;sucrec;numrec';
  if datosdb.Buscar(recibos_detalle, 'Idc' , 'Tipo', 'Sucrec', 'Numrec', xidc, xtipo, xsucursal, xnumero) then Begin
    Anulado := recibos_detalle.FieldByName('anulado').AsString;
    Result  := True;
  end else Result := False;
  recibos_detalle.IndexFieldNames := 'Sucursal;Numero;Items';
end;

procedure TTCreditos.AnularReciboPago(xidc, xtipo, xsucursal, xnumero, xanular: String);
// Objetivo...: Anular/Activar Recibo
Begin
  datosdb.tranSQL('update recibos_detalle set anulado = ' + '"' + xanular + '"' + ' where idc = ' + '"' + xidc + '"' + ' and tipo = ' + '"' + xtipo + '"' + ' and sucrec = ' + '"' + xsucursal + '"' + ' and numrec = ' + '"' + xnumero + '"');
end;

function TTCreditos.setRecibosFechas(xdesde, xhasta: String): TQuery;
// Objetivo...: devolver recibos fecha
Begin
  Result := datosdb.tranSQL('select recibos_detalle.sucursal, recibos_detalle.numero, recibos_detalle.items, recibos_detalle.idc, recibos_detalle.tipo, recibos_detalle.sucrec, recibos_detalle.numrec, recibos_detalle.fecha, ' +
                            'distribucioncobros.* from recibos_detalle, distribucioncobros where recibos_detalle.sucursal = distribucioncobros.sucursal and recibos_detalle.numero = distribucioncobros.numero and recibos_detalle.items = ' +
                            '''' + '01' + '''' + ' and recibos_detalle.fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and recibos_detalle.fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' +
                            ' order by numrec');
end;

procedure TTCreditos.AjustarNumeroRecibo(xsucursalrecibo, xnumerorecibo, xnumerocorrelativo: String);
// Objetivo...: Ajustar N�mero de Recibo
Begin
  datosdb.tranSQL('update recibos_detalle set numrec = ' + '''' + xnumerocorrelativo + '''' + ' where sucursal = ' + '''' + xsucursalrecibo + '''' + ' and numero = ' + '''' + xnumerorecibo + '''');
  datosdb.closeDB(recibos_detalle); recibos_detalle.Open;
end;

procedure TTCreditos.RegistrarFormatoImpresion(xlineassep, xlineasdet, xlineaDiv, xmargenSup, xmargenIzq, xmodelo: String);
// Objetivo...: Registrar Modelo de Impresi�n
Begin
  if formato_impresion.FindKey(['REC001']) then formato_impresion.Edit else formato_impresion.Append;
  formato_impresion.FieldByName('id').AsString         := 'REC001';
  formato_impresion.FieldByName('formato').AsString    := xmodelo;
  formato_impresion.FieldByName('lineassep').AsInteger := StrToInt(Trim(xlineassep));
  formato_impresion.FieldByName('lineasdet').AsInteger := StrToInt(Trim(xlineasdet));
  formato_impresion.FieldByName('lineadiv').AsInteger  := StrToInt(Trim(xlineadiv));
  formato_impresion.FieldByName('margenIzq').AsInteger := StrToInt(Trim(xmargenIzq));
  formato_impresion.FieldByName('margensup').AsInteger := StrToInt(Trim(xmargensup));
  try
    formato_impresion.Post
   except
    formato_impresion.Cancel
  end;
end;

procedure TTCreditos.getFormatoImpresion;
// Objetivo...: Recuperar Modelo de Impresi�n
Begin
  if formato_impresion.FindKey(['REC001']) then Begin
    lineassep := formato_impresion.FieldByName('lineassep').AsString;
    lineasdet := formato_impresion.FieldByName('lineasdet').AsString;
    lineadiv  := formato_impresion.FieldByName('lineadiv').AsString;
    modelo    := formato_impresion.FieldByName('formato').AsString;
    margenSup := formato_impresion.FieldByName('margensup').AsString;
    margenIzq := formato_impresion.FieldByName('margenizq').AsString;
  end else Begin
    lineassep := '0'; lineasdet := '0'; modelo := ''; lineadiv := '95'; margensup := '8'; margenizq := '0';
  end;
  if lineadiv  = '' then lineadiv  := '95';
  if lineassep = '' then lineassep := '20';
end;

procedure TTCreditos.RegistrarFormatoImpresionBoletas(xlineassep, xlineasdet, xlineaDiv, xmargenSup, xmargenIzq, xmodelo, xfuentecb: String);
// Objetivo...: Registrar Modelo de Impresi�n Boletas Bancarias
Begin
  if formato_impresion.FindKey(['REC002']) then formato_impresion.Edit else formato_impresion.Append;
  formato_impresion.FieldByName('id').AsString         := 'REC002';
  formato_impresion.FieldByName('formato').AsString    := xmodelo;
  formato_impresion.FieldByName('lineassep').AsInteger := StrToInt(Trim(xlineassep));
  formato_impresion.FieldByName('lineasdet').AsInteger := StrToInt(Trim(xlineasdet));
  formato_impresion.FieldByName('lineadiv').AsInteger  := StrToInt(Trim(xlineadiv));
  formato_impresion.FieldByName('margenIzq').AsInteger := StrToInt(Trim(xmargenIzq));
  formato_impresion.FieldByName('margensup').AsInteger := StrToInt(Trim(xmargensup));
  formato_impresion.FieldByName('fuentecb').AsInteger  := StrToInt(Trim(xfuentecb));
  try
    formato_impresion.Post
   except
    formato_impresion.Cancel
  end;
end;

procedure TTCreditos.getFormatoImpresionBoletas;
// Objetivo...: Recuperar Modelo de Impresi�n
Begin
  if formato_impresion.FindKey(['REC002']) then Begin
    lineassep := formato_impresion.FieldByName('lineassep').AsString;
    lineasdet := formato_impresion.FieldByName('lineasdet').AsString;
    lineadiv  := formato_impresion.FieldByName('lineadiv').AsString;
    modelo    := formato_impresion.FieldByName('formato').AsString;
    margenSup := formato_impresion.FieldByName('margensup').AsString;
    margenIzq := formato_impresion.FieldByName('margenizq').AsString;
    fuentecb  := formato_impresion.FieldByName('fuentecb').AsString;
  end else Begin
    lineassep := '0'; lineasdet := '0'; modelo := ''; lineadiv := '95'; margensup := '8'; margenizq := '0'; fuentecb := '14';
  end;
  if lineadiv  = '' then lineadiv  := '95';
  if lineassep = '' then lineassep := '20';
end;

procedure TTCreditos.ImprimirRecibo(xsucursal, xnumero, xcodprest, xexpediente: String; salida: char);
// Objetivo...: Imprimir Recibo de Pago
const
  espacios = 34;
var
  i, j, k, l, esp: Integer;
  hc: Boolean;
Begin
  getFormatoImpresion;
  if salida = 'I' then list.ImprimirHorizontal;
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  getDatosCobro(xsucursal, xnumero);
  prestatario.getDatos(xcodprest);
  totales[1] := Efectivo + Cheques;
  if Length(Trim(margenIzq)) = 0 then margenIzq := '0';
  esp := espacios + StrToInt(margenIzq);

  for i := 1 to strtoint(margensup) do list.Linea(0, 0, '     ', 1, 'Arial, normal, 8', salida, 'S');

  if credito_historico then categoria.getDatos(Idcredito);
  getDatos(xcodprest, xexpediente);
  if not credito_historico then categoria.getDatos(Idcredito);
  if Length(Trim(idcredito)) = 0 then Begin
    verificarSiExisteExpedienteHistorico(xcodprest, xexpediente);
    categoria.getDatos(Idcredito);
  end;

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(63, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + Fechacobro, 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 60, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + Fechacobro, 3, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '        ' + utiles.espacios(StrToInt(margenIzq)) + categoria.DescripLinea + ' - ' + categoria.Descrip, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, '        ' + utiles.espacios(StrToInt(margenIzq)) + categoria.DescripLinea + ' - ' + categoria.Descrip, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '     ', 1, 'Arial, normal, 20', salida, 'S');
  list.Linea(0, 0, '     ', 1, 'Arial, normal, 18', salida, 'S');

  list.Linea(0, 0, utiles.espacios(esp + 5) + prestatario.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + prestatario.nombre, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp + 5) + prestatario.domicilio, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + prestatario.domicilio, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp + 5) + prestatario.localidad, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(60, list.lineactual, utiles.espacios(StrToInt(margenIzq)) + prestatario.codpost, 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + prestatario.localidad, 3, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 60, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + prestatario.codpost, 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  if Length(Trim(prestatario.Cuit)) = 13 then list.Linea(0, 0, utiles.espacios(esp + 5) + prestatario.cuit, 1, 'Arial, normal, 9', salida, 'N') else list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(45, list.lineactual, prestatario.Codpfis, 2, 'Arial, normal, 9', salida, 'N');
  if Length(Trim(prestatario.Cuit)) = 13 then list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + prestatario.cuit, 3, 'Arial, normal, 9', salida, 'N') else list.Linea(StrToInt(lineadiv), list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 45, list.Lineactual, prestatario.codpfis, 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');


  list.Linea(0, 0, utiles.espacios(esp - 18) + 'Recib�(mos) la suma de Pesos:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 18) + 'Recib�(mos) la suma de Pesos:', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp - 17) + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[1])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[1])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 1, 2) + ' ctvos.', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 17) + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[1])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[1])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 1, 2) + ' ctvos.', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp - 18) + 'En Concepto de:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 18) + 'En Concepto de:', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  //BuscarReciboCobro(xsucursal, xnumero, '01');

  datosdb.Filtrar(recibos_detalle, 'sucursal = ' + '''' + xsucursal + '''' + ' and numero = ' + '''' + xnumero + '''');
  recibos_detalle.First;

  idanter[1] := recibos_detalle.FieldByName('sucursal').AsString;
  idanter[2] := recibos_detalle.FieldByName('numero').AsString;
  l := 0; totales[1] := 0;
  while not recibos_detalle.Eof do Begin  // Detalle de Cobros
    if (recibos_detalle.FieldByName('sucursal').AsString <> idanter[1]) or (recibos_detalle.FieldByName('numero').AsString <> idanter[2]) then Break;
    list.Linea(0, 0, utiles.espacios(esp - 17) + recibos_detalle.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
    if recibos_detalle.FieldByName('monto').AsFloat <> 0 then list.importe({65}67 + ((esp - 7) div 3), list.Lineactual, masc, recibos_detalle.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8') else
      list.importe({65}67 + ((esp - 7) div 3), list.Lineactual, masc, 0, 2, 'Arial, normal, 8');
    list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 17) + recibos_detalle.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
    if recibos_detalle.FieldByName('monto').AsFloat <> 0 then list.importe({StrToInt(lineadiv) + 65}StrToInt(lineadiv) + 67 + ((esp - 7) div 3), list.Lineactual, masc, recibos_detalle.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8') else
      list.importe(StrToInt(lineadiv) + 67 + ((esp - 7) div 3), list.Lineactual, masc, 0, 4, 'Arial, normal, 8');
    list.Linea(StrToInt(lineadiv) + 68 + ((esp - 7) div 3), list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
    Inc(l);
    idanter[1] := recibos_detalle.FieldByName('sucursal').AsString;
    idanter[2] := recibos_detalle.FieldByName('numero').AsString;
    totales[1] := totales[1] + recibos_detalle.FieldByName('monto').AsFloat;
    recibos_detalle.Next;
  end;

  datosdb.QuitarFiltro(recibos_detalle);

  getDatosCobro(xsucursal, xnumero);      // Efectivo
  tcuotas[1, 1] := utiles.espacios(esp - 7) + 'En Efectivo';
  tcuotas[1, 3] := utiles.FormatearNumero(FloatToStr(efectivo));

   hc := False;
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, '01') then Begin
    idanter[1] := cheques_mov.FieldByName('sucursal').AsString;
    idanter[2] := cheques_mov.FieldByName('numero').AsString;
    i := 1;
    while not cheques_mov.Eof do Begin  // Detalle de Cheques
      if (cheques_mov.FieldByName('sucursal').AsString <> idanter[1]) or (cheques_mov.FieldByName('numero').AsString <> idanter[2]) then Break;
      entbcos.getDatos(cheques_mov.FieldByName('codbanco').AsString);
      Inc(i);
      tcuotas[i, 1] := cheques_mov.FieldByName('nrocheque').AsString;
      tcuotas[i, 2] := Copy(entbcos.descrip, 1, 20) + ' - ' + copy(cheques_mov.FieldByName('filial').AsString, 1, 15) + ' - ' + utiles.sFormatoFecha(cheques_mov.FieldByName('fecha').AsString);
      tcuotas[i, 3] := cheques_mov.FieldByName('monto').AsString;

      idanter[1] := cheques_mov.FieldByName('sucursal').AsString;
      idanter[2] := cheques_mov.FieldByName('numero').AsString;
      cheques_mov.Next;
    end;
    hc := True;
  end;

  k := StrToInt(lineasdet) - l;
  for j := 1 to k - (i+1) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');  // Lineas entre comprobantes y Efectivo

  for j := 1 to i do Begin
    if j = 1 then Begin
      list.Linea(0, 0, utiles.espacios(esp - 7) + 'En Efectivo:', 1, 'Arial, normal, 8', salida, 'N');
      list.importe(25 + ((esp - 7) div 2), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 2, 'Arial, normal, 8');
      list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 7) + 'En Efectivo:', 3, 'Arial, normal, 8', salida, 'N');
      list.importe(StrToInt(lineadiv) + 25 + ((esp - 7) div 2), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 4, 'Arial, normal, 8');
      list.Linea(StrToInt(lineadiv) + 50 + ((esp - 7) div 2), list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '  ', 1, 'Arial, normal, 8', salida, 'S');
    end else Begin
      if hc then Begin
        if j = 2 then list.Linea(0, 0, utiles.espacios(esp - 7) + 'En Cheques:', 1, 'Arial, normal, 8', salida, 'N') else list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(15 + ((esp - 7) div 3), list.Lineactual,tcuotas[j, 1], 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(24 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 2], 3, 'Arial, normal, 8', salida, 'N');
        list.importe(67 + ((esp - 7) div 3), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 4, 'Arial, normal, 8');

        if j = 2 then list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 7) + 'En Cheques:', 5, 'Arial, normal, 8', salida, 'N') else list.Linea(StrToInt(lineadiv), list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
        list.Linea(StrToInt(lineadiv) + 15 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 1], 6, 'Arial, normal, 8', salida, 'N');
        list.Linea(StrToInt(lineadiv) + 24 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 2], 7, 'Arial, normal, 8', salida, 'N');
        list.importe(StrToInt(lineadiv) + 67 + ((esp - 7) div 3), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 8, 'Arial, normal, 8');
        list.Linea(StrToInt(lineadiv) + 67 + ((esp - 7) div 3), list.Lineactual, '', 9, 'Arial, normal, 8', salida, 'S');
      end else Begin
        list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      end;
    end;
  end;

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 20', salida, 'S');
  list.Linea(0, 0, '  ', 1, 'Arial, normal, 20', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(34, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 11');
  list.Linea(StrToInt(lineadiv), list.Lineactual, '  ', 3, 'Arial, negrita, 11', salida, 'N');
  list.importe(StrToInt(lineadiv) + 34, list.Lineactual, '', totales[1], 5, 'Arial, negrita, 11');

  credito_historico := False;
  list.FinList;
  if salida = 'I' then list.ImprimirVetical;
end;

procedure TTCreditos.IniciarInforme(salida: char);
// Objetivo...: Iniciar Informe
Begin
  if not infIniciado then Begin
    if salida <> 'T' then list.Setear(salida);
    infIniciado := True;
  end else Begin
    if salida <> 'T' then Begin
      list.CompletarPaginaConNumeracion;
      list.pagina := 0; list.m := 0;
      list.IniciarNuevaPagina;
    end;
  end;
  tipoList := salida;
end;

procedure TTCreditos.RegistrarCheque(xsucursal, xnumero, xitems, xnrocheque, xfecha, xcodbanco, xfilial, xpropio: String; xmonto: real; xcantitems: Integer; xcodprest: string);
// Objetivo...: registrar cheques
Begin
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems) then cheques_mov.Edit else cheques_mov.Append;
  cheques_mov.FieldByName('sucursal').AsString  := xsucursal;
  cheques_mov.FieldByName('numero').AsString    := xnumero;
  cheques_mov.FieldByName('items').AsString     := xitems;
  cheques_mov.FieldByName('nrocheque').AsString := xnrocheque;
  cheques_mov.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  cheques_mov.FieldByName('codbanco').AsString  := xcodbanco;
  cheques_mov.FieldByName('filial').AsString    := xfilial;
  cheques_mov.FieldByName('propio').AsString    := xpropio;
  cheques_mov.FieldByName('monto').AsFloat      := xmonto;
  cheques_mov.FieldByName('codprest').AsString  := xcodprest;
  try
    cheques_mov.Post
   except
    cheques_mov.Cancel
  end;
  if utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') = xitems then datosdb.tranSQL('delete from cheques_mov where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') + '"');

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Cheque Expte. ' + xnrocheque + ' ' + xcodbanco);
end;

function  TTCreditos.setCheques(xsucursal, xnumero: String): TQuery;
// Objetivo...: Devolver set de cheques
Begin
  Result := datosdb.tranSQL('select * from cheques_mov where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' order by items');
end;

function  TTCreditos.setCheques(xcodbco: String): TQuery;
// Objetivo...: Devolver set de cheques
Begin
  Result := datosdb.tranSQL('select * from cheques_mov where codbanco = ' + '"' + xcodbco + '"' + ' order by fecha');
end;

function  TTCreditos.setChequesDevueltos(xcodbco: String): TQuery;
// Objetivo...: Devolver set de cheques
Begin
  Result := datosdb.tranSQL('select * from cheques_mov where codbanco = ' + '"' + xcodbco + '"' + ' and devuelto = ' + '"' + 'S' + '"' + ' order by fecha');
end;

function TTCreditos.setChequesDevueltosPrestatarios(xcodprest, xexpediente: String): TQuery;
// Objetivo...: Devolver set de cheques
Begin
  //Result := datosdb.tranSQL('select * from cheques_mov where codprest = ' + '"' + xcodprest + '"' + ' and devuelto = ' + '"' + 'S' + '"' + ' order by fecha');
end;

function  TTCreditos.setChequesDevueltos(xdfecha, xhfecha: String): TQuery;
// Objetivo...: Devolver set de cheques
Begin
  Result := datosdb.tranSQL('select * from cheques_mov where fechadev >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fechadev <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha');
end;

procedure TTCreditos.RechazarCheque(xsucursal, xnumero, xitems, xnrorecibo, xfecha: String; xcomision: Real);
// Objetivo...: Marcar Cheques Rechazados por el Banco
Begin
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems) then Begin
    cheques_mov.Edit;
    cheques_mov.FieldByName('devuelto').AsString  := 'S';
    cheques_mov.FieldByName('nrorecibo').AsString := xnrorecibo;
    cheques_mov.FieldByName('fechadev').AsString  := utiles.sExprFecha2000(xfecha);
    cheques_mov.FieldByName('comision').AsFloat   := xcomision;
    try
      cheques_mov.Post
     except
      cheques_mov.Cancel
    end;

    logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Cheque Rechazado ' + xnumero + ' ' + xsucursal);
  end;
end;

procedure TTCreditos.RechazarChequeManual(xsucursal, xnumero, xitems, xnrorecibo, xfecha: String; xcomision: Real);
// Objetivo...: Marcar Cheques Rechazados por el Banco
var
  monto: Real;
  ncheq: String;
Begin
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems) then Begin
    monto := cheques_mov.FieldByName('monto').AsFloat;
    ncheq := cheques_mov.FieldByName('nrocheque').AsString;
    cheques_mov.Edit;
    cheques_mov.FieldByName('devuelto').AsString  := 'S';
    cheques_mov.FieldByName('nrorecibo').AsString := xnrorecibo;
    cheques_mov.FieldByName('fechadev').AsString  := utiles.sExprFecha2000(xfecha);
    cheques_mov.FieldByName('comision').AsFloat   := xcomision;
    try
      cheques_mov.Post
     except
      cheques_mov.Cancel
    end;

    logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Cheque Rechazado Manual ' + xnumero + ' ' + xsucursal);
  end;
end;

procedure TTCreditos.AnularRechazoCheque(xsucursal, xnumero, xitems: String);
// Objetivo...: Marcar Cheques Rechazados por el Banco
Begin
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems) then Begin
    cheques_mov.Edit;
    cheques_mov.FieldByName('devuelto').AsString  := '';
    cheques_mov.FieldByName('nrorecibo').AsString := '';
    cheques_mov.FieldByName('fechadev').AsString  := '';
    cheques_mov.FieldByName('comision').AsFloat   := 0;
    try
      cheques_mov.Post
     except
      cheques_mov.Cancel
    end;
  end;
end;

procedure TTCreditos.getDatosCheque(xsucursal, xnumero, xitems: String);
// Objetivo...: Recuperar los datos de los cheques
Begin
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems) then Begin
    FechaCheque := utiles.sFormatoFecha(cheques_mov.FieldByName('fecha').AsString);
  end else Begin
    FechaCheque := '';
  end;
end;

procedure TTCreditos.ListarControlRecibos(xdfecha, xhfecha, xlistar: String; salida: char; xincluir_detalle: Boolean);
// Objetivo...: Listar Control de Recibos
var
  r: TQuery;
  f: Byte;
  cant: Integer;
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Control de Ingresos por Cobro de Recibos - Per�odo: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
    List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
    List.Titulo(1, list.Lineactual, 'N� de Recibo', 2, 'Arial, cursiva, 8');
    List.Titulo(20, list.Lineactual, 'Expediente      Prestatario', 3, 'Arial, cursiva, 8');
    List.Titulo(74, list.Lineactual, 'Efectivo', 4, 'Arial, cursiva, 8');
    List.Titulo(88, list.Lineactual, 'Cheques', 5, 'Arial, cursiva, 8');
    List.Titulo(96, list.Lineactual, 'An.', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if salida = 'X' then Begin
    c1 := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 13);
    excel.setString('a' + l1, 'a' + l1, 'Control de Ingresos por Cobro de Recibos - Per�odo: ' + xdfecha + '-' + xhfecha, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'N� de Recibo', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 37);
    excel.setString('b' + l1, 'b' + l1, 'Expediente / Prestatario', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 25);
    excel.setString('d' + l1, 'd' + l1, 'Efectivo', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('d' + l1, 'd' + l1, 10);
    excel.FijarAnchoColumna('e' + l1, 'e' + l1, 14);
    excel.setString('e' + l1, 'e' + l1, 'Cheques', 'Arial, negrita, 10');
    excel.setString('f' + l1, 'f' + l1, 'An.', 'Arial, negrita, 10');
    Inc(c1);
  end;

  IniciarArreglos;
  cant := 0;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'Control Recibos de Pagos de Cr�ditos', 1, 'Arial, normal, 14', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
  if salida = 'X' then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Control de Recibos de Pagos de Cr�ditos', 'Arial, negrita, 14');
  end;

  rsql := datosdb.tranSQL('select distinct * from recibos_detalle where fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha, idc, tipo, sucrec, numrec');
  rsql.Open; idanter[1] := 'N'; totgral[1] := 0; totgral[2] := 0;
  idanter[3] := rsql.FieldByName('fecha').AsString;
  while not rsql.Eof do Begin
    if rsql.FieldByName('fecha').AsString <> idanter[3] then TotalPorDia(salida);
    if rsql.FieldByName('idc').AsString + rsql.FieldByName('tipo').AsString + rsql.FieldByName('sucrec').AsString + rsql.FieldByName('numrec').AsString <> idanter[2] then Begin
      BuscarCobro(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString);
      prestatario.getDatos(Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 5));
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, rsql.FieldByName('idc').AsString + '  ' + rsql.FieldByName('tipo').AsString + '  ' + rsql.FieldByName('sucrec').AsString + '  ' + rsql.FieldByName('numrec').AsString, 1, 'Arial, normal, 9', salida, 'N');
        list.Linea(20, list.Lineactual, distribucioncobros.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 30), 2, 'Arial, normal, 9', salida, 'N');
        list.importe(80, list.Lineactual, '', distribucioncobros.FieldByname('efectivo').AsFloat, 3, 'Arial, normal, 9');
        list.importe(95, list.Lineactual, '', distribucioncobros.FieldByname('cheques').AsFloat, 4, 'Arial, normal, 9');
        list.Linea(96, list.Lineactual, rsql.FieldByName('anulado').AsString, 5, 'Arial, normal, 9', salida, 'S');
      end;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, rsql.FieldByName('idc').AsString + '  ' + rsql.FieldByName('tipo').AsString + '  ' + rsql.FieldByName('sucrec').AsString + '  ' + rsql.FieldByName('numrec').AsString, 'Arial, normal, 9');
        excel.setString('b' + l1, 'b' + l1, distribucioncobros.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 30), 'Arial, nornal, 9');
        excel.setReal('d' + l1, 'd' + l1, distribucioncobros.FieldByname('efectivo').AsFloat, 'Arial, normal, 9');
        excel.setReal('e' + l1, 'e' + l1, distribucioncobros.FieldByname('cheques').AsFloat, 'Arial, normal, 9');
        excel.setString('f' + l1, 'f' + l1, rsql.FieldByName('anulado').AsString, 'Arial, nornal, 9');
      end;
      Inc(cant);
      r := datosdb.tranSQL('select * from cheques_mov where sucursal = ' + '"' + rsql.FieldByName('sucursal').AsString + '"' + ' and numero = ' + '"' + rsql.FieldByName('numero').AsString + '"');
      r.Open; f := 0;
      while not r.Eof do Begin
        f := 1;
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '     ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(12, list.Lineactual, r.FieldByName('nrocheque').AsString, 2, 'Arial, normal, 8', salida, 'N');
          entbcos.getDatos(r.FieldByName('codbanco').AsString);
          list.Linea(22, list.Lineactual, entbcos.descrip, 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(55, list.Lineactual, r.FieldByName('filial').AsString, 4, 'Arial, normal, 8', salida, 'N');
          list.importe(95, list.Lineactual, '', r.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
          if r.FieldByName('devuelto').AsString <> 'S' then list.Linea(96, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S') else Begin
            list.Linea(96, list.Lineactual, 'Devuelto', 6, 'Arial, normal, 8', salida, 'S');
            totales[5] := totales[5] + r.FieldByName('monto').AsFloat;
          end;
        end;
        if (salida = 'X') then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('a' + l1, 'a' + l1, '''' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 'Arial, normal, 8');
          excel.setString('b' + l1, 'b' + l1, r.FieldByName('nrocheque').AsString, 'Arial, normal, 8');
          entbcos.getDatos(r.FieldByName('codbanco').AsString);
          excel.setString('c' + l1, 'c' + l1, entbcos.descrip, 'Arial, normal, 8');
          excel.setString('d' + l1, 'd' + l1, r.FieldByName('filial').AsString, 'Arial, normal, 8');
          excel.setReal('e' + l1, 'e' + l1, r.FieldByName('monto').AsFloat, 'Arial, normal, 8');
          if r.FieldByName('devuelto').AsString <> 'S' then excel.setString('f' + l1, 'f' + l1, '', 'Arial, normal, 8') else Begin
            excel.setString('f' + l1, 'f' + l1, 'Devuelto', 'Arial, normal, 8');
            totales[5] := totales[5] + r.FieldByName('monto').AsFloat;
          end;
        end;
        r.Next;
      end;
      r.Close; r.Free;

      // Detalle
      if xincluir_detalle then Begin
        datosdb.Filtrar(recibos_detalle, 'sucursal = ' + '''' + rsql.FieldByName('sucursal').AsString + '''' + ' and numero = ' + '''' + rsql.FieldByName('numero').AsString + '''');
        recibos_detalle.First;
        while not recibos_detalle.Eof do Begin
          list.Linea(0, 0, '                    ' + recibos_detalle.FieldByName('concepto').AsString, 1, 'Arial, normal, 7', salida, 'S');
          list.importe(85, list.Lineactual, '', recibos_detalle.FieldByName('monto').AsFloat, 2, 'Arial, normal, 7');
          list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 7', salida, 'S');
          recibos_detalle.Next;
        end;
        list.Linea(0, 0, ' ', 1, 'Arial, normal, 7', salida, 'S');
        datosdb.QuitarFiltro(recibos_detalle);
      end;

      if Length(Trim(rsql.FieldByName('anulado').AsString)) = 0 then Begin
        totales[1] := totales[1] + distribucioncobros.FieldByname('efectivo').AsFloat;
        totales[2] := totales[2] + distribucioncobros.FieldByname('cheques').AsFloat;
        totales[3] := totales[3] + distribucioncobros.FieldByname('efectivo').AsFloat;
        totales[4] := totales[4] + distribucioncobros.FieldByname('cheques').AsFloat;
      end;

      if f = 1 then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      idanter[2] := rsql.FieldByName('idc').AsString + rsql.FieldByName('tipo').AsString + rsql.FieldByName('sucrec').AsString + rsql.FieldByName('numrec').AsString;
      idanter[1] := 'S';
    end;
    idanter[3] := rsql.FieldByName('fecha').AsString;

    rsql.Next;
  end;
  rsql.Close; rsql := Nil;
  TotalPorDia(salida);

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, 'Cantidad de Operaciones Cr�ditos:      ' + IntToStr(cant), 1, 'Arial, negrita, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 10', salida, 'S');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Cantidad de Operaciones Cr�ditos:', 'Arial, negrita, 9');
    excel.setInteger('e' + l1, 'e' + l1, cant, 'Arial, normal, 9');
  end;

  // Cancelaciones anticipadas
  rsql := datosdb.tranSQL('select * from recibos_detalle where fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and monto < 0 ' + ' order by fecha, idc, tipo, sucrec, numrec');
  rsql.Open; totales[7] := 0;
  if rsql.RecordCount > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, 'Descuentos por Cancelaciones Anticipadas', 1, 'Arial, normal, 14', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Descuentos por Cancelaciones Anticipadas', 'Arial, negrita, 11');
    end;
    while not rsql.Eof do Begin
      BuscarCobro(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString);
      prestatario.getDatos(Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 5));
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, rsql.FieldByName('idc').AsString + '  ' + rsql.FieldByName('tipo').AsString + '  ' + rsql.FieldByName('sucrec').AsString + '  ' + rsql.FieldByName('numrec').AsString, 1, 'Arial, normal, 9', salida, 'N');
        list.Linea(20, list.Lineactual, distribucioncobros.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 30), 2, 'Arial, normal, 9', salida, 'N');
        list.importe(95, list.Lineactual, '', rsql.FieldByname('monto').AsFloat, 3, 'Arial, normal, 9');
        list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 9', salida, 'S');
      end;
      if salida = 'X' then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, rsql.FieldByName('idc').AsString + '  ' + rsql.FieldByName('tipo').AsString + '  ' + rsql.FieldByName('sucrec').AsString + '  ' + rsql.FieldByName('numrec').AsString, 'Arial, normal, 9');
        excel.setString('b' + l1, 'b' + l1, distribucioncobros.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 30), 'Arial, normal, 9');
        excel.setReal('e' + l1, 'e' + l1, rsql.FieldByname('monto').AsFloat, 'Arial, normal, 9');
      end;
      totales[7] := totales[7] + rsql.FieldByName('monto').AsFloat;
      rsql.Next;
    end;
  end;
  rsql.Close; rsql := Nil;

  if totales[7] <> 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Subtotal Descuentos:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(95, list.Lineactual, '', totales[7], 2, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Subtotal Descuentos:', 'Arial, negrita, 9');
      excel.setReal('e' + l1, 'e' + l1, totales[7], 'Arial, normal, 9');
    end;
  end;

  ListarChequesDevueltos(xdfecha, xhfecha, salida);

  if totales[1] + totales[2] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totales[2] - totales[6], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, 'Descuentos Cancelaciones Anticipadas / Total Final:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(80, list.Lineactual, '', totales[7], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', (totales[1] + totales[2] - totales[6]) + totales[7], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Total:', 'Arial, negrita, 10');
      excel.setReal('d' + l1, 'd' + l1, totales[1], 'Arial, negrita, 10');
      excel.setReal('e' + l1, 'e' + l1, totales[2] - totales[6], 'Arial, negrita, 10');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Descuentos Cancelaciones Anticipadas / Total Final:', 'Arial, negrita, 10');
      excel.setReal('d' + l1, 'd' + l1, totales[7], 'Arial, negrita, 10');
      excel.setReal('d' + l1, 'd' + l1, (totales[1] + totales[2] - totales[6]) + totales[7], 'Arial, negrita, 10');
    end;
  end;

  if idanter[1] = 'N' then Begin
    if (salida = 'P') or (salida = 'I') then list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 10', salida, 'S');
    if (salida = 'X') then excel.setString('a' + l1, 'a' + l1, 'No se Registraron Operaciones', 'Arial, negrita, 12');
  end;
  idanter[2] := '';

  if salida = 'X' then excel.setString('a2', 'a2', '');

  if xlistar <> 'N' then Begin
    if (salida = 'P') or (salida = 'I') then list.FinList;
  end;
  if salida = 'X' then excel.Visulizar;
end;

procedure TTCreditos.TotalPorDia(salida: char);
// Objetivo...: Ruptura por Fecha
Begin
  if totales[3] + totales[4] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Subtotal Fecha ' + utiles.sFormatoFecha(idanter[3]) + ':', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(80, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 9');
      list.importe(95, list.Lineactual, '', totales[4] - totales[5], 3, 'Arial, negrita, 9');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Subtotal Fecha ' + utiles.sFormatoFecha(idanter[3]) + ':', 'Arial, negrita, 9');
      excel.setReal('d' + l1, 'd' + l1, totales[3], 'Arial, negrita, 9');
      excel.setReal('e' + l1, 'e' + l1, totales[4] - totales[5], 'Arial, negrita, 9');
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, ' ', 'Arial, negrita, 9');
    end;
  end;
  totales[3] := 0; totales[4] := 0; totales[5] := 0;
end;

procedure TTCreditos.ListarInformeCapitalAportes(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Control de Aportes y Amortizaciones
var
  rp: array[1..200, 1..7] of String;
  i, j, h, cantidad_pagos, n: Integer;
  c, e: String;
  indice: Real;
  lista: TStringList;
Begin
  rsql :=  datosdb.tranSQL('select * from distribucioncobros where fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''' + ' order by fecha');
  rsql.Open;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida); list.altopag := 0; list.m := 0;
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Distribuci�n de Capital y Aportes - Per�odo: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
    List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
    List.Titulo(1, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(8, list.Lineactual, 'Expediente      Prestatario', 3, 'Arial, cursiva, 8');
    List.Titulo(50, list.Lineactual, 'Aporte', 4, 'Arial, cursiva, 8');
    List.Titulo(60, list.Lineactual, 'Amortiz.', 5, 'Arial, cursiva, 8');
    List.Titulo(70, list.Lineactual, 'Punit.', 6, 'Arial, cursiva, 8');
    List.Titulo(80, list.Lineactual, 'a Cuenta', 7, 'Arial, cursiva, 8');
    List.Titulo(90, list.Lineactual, 'Desc.', 8, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if salida = 'X' then Begin
    c1 := 0;
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.FijarAnchoColumna('a' + l1, 'a' + l1, 13);
    excel.setString('a' + l1, 'a' + l1, 'Distribuci�n de Capital y Aportes - Per�odo: ' + xdfecha + '-' + xhfecha, 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, '');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Fecha', 'Arial, negrita, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 37);
    excel.setString('b' + l1, 'b' + l1, 'Expediente / Prestatario', 'Arial, negrita, 10');
    excel.setString('c' + l1, 'c' + l1, 'Aporte', 'Arial, negrita, 10');
    excel.setString('d' + l1, 'd' + l1, 'Amortiz.', 'Arial, negrita, 10');
    excel.setString('e' + l1, 'e' + l1, 'Punit', 'Arial, negrita, 10');
    excel.setString('f' + l1, 'f' + l1, 'a Cuenta', 'Arial, negrita, 10');
    excel.setString('g' + l1, 'g' + l1, 'Descuento', 'Arial, negrita, 10');
    Inc(c1);
  end;

  totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[6] := 0; totales[7] := 0; totales[8] := 0; totales[9] := 0; totales[10] := 0; totales[11] := 0;
  idanter[2] := rsql.FieldByName('fecha').AsString;
  while not rsql.Eof do Begin

    //--------------------------------------------------------------------------

    if rsql.FieldByName('expediente').AsString <> idanter[1] then Begin
    c := Copy(rsql.FieldByName('expediente').AsString, 1, 5);
    e := Copy(rsql.FieldByName('expediente').AsString, 7, 4);
    h := 0;

    if rsql.FieldByName('fecha').AsString <> idanter[2] then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

    if Buscar(c, e) then Begin
      getDatos(c, e);
      detcred := creditos_det;

      if credito.Refinanciado = 'S' then Begin  // Creditos Refinanciados
        detcred := creditos_detrefinanciados;
        detcred.Open;
        h       := 1;
      end;

      if credito.CuotasRef = 'S' then Begin  // Creditos Refinanciados
        detcred := creditos_detrefcuotas;
        detcred.Open;
        h       := 1;
      end;
    end else Begin
      if verificarSiExisteExpedienteHistorico(c, e) then Begin
        getDatosExpedienteHistorico(c, e);
        detcred := creditos_dethist;
        detcred.Open;
        h       := 1;
      end;
    end;

    // Prorrateamos los montos
    totales[1] := 0; totales[2] := 0; totales[3] := 0; totales[4] := 0; totales[5] := 0; totales[10] := 0;
    datosdb.Filtrar(detcred, 'codprest = ' + '''' + Copy(rsql.FieldByName('expediente').AsString, 1, 5) + '''' + ' and expediente = ' + '''' + Copy(rsql.FieldByName('expediente').AsString, 7, 4) + '''');

    // Cargamos los movimientos a la matriz, las cuotas
    for i := 1 to 200 do Begin
      rp[i, 1] := ''; rp[i, 2] := ''; rp[i, 3] := ''; rp[i, 4] := ''; rp[i, 5] := ''; rp[i, 6] := '';
    end;

    lista := TStringList.Create;

    detcred.First; i := 0;
    while not detcred.Eof do Begin
      if (detcred.FieldByName('tipomov').AsInteger = 1) then Begin
        Inc(i);
        rp[i, 1] := detcred.FieldByName('items').AsString;
        rp[i, 2] := utiles.FormatearNumero(detcred.FieldByName('aporte').AsString);
        rp[i, 3] := utiles.FormatearNumero(detcred.FieldByName('amortizacion').AsString);
        rp[i, 5] := detcred.FieldByName('estado').AsString;
        rp[i, 6] := detcred.FieldByName('codprest').AsString + detcred.FieldByName('expediente').AsString + detcred.FieldByName('items').AsString;
        j        := i;
      end else
        lista.Add(detcred.FieldByName('refpago').AsString);
      detcred.Next;
    end;

    detcred.First; // Prorrateamos los pagos
    while not detcred.Eof do Begin

      if (detcred.FieldByName('fechavto').AsString >= utiles.sExprFecha2000(xdfecha)) and (detcred.FieldByName('fechavto').AsString <= utiles.sExprFecha2000(xhfecha)) and (detcred.FieldByName('tipomov').AsInteger = 2) then Begin
        if (detcred.FieldByName('fechavto').AsString = rsql.FieldByName('fecha').AsString) then Begin

          // Averiguamos en cuantos pagos se hizo la cuota
          cantidad_pagos := 0;
          For n := 1 to lista.Count do
            if lista.Strings[n-1] = detcred.FieldByName('refpago').AsString then Inc(cantidad_pagos);
          lista.Clear;
          //-------------------------------------------------------------------

          For i := 1 to j do Begin
            if rp[i, 1] = Copy(detcred.FieldByName('refpago').AsString, 10, 3) then Begin
              if detcred.FieldByName('indice').AsFloat <> 0 then indice := detcred.FieldByName('indice').AsFloat else indice := 1;

              if (rp[i, 5] = 'P') and (detcred.FieldByName('saldocuota').AsFloat = 0) and (cantidad_pagos < 2) then Begin   // si est� pagada en un 100%
                totales[1]  := totales[1]  + (StrToFloat(rp[i, 2]) * indice);
                totales[2]  := totales[2]  + (StrToFloat(rp[i, 3]) * indice);
                totales[5]  := totales[5]  + (detcred.FieldByName('interes').AsFloat * indice);
                totales[10] := totales[10] + (detcred.FieldByName('descuento').AsFloat * indice);
              end else Begin                       // pagos parciales
                totales[3]  := totales[3]  + (detcred.FieldByName('total').AsFloat * indice);
                totales[5]  := totales[5]  + (detcred.FieldByName('interes').AsFloat * indice);
                totales[10] := totales[10] + (detcred.FieldByName('descuento').AsFloat * indice);
              end;
            end;
          end;
        end;
      end;

      detcred.Next;
    end;

    datosdb.QuitarFiltro(detcred);

    if h = 1 then datosdb.closedb(detcred);

      //--------------------------------------------------------------------------

      prestatario.getDatos(Copy(rsql.FieldByName('expediente').AsString, 1, 5));
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(8, list.Lineactual, rsql.FieldByName('expediente').AsString, 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(17, list.Lineactual, Copy(prestatario.nombre, 1, 25), 3, 'Arial, normal, 8', salida, 'N');
        list.importe(55, list.Lineactual, '', totales[1], 4, 'Arial, normal, 8');  // aporte
        list.importe(65, list.Lineactual, '', totales[2], 5, 'Arial, normal, 8');  // capital
        list.importe(75, list.Lineactual, '', totales[5], 6, 'Arial, normal, 8');  // punitorio
        list.importe(85, list.Lineactual, '', totales[3], 7, 'Arial, normal, 8');  // a cuenta
        list.importe(95, list.Lineactual, '', totales[10], 8, 'Arial, normal, 8');  // a cuenta
        list.Linea(95, list.Lineactual, '' {+ '   ' + inttostr(cantidad_pagos)}, 9, 'Arial, normal, 8', salida, 'S');
      end;
      if salida = 'X' then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('a' + l1, 'a' + l1, '''' + utiles.sFormatoFecha(rsql.FieldByName('fecha').AsString), 'Arial, normal, 8');
        excel.setString('b' + l1, 'b' + l1, rsql.FieldByName('expediente').AsString + ' ' + Copy(prestatario.nombre, 1, 25), 'Arial, normal, 8');
        excel.setReal('c' + l1, 'c' + l1, totales[1], 'Arial, normal, 8');
        excel.setReal('d' + l1, 'd' + l1, totales[2], 'Arial, normal, 8');
        excel.setReal('e' + l1, 'e' + l1, totales[5], 'Arial, normal, 8');
        excel.setReal('f' + l1, 'f' + l1, totales[3], 'Arial, normal, 8');
        excel.setReal('g' + l1, 'g' + l1, totales[10], 'Arial, normal, 8');
      end;

      totales[6]  := totales[6]  + totales[1];
      totales[7]  := totales[7]  + totales[2];
      totales[8]  := totales[8]  + totales[5];
      totales[9]  := totales[9]  + totales[3];
      totales[11] := totales[11] + totales[10];

      idanter[1] := rsql.FieldByName('expediente').AsString;

    end;

    idanter[2] := rsql.FieldByName('fecha').AsString;

    rsql.Next;
  end;

  rsql.Close; rsql.Free;

  if totales[6] + totales[7] + totales[8] + totales[9] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Subtotales:', 1, 'Arial, negrita, 8', salida, 'N');
      list.importe(55, list.Lineactual, '', totales[6], 2, 'Arial, negrita, 8');  // aporte
      list.importe(65, list.Lineactual, '', totales[7], 3, 'Arial, negrita, 8');  // capital
      list.importe(75, list.Lineactual, '', totales[8], 4, 'Arial, negrita, 8');  // punitorio
      list.importe(85, list.Lineactual, '', totales[9], 5, 'Arial, negrita, 8');  // a cuenta
      list.importe(95, list.Lineactual, '', totales[11], 6, 'Arial, negrita, 8');  // a cuenta
      list.Linea(95, list.Lineactual, '', 7, 'Arial, negrita, 8', salida, 'S');
    end;
    if salida = 'X' then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, 'Subtotales:', 'Arial, negrita, 8');
      excel.setReal('c' + l1, 'c' + l1, totales[6], 'Arial, negrita, 8');
      excel.setReal('d' + l1, 'd' + l1, totales[7], 'Arial, negrita, 8');
      excel.setReal('e' + l1, 'e' + l1, totales[8], 'Arial, negrita, 8');
      excel.setReal('f' + l1, 'f' + l1, totales[9], 'Arial, negrita, 8');
      excel.setReal('g' + l1, 'g' + l1, totales[11], 'Arial, negrita, 8');
    end;
  end;

  if salida = 'X' then excel.Visulizar else PresentarInforme;
end;

//------------------------------------------------------------------------------

procedure TTCreditos.ListControlChequesRecibos(xdfecha, xhfecha, xlistar: String; salida: char);
// Objetivo...: Listar Control de Recibos
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Control de Cheques Recibos - Per�odo: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  List.Titulo(1, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  List.Titulo(10, list.Lineactual, 'N� Cheque', 3, 'Arial, cursiva, 8');
  List.Titulo(19, list.Lineactual, 'Entidad Bancaria', 4, 'Arial, cursiva, 8');
  List.Titulo(43, list.Lineactual, 'Filial', 5, 'Arial, cursiva, 8');
  List.Titulo(57, list.Lineactual, 'Prestatario', 6, 'Arial, cursiva, 8');
  List.Titulo(89, list.Lineactual, 'Monto', 7, 'Arial, cursiva, 8');
  List.Titulo(97, list.Lineactual, 'F.Oper.', 8, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  IniciarArreglos;

  list.Linea(0, 0, 'Cheques de Pagos de Cr�ditos - Cr�ditos', 1, 'Arial, normal, 14', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  rsql.Open;
  idanter[1] := rsql.FieldByName('fecha').AsString;
  while not rsql.Eof do Begin
    if rsql.FieldByName('fecha').AsString <> idanter[1] then TotalDiaCheque(salida);
    getDatosCheque(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString, rsql.FieldByName('items').AsString);
    list.Linea(0, 0, '     ' + FechaCheque, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, rsql.FieldByName('nrocheque').AsString, 2, 'Arial, normal, 8', salida, 'N');
    entbcos.getDatos(rsql.FieldByName('codbanco').AsString);
    getDatosCobro(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString);
    prestatario.getDatos(ccodprest);
    list.Linea(19, list.Lineactual, Copy(entbcos.descrip, 1, 30), 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(43, list.Lineactual, Copy(rsql.FieldByName('filial').AsString, 1, 20), 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(57, list.Lineactual, Copy(prestatario.nombre, 1, 35), 5, 'Arial, normal, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', rsql.FieldByName('monto').AsFloat, 6, 'Arial, normal, 8');
    list.Linea(96, list.Lineactual, Fechacobro, 7, 'Arial, normal, 8', salida, 'N');
    totales[1] := totales[1] + rsql.FieldByname('monto').AsFloat;
    totales[2] := totales[2] + rsql.FieldByname('monto').AsFloat;
    idanter[1] := rsql.FieldByName('fecha').AsString;
    rsql.Next;
  end;
  rsql.Close; rsql.Free; rsql := Nil;

  TotalDiaCheque(salida);

  ListarChequesDevueltos(xdfecha, xhfecha, salida);

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
  end;

  if totales[1] = 0 then list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 10', salida, 'S');

  if xlistar <> 'N' then list.FinList;
end;

procedure TTCreditos.TotalDiaCheque(salida: char);
// Objetivo...: Agregar un items
Begin
  if totales[2] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, '     Total Fecha ' + utiles.sFormatoFecha(idanter[1]), 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  totales[2] := 0;
end;

procedure TTCreditos.ListarControlChequesRecibos(xdfecha, xhfecha, xlistar: String; salida: char);
// Objetivo...: Listar cheques por fecha de operacion
Begin
  rsql := datosdb.tranSQL('select * from cheques_mov where fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha, codbanco');
  ListControlChequesRecibos(xdfecha, xhfecha, xlistar, salida);
end;

procedure TTCreditos.ListarControlChequesRecibosFechaRecepcion(xdfecha, xhfecha, xlistar: String; salida: char);
// Objetivo...: Listar cheques por fecha de recepcion
Begin
  rsql := datosdb.tranSQL('select distribucioncobros.sucursal, distribucioncobros.numero, distribucioncobros.fecha as fecha1, cheques_mov.sucursal, cheques_mov.numero, cheques_mov.items, cheques_mov.nrocheque, cheques_mov.fecha, ' +
                          'cheques_mov.codbanco, cheques_mov.filial, cheques_mov.monto from distribucioncobros, cheques_mov where distribucioncobros.sucursal = cheques_mov.sucursal and distribucioncobros.numero = cheques_mov.numero and ' +
                          'distribucioncobros.fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and distribucioncobros.fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by cheques_mov.fecha, codbanco');
  ListControlChequesRecibos(xdfecha, xhfecha, xlistar, salida);
end;

{procedure TTCreditos.ListarChequesDevueltosPrestatario(xcodprest, xexpediente: String; salida: char);
// Objetivo...: Informar Cheques Devueltos
var
  r: TQuery;
  indice: string;
Begin
  list.Linea(0, 0, 'Cheques Devueltos por el Banco - Recibos', 1, 'Arial, normal, 14', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  indice := creditos_det.IndexFieldNames;
  creditos_det.IndexFieldNames := 'RECIBO';

  r := setChequesDevueltos(xdfecha, xhfecha);
  r.Open; totales[6] := 0;
  while not r.Eof do Begin
    entbcos.getDatos(r.FieldByName('codbanco').AsString);
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, r.FieldByName('nrocheque').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(10, list.Lineactual, copy(entbcos.descrip, 1, 25) + ' (' + r.FieldByName('filial').AsString + ')', 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(55, list.Lineactual, utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + ' - Devuelto: ' + utiles.sFormatoFecha(r.FieldByName('fechadev').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.importe(90, list.Lineactual, '', r.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      list.importe(96, list.Lineactual, '', r.FieldByName('comision').AsFloat, 5, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, r.FieldByName('nrocheque').AsString, 'Arial, normal, 9');
      excel.setString('b' + l1, 'b' + l1, entbcos.descrip + ' (' + r.FieldByName('filial').AsString + ')', 'Arial, normal, 9');
      excel.setString('c' + l1, 'c' + l1, utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + ' - Devuelto: ' + utiles.sFormatoFecha(r.FieldByName('fechadev').AsString), 'Arial, normal, 9');
      excel.setReal('d' + l1, 'd' + l1, r.FieldByName('monto').AsFloat, 'Arial, normal, 9');
      excel.setReal('e' + l1, 'e' + l1, r.FieldByName('comision').AsFloat, 'Arial, normal, 9');
    end;

    if (credito.BuscarReciboCobro(r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, '01')) then begin
      creditos_det.FindKey([r.FieldByName('numero').AsString + r.FieldByName('sucursal').AsString]);
      prestatario.getDatos(creditos_det.FieldByName('codprest').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '          Prestatario: ' +  creditos_det.FieldByName('codprest').AsString + '-' + creditos_det.FieldByName('expediente').AsString + '  ' + prestatario.nombre, 1, 'Arial, cursiva, 8', salida, 'S');
      End;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('b' + l1, 'b' + l1, '          Prestatario: ' +  creditos_det.FieldByName('codprest').AsString + '-' + creditos_det.FieldByName('expediente').AsString + '  ' + prestatario.nombre, 'Arial, cursiva, 9');
      end;
    end;

    totales[6] := totales[6] + r.FieldByName('monto').AsFloat;
    r.Next;
  end;

  if r.RecordCount = 0 then
    if totales[1] = 0 then list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  r.Close; r.Free;

  creditos_det.IndexFieldNames := indice;
end;}

procedure TTCreditos.ListarChequesDevueltos(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Informar Cheques Devueltos
var
  r: TQuery;
  indice: string;
Begin
  list.Linea(0, 0, 'Cheques Devueltos por el Banco - Recibos', 1, 'Arial, normal, 14', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  indice := creditos_det.IndexFieldNames;
  creditos_det.IndexFieldNames := 'RECIBO';

  r := setChequesDevueltos(xdfecha, xhfecha);
  r.Open; totales[6] := 0;
  while not r.Eof do Begin
    entbcos.getDatos(r.FieldByName('codbanco').AsString);
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, r.FieldByName('nrocheque').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(10, list.Lineactual, copy(entbcos.descrip, 1, 25) + ' (' + r.FieldByName('filial').AsString + ')', 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(55, list.Lineactual, utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + ' - Devuelto: ' + utiles.sFormatoFecha(r.FieldByName('fechadev').AsString), 3, 'Arial, normal, 8', salida, 'N');
      list.importe(90, list.Lineactual, '', r.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      list.importe(96, list.Lineactual, '', r.FieldByName('comision').AsFloat, 5, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, r.FieldByName('nrocheque').AsString, 'Arial, normal, 9');
      excel.setString('b' + l1, 'b' + l1, entbcos.descrip + ' (' + r.FieldByName('filial').AsString + ')', 'Arial, normal, 9');
      excel.setString('c' + l1, 'c' + l1, utiles.sFormatoFecha(r.FieldByName('fecha').AsString) + ' - Devuelto: ' + utiles.sFormatoFecha(r.FieldByName('fechadev').AsString), 'Arial, normal, 9');
      excel.setReal('d' + l1, 'd' + l1, r.FieldByName('monto').AsFloat, 'Arial, normal, 9');
      excel.setReal('e' + l1, 'e' + l1, r.FieldByName('comision').AsFloat, 'Arial, normal, 9');
    end;

    if (length(trim(r.FieldByName('codprest').AsString)) = 0) then begin
      if (credito.BuscarReciboCobro(r.FieldByName('sucursal').AsString, r.FieldByName('numero').AsString, '01')) then begin
        creditos_det.FindKey([r.FieldByName('numero').AsString + r.FieldByName('sucursal').AsString]);
        prestatario.getDatos(creditos_det.FieldByName('codprest').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, '          Prestatario: ' +  creditos_det.FieldByName('codprest').AsString + '-' + creditos_det.FieldByName('expediente').AsString + '  ' + prestatario.nombre, 1, 'Arial, cursiva, 8', salida, 'S');
        End;
        if (salida = 'X') then Begin
          Inc(c1); l1 := Trim(IntToStr(c1));
          excel.setString('b' + l1, 'b' + l1, '          Prestatario: ' +  creditos_det.FieldByName('codprest').AsString + '-' + creditos_det.FieldByName('expediente').AsString + '  ' + prestatario.nombre, 'Arial, cursiva, 9');
        end;
      end;
    end else begin
      prestatario.getDatos(r.FieldByName('codprest').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, '          Prestatario: ' +  creditos_det.FieldByName('codprest').AsString + '-' + creditos_det.FieldByName('expediente').AsString + '  ' + prestatario.nombre, 1, 'Arial, cursiva, 8', salida, 'S');
      End;
      if (salida = 'X') then Begin
        Inc(c1); l1 := Trim(IntToStr(c1));
        excel.setString('b' + l1, 'b' + l1, '          Prestatario: ' +  creditos_det.FieldByName('codprest').AsString + '-' + creditos_det.FieldByName('expediente').AsString + '  ' + prestatario.nombre, 'Arial, cursiva, 9');
      end;
    end;

    totales[6] := totales[6] + r.FieldByName('monto').AsFloat;
    r.Next;
  end;

  if r.RecordCount = 0 then
    if totales[1] = 0 then list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 10', salida, 'S');

  list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  r.Close; r.Free;

  creditos_det.IndexFieldNames := indice;
end;

procedure TTCreditos.RegistrarIndice(xtipocalculo, xindice: String);
// Objetivo...: Agregar un items
Begin
  if datosdb.Buscar(calculo_indice, 'tipocalculo', 'items', xtipocalculo, xindice) then calculo_indice.Edit else calculo_indice.Append;
  calculo_indice.FieldByName('tipocalculo').AsString := xtipocalculo;
  calculo_indice.FieldByName('items').AsString       := xindice;
  try
    calculo_indice.Post
   except
    calculo_indice.Cancel
  end;
end;

procedure TTCreditos.BorrarIndice(xtipocalculo, xindice: String);
// Objetivo...: Borrar un items
Begin
  if datosdb.Buscar(calculo_indice, 'tipocalculo_items', 'items') then calculo_indice.Delete;
end;

function  TTCreditos.setCalculoIndices: TQuery;
// Objetivo...: Devolver un set de items
Begin
  Result := datosdb.tranSQL('select * from calculo_indice');
end;

function  TTCreditos.setIndiceCalculo(xtipocalculo: String): String;
// Objetivo...: Retornar tipo de calculo
Begin
  Result := '';
  if not calculo_indice.Active then calculo_indice.Open;
  calculo_indice.First;
  while not calculo_indice.Eof do Begin
    if calculo_indice.FieldByName('tipocalculo').AsString = xtipocalculo then Begin
      Result := calculo_indice.FieldByName('items').AsString;
      Break;
    end;
    calculo_indice.Next;
  end;
end;

function TTCreditos.verificarOperacionesEnExpediente(xcodprest: String): Boolean;
// Objetivo...: Verificar Operaciones en Expediente
var
  rb: Boolean;
Begin
  rb := False;
  rsql := datosdb.tranSQL('select codprest from creditos_cab where codprest = ' + '"' + xcodprest + '"');
  rsql.Open;
  if rsql.RecordCount > 0 then rb := True;
  rsql.Close; rsql.Free;
  rsql := datosdb.tranSQL('select codprest from creditos_cabhist where codprest = ' + '"' + xcodprest + '"');
  rsql.Open;
  if rsql.RecordCount > 0 then rb := True;
  rsql.Close; rsql.Free;
  rsql := datosdb.tranSQL('select codprest from creditos_cabrefinanciados where codprest = ' + '"' + xcodprest + '"');
  rsql.Open;
  if rsql.RecordCount > 0 then rb := True;
  rsql.Close; rsql.Free;
  rsql := datosdb.tranSQL('select codprest from creditos_cabrefcuotas where codprest = ' + '"' + xcodprest + '"');
  rsql.Open;
  if rsql.RecordCount > 0 then rb := True;
  rsql.Close; rsql.Free;
  Result := rb;
end;

function  TTCreditos.verificarSiElCreditoEstaSaldado(xcodprest, xexpediente: String): Boolean;
// Objetivo...: Verificar si el cr�dito est� saldado
Begin
  Result := True;
  datosdb.Filtrar(detcred, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  detcred.First;
  while not detcred.Eof do Begin
    if detcred.FieldByName('tipomov').AsString = '1' then Begin
      if detcred.FieldByName('estado').AsString =  'I' then Begin
        Result := False;
        Break;
      end;
    end;
    detcred.Next;
  end;
  datosdb.QuitarFiltro(detcred);
end;

//---------- Imputaci�n de Gatos --------------------

function  TTCreditos.BuscarGasto(xcodprest, xexpediente, xitems: String): Boolean;
// Objetivo...: Retornar Gasto
Begin
  Result := datosdb.Buscar(gastos, 'codprest', 'expediente', 'items', xcodprest, xexpediente, xitems);
end;

procedure TTCreditos.RegistrarGasto(xcodprest, xexpediente, xitems, xidgasto, xrecibo, xfecha, xconcepto: String; xmonto: Real; xcantitems: Integer);
// Objetivo...: Registrar Gastos Cr�ditos
Begin
  if BuscarGasto(xcodprest, xexpediente, xitems) then gastos.Edit else gastos.Append;
  gastos.FieldByName('codprest').AsString   := xcodprest;
  gastos.FieldByName('expediente').AsString := xexpediente;
  gastos.FieldByName('items').AsString      := xitems;
  gastos.FieldByName('idgasto').AsString    := xidgasto;
  gastos.FieldByName('recibo').AsString     := xrecibo;
  gastos.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  gastos.FieldByName('concepto').AsString   := xconcepto;
  gastos.FieldByName('monto').AsFloat       := xmonto;
  gastos.FieldByName('estado').AsString     := 'I';
  try
    gastos.Post
   except
    gastos.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from gastos where codprest = ' + '"' + xcodprest + '"' + ' and expediente = ' + '"' + xexpediente + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') + '"');
    datosdb.refrescar(gastos);
  end;

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Gastos Expediente ' + xcodprest + '-' + xexpediente);
end;

function  TTCreditos.setItemsGasto(xcodprest, xexpediente: String): TStringList;
// Objetivo...: devolver los items imputados en gastos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  datosdb.Filtrar(gastos, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  gastos.First;
  while not gastos.Eof do Begin
    if (gastos.FieldByName('codprest').AsString <> xcodprest) or (gastos.FieldByName('expediente').AsString <> xexpediente) then Break;
    if Length(Trim(gastos.FieldByName('fecha').AsString)) > 0 then l.Add(gastos.FieldByName('idgasto').AsString + gastos.FieldByName('fecha').AsString + gastos.FieldByName('recibo').AsString + ';1' + utiles.FormatearNumero(gastos.FieldByName('monto').AsString) + ';2' + gastos.FieldByName('concepto').AsString + ';3' + gastos.FieldByName('items').AsString);
    gastos.Next;
  end;
  datosdb.QuitarFiltro(gastos);
  Result := l;
end;

procedure  TTCreditos.BorrarGasto(xcodprest, xexpediente, xitems: String);
// Objetivo...: Retornar Gasto
Begin
  if BuscarGasto(xcodprest, xexpediente, xitems) then gastos.Delete;
  datosdb.refrescar(gastos);
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Borrando Gasto Expediente ' + xcodprest + '-' + xexpediente);
end;

procedure  TTCreditos.RegistrarReferenciaGasto(xcodprest, xexpediente, xitems, xrecibo: String);
// Objetivo...: Retornar Gasto
Begin
  if BuscarGasto(xcodprest, xexpediente, xitems) then Begin
    gastos.Edit;
    gastos.FieldByName('referencia').AsString := xrecibo;
    try
      gastos.Post
     except
      gastos.Cancel
    end;
    datosdb.refrescar(gastos);
  end;
end;

function  TTCreditos.setReferenciaGasto(xcodprest, xexpediente, xitems: String): String;
// Objetivo...: Retornar Gasto
Begin
  if BuscarGasto(xcodprest, xexpediente, xitems) then Result := gastos.FieldByName('referencia').AsString else Result := '';
end;

procedure  TTCreditos.ListarGastos(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Gastos
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Gastos Administrativos Registrados en el Per�odo ' + xdfecha + ' - ' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  List.Titulo(8, list.Lineactual, 'Expediente / Prestatario', 2, 'Arial, cursiva, 8');
  List.Titulo(53, list.Lineactual, 'Concepto del Gasto', 3, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  gastos.First; totales[1] := 0;
  while not gastos.Eof do Begin
    if (gastos.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdfecha)) and (gastos.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhfecha)) then Begin
      prestatario.getDatos(gastos.FieldByName('codprest').AsString);
      gastosFijos.getDatos(gastos.FieldByName('idgasto').AsString);
      list.Linea(0, 0, utiles.sFormatoFecha(gastos.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(8, list.Lineactual,  gastos.FieldByName('codprest').AsString + '-' + gastos.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(53, list.Lineactual,  gastosFijos.Descrip, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', gastos.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
      list.Linea(96, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      totales[1] := totales[1] + gastos.FieldByName('monto').AsFloat;
    end;
    gastos.Next;
  end;

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total de Gastos:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTCreditos.RegistrarGastoComoPagado(xcodigobarra, xfecha, xhora, xcodprest, xexpediente, xfechaliq, ximput: String);
// Objetivo...: Marcar el gasto como pago
Begin
  datosdb.Filtrar(gastos, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  gastos.First;
  while not gastos.Eof do Begin
    gastos.Edit;
    gastos.FieldByName('estado').AsString := 'P';
    try
      gastos.Post
     except
      gastos.Cancel
    end;
    gastos.Next;
  end;

  datosdb.refrescar(gastos);
  datosdb.QuitarFiltro(gastos);

  boleta.MarcarBoletaComoPaga(xcodigobarra, xfecha, xhora, xfechaliq, ximput);
end;

{ ***************************************************************************** }

procedure TTCreditos.HabilitarExt;
// Objetivo...:  Habilitar Creditos Extendidos
begin
  creditos_cab.Close; creditos_det.Close;
  creditos_cab := Nil; creditos_det := Nil;
  creditos_cab := datosdb.openDB('creditos_cabext', '');
  creditos_det := datosdb.openDB('creditos_detext', '');
  creditos_cab.Open; creditos_det.Open;
  detcred := creditos_det;
end;

procedure TTCreditos.InHabilitarExt;
// Objetivo...:  Inhabilitar Creditos Extendidos
Begin
  creditos_cab.Close; creditos_det.Close;
  creditos_cab := Nil; creditos_det := Nil;
  creditos_cab := datosdb.openDB('creditos_cab', '');
  creditos_det := datosdb.openDB('creditos_det', '');
  creditos_cab.Open; creditos_det.Open;
  detcred := creditos_det;
end;

procedure TTCreditos.GuardarRefinanciacionExtendida(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xintervalopg, xTipoIndice, xtipocalculo, xfechappago: String; xmonto, xentrega, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xmonto_real: Real; xcantitems: Integer);
// Objetivo...: Guardamos Refinanciaci�n Extendida
Begin
 HabilitarExt;
 Guardar(xcodprest, xexpediente, xfecha, xidcredito, xformapago, xcantcuotas, xpergracia, xconcepto, xitems, xfechavto, xconceptoitems, xintervalopg, xTipoIndice, xtipocalculo, xfechappago, xmonto, xentrega, xindice, xaporte, xamortizacion, xaportec, xtotal, xsaldo, xinteres, xmonto_real, xcantitems);
 InHabilitarExt;
end;

procedure TTCreditos.InfPresentarCreditoRefinanciacionExtendida(salida: Char);
// Objetivo...: Listamos Refinanciaci�n Extendida
Begin
 HabilitarExt;
 credito_historico := False;
 InfPresentarCredito(salida);
 InHabilitarExt;
end;

procedure TTCreditos.ListarResumenDePagosRefinanciacionExtendida(listSel: TStringList; xfecha: String; disc_linea, xinfresumido: Boolean; salida: char);
// Objetivo...: Listamos Refinanciaci�n Extendida
Begin
 HabilitarExt;
 credito_historico := False;
 ListarResumenDePagos(listSel, xfecha, disc_linea, xinfresumido, salida);
 InHabilitarExt;
end;

function TTCreditos.BuscarRefinanciacionExtendida(xcodprest, xexpediente: String): Boolean;
// Objetivo...: Listamos Refinanciaci�n Extendida
Begin
 creditos_cabext.Open;
 ExisteCredito := datosdb.Buscar(creditos_cabext, 'codprest', 'expediente', xcodprest, xexpediente);
 Result        := ExisteCredito;
 creditos_cabext.Close;
end;

procedure TTCreditos.BorrarRefinanciacionExtendida(xcodprest, xexpediente: String);
// Objetivo...: Listamos Refinanciaci�n Extendida
Begin
 datosdb.tranSQL('delete from creditos_cabext where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
 datosdb.tranSQL('delete from creditos_detext where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
 logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Borrando Refinanciaci�n Extendida Expediente ' + xcodprest + '-' + xexpediente);
end;

function TTCreditos.setItemsRefinanciacionExtendida: TQuery;
// Objetivo...: Devolver los Items de los Cr�ditos
Begin
  Result := datosdb.tranSQL('SELECT * FROM creditos_detext WHERE codprest = ' + '"' + codprest + '"' + ' AND expediente = ' + '"' + expediente + '"' + ' AND estado <> ' + '"' + 'R' + '"' + ' ORDER BY items');
end;

procedure TTCreditos.TransferirHistoricoRefinanciacionExtendida(xcodprest, xexpediente: String);
// Objetivo...: Transferir al Registro Hist�rico los datos ingresados
Begin
  HabilitarExt;
  getDatos(xcodprest, xexpediente);

  creditos_cabhist := nil; creditos_dethist := nil; gastos_hist := nil;
  creditos_cabhist := datosdb.openDB('creditos_cabexthist', '');
  creditos_dethist := datosdb.openDB('creditos_detexthist', '');
  gastos_hist      := Nil;
  Refinanciado     := '';
  detcred          := creditos_det;   // Apuntadores de tablas

  cab_credito      := creditos_cab;
  cab_creditohist  := creditos_cabhist;
  det_creditos     := creditos_det;
  det_creditohist  := creditos_dethist;

  TransferirRegistrosAlHistorico(xcodprest, xexpediente);
end;

function TTCreditos.setExpedientesRefinanciacionExtendida(xcodprest: String): TQuery;
// Objetivo...: Bloquear procesos
Begin
  Result := datosdb.tranSQL('select * from creditos_cabext where codprest = ' + '''' + xcodprest + '''');
end;

{ ***************************************************************************** }

function  TTCreditos.BuscarItemsSeg(xcodprest, xexpediente, xitems: String): Boolean;
// Objetivo...: Buscar Items Seguimiento
Begin
  Result := datosdb.Buscar(segexptes, 'codprest', 'expediente', 'items', xcodprest, xexpediente, xitems);
end;

procedure TTCreditos.RegistrarItemsSeg(xcodprest, xexpediente, xitems, xfecha, xconcepto: String; xcantitems: Integer);
// Objetivo...: registrar items
Begin
  if BuscarItemsSeg(xcodprest, xexpediente, xitems) then segexptes.Edit else segexptes.Append;
  segexptes.FieldByName('codprest').AsString   := xcodprest;
  segexptes.FieldByName('expediente').AsString := xexpediente;
  segexptes.FieldByName('items').AsString      := xitems;
  segexptes.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
  segexptes.FieldByName('concepto').AsString   := xconcepto;
  try
    segexptes.Post
   except
    segexptes.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from ' + segexptes.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(segexptes); segexptes.Open;
  end;

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Items Seguimiento Expediente ' + xcodprest + '-' + xexpediente);
end;

function  TTCreditos.setItemsSeg(xcodprest, xexpediente: String): TStringList;
// Objetivo...: Devolver items seguimiento del expediente
var
  l: TStringList;
Begin
  l := TStringList.Create;

  segexptes.IndexFieldNames := 'Codprest;Expediente;Fecha';
  datosdb.Filtrar(segexptes, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  segexptes.First;
  while not segexptes.Eof do Begin
    if (segexptes.FieldByName('codprest').AsString <> xcodprest) or (segexptes.FieldByName('expediente').AsString <> xexpediente) then Break;
    l.Add(segexptes.FieldByName('items').AsString + utiles.sFormatoFecha(segexptes.FieldByName('fecha').AsString) + segexptes.FieldByName('concepto').AsString);
    segexptes.Next;
  end;
  datosdb.QuitarFiltro(segexptes);
  segexptes.IndexFieldNames := 'Codprest;Expediente;Items';

  Result := l;
end;

procedure TTCreditos.BorrarItemsSeg(xcodprest, xexpediente: String);
// objetivo...: Borrar Items Seguimiento expedientes
Begin
  datosdb.tranSQL('delete from ' + segexptes.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Borrando Items Seguimiento Expediente ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.ListarSeguimientoExpediente(xcodprest, xexpediente: String; salida: char);
// objetivo...: Borrar Items Seguimiento expedientes
var
  f: Boolean;
Begin
  idanter[2] := ''; idanter[3] := '';
  if not BuscarItemsSeg(xcodprest, xexpediente, '001') then list.Linea(55, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S') else Begin
    while not segexptes.Eof do Begin
      if (segexptes.FieldByName('codprest').AsString <> xcodprest) or (segexptes.FieldByName('expediente').AsString <> xexpediente) then Break;
      if not f then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(56, list.Lineactual, utiles.sFormatoFecha(segexptes.FieldByName('fecha').AsString), 5, 'Arial, normal, 8', salida, 'N');
          list.Linea(64, list.Lineactual, segexptes.FieldByName('concepto').AsString, 6, 'Arial, normal, 8', salida, 'S');
        end;
        if salida = 'X' then Begin
          Inc(c1); l1 := IntToStr(c1);
          excel.setString('e' + l1, 'e' + l1, '''' + utiles.sFormatoFecha(segexptes.FieldByName('fecha').AsString), 'Arial, normal, 8');
          excel.setString('f' + l1, 'f' + l1, segexptes.FieldByName('concepto').AsString, 'Arial, normal, 8');
        end;
        f := True;
      end else Begin
        if segexptes.FieldByName('fecha').AsString <> idanter[2] then Begin
          idanter[3] := utiles.sFormatoFecha(segexptes.FieldByName('fecha').AsString);
          idanter[2] := segexptes.FieldByName('fecha').AsString;
        end else
          idanter[3] := '';
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(56, list.Lineactual, idanter[3], 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(64, list.Lineactual, segexptes.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
        end;
        if salida = 'X' then Begin
          Inc(c1); l1 := IntToStr(c1);
          excel.setString('e' + l1, 'e' + l1, '''' + idanter[3], 'Arial, normal, 8');
          excel.setString('f' + l1, 'f' + l1, segexptes.FieldByName('concepto').AsString, 'Arial, normal, 8');
        end;
      end;
      segexptes.Next;
    end;
  end;
end;

{ ***************************************************************************** }

function  TTCreditos.BuscarChequeCredito(xcodprest, xexpediente, xitems: String): Boolean;
// objetivo...: Buscar Items
Begin
  Result := datosdb.Buscar(cheques_creditos, 'codprest', 'expediente', 'items', xcodprest, xexpediente, xitems);
end;

procedure TTCreditos.RegistrarChequeCredito(xcodprest, xexpediente, xitems, xnrocheque, xcodcta: String; xmonto: Real; xcantitems: Integer);
// objetivo...: Registrar Items
Begin
  if BuscarChequeCredito(xcodprest, xexpediente, xitems) then cheques_creditos.Edit else cheques_creditos.Append;
  cheques_creditos.FieldByName('codprest').AsString   := xcodprest;
  cheques_creditos.FieldByName('expediente').AsString := xexpediente;
  cheques_creditos.FieldByName('items').AsString      := xitems;
  cheques_creditos.FieldByName('nrocheque').AsString  := xnrocheque;
  cheques_creditos.FieldByName('codcta').AsString     := xcodcta;
  cheques_creditos.FieldByName('monto').AsFloat       := xmonto;
  try
    cheques_creditos.Post
   except
    cheques_creditos.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') then Begin
    datosdb.tranSQL('delete from cheques_creditos where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(cheques_creditos); cheques_creditos.Open;
  end;

  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Registrando Cheque Entrega Cr�dito ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.BorrarChequeCredito(xcodprest, xexpediente: String);
// objetivo...: Borrar Items
Begin
  datosdb.tranSQL('delete from cheques_creditos where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  datosdb.closeDB(cheques_creditos); cheques_creditos.Open;
  logsist.RegistrarLog(usuario.usuario, 'Cr�ditos', 'Borrando Cheque Expediente ' + xcodprest + '-' + xexpediente);
end;

procedure TTCreditos.getDatosChequeCredito(xcodprest, xexpediente, xitems: String);
// objetivo...: Recuperar una instancia
Begin
  if BuscarChequeCredito(xcodprest, xexpediente, xitems) then Begin
    Nrocheque := cheques_creditos.FieldByName('nrocheque').AsString;
    Codcta    := cheques_creditos.FieldByName('codcta').AsString;
  end else Begin
    Nrocheque := '';
    Codcta    := '';
  end;
end;

function  TTCreditos.setChequesCredito(xcodprest, xexpediente: String): TStringList;
// Objetivo...: Retornar Cheques Cr�ditos
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if BuscarChequeCredito(xcodprest, xexpediente, '01') then Begin
    while not cheques_creditos.Eof do Begin
      if (cheques_creditos.FieldByName('codprest').AsString <> xcodprest) or (cheques_creditos.FieldByName('expediente').AsString <> xexpediente) then Break;
      l.Add(cheques_creditos.FieldByName('items').AsString + cheques_creditos.FieldByName('nrocheque').AsString + ';1' + cheques_creditos.FieldByName('codcta').AsString + cheques_creditos.FieldByName('monto').AsString);
      cheques_creditos.Next;
    end;
  end;
  Result := l;
end;

function  TTCreditos.setChequesCreditoHistorico(xcodprest, xexpediente: String): TStringList;
// Objetivo...: Retornar Cheques Cr�ditos
var
  l: TStringList;
  t: TTable;
Begin
  t := datosdb.openDB('cheques_creditoshit', '');
  l := TStringList.Create;
  if datosdb.Buscar(t, 'codprest', 'expediente', 'items', xcodprest, xexpediente, '01') then Begin
    while not t.Eof do Begin
      if (t.FieldByName('codprest').AsString <> xcodprest) or (t.FieldByName('expediente').AsString <> xexpediente) then Break;
      l.Add(t.FieldByName('items').AsString + t.FieldByName('nrocheque').AsString + ';1' + t.FieldByName('codcta').AsString + t.FieldByName('monto').AsString);
      t.Next;
    end;
  end;
  datosdb.closeDB(t);
  Result := l;
end;

procedure TTCreditos.AjustarIndiceCalculo(xcodprest, xexpediente, xindice: String);
// Objetivo...: Ajustar Indice C�lculos
Begin
  if Buscar(xcodprest, xexpediente) then Begin
    creditos_cab.Edit;
    creditos_cab.FieldByName('indicecalculo').AsString := xindice;
    try
      creditos_cab.Post
     except
      creditos_cab.Cancel
    end;
    datosdb.refrescar(creditos_cab);
  end;
end;

{ ***************************************************************************** }

function TTCreditos.Bloquear: Boolean;
// Objetivo...: Bloquear procesos
Begin
  if not bloqueos.FindKey(['creditos']) then Begin
    Result := True;
    bloqueos.Append;
    bloqueos.FieldByName('proceso').AsString := 'creditos';
    bloqueos.FieldByName('estado').AsString  := 'B';
    try
      bloqueos.Post
     except
      bloqueos.Cancel
    end;
    datosdb.refrescar(bloqueos);
  end else Begin
    if bloqueos.FieldByName('estado').AsString = 'B' then Result := False else Begin
      Result := True;
      bloqueos.Edit;
      bloqueos.FieldByName('estado').AsString  := 'B';
      try
        bloqueos.Post
       except
        bloqueos.Cancel
      end;
      datosdb.refrescar(bloqueos);
    end;
  end;
end;

procedure TTCreditos.QuitarBloqueo;
// Objetivo...: Quitar Bloqueo a procesos
Begin
  if bloqueos.FindKey(['creditos']) then Begin
    bloqueos.Edit;
    bloqueos.FieldByName('estado').AsString  := 'L';
    try
      bloqueos.Post
     except
      bloqueos.Cancel
    end;
    datosdb.refrescar(bloqueos);
  end;
end;

procedure TTCreditos.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  planctas.conectar;
  if conexiones = 0 then Begin
    if not creditos_cab.Active       then creditos_cab.Open;
    if not creditos_det.Active       then creditos_det.Open;
    if not recibos.Active            then recibos.Open;
    if not exptesjudiciales.Active   then exptesjudiciales.Open;
    if not distribucioncobros.Active then distribucioncobros.Open;
    if not recibos_detalle.Active    then recibos_detalle.Open;
    if not cheques_mov.Active        then cheques_mov.Open;
    if not formato_Impresion.Active  then formato_Impresion.Open;
    if not calculo_indice.Active     then calculo_indice.Open;
    if not gastos.Active             then gastos.Open;
    if not segexptes.Active          then segexptes.Open;
    if not cheques_creditos.Active   then cheques_creditos.Open;
    if not bloqueos.Active           then bloqueos.Open;
    if not codigo_barras.Active      then codigo_barras.Open;
    if not creditos_det_tf.Active    then creditos_det_tf.Open;
    if not garantias.Active          then garantias.Open;
    if not obs_historico.Active      then obs_historico.Open;
  end;
  Inc(conexiones);
  prestatario.conectar;
  boleta.conectar;
  entbcos.conectar;
  gastosFijos.conectar;
  categoria.conectar;
  ctactebcos.conectar;
  excluirexpedientes.conectar;
  detcred := creditos_det;

  setCodigoBarras;
end;

procedure TTCreditos.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(creditos_cab);
    datosdb.closeDB(creditos_det);
    datosdb.closeDB(recibos);
    datosdb.closeDB(exptesjudiciales);
    datosdb.closeDB(distribucioncobros);
    datosdb.closeDB(recibos_detalle);
    datosdb.closeDB(cheques_mov);
    datosdb.closeDB(formato_impresion);
    datosdb.closeDB(calculo_indice);
    datosdb.closeDB(gastos);
    datosdb.closeDB(segexptes);
    datosdb.closeDB(cheques_creditos);
    datosdb.closeDB(bloqueos);
    datosdb.closeDB(codigo_barras);
    datosdb.closeDB(creditos_det_tf);
    datosdb.closeDB(garantias);
    datosdb.closeDB(obs_historico);
  end;
  prestatario.desconectar;
  boleta.desconectar;
  desconectar_creditosRefinanciados;
  desconectar_cuotasRefinanciadas;
  entbcos.desconectar;
  gastosFijos.desconectar;
  categoria.desconectar;
  ctactebcos.desconectar;
  excluirexpedientes.desconectar;
end;

procedure TTCreditos.conectar_creditosRefinanciados;
// Objetivo...: cerrar tablas de persistencia de creditos refinanciados
begin
  if not credito_historico then Begin
    creditos_cabrefinanciados.Active := False; creditos_detrefinanciados.Active := False;
    creditos_cabrefinanciados := datosdb.opendb('creditos_cabrefinanciados', '');
    creditos_detrefinanciados := datosdb.opendb('creditos_detrefinanciados', '');
    if not creditos_cabrefinanciados.Active then creditos_cabrefinanciados.Open;
    if not creditos_detrefinanciados.Active then creditos_detrefinanciados.Open;
    detcred := creditos_detrefinanciados;
  End;
  if credito_historico then Begin
    creditos_cabrefinanciados.Active := False; creditos_detrefinanciados.Active := False;
    creditos_cabrefinanciados := datosdb.opendb('creditos_cabhistrefinanciados', '');
    creditos_detrefinanciados := datosdb.opendb('creditos_dethistrefinanciados', '');
    if not creditos_cabrefinanciados.Active then creditos_cabrefinanciados.Open;
    if not creditos_detrefinanciados.Active then creditos_detrefinanciados.Open;
    detcred := creditos_detrefinanciados;
  End;
end;

procedure TTCreditos.desconectar_creditosRefinanciados;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(creditos_cabrefinanciados);
  datosdb.closeDB(creditos_detrefinanciados);
  detcred := creditos_detrefcuotas;
  Refinanciado := '';
end;

procedure TTCreditos.conectar_cuotasRefinanciadas;
// Objetivo...: cerrar tablas de persistencia de cuotas refinanciados
begin
  if not credito_historico then Begin
    creditos_cabrefcuotas.Active := False; creditos_detrefcuotas.Active := False;
    creditos_cabrefcuotas := datosdb.openDB('creditos_cabrefcuotas', '');
    creditos_detrefcuotas := datosdb.openDB('creditos_detrefcuotas', '');
    if not creditos_cabrefcuotas.Active then creditos_cabrefcuotas.Open;
    if not creditos_detrefcuotas.Active then creditos_detrefcuotas.Open;
    detcred := creditos_detrefcuotas;    // Activamos el intercambio
  end;
  if credito_historico then Begin
    creditos_cabrefcuotas.Active := False; creditos_detrefcuotas.Active := False;
    creditos_cabrefcuotas := datosdb.openDB('creditos_cabhistrefcuotas', '');
    creditos_detrefcuotas := datosdb.openDB('creditos_dethistrefcuotas', '');
    if not creditos_cabrefcuotas.Active then creditos_cabrefcuotas.Open;
    if not creditos_detrefcuotas.Active then creditos_detrefcuotas.Open;
    detcred := creditos_detrefcuotas;    // Activamos el intercambio
  end;
end;

procedure TTCreditos.desconectar_cuotasRefinanciadas;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(creditos_cabrefcuotas);
  datosdb.closeDB(creditos_detrefcuotas);
  detcred := creditos_det;      // Inactivamos el intercambio
  RefinanciaCuota := '';
end;

procedure TTCreditos.ActivarTP;
// Objetivo...: conmutar tablas de persistencia
begin
  detcred := creditos_det;
  if ref_c = 'S' then conectar_creditosRefinanciados;
  if ref_u = 'S' then conectar_cuotasRefinanciadas;
  datosdb.QuitarFiltro(detcred);
end;

procedure TTCreditos.EstablecerCodigoBarras(xopcion: Integer);
Begin
  if codigo_barras.RecordCount > 0 then codigo_barras.Edit else codigo_barras.Append;
  codigo_barras.FieldByName('activar').AsInteger := xopcion;
  try
    codigo_barras.Post
   except
    codigo_barras.Cancel
  end;
  datosdb.refrescar(codigo_barras);
  if xopcion = 1 then codigobarras := True else codigobarras := False;
end;

function  TTCreditos.setCodigoBarras: Boolean;
Begin
  if not codigo_barras.Active then codigo_barras.Open;
  codigo_barras.First;
  if codigo_barras.FieldByName('activar').AsInteger = 1 then codigobarras := True else codigobarras := False;
  Result := codigobarras;
end;

procedure TTCreditos.AgregarItemsRecibo(xitems, xconcepto, xmonto: String);
// Objetivo...: Anexar Items a Recibos
var
  i, j: integer;
Begin
  if xitems = '01' then Begin
    For i := 1 to 800 do
      For j := 1 to 11 do mov[i, j] := '';
    itbol := 0;
  end;

  Inc(itbol);
  mov[itbol, 1] := xitems;
  mov[itbol, 2] := xconcepto;
  mov[itbol, 3] := xmonto;
end;

procedure TTCreditos.ListarRecibo(xcodprest, xexpediente, xcuentabcaria, xfechaemis, xfechavto1, xmontovto1, xfechavto2, xmontovto2, xidcredito, xidc, xtipo, xsucursal, xnumero: String; salida: char; xtipo_recibo, xnrotrans: String);
// Objetivo...: Listar Recibo
var
  i, ldet, items: Integer;
  codigobarra, fecha, hora: String;
  espacios_en_det, li, sep1, sep2, ms: Integer;
  difmontos: Real;
  archivo: TextFile;
Begin
  getFormatoImpresionBoletas;
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  if Length(Trim(margenIzq)) = 0 then margenIzq := '0';

  sep1      := formato_impresion.FieldByName('lineasdet').AsInteger;
  sep2      := formato_impresion.FieldByName('lineadiv').AsInteger;
  lineasdet := formato_impresion.FieldByName('lineassep').AsString;
  ms        := formato_impresion.FieldByName('margensup').AsInteger;

  For i := 1 to ms do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  list.derecha(95, list.Lineactual, '', ''{'ADR'}, 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  prestatario.getDatos(xcodprest);
  categoria.getDatos(xidcredito);

  // 1� Cuerpo
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'Prestatario: ' + xcodprest + '-' + xexpediente + '  ' + prestatario.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(75, list.Lineactual, 'Fecha: ' + xfechaemis, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'L�nea: ' + categoria.Items + ' ' + categoria.Descrip + ' - ' + categoria.DescripLinea, 1, 'Arial, normal, 9', salida, 'N');

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  difmontos := StrToFloat(xmontovto2) - StrToFloat(xmontovto1);
  excluirexpedientes.getDatosItems('01');
  codigobarra := excluirexpedientes.Ente + xcuentabcaria + Copy(xcodprest, 2, 4) + Copy(xexpediente, 3, 2) + Copy(xfechavto1, 7,2) + utiles.sLlenarIzquierda(utiles.setFechaJuliana(xfechavto1), 3, '0') + utiles.setMontoSinSignosDecimales(xmontovto1, 7) +
                 utiles.sLlenarIzquierda(excluirexpedientes.Intervalo, 2, '0') + utiles.setMontoSinSignosDecimales(FloatToStr(difmontos), 7);
  codigobarra := codigobarra + digitoverificador.setDigitoVerificador(codigobarra);

  AssignFile(archivo, 'c:\codigobarra.txt');
  Rewrite(archivo);
  WriteLn(archivo, codigobarra);
  closeFile(archivo);

  items := 0;
  For i := 1 to itbol do Begin
    if Length(Trim(mov[i, 1])) = 0 then Break;
    list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + mov[i, 2], 1, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', StrToFloat(mov[i, 3]), 2, 'Arial, normal, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    Inc(items);
  end;

  ldet := items;

  For i := ldet to StrToInt(lineasdet) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  List.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + '1� Vto.: ' + xfechavto1, 1, 'Arial, normal, 9', salida, 'N');
  list.importe(30, list.Lineactual, '', StrToFloat(xmontovto1), 2, 'Arial, normal, 9');
  list.Linea(50, list.Lineactual, '2� Vto.: ' + xfechavto2, 3, 'Arial, normal, 9', salida, 'N');
  list.importe(80, list.Lineactual, '', StrToFloat(xmontovto2), 4, 'Arial, normal, 9');
  list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

  List.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'N');
  List.Linea(2, list.Lineactual, '*' + codigobarra + '*', 2, 'IDAutomationCode39, normal, ' + fuentecb, salida, 'S');

  For i := 1 to sep1 do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  // 2� Cuerpo
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', '' {'Prestatario'}, 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  For i := 1 to StrToInt(lineassep) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'Prestatario: ' + xcodprest + '-' + xexpediente + '  ' + prestatario.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(75, list.Lineactual, 'Fecha: ' + utiles.setFechaActual, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'L�nea: ' + categoria.Items + ' ' + categoria.Descrip + ' - ' + categoria.DescripLinea, 1, 'Arial, normal, 9', salida, 'N');

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  items := 0;
  For i := 1 to itbol do Begin
    if Length(Trim(mov[i, 1])) = 0 then Break;
    list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + mov[i, 2], 1, 'Arial, normal, 8', salida, 'N');
    list.importe(90, list.Lineactual, '', StrToFloat(mov[i, 3]), 2, 'Arial, normal, 8');
    list.Linea(91, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    Inc(items);
  end;

  ldet := items;

  For i := ldet to StrToInt(lineasdet) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  List.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + '1� Vto.: ' + xfechavto1, 1, 'Arial, normal, 9', salida, 'N');
  list.importe(30, list.Lineactual, '', StrToFloat(xmontovto1), 2, 'Arial, normal, 9');
  list.Linea(50, list.Lineactual, '2� Vto.: ' + xfechavto2, 3, 'Arial, normal, 9', salida, 'N');
  list.importe(80, list.Lineactual, '', StrToFloat(xmontovto2), 4, 'Arial, normal, 9');
  list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

  For i := 1 to sep2 do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  // 3� Cuerpo
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', '' {'Banco'}, 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  For i := 1 to StrToInt(lineassep) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'Prestatario: ' + xcodprest + '-' + xexpediente + '  ' + prestatario.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(75, list.Lineactual, 'Fecha: ' + utiles.setFechaActual, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'L�nea: ' + categoria.Items + ' ' + categoria.Descrip + ' - ' + categoria.DescripLinea, 1, 'Arial, normal, 9', salida, 'N');

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  List.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + '1� Vto.: ' + xfechavto1, 1, 'Arial, normal, 9', salida, 'N');
  list.importe(30, list.Lineactual, '', StrToFloat(xmontovto1), 2, 'Arial, normal, 9');
  list.Linea(50, list.Lineactual, '2� Vto.: ' + xfechavto2, 3, 'Arial, normal, 9', salida, 'N');
  list.importe(80, list.Lineactual, '', StrToFloat(xmontovto2), 4, 'Arial, normal, 9');
  list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

  if xtipo_recibo <> 'NNN' then Begin
    fecha := utiles.setFechaActual;
    hora  := utiles.setHoraActual24;

    if (salida = 'I') and (Length(Trim(xnrotrans)) > 0) then Begin      // Rgistramos la transacci�n
      // Transferimos el Expediente Actualizado
      GuardarExpediente_WorkActualizado(xnrotrans, xcodprest, xexpediente);

      For i := 1 to itbol do Begin
        if Length(Trim(mov[i, 1])) = 0 then Break;
        boleta.RegistrarBoletaCodigoBarras(codigobarra, fecha, hora, xcodprest, expediente, xfechaemis, xfechavto1, xfechavto2, xcuentabcaria, StrToFloat(xmontovto1), StrToFloat(xmontovto2), mov[i, 1], mov[i, 2], xtipo_recibo, xidc, xtipo, xsucursal, xnumero, xnrotrans, StrToFloat(mov[i, 3]), items);
      end;
    end;
  end;

  list.FinList;
end;

procedure TTCreditos.ReimprimirRecibo(xcodigobarra, xfecha, xhora: String; salida: char);
// Obejtivo...: listar recibo
Begin
  boleta.getDatosBoletaCodigoBarras(xcodigobarra, xfecha, xhora);
  getDatos(boleta.codprest, boleta.expediente);
  ListarRecibo(boleta.codprest, boleta.expediente, boleta.ctactebcaria, boleta.fechaemis, boleta.fechavto1, FloatToStr(boleta.montovto1), boleta.fechavto2, FloatToStr(boleta.montovto2), credito.Idcredito, boleta.Idc, boleta.Tipo, boleta.Sucursal, boleta.Numero, salida, 'NNN', '');
end;

//------------------------------------------------------------------------------

procedure TTCreditos.ReiniciarExpediente_Work;
// Objetivo...: Reiniciar Expediente
Begin
  idanter_work := '';
end;

procedure TTCreditos.GuardarExpediente_Work(xcodprest, xexpediente: String);
// Objetivo...: Guardar un Registro temporal del Expediente
var
  creditos_detsql: TQuery;
  i: integer;
Begin
  if codigobarras then Begin
    if xcodprest + xexpediente <> idanter_work then Begin
      if (credito.Refinanciado <> 'S') and (credito.RefinanciaCuota <> 'S') then creditos_detwork := datosdb.openDB('creditos_detwork', '');
      if (credito.Refinanciado = 'S') then creditos_detwork := datosdb.openDB('creditos_detwork_ref', '');
      if (credito.RefinanciaCuota = 'S') then creditos_detwork := datosdb.openDB('creditos_detwork_refcuotas', '');

      creditos_detwork.Open;
      datosdb.tranSQL('delete from ' + creditos_detwork.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
      datosdb.refrescar(creditos_detwork);

      if (credito.Refinanciado <> 'S') and (credito.RefinanciaCuota <> 'S') then creditos_detsql := datosdb.tranSQL('select * from creditos_det where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
      if (credito.Refinanciado = 'S') then creditos_detsql := datosdb.tranSQL('select * from creditos_detrefinanciados where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
      if (credito.RefinanciaCuota = 'S') then creditos_detsql := datosdb.tranSQL('select * from creditos_detrefcuotas where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');

      creditos_detsql.Open;
      while not creditos_detsql.Eof do Begin
        if datosdb.Buscar(creditos_detwork, 'codprest', 'expediente', 'items', 'recibo', creditos_detsql.FieldByName('codprest').AsString, creditos_detsql.FieldByName('expediente').AsString, creditos_detsql.FieldByName('items').AsString, creditos_detsql.FieldByName('recibo').AsString) then creditos_detwork.Edit else creditos_detwork.Append;
        creditos_detwork.FieldByName('codprest').AsString    := creditos_detsql.FieldByName('codprest').AsString;
        creditos_detwork.FieldByName('expediente').AsString  := creditos_detsql.FieldByName('expediente').AsString;
        creditos_detwork.FieldByName('items').AsString       := creditos_detsql.FieldByName('items').AsString;
        creditos_detwork.FieldByName('recibo').AsString      := creditos_detsql.FieldByName('recibo').AsString;
        creditos_detwork.FieldByName('concepto').AsString    := creditos_detsql.FieldByName('concepto').AsString;
        creditos_detwork.FieldByName('amortizacion').AsFloat := creditos_detsql.FieldByName('amortizacion').AsFloat;
        creditos_detwork.FieldByName('aporte').AsFloat       := creditos_detsql.FieldByName('aporte').AsFloat;
        creditos_detwork.FieldByName('total').AsFloat        := creditos_detsql.FieldByName('total').AsFloat;
        creditos_detwork.FieldByName('fechavto').AsString    := creditos_detsql.FieldByName('fechavto').AsString;
        creditos_detwork.FieldByName('saldo').AsFloat        := creditos_detsql.FieldByName('saldo').AsFloat;
        creditos_detwork.FieldByName('saldocuota').AsFloat   := creditos_detsql.FieldByName('saldocuota').AsFloat;
        creditos_detwork.FieldByName('tipomov').AsInteger    := creditos_detsql.FieldByName('tipomov').AsInteger;
        creditos_detwork.FieldByName('refpago').AsString     := creditos_detsql.FieldByName('refpago').AsString;
        creditos_detwork.FieldByName('estado').AsString      := creditos_detsql.FieldByName('estado').AsString;
        creditos_detwork.FieldByName('interes').AsFloat      := creditos_detsql.FieldByName('interes').AsFloat;
        creditos_detwork.FieldByName('indice').AsFloat       := creditos_detsql.FieldByName('indice').AsFloat;
        creditos_detwork.FieldByName('refinancia').AsString  := creditos_detsql.FieldByName('refinancia').AsString;
        if datosdb.verificarSiExisteCampo(creditos_det, 'fecharef') then creditos_detwork.FieldByName('fecharef').AsString    := creditos_detsql.FieldByName('fecharef').AsString;
        creditos_detwork.FieldByName('cuotasref').AsString   := creditos_detsql.FieldByName('cuotasref').AsString;
        creditos_detwork.FieldByName('refcredito').AsString  := creditos_detsql.FieldByName('refcredito').AsString;
        creditos_detwork.FieldByName('descuento').AsFloat    := creditos_detsql.FieldByName('descuento').AsFloat;
        creditos_detwork.FieldByName('tasaint').AsFloat      := creditos_detsql.FieldByName('tasaint').AsFloat;
        creditos_detwork.FieldByName('montoint').AsFloat     := creditos_detsql.FieldByName('montoint').AsFloat;
        creditos_detwork.FieldByName('fechapago').AsString   := creditos_detsql.FieldByName('fechapago').AsString;
        creditos_detwork.FieldByName('nrotrans').AsString    := creditos_detsql.FieldByName('nrotrans').AsString;
        try
          creditos_detwork.Post
         except
          creditos_detwork.Cancel
        end;
        creditos_detsql.Next;
      end;
      creditos_detsql.Close;
      creditos_detsql.Destroy; creditos_detsql := Nil;
      datosdb.closedb(creditos_detwork);

      idanter_work := xcodprest + xexpediente;
    end;
  end;
end;

procedure TTCreditos.RestaurarExpediente_Work(xcodprest, xexpediente: String);
// Objetivo...: Restaurar un Registro del Almacenamiento Temporal
var
  creditos_detw: TTable;
Begin
  if codigobarras then Begin
    if (credito.Refinanciado <> 'S') and (credito.RefinanciaCuota <> 'S') then creditos_detwork := datosdb.openDB('creditos_detwork', '');
    if (credito.Refinanciado = 'S') then creditos_detwork := datosdb.openDB('creditos_detwork_ref', '');
    if (credito.RefinanciaCuota = 'S') then creditos_detwork := datosdb.openDB('creditos_detwork_refcuotas', '');

    creditos_detwork.Open;
    datosdb.Filtrar(creditos_detwork, 'codprest = ' + '''' + xcodprest + '''' + ' AND expediente = ' + '''' + xexpediente + '''');
    if creditos_detwork.RecordCount > 0 then Begin

      if (credito.Refinanciado <> 'S') and (credito.RefinanciaCuota <> 'S') then creditos_detw := creditos_det;
      if (credito.Refinanciado = 'S') then creditos_detw := creditos_detrefinanciados;
      if (credito.RefinanciaCuota = 'S') then creditos_detw := creditos_detrefcuotas;

      datosdb.closeDB(creditos_detw);
      datosdb.tranSQL('delete from ' + creditos_detw.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
      creditos_detw.Open;
      creditos_detwork.First;
      while not creditos_detwork.Eof do Begin
        if datosdb.Buscar(creditos_detw, 'codprest', 'expediente', 'items', 'recibo', creditos_detwork.FieldByName('codprest').AsString, creditos_detwork.FieldByName('expediente').AsString, creditos_detwork.FieldByName('items').AsString, creditos_detwork.FieldByName('recibo').AsString) then creditos_detw.Edit else creditos_detw.Append;
        creditos_detw.FieldByName('codprest').AsString    := creditos_detwork.FieldByName('codprest').AsString;
        creditos_detw.FieldByName('expediente').AsString  := creditos_detwork.FieldByName('expediente').AsString;
        creditos_detw.FieldByName('items').AsString       := creditos_detwork.FieldByName('items').AsString;
        creditos_detw.FieldByName('recibo').AsString      := creditos_detwork.FieldByName('recibo').AsString;
        creditos_detw.FieldByName('concepto').AsString    := creditos_detwork.FieldByName('concepto').AsString;
        creditos_detw.FieldByName('amortizacion').AsFloat := creditos_detwork.FieldByName('amortizacion').AsFloat;
        creditos_detw.FieldByName('aporte').AsFloat       := creditos_detwork.FieldByName('aporte').AsFloat;
        creditos_detw.FieldByName('total').AsFloat        := creditos_detwork.FieldByName('total').AsFloat;
        creditos_detw.FieldByName('fechavto').AsString    := creditos_detwork.FieldByName('fechavto').AsString;
        creditos_detw.FieldByName('saldo').AsFloat        := creditos_detwork.FieldByName('saldo').AsFloat;
        creditos_detw.FieldByName('saldocuota').AsFloat   := creditos_detwork.FieldByName('saldocuota').AsFloat;
        creditos_detw.FieldByName('tipomov').AsInteger    := creditos_detwork.FieldByName('tipomov').AsInteger;
        creditos_detw.FieldByName('refpago').AsString     := creditos_detwork.FieldByName('refpago').AsString;
        creditos_detw.FieldByName('estado').AsString      := creditos_detwork.FieldByName('estado').AsString;
        creditos_detw.FieldByName('interes').AsFloat      := creditos_detwork.FieldByName('interes').AsFloat;
        creditos_detw.FieldByName('indice').AsFloat       := creditos_detwork.FieldByName('indice').AsFloat;
        creditos_detw.FieldByName('refinancia').AsString  := creditos_detwork.FieldByName('refinancia').AsString;
        if datosdb.verificarSiExisteCampo(creditos_detwork, 'fecharef') then creditos_detw.FieldByName('fecharef').AsString    := creditos_detwork.FieldByName('fecharef').AsString;
        creditos_detw.FieldByName('cuotasref').AsString   := creditos_detwork.FieldByName('cuotasref').AsString;
        creditos_detw.FieldByName('refcredito').AsString  := creditos_detwork.FieldByName('refcredito').AsString;
        creditos_detw.FieldByName('descuento').AsFloat    := creditos_detwork.FieldByName('descuento').AsFloat;
        creditos_detw.FieldByName('tasaint').AsFloat      := creditos_detwork.FieldByName('tasaint').AsFloat;
        creditos_detw.FieldByName('montoint').AsFloat     := creditos_detwork.FieldByName('montoint').AsFloat;
        creditos_detw.FieldByName('fechapago').AsString   := creditos_detwork.FieldByName('fechapago').AsString;
        try
          creditos_detw.Post
         except
          creditos_detw.Cancel
        end;
        creditos_detwork.Next;
      end;

      datosdb.closedb(creditos_detw); creditos_detw.Open;
    end;
  end;
end;

procedure TTCreditos.GuardarExpediente_WorkActualizado(xnrotrans, xcodprest, xexpediente: String);
// Objetivo...: Guardar un Registro temporal del Expediente Actualizado
var
  creditos_detsql: TQuery;
  i: integer;
Begin
  if (codigobarras) and (Length(Trim(xnrotrans)) > 0) then Begin
    creditos_detwork := datosdb.openDB('creditos_det_cb', '');
    creditos_detwork.Open;
    datosdb.tranSQL('delete from ' + creditos_detwork.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + ''''); // ' and nrotrans = ' + '''' + xnrotrans + '''');
    datosdb.refrescar(creditos_detwork);

    if (credito.Refinanciado <> 'S') and (credito.RefinanciaCuota <> 'S') then creditos_detsql := datosdb.tranSQL('select * from creditos_det where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + ''''); // + ' and nrotrans = ' + '''' + xnrotrans + '''');
    if (credito.Refinanciado = 'S') then creditos_detsql := datosdb.tranSQL('select * from creditos_detrefinanciados where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + ''''); // + ' and nrotrans = ' + '''' + xnrotrans + '''');
    if (credito.RefinanciaCuota = 'S') then creditos_detsql := datosdb.tranSQL('select * from creditos_detrefcuotas where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + ''''); // + ' and nrotrans = ' + '''' + xnrotrans + '''');

    creditos_detsql.Open;
    while not creditos_detsql.Eof do Begin
      if datosdb.Buscar(creditos_detwork, 'nrotrans', 'codprest', 'expediente', 'items', 'recibo', xnrotrans, creditos_detsql.FieldByName('codprest').AsString, creditos_detsql.FieldByName('expediente').AsString, creditos_detsql.FieldByName('items').AsString, creditos_detsql.FieldByName('recibo').AsString) then creditos_detwork.Edit else creditos_detwork.Append;
      creditos_detwork.FieldByName('nrotrans').AsString    := xnrotrans;
      creditos_detwork.FieldByName('codprest').AsString    := creditos_detsql.FieldByName('codprest').AsString;
      creditos_detwork.FieldByName('expediente').AsString  := creditos_detsql.FieldByName('expediente').AsString;
      creditos_detwork.FieldByName('items').AsString       := creditos_detsql.FieldByName('items').AsString;
      creditos_detwork.FieldByName('recibo').AsString      := creditos_detsql.FieldByName('recibo').AsString;
      creditos_detwork.FieldByName('concepto').AsString    := creditos_detsql.FieldByName('concepto').AsString;
      creditos_detwork.FieldByName('amortizacion').AsFloat := creditos_detsql.FieldByName('amortizacion').AsFloat;
      creditos_detwork.FieldByName('aporte').AsFloat       := creditos_detsql.FieldByName('aporte').AsFloat;
      creditos_detwork.FieldByName('total').AsFloat        := creditos_detsql.FieldByName('total').AsFloat;
      creditos_detwork.FieldByName('fechavto').AsString    := creditos_detsql.FieldByName('fechavto').AsString;
      creditos_detwork.FieldByName('saldo').AsFloat        := creditos_detsql.FieldByName('saldo').AsFloat;
      creditos_detwork.FieldByName('saldocuota').AsFloat   := creditos_detsql.FieldByName('saldocuota').AsFloat;
      creditos_detwork.FieldByName('tipomov').AsInteger    := creditos_detsql.FieldByName('tipomov').AsInteger;
      creditos_detwork.FieldByName('refpago').AsString     := creditos_detsql.FieldByName('refpago').AsString;
      creditos_detwork.FieldByName('estado').AsString      := creditos_detsql.FieldByName('estado').AsString;
      creditos_detwork.FieldByName('interes').AsFloat      := creditos_detsql.FieldByName('interes').AsFloat;
      creditos_detwork.FieldByName('indice').AsFloat       := creditos_detsql.FieldByName('indice').AsFloat;
      creditos_detwork.FieldByName('refinancia').AsString  := creditos_detsql.FieldByName('refinancia').AsString;
      if datosdb.verificarSiExisteCampo(creditos_det, 'fecharef') then creditos_detwork.FieldByName('fecharef').AsString    := creditos_detsql.FieldByName('fecharef').AsString;
      creditos_detwork.FieldByName('cuotasref').AsString   := creditos_detsql.FieldByName('cuotasref').AsString;
      creditos_detwork.FieldByName('refcredito').AsString  := creditos_detsql.FieldByName('refcredito').AsString;
      creditos_detwork.FieldByName('descuento').AsFloat    := creditos_detsql.FieldByName('descuento').AsFloat;
      creditos_detwork.FieldByName('tasaint').AsFloat      := creditos_detsql.FieldByName('tasaint').AsFloat;
      creditos_detwork.FieldByName('montoint').AsFloat     := creditos_detsql.FieldByName('montoint').AsFloat;
      creditos_detwork.FieldByName('fechapago').AsString   := creditos_detsql.FieldByName('fechapago').AsString;
      try
        creditos_detwork.Post
       except
        creditos_detwork.Cancel
      end;
      creditos_detsql.Next;
    end;
    creditos_detsql.Close;
    creditos_detsql.Destroy; creditos_detsql := Nil;
    datosdb.closedb(creditos_detwork);

    idanter_work := xcodprest + xexpediente;
  end;
end;

procedure TTCreditos.RestaurarExpediente_WorkActualizado(xnrotrans, xcodigobarra, xfecha, xhora, xcodprest, xexpediente, xfechaliq, ximput: String);
// Objetivo...: Restaurar un Registro Actualizado del Almacenamiento Temporal
var
  creditos_detw: TTable;
Begin
  if (codigobarras) and (Length(Trim(xnrotrans)) > 0) then Begin

    getDatos(xcodprest, xexpediente);  // Cargamos el Expediente
    creditos_detwork := datosdb.openDB('creditos_det_cb', '');
    creditos_detwork.Open;
    datosdb.Filtrar(creditos_detwork, 'nrotrans = ' + '''' + xnrotrans  + '''' + ' and codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');

    if creditos_detwork.RecordCount > 0 then Begin
      if (credito.Refinanciado <> 'S') and (credito.RefinanciaCuota <> 'S') then creditos_detw := creditos_det;
      if (credito.Refinanciado = 'S') then creditos_detw := creditos_detrefinanciados;
      if (credito.RefinanciaCuota = 'S') then creditos_detw := creditos_detrefcuotas;

      datosdb.tranSQL('delete from ' + creditos_detw.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');  /// + ' and nrotrans = ' + '''' + xnrotrans + '''');
      datosdb.closeDB(creditos_detw); creditos_detw.Open;

      creditos_detwork.First;
      while not creditos_detwork.Eof do Begin
        if datosdb.Buscar(creditos_detw, 'codprest', 'expediente', 'items', 'recibo', creditos_detwork.FieldByName('codprest').AsString, creditos_detwork.FieldByName('expediente').AsString, creditos_detwork.FieldByName('items').AsString, creditos_detwork.FieldByName('recibo').AsString) then creditos_detw.Edit else creditos_detw.Append;
        creditos_detw.FieldByName('codprest').AsString    := creditos_detwork.FieldByName('codprest').AsString;
        creditos_detw.FieldByName('expediente').AsString  := creditos_detwork.FieldByName('expediente').AsString;
        creditos_detw.FieldByName('items').AsString       := creditos_detwork.FieldByName('items').AsString;
        creditos_detw.FieldByName('recibo').AsString      := creditos_detwork.FieldByName('recibo').AsString;
        creditos_detw.FieldByName('concepto').AsString    := creditos_detwork.FieldByName('concepto').AsString;
        creditos_detw.FieldByName('amortizacion').AsFloat := creditos_detwork.FieldByName('amortizacion').AsFloat;
        creditos_detw.FieldByName('aporte').AsFloat       := creditos_detwork.FieldByName('aporte').AsFloat;
        creditos_detw.FieldByName('total').AsFloat        := creditos_detwork.FieldByName('total').AsFloat;
        creditos_detw.FieldByName('fechavto').AsString    := creditos_detwork.FieldByName('fechavto').AsString;
        creditos_detw.FieldByName('saldo').AsFloat        := creditos_detwork.FieldByName('saldo').AsFloat;
        creditos_detw.FieldByName('saldocuota').AsFloat   := creditos_detwork.FieldByName('saldocuota').AsFloat;
        creditos_detw.FieldByName('tipomov').AsInteger    := creditos_detwork.FieldByName('tipomov').AsInteger;
        creditos_detw.FieldByName('refpago').AsString     := creditos_detwork.FieldByName('refpago').AsString;
        creditos_detw.FieldByName('estado').AsString      := creditos_detwork.FieldByName('estado').AsString;
        creditos_detw.FieldByName('interes').AsFloat      := creditos_detwork.FieldByName('interes').AsFloat;
        creditos_detw.FieldByName('indice').AsFloat       := creditos_detwork.FieldByName('indice').AsFloat;
        creditos_detw.FieldByName('refinancia').AsString  := creditos_detwork.FieldByName('refinancia').AsString;
        if datosdb.verificarSiExisteCampo(creditos_detwork, 'fecharef') then creditos_detw.FieldByName('fecharef').AsString    := creditos_detwork.FieldByName('fecharef').AsString;
        creditos_detw.FieldByName('cuotasref').AsString   := creditos_detwork.FieldByName('cuotasref').AsString;
        creditos_detw.FieldByName('refcredito').AsString  := creditos_detwork.FieldByName('refcredito').AsString;
        creditos_detw.FieldByName('descuento').AsFloat    := creditos_detwork.FieldByName('descuento').AsFloat;
        creditos_detw.FieldByName('tasaint').AsFloat      := creditos_detwork.FieldByName('tasaint').AsFloat;
        creditos_detw.FieldByName('montoint').AsFloat     := creditos_detwork.FieldByName('montoint').AsFloat;
        creditos_detw.FieldByName('fechapago').AsString   := creditos_detwork.FieldByName('fechapago').AsString;
        creditos_detw.FieldByName('nrotrans').AsString    := xnrotrans;
        try
          creditos_detw.Post
         except
          creditos_detw.Cancel
        end;

        // Marcamos como Transferido
        creditos_detwork.Edit;
        creditos_detwork.FieldByName('transf').AsString := 'S';
        try
          creditos_detwork.Post
         except
          creditos_detwork.Cancel
        end;

        creditos_detwork.Next;
      end;

      // a partir de aca verificar por el campo transf si la cuota esta o no saldada
      {creditos_detwork.First;
      while not creditos_detwork.Eof do Begin
        if (creditos_detwork.FieldByName('transf').AsString = 'S') and (creditos_detwork.FieldByName('estado').AsString = 'P') then Begin
          // Marcamos la Cuota como Pagada
          if datosdb.Buscar(creditos_detw, 'codprest', 'expediente', 'items', 'recibo', creditos_detwork.FieldByName('codprest').AsString, creditos_detwork.FieldByName('expediente').AsString, creditos_detwork.FieldByName('items').AsString, creditos_detwork.FieldByName('recibo').AsString) then Begin
            creditos_detw.Edit;
            creditos_detw.FieldByName('estado').AsString := creditos_detwork.FieldByName('estado').AsString;
            creditos_detw.FieldByName('saldo').AsFloat   := creditos_detwork.FieldByName('saldo').AsFloat;
            try
              creditos_detw.Post
             except
              creditos_detw.Cancel
            end;
          end;
        end;
        creditos_detwork.Next;
      end;}

      datosdb.closedb(creditos_detw); creditos_detw.Open;
      datosdb.closedb(creditos_detwork);

      // Marcamos la Boleta como Liquidada
      boleta.MarcarBoletaComoPaga(xcodigobarra, xfecha, xhora, xfechaliq, ximput);

    end;
  end;
end;

procedure TTCreditos.RestaurarExpediente_WorkActualizado_Temporalmente(xcodprest, xexpediente: String);
// Objetivo...: Restaurar un Registro Actualizado del Almacenamiento Temporal para cuando hay que liquidar una cuota y todavia no se pago la anterior
// esto restaura la ultima instancia
var
  ultimainst: String;
  creditos_detw: TTable;
Begin
  if (codigobarras) then Begin

    getDatos(xcodprest, xexpediente);  // Cargamos el Expediente

    creditos_detwork := datosdb.openDB('creditos_det_cb', '');
    creditos_detwork.Open;
    datosdb.Filtrar(creditos_detwork, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');

    // Recuperamos la Instancia mas reciente
    while not creditos_detwork.Eof do Begin
      if creditos_detwork.FieldByName('nrotrans').AsString > ultimainst then ultimainst := creditos_detwork.FieldByName('nrotrans').AsString;
      creditos_detwork.Next;
    end;

    // Ahora la restauramos
    datosdb.QuitarFiltro(creditos_detwork);
    datosdb.Filtrar(creditos_detwork, 'nrotrans = ' + '''' + ultimainst + '''' +  ' and codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
    creditos_detwork.First;

    if creditos_detwork.RecordCount > 0 then Begin
      if (credito.Refinanciado <> 'S') and (credito.RefinanciaCuota <> 'S') then creditos_detw := creditos_det;
      if (credito.Refinanciado = 'S') then creditos_detw := creditos_detrefinanciados;
      if (credito.RefinanciaCuota = 'S') then creditos_detw := creditos_detrefcuotas;

      datosdb.closeDB(creditos_detw);
      datosdb.tranSQL('delete from ' + creditos_detw.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''' + ' and nrotrans = ' + '''' + ultimainst + '''');
      creditos_detw.Open;

      creditos_detwork.First;
      while not creditos_detwork.Eof do Begin
        if datosdb.Buscar(creditos_detw, 'codprest', 'expediente', 'items', 'recibo', creditos_detwork.FieldByName('codprest').AsString, creditos_detwork.FieldByName('expediente').AsString, creditos_detwork.FieldByName('items').AsString, creditos_detwork.FieldByName('recibo').AsString) then creditos_detw.Edit else creditos_detw.Append;
        creditos_detw.FieldByName('codprest').AsString    := creditos_detwork.FieldByName('codprest').AsString;
        creditos_detw.FieldByName('expediente').AsString  := creditos_detwork.FieldByName('expediente').AsString;
        creditos_detw.FieldByName('items').AsString       := creditos_detwork.FieldByName('items').AsString;
        creditos_detw.FieldByName('recibo').AsString      := creditos_detwork.FieldByName('recibo').AsString;
        creditos_detw.FieldByName('concepto').AsString    := creditos_detwork.FieldByName('concepto').AsString;
        creditos_detw.FieldByName('amortizacion').AsFloat := creditos_detwork.FieldByName('amortizacion').AsFloat;
        creditos_detw.FieldByName('aporte').AsFloat       := creditos_detwork.FieldByName('aporte').AsFloat;
        creditos_detw.FieldByName('total').AsFloat        := creditos_detwork.FieldByName('total').AsFloat;
        creditos_detw.FieldByName('fechavto').AsString    := creditos_detwork.FieldByName('fechavto').AsString;
        creditos_detw.FieldByName('saldo').AsFloat        := creditos_detwork.FieldByName('saldo').AsFloat;
        creditos_detw.FieldByName('saldocuota').AsFloat   := creditos_detwork.FieldByName('saldocuota').AsFloat;
        creditos_detw.FieldByName('tipomov').AsInteger    := creditos_detwork.FieldByName('tipomov').AsInteger;
        creditos_detw.FieldByName('refpago').AsString     := creditos_detwork.FieldByName('refpago').AsString;
        creditos_detw.FieldByName('estado').AsString      := creditos_detwork.FieldByName('estado').AsString;
        creditos_detw.FieldByName('interes').AsFloat      := creditos_detwork.FieldByName('interes').AsFloat;
        creditos_detw.FieldByName('indice').AsFloat       := creditos_detwork.FieldByName('indice').AsFloat;
        creditos_detw.FieldByName('refinancia').AsString  := creditos_detwork.FieldByName('refinancia').AsString;
        if datosdb.verificarSiExisteCampo(creditos_detwork, 'fecharef') then creditos_detw.FieldByName('fecharef').AsString    := creditos_detwork.FieldByName('fecharef').AsString;
        creditos_detw.FieldByName('cuotasref').AsString   := creditos_detwork.FieldByName('cuotasref').AsString;
        creditos_detw.FieldByName('refcredito').AsString  := creditos_detwork.FieldByName('refcredito').AsString;
        creditos_detw.FieldByName('descuento').AsFloat    := creditos_detwork.FieldByName('descuento').AsFloat;
        creditos_detw.FieldByName('tasaint').AsFloat      := creditos_detwork.FieldByName('tasaint').AsFloat;
        creditos_detw.FieldByName('montoint').AsFloat     := creditos_detwork.FieldByName('montoint').AsFloat;
        creditos_detw.FieldByName('fechapago').AsString   := creditos_detwork.FieldByName('fechapago').AsString;
        creditos_detw.FieldByName('nrotrans').AsString    := ultimainst;
        try
          creditos_detw.Post
         except
          creditos_detw.Cancel
        end;
        creditos_detwork.Next;
      end;

      datosdb.closedb(creditos_detw); creditos_detw.Open;
      datosdb.closedb(creditos_detwork);

    end;
  end;
end;

//------------------------------------------------------------------------------

function  TTCreditos.BuscarTF(xcodprest, xexpediente, xtransaccion: String): Boolean;
// Objetivo...: Buscar Instancia
Begin
  if creditos_det_tf.IndexFieldNames <> 'Codprest;Expediente;Transaccion' then creditos_det_tf.IndexFieldNames := 'Codprest;Expediente;Transaccion';
  Result := datosdb.Buscar(creditos_det_tf, 'codprest', 'expediente', 'transaccion', xcodprest, xexpediente, xtransaccion);
end;

procedure TTCreditos.RegistrarTF(xcodprest, xexpediente, xtransaccion, xitems, xrecibo, xitems_recibo: String; xcapital, xamortizacion, xinteres, xpunitorio, xmontocuota: Real; xestado: String);
// Objetivo...: Guardar Instancia
var
  amort, totpagos: Real;
Begin
  if BuscarTF(xcodprest, xexpediente, xtransaccion) then creditos_det_tf.Edit else creditos_det_tf.Append;
  creditos_det_tf.FieldByName('codprest').AsString    := xcodprest;
  creditos_det_tf.FieldByName('expediente').AsString  := xexpediente;
  creditos_det_tf.FieldByName('transaccion').AsString := xtransaccion;
  creditos_det_tf.FieldByName('items').AsString       := xitems;
  creditos_det_tf.FieldByName('capital').AsFloat      := xcapital;
  creditos_det_tf.FieldByName('amortizacion').AsFloat := xamortizacion;
  creditos_det_tf.FieldByName('interes').AsFloat      := xinteres;
  creditos_det_tf.FieldByName('punitorio').AsFloat    := xpunitorio;
  creditos_det_tf.FieldByName('montocuota').AsFloat   := xmontocuota;
  creditos_det_tf.FieldByName('estado').AsString      := xestado;
  try
    creditos_det_tf.Post
   except
    creditos_det_tf.Cancel
  end;
  datosdb.closeDB(creditos_det_tf); creditos_det_tf.Open;

  // Vemos si marcamos o no la cuota como paga
  if Buscar(xcodprest, xexpediente, xitems, '-') then Begin
    if xestado = 'P' then Begin    // Pendiente
      //amort := detcred.FieldByName('amortizacion').AsFloat;

      // Calculamos el saldo de la Cuota -> Amortizacion - los pagos parciales
      datosdb.Filtrar(creditos_det_tf, 'codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''' + ' and items = ' + '''' + xitems + '''');
      creditos_det_tf.First; totpagos := 0;
      while not creditos_det_tf.Eof do Begin
        //totpagos := totpagos +  creditos_det_tf.FieldByName('capital').AsFloat;
        totpagos := totpagos + (creditos_det_tf.FieldByName('montocuota').AsFloat - creditos_det_tf.FieldByName('capital').AsFloat);
        creditos_det_tf.Next;
      end;
      datosdb.QuitarFiltro(creditos_det_tf);

      // Modificamos el saldo de la Cuota
      detcred.Edit;
      if xinteres > 0 then detcred.FieldByName('aporte').AsFloat := xinteres;   // Interes flotante
      detcred.FieldByName('amortizacion').AsFloat := totpagos;
      detcred.FieldByName('saldocuota').AsFloat   := totpagos;
      detcred.FieldByName('total').AsFloat        := totpagos; //amort - totpagos;
      detcred.FieldByName('estado').AsString      := 'I';
      try
        detcred.Post
       except
        detcred.Cancel
      end;
      datosdb.closeDB(detcred); detcred.Open;

    end;
  end;

  ControlarSaldoTF(xcodprest, xexpediente, xitems);
end;

procedure TTCreditos.getDatosTF(xcodprest, xexpediente, xtransaccion: String);
// Objetivo...: Buscar Instancia
Begin
  if BuscarTF(xcodprest, xexpediente, xtransaccion) then Begin
    codpresttf     := creditos_det_tf.FieldByName('codprest').AsString;
    expedientetf   := creditos_det_tf.FieldByName('expediente').AsString;
    transacciontf  := creditos_det_tf.FieldByName('transaccion').AsString;
    capitaltf      := creditos_det_tf.FieldByName('capital').AsFloat;
    amortizaciontf := creditos_det_tf.FieldByName('amortizacion').AsFloat;
    interestf      := creditos_det_tf.FieldByName('interes').AsFloat;
    punitoriotf    := creditos_det_tf.FieldByName('punitorio').AsFloat;
    estadotf       := creditos_det_tf.FieldByName('estado').AsString;
  end else Begin
    codpresttf := ''; expedientetf := ''; transacciontf := ''; capitaltf := 0; amortizaciontf := 0; interestf := 0; punitoriotf := 0; estadotf := '';
  end;
end;

procedure TTCreditos.BorrarTF(xcodprest, xexpediente, xtransaccion, xitems, xit1, xcuota_amortizacion: String);
// Objetivo...: Borrar Instancia
var
  tc, tp, ap: Real;
  borrado: Boolean;
Begin
  // Valor total de la cuota
  datosdb.Filtrar(creditos_det_tf, 'Codprest = ' + '''' + xcodprest + '''' + ' and Expediente = ' + '''' + xexpediente + '''' + ' and Items = ' + '''' + xitems + '''');
  creditos_det_tf.First; tc := 0;
  while not creditos_det_tf.Eof do Begin
    tc := tc + creditos_det_tf.FieldByName('montocuota').AsFloat;
    creditos_det_tf.Next;
  end;
  datosdb.QuitarFiltro(creditos_det_tf);

  if BuscarTF(xcodprest, xexpediente, xtransaccion) then Begin
    creditos_det_tf.Delete;  // Eliminamos
    datosdb.closeDB(creditos_det_tf); creditos_det_tf.Open;
    borrado := True;
  end;

  // Recontamos el resto
  datosdb.Filtrar(creditos_det_tf, 'Codprest = ' + '''' + xcodprest + '''' + ' and Expediente = ' + '''' + xexpediente + '''' + ' and Items = ' + '''' + xitems + '''');
  creditos_det_tf.First; tp := 0;
  while not creditos_det_tf.Eof do Begin
    tp := tp + creditos_det_tf.FieldByName('capital').AsFloat;
    ap := ap + creditos_det_tf.FieldByName('interes').AsFloat;
    creditos_det_tf.Next;
  end;
  datosdb.closeDB(creditos_det_tf); creditos_det_tf.Open;

  if borrado then Begin  //
  if Buscar(xcodprest, xexpediente, xitems, '-') then Begin   // Restablecemos el estado anterior
    detcred.Edit;
    detcred.FieldByName('amortizacion').AsFloat := tc - tp;
    detcred.FieldByName('aporte').AsFloat       := ap;
    detcred.FieldByName('saldocuota').AsFloat   := tc - tp;
    detcred.FieldByName('total').AsFloat        := tc - tp;
    detcred.FieldByName('estado').AsString      := 'I';
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;

  if borrado then Begin   // Actualiza en el items de cobro, el monto del capital, en el primer pago :: 14/11/2007
    if Buscar(xcodprest, xexpediente, xit1, xcuota_amortizacion) then Begin
      detcred.Edit;
      detcred.FieldByName('montoint').AsFloat := ap;
      try
        detcred.Post
       except
        detcred.Cancel
      end;
      datosdb.closeDB(detcred); detcred.Open;
    end;
  end;
  end;
end;

function TTCreditos.VerificarPagosTF(xcodprest, xexpediente, xitems: String): Boolean;
// Objetivo...: Verificar Instancia Pagos
Begin
  if creditos_det_tf.IndexFieldNames <> 'Codprest;Expediente;Items' then creditos_det_tf.IndexFieldNames := 'Codprest;Expediente;Items';
  Result := datosdb.Buscar(creditos_det_tf, 'codprest', 'expediente', 'items', xcodprest, xexpediente, xitems);
  creditos_det_tf.IndexFieldNames := 'Codprest;Expediente;Transaccion';
end;

function TTCreditos.SetTotalPagosTF(xcodprest, xexpediente, xitems: String): Real;
// Objetivo...: Borrar Instancia
var
  mc: real;
Begin
  datosdb.Filtrar(creditos_det_tf, 'Codprest = ' + '''' + xcodprest + '''' + ' and Expediente = ' + '''' + xexpediente + '''' + ' and Items = ' + '''' + xitems + '''');
  creditos_det_tf.First; mc := 0;
  while not creditos_det_tf.Eof do Begin
    mc := mc + (creditos_det_tf.FieldByName('montocuota').AsFloat - creditos_det_tf.FieldByName('capital').AsFloat);
    creditos_det_tf.Next;
  end;
  datosdb.QuitarFiltro(creditos_det_tf);
  Result := mc;
end;

procedure TTCreditos.ControlarSaldoTF(xcodprest, xexpediente, xitems: String);
// Objetivo...: Borrar Instancia
var
  mc, tc, int: real;
Begin
  datosdb.Filtrar(creditos_det_tf, 'Codprest = ' + '''' + xcodprest + '''' + ' and Expediente = ' + '''' + xexpediente + '''' + ' and Items = ' + '''' + xitems + '''');
  creditos_det_tf.First; mc := 0; tc := 0; int := 0;
  while not creditos_det_tf.Eof do Begin
    tc  := tc  + creditos_det_tf.FieldByName('montocuota').AsFloat;
    mc  := mc  + creditos_det_tf.FieldByName('capital').AsFloat;
    int := int + creditos_det_tf.FieldByName('interes').AsFloat;
    creditos_det_tf.Next;
  end;
  datosdb.QuitarFiltro(creditos_det_tf);

  if Buscar(xcodprest, xexpediente, xitems, '-') then Begin   // Restablecemos el estado anterior
    detcred.Edit;
    detcred.FieldByName('aporte').AsFloat := int;
    if tc = mc then Begin
      detcred.FieldByName('amortizacion').AsFloat := tc;
      detcred.FieldByName('saldocuota').AsFloat   := 0;
      detcred.FieldByName('total').AsFloat        := tc;  // ver
      detcred.FieldByName('estado').AsString      := 'P';
    end else
      detcred.FieldByName('estado').AsString      := 'I';
    try
      detcred.Post
     except
      detcred.Cancel
    end;
    datosdb.closeDB(detcred); detcred.Open;
  end;
end;

function TTCreditos.SetSaldoOriginalTF(xcodprest, xexpediente, xitems: String): Real;
// Objetivo...: Devolver Saldo Actual
var
  mc: real;
Begin
  datosdb.Filtrar(creditos_det_tf, 'Codprest = ' + '''' + xcodprest + '''' + ' and Expediente = ' + '''' + xexpediente + '''' + ' and Items = ' + '''' + xitems + '''');
  creditos_det_tf.First; mc := 0;
  while not creditos_det_tf.Eof do Begin
    mc := mc + creditos_det_tf.FieldByName('montocuota').AsFloat;
    creditos_det_tf.Next;
  end;
  datosdb.QuitarFiltro(creditos_det_tf);
  Result := mc;
end;

function TTCreditos.SetTotalPagadoTF(xcodprest, xexpediente, xitems: String): Real;
// Objetivo...: Devolver Total de Pagos para una Cuota
var
  mc: real;
Begin
  datosdb.Filtrar(creditos_det_tf, 'Codprest = ' + '''' + xcodprest + '''' + ' and Expediente = ' + '''' + xexpediente + '''' + ' and Items = ' + '''' + xitems + '''');
  creditos_det_tf.First; mc := 0;
  while not creditos_det_tf.Eof do Begin
    mc := mc + (creditos_det_tf.FieldByName('capital').AsFloat + creditos_det_tf.FieldByName('interes').AsFloat); // - creditos_det_tf.FieldByName('punitorio').AsFloat);
    creditos_det_tf.Next;
  end;
  datosdb.QuitarFiltro(creditos_det_tf);
  Result := mc;
end;

function  TTCreditos.BuscarGarantia(xcodprest, xexpediente, xitems: String): Boolean;
// Objetivo...: Buscar Garantia
Begin
  Result := datosdb.Buscar(garantias, 'codprest', 'expediente', 'items', xcodprest, xexpediente, xitems);
end;

procedure TTCreditos.RegistrarGarantia(xcodprest, xexpediente, xitems, xtipo, xobservac, xalta, xvence: String; xcantitems: Integer);
// Objetivo...: Verificar Instancia Pagos
Begin
  if BuscarGarantia(xcodprest, xexpediente, xitems) then garantias.Edit else garantias.Append;
  garantias.FieldByName('codprest').AsString   := xcodprest;
  garantias.FieldByName('expediente').AsString := xexpediente;
  garantias.FieldByName('tipo').AsString       := xtipo;
  garantias.FieldByName('items').AsString      := xitems;
  garantias.FieldByName('observac').AsString   := xobservac;
  garantias.FieldByName('alta').AsString       := utiles.sExprFecha2000(xalta);
  garantias.FieldByName('vence').AsString      := utiles.sExprFecha2000(xvence);
  try
    garantias.Post
   except
    garantias.Cancel
  end;
  if (xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0')) then Begin
    datosdb.tranSQL('delete from ' + garantias.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(garantias); garantias.Open;
  end;
end;

procedure TTCreditos.BorrarGarantia(xcodprest, xexpediente: String);
// Objetivo...: Verificar Instancia Pagos
Begin
  datosdb.tranSQL('delete from ' + garantias.TableName + ' where codprest = ' + '''' + xcodprest + '''' + ' and expediente = ' + '''' + xexpediente + '''');
  datosdb.closeDB(garantias); garantias.Open;
end;

procedure TTCreditos.getDatosGarantia(xcodprest, xexpediente, xitems: String);
// Objetivo...: Verificar Instancia Pagos
Begin
  if BuscarGarantia(xcodprest, xexpediente, xitems) then Begin
    TipoGar     := garantias.FieldByName('tipo').AsString;
    ItemsGar    := garantias.FieldByName('items').AsString;
    ObservacGar := garantias.FieldByName('observac').AsString;
    AltaGar     := utiles.sFormatoFecha(garantias.FieldByName('alta').AsString);
    VenceGar    := utiles.sFormatoFecha(garantias.FieldByName('vence').AsString);
  end else Begin
    ItemsGar := ''; ObservacGar := ''; AltaGar := ''; VenceGar := ''; Tipogar := '';
  end;
end;

function  TTCreditos.setGarantia(xcodprest, xexpediente: String): TObjectList;
// Objetivo...: Verificar Instancia Pagos
var
  l: TObjectList;
  objeto: TTCreditos;
Begin
  l := TObjectList.Create;
  if BuscarGarantia(xcodprest, xexpediente, '001') then Begin
    while not garantias.Eof do Begin
      if (garantias.FieldByName('codprest').AsString <> xcodprest) or (garantias.FieldByName('expediente').AsString <> xexpediente) then Break;
      objeto := TTCreditos.Create;
      objeto.Codprest    := garantias.FieldByName('codprest').AsString;
      objeto.Expediente  := garantias.FieldByName('expediente').AsString;
      objeto.Itemsgar    := garantias.FieldByName('items').AsString;
      objeto.Tipogar     := garantias.FieldByName('tipo').AsString;
      objeto.Observacgar := garantias.FieldByName('observac').AsString;
      objeto.Altagar     := utiles.sFormatoFecha(garantias.FieldByName('alta').AsString);
      objeto.Vencegar    := utiles.sFormatoFecha(garantias.FieldByName('vence').AsString);
      l.Add(objeto);
      garantias.Next;
    end;
  end;
  Result := l;
end;

procedure TTCreditos.ListarGarantias(xdesde, xhasta: String; salida, xtipo: char);
// Objetivo...: Listar altas de garantias
var
  i: Integer;
  lista: boolean;
Begin
  list.Setear(salida); list.altopag := 0; list.m := 0;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  if xtipo = '1' then List.Titulo(0, 0, ' Altas de Prendas, Hipotecas y Manifestaciones de Bienes - Per�odo: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  if xtipo = '2' then List.Titulo(0, 0, ' Ven. de Prendas, Hipotecas y Manifestaciones de Bienes - Per�odo: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  List.Titulo(1, list.Lineactual, 'Expediente      Prestatario', 2, 'Arial, cursiva, 8');
  List.Titulo(35, list.Lineactual, 'Linea', 3, 'Arial, cursiva, 8');
  List.Titulo(54, list.Lineactual, 'Concepto', 4, 'Arial, cursiva, 8');
  List.Titulo(85, list.Lineactual, 'T', 5, 'Arial, cursiva, 8');
  List.Titulo(87, list.Lineactual, 'Alta', 6, 'Arial, cursiva, 8');
  List.Titulo(94, list.Lineactual, 'Vencim.', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  if (xtipo = '1') or (xtipo = '3') then datosdb.Filtrar(garantias, 'alta >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and alta <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  if (xtipo = '2') then datosdb.Filtrar(garantias, 'vence >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and vence <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');

  garantias.First; i := 0;
  while not garantias.Eof do Begin
    lista := false;
    prestatario.getDatos(garantias.FieldByName('codprest').AsString);
    if (credito.Buscar(garantias.FieldByName('codprest').AsString, garantias.FieldByName('expediente').AsString)) then begin
      credito.getDatos(garantias.FieldByName('codprest').AsString, garantias.FieldByName('expediente').AsString);
      categoria.getDatos(credito.idcredito);
      lista := true;
    end else begin
      if (xtipo = '3') then lista := false else lista := true;
      if (datosdb.Buscar(creditos_cabhist, 'codprest', 'expediente', garantias.FieldByName('codprest').AsString, garantias.FieldByName('expediente').AsString)) then begin
        categoria.getDatos(creditos_cabhist.FieldByName('idcredito').AsString);
      end;
    end;

    if (xtipo = '2') then lista := true;    

    if (lista) then begin
      list.Linea(0, 0, garantias.FieldByName('codprest').AsString + ' ' + garantias.FieldByName('expediente').AsString + '  ' + Copy(prestatario.nombre, 1, 25), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(35, list.Lineactual, Copy(categoria.Descrip, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(54, list.Lineactual, Copy(garantias.FieldByName('observac').AsString, 1, 35), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(85, list.Lineactual, garantias.FieldByName('tipo').AsString, 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(87, list.Lineactual, utiles.sFormatoFecha(garantias.FieldByName('alta').AsString), 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(94, list.Lineactual, utiles.sFormatoFecha(garantias.FieldByName('vence').AsString), 6, 'Arial, normal, 8', salida, 'S');
      Inc(i);
    end;
    garantias.Next;
  End;
  datosdb.QuitarFiltro(garantias);

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Cantidad de Registros Listados: ' + IntToStr(i), 1, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;

//------------------------------------------------------------------------------

procedure TTCreditos.VerificarQueElCreditoNoEsteCancelado(xcodprest, xexpediente, xestado: String);
// Objetivo...: Verificar estado
Begin
  if Buscar(xcodprest, xexpediente) then Begin
    creditos_cab.Edit;
    creditos_cab.FieldByName('estado').AsString := xestado;
    try
      creditos_cab.Post
     except
      creditos_cab.Cancel
    end;
  End;
End;

//------------------------------------------------------------------------------

{===============================================================================}

function credito: TTCreditos;
begin
  if xcredito = nil then
    xcredito := TTCreditos.Create;
  Result := xcredito;
end;

{===============================================================================}

initialization

finalization
  xcredito.Free;

end.
