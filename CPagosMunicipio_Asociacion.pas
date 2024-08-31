unit CPagosMunicipio_Asociacion;

interface

uses CMunicipios_Asociacion, CBDT, SysUtils, DB, DBTables, CUtiles, CListar,
     CIDBFM, Classes, CParametrosEmpresa, CBancos, CLogSeg, CUsuario,
     CCuentasBancariasCont_ADR, CDigitoVerificador, CBoletasADR,
     CExcluirExpedienteBarrasADR, CComregi;

const
  cantt = 10;

type

TTPagosMunicipio_Asociacion = class
  MontoBase: Real;
 public
  { Declaraciones Públicas }
  CCodprest, Cexpediente, Fechacobro, Anulado, Idc, Tipo, Sucursal, Numero, ChequesFecha, Idrec, Tiporec, Sucrec, Numrec: String;
  Efectivo, Cheques: Real;
  aportesMC, distribucioncobros, recibos_detalle, cheques_mov, formato_impresion, codigo_barras: TTable;
  codigobarras: Boolean;

  constructor Create;
  destructor  Destroy; override;

  function   Buscar(xanio, xidtitular, xmes: String): Boolean;
  procedure  GenerarPlanDePago(xanio, xidtitular, xmes, xconcepto: String);
  procedure  RegistrarPago(xanio, xidtitular, xmes, xfecha, xrecibo, xconcepto: String; xmonto, xrecargo: Real);
  procedure  FijarEstadoCuota(xanio, xidtitular, xmes, xestado: String);
  procedure  AnularPago(xanio, xidtitular, xmes: String);
  procedure  BorrarPlanDePagos(xanio, xidtitular: String);

  function   setCuotasImpagas(xanio, xidtitular: String): TQuery;
  function   setCuotasPagas(xanio, xidtitular: String): TQuery;
  function   setPrimerMes(xanio, xidtitular: String): String;

  procedure  RegistrarReciboPago(xanio, xidtitular, xmes, xcomprobante: string);

  procedure  ListarDetalleCobros(xdfecha, xhfecha: String; titSel: TStringList; salida: Char);
  procedure  InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: TStringList; salida: char);
  procedure  ListarCuotasImpagas(xfdesde, xfhasta, xmeses: String; titSel: TStringList; salida: char);

  function   verificarSiElTitularTieneOperaciones(xidtitular: String): Boolean;
  function   verificarSiElTitularTienePlan(xidtitular, xanio: String): Boolean;

  procedure  ExportarInforme(xarchivo: String);

  function   BuscarCobro(xsucursal, xnumero: String): Boolean;
  procedure  RegistrarCobro(xsucursal, xnumero, xexpediente, xfecha: String; xefectivo, xcheque: Real);
  procedure  getDatosCobro(xsucursal, xnumero: String); overload;
  procedure  getDatosCobro(xsucursal, xnumero, xitems, xfecha, xcodigo: String); overload;
  procedure  BorrarCobro(xsucursal, xnumero: String);
  function   BuscarReciboCobro(xsucursal, xnumero, xitems: String): Boolean;
  procedure  RegistrarRecibo(xsucursal, xnumero, xitems, xconcepto, xidc, xtipo, xsucrec, xnumrec, xfecha, xmodo, xtipomov: String; xmonto: Real; xcantitems: Integer);
  function   setRecibosPago(xsucursal, xnumero: String): TQuery;
  function   BuscarReciboPorNumeroImpresion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
  procedure  AnularReciboPago(xidc, xtipo, xsucursal, xnumero, xanular: String);
  procedure  RegistrarCheque(xsucursal, xnumero, xitems, xnrocheque, xfecha, xcodbanco, xfilial: String; xmonto: real; xcantitems: Integer);
  function   setCheques(xsucursal, xnumero: String): TQuery;
  procedure  getDatosCheque(xsucursal, xnumero, xitems: String);
  procedure  ImprimirRecibo(xsucursal, xnumero: String; salida: char);
  procedure  ListarControlRecibos(xdfecha, xhfecha: String; salida: char);
  procedure  ListarControlChequesRecibidos(xdfecha, xhfecha: String; salida: char);
  procedure  ListarControlChequesRecibosFechaRecepcion(xdfecha, xhfecha: String; salida: char);

  function   setRecibosFechas(xdesde, xhasta: String): TQuery;
  procedure  AjustarNumeroRecibo(xsucursalrecibo, xnumerorecibo, xnumerocorrelativo: String);
  function   setCodigoBarras: Boolean;

  procedure  IniciarExpedientes;
  procedure  Transferir_Work(xperiodo, xidtitular: String);
  procedure  Restaurar_Work(xperiodo, xidtitular: String);
  procedure  Transferir_WorkActualizado(xcodigobarra, xfecha, xhora, xperiodo, xidtitular: String);
  procedure  Restaurar_WorkActualizado(xcodigobarra, xfecha, xhora, xperiodo, xidtitular: String);

  procedure  AgregarItemsRecibo(xitems, xconcepto, xmonto: String);
  procedure  ListarRecibo(xcodprest, xperiodo, xcuentabcaria, xfechaemis, xfechavto1, xmontovto1, xfechavto2, xmontovto2, xidcredito: String; salida: char; xtipo_recibo, xidc, xtipo, xsucursal, xnumero: String);
  procedure  ReimprimirRecibo(xcodigobarra, xfecha, xhora: String; salida: char);

  procedure  conectar;
  procedure  desconectar;
 protected
  { Declaraciones Protegidas }
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  idanter0, idanter1, idanter2: String;
  lineassep, lineasdet, modelo, lineadiv, margensup, margenizq: String;
  totales: array [1..cantt] of Real;
  meses: array[1..12] of String;
  idanter: array[1..3] of String;
  tcuotas: array[1..100, 1..9]  of String;
  mov: array[1..50, 1..3] of String;
  l: Boolean;
  difanios, itbol: Integer;
  detalle: TStringList;
  rsql: TQuery;
  procedure  TotCobros(salida: char);
  procedure  Linea(xidanter: String; xmi: Integer; salida: Char);
  procedure  TotalesFinales(salida: char);
  procedure  listLineaAtrazos(xidtitular: String; salida: char);
  function   setFechaPrimerPago(xidtitular: String): String;
  procedure  getFormatoImpresion;
  procedure  TotalPorDia(salida: char);
  procedure  TotalDiaCheque(salida: char);
end;

function aportesMC: TTPagosMunicipio_Asociacion;

implementation

var
  xaportesMC: TTPagosMunicipio_Asociacion = nil;

constructor TTPagosMunicipio_Asociacion.Create;
begin
  aportesMC := datosdb.openDB('aportesMC', '');
  distribucioncobros        := datosdb.openDB('distribucioncobrosMC', '');
  recibos_detalle           := datosdb.openDB('recibos_detalleMC', '');
  cheques_mov               := datosdb.openDB('cheques_movMC', '');
  formato_Impresion         := datosdb.openDB('formatoImpresion', '');
  codigo_barras             := datosdb.openDB('codigobarras', '');
end;

destructor TTPagosMunicipio_Asociacion.Destroy;
begin
  inherited Destroy;
end;

function   TTPagosMunicipio_Asociacion.Buscar(xanio, xidtitular, xmes: String): Boolean;
// Objetivo...: Buscar Reg. de aportesMC
begin
  if aportesMC.IndexFieldNames <> 'Anio;Idtitular;Mes' then aportesMC.IndexFieldNames := 'Anio;Idtitular;Mes';
  Result := datosdb.Buscar(aportesMC, 'Anio', 'Idtitular', 'Mes', xanio, xidtitular, xmes);
end;

procedure  TTPagosMunicipio_Asociacion.GenerarPlanDePago(xanio, xidtitular, xmes, xconcepto: String);
// Objetivo...: Registrar pago
begin
  if xmes = '01' then datosdb.tranSQL('DELETE FROM aportesMC WHERE anio = ' + '"' + xanio + '"' + ' AND idtitular = ' + '"' + xidtitular + '"');
  aportesMC.Append;
  aportesMC.FieldByName('anio').AsString      := xanio;
  aportesMC.FieldByName('idtitular').AsString := xidtitular;
  aportesMC.FieldByName('mes').AsString       := xmes;
  aportesMC.FieldByName('concepto').AsString  := xconcepto;
  aportesMC.FieldByName('estado').AsString    := 'I';
  try
    aportesMC.Post
   except
    aportesMC.Cancel
  end;
  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Generando Plan Pagos Mun/Com. ' + xanio + '-' + xidtitular);
end;

procedure  TTPagosMunicipio_Asociacion.RegistrarPago(xanio, xidtitular, xmes, xfecha, xrecibo, xconcepto: String; xmonto, xrecargo: Real);
// Objetivo...: Registrar pago
begin
  if Buscar(xanio, xidtitular, xmes) then aportesMC.Edit else aportesMC.Append;
  aportesMC.FieldByName('anio').AsString      := xanio;
  aportesMC.FieldByName('idtitular').AsString := xidtitular;
  aportesMC.FieldByName('mes').AsString       := xmes;
  aportesMC.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  aportesMC.FieldByName('recibo').AsString    := xrecibo;
  aportesMC.FieldByName('concepto').AsString  := xconcepto;
  aportesMC.FieldByName('monto').AsFloat      := xmonto;
  aportesMC.FieldByName('recargo').AsFloat    := xrecargo;
  aportesMC.FieldByName('estado').AsString    := 'P';
  try
    aportesMC.Post
   except
    aportesMC.Cancel
  end;
  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Registrando Pago Mun/Com. ' + xanio + '-' + xidtitular);
end;

procedure TTPagosMunicipio_Asociacion.FijarEstadoCuota(xanio, xidtitular, xmes, xestado: String);
// Objetivo...: Fijar Estado de la Cuota
Begin
  if Buscar(xanio, xidtitular, xmes) then aportesMC.Edit else aportesMC.Append;
  aportesMC.FieldByName('estado').AsString  := xestado;
  try
    aportesMC.Post
   except
    aportesMC.Cancel
  end;
  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Estableciendo Estado Cuota ' + xanio + '-' + xidtitular);
end;

procedure TTPagosMunicipio_Asociacion.AnularPago(xanio, xidtitular, xmes: String);
// Objetivo...: Anular un pago efectuado
Begin
  if Buscar(xanio, xidtitular, xmes) then Begin
    aportesMC.Edit;
    aportesMC.FieldByName('fecha').AsString    := '';
    aportesMC.FieldByName('recibo').AsString   := '';
    aportesMC.FieldByName('concepto').AsString := 'Cuota Mes de ' + utiles.setMes(StrToInt(xmes)) + ' del ' + xanio;
    aportesMC.FieldByName('monto').AsFloat     := 0;
    aportesMC.FieldByName('recargo').AsFloat   := 0;
    aportesMC.FieldByName('estado').AsString   := 'I';
    try
      aportesMC.Post
     except
      aportesMC.Cancel
    end;
  end;
  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Anulando Pago ' + xanio + '-' + xidtitular);
end;

procedure TTPagosMunicipio_Asociacion.BorrarPlanDePagos(xanio, xidtitular: String);
// Objetivo...: Dar de baja un plan completo
Begin
  datosdb.tranSQL('DELETE FROM aportesMC WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"');
  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Borrando Plan Pagos Mun/Com. ' + xanio + '-' + xidtitular);
end;

function  TTPagosMunicipio_Asociacion.setCuotasImpagas(xanio, xidtitular: String): TQuery;
// Objetivo...: retornar cuotas impagas
Begin
  Result := datosdb.tranSQL('SELECT * FROM aportesMC WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"' + ' AND estado = ' + '"' + 'I' + '"');
end;

function  TTPagosMunicipio_Asociacion.setCuotasPagas(xanio, xidtitular: String): TQuery;
// Objetivo...: retornar cuotas impagas
Begin
  Result := datosdb.tranSQL('SELECT * FROM aportesMC WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"' + ' AND estado = ' + '"' + 'P' + '"');
end;

function TTPagosMunicipio_Asociacion.setPrimerMes(xanio, xidtitular: String): String;
// Objetivo...: Devolver el mes inicial
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM aportesMC WHERE Anio = ' + '"' + xanio + '"' + ' AND Idtitular = ' + '"' + xidtitular + '"' + ' ORDER BY anio, mes');
  r.Open;
  if r.RecordCount > 0 then Result := r.FieldByName('mes').AsString else Result := '01';
  r.Close; r.Free;
end;

procedure TTPagosMunicipio_Asociacion.RegistrarReciboPago(xanio, xidtitular, xmes, xcomprobante: string);
// Objetivo...: Registrar Comprobante de Pago
begin
  if Buscar(xanio, xidtitular, xmes) then begin
    aportesMC.Edit;
    aportesMC.FieldByName('comprobante').AsString := xcomprobante;
    try
      aportesMC.Post
     except
      aportesMC.Cancel
    end;
    datosdb.closeDB(aportesMC); aportesMC.Open; 
  end;
end;

procedure TTPagosMunicipio_Asociacion.ListarDetalleCobros(xdfecha, xhfecha: String; titSel: TStringList; salida: Char);
// Objetivo...: Listar Detalle de Cobros
var
  i, anioini: Integer;
  f, z, comprobante: String;
Begin
  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, 'Informe Detallado de Aportes', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Mes          F.Cobro', 1, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'Concepto', 2, 'Arial, cursiva, 8');
    List.Titulo(55, List.lineactual, 'Recibo', 3, 'Arial, cursiva, 8');
    List.Titulo(71, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(85, List.lineactual, 'Recargo', 5, 'Arial, cursiva, 8');
    List.Titulo(96, List.lineactual, 'E', 6, 'Arial, cursiva, 8');
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
  idanter0 := ''; l := False;

  difanios := StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4)) - StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4));
  anioini  := StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4));

  for i := 1 to difanios + 1 do Begin

    datosdb.Filtrar(aportesMC, 'anio = ' + IntToStr(anioini));

    if i > 1 then
      if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S') else list.LineaTxt('', True);

    if salida <> 'T' then Begin
      list.Linea(0, 0, 'Año: ' + IntToStr(anioini), 1, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt('Año: ' + IntToStr(anioini), True);
      list.LineaTxt('', True);
    end;

    aportesMC.First;
    while not aportesMC.Eof do Begin
      if (StrToInt(aportesMC.FieldByName('anio').AsString + aportesMC.FieldByName('mes').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xdfecha), 1, 4) + Copy(xdfecha, 4, 2))) and (StrToInt(aportesMC.FieldByName('anio').AsString + aportesMC.FieldByName('mes').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xhfecha), 1, 4) + Copy(xhfecha, 4, 2))) and (utiles.verificarItemsLista(titSel, aportesMC.FieldByName('idtitular').AsString)) then Begin
        if aportesMC.FieldByName('idtitular').AsString <> idanter0 then Begin
          TotCobros(salida);
          if l then
            if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S') else list.LineaTxt('', True);
          municipio.getDatos(aportesMC.FieldByName('idtitular').AsString);
          if salida <> 'T' then Begin
            list.Linea(0, 0, municipio.Nombre, 1, 'Arial, negrita, 9', salida, 'N');
            list.Linea(50, list.Lineactual, municipio.domicilio, 2, 'Arial, negrita, 9', salida, 'S');
            list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
          end else Begin
            list.LineaTxt(Copy(municipio.Nombre, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(municipio.Nombre, 1, 30))))), False);
            list.LineaTxt(Copy(municipio.domicilio, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(municipio.domicilio, 1, 30))))), True);
            list.LineaTxt('', True);
          end;
          idanter0 := aportesMC.FieldByName('idtitular').AsString;
        end;

        comprobante := '';
        if (length(trim(aportesMC.FieldByName('comprobante').AsString)) = 0) then begin
          z := utiles.sLlenarIzquierda (Copy(aportesMC.FieldByName('fecha').AsString, 1, 4) + aportesMC.FieldByName('idtitular').AsString + aportesMC.FieldByName('mes').AsString, 11, '0');
          getDatosCobro('2100', z, aportesMC.FieldByName('mes').AsString, aportesMC.FieldByName('fecha').AsString, aportesMC.FieldByName('idtitular').AsString);
        end else begin
          comprobante := aportesMC.FieldByName('comprobante').AsString;
        end;

        if salida <> 'T' then Begin
          list.Linea(0, 0, aportesMC.FieldByName('mes').AsString + '/' + aportesMC.FieldByName('anio').AsString + '   ' + utiles.sFormatoFecha(aportesMC.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(25, list.Lineactual, aportesMC.FieldByName('concepto').AsString, 2, 'Arial, normal, 8', salida, 'N');
          if (length(trim(comprobante)) = 0) then
            list.Linea(55, list.Lineactual, Tiporec + ' ' + Sucrec + Numrec, 3, 'Arial, normal, 8', salida, 'N')
          else
            list.Linea(55, list.Lineactual, comprobante, 3, 'Arial, normal, 8', salida, 'N');
          list.Importe(75, list.Lineactual, '', aportesMC.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
          list.Importe(90, list.Lineactual, '', aportesMC.FieldByName('recargo').AsFloat, 5, 'Arial, normal, 8');
          list.Linea(96, list.Lineactual, aportesMC.FieldByName('estado').AsString, 6, 'Arial, normal, 8', salida, 'S');
        end else Begin
          if Length(Trim(aportesMC.FieldByName('fecha').AsString)) = 8 then f := utiles.sFormatoFecha(aportesMC.FieldByName('fecha').AsString) else f := '        ';
          list.LineaTxt(aportesMC.FieldByName('mes').AsString + '/' + aportesMC.FieldByName('anio').AsString + '  ' + f + '  ', False);
          list.LineaTxt(Copy(aportesMC.FieldByName('concepto').AsString, 1, 30) + utiles.espacios(31 - (Length(TrimRight(Copy(aportesMC.FieldByName('concepto').AsString, 1, 30))))), False);
          list.LineaTxt(Tiporec + ' ' + Sucrec + Numrec + utiles.espacios(16 - (Length(TrimRight(Tiporec + ' ' + Sucrec + Numrec)))), False);
          list.ImporteTxt(aportesMC.FieldByName('monto').AsFloat, 9, 2, False);
          list.ImporteTxt(aportesMC.FieldByName('recargo').AsFloat, 9, 2, False);
          list.LineaTxt(' ' + aportesMC.FieldByName('estado').AsString, True);
        end;
        totales[1] := totales[1] + 1;
        if Length(Trim(aportesMC.FieldByName('fecha').AsString)) > 0 then totales[2] := totales[2] + 1 else
          totales[8] := totales[8] + municipio.Tarifa;
        totales[3] := totales[3] + aportesMC.FieldByName('monto').AsFloat;
        totales[4] := totales[4] + aportesMC.FieldByName('recargo').AsFloat;
        totales[6] := totales[6] + aportesMC.FieldByName('monto').AsFloat;
        totales[7] := totales[7] + aportesMC.FieldByName('recargo').AsFloat;
        l := True;
      end;
      aportesMC.Next;
    end;
    TotCobros(salida);

    datosdb.QuitarFiltro(aportesMC);
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

  if l then Begin
    if salida <> 'T' then list.FinList;
  end else utiles.msgError('No Existen Datos para Listar ...!');
  if salida = 'T' then list.FinalizarExportacion;
end;

procedure TTPagosMunicipio_Asociacion.TotCobros(salida: char);
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

procedure TTPagosMunicipio_Asociacion.InformeEstadoCuotas(xfdesde, xfhasta: String; titSel: TStringList; salida: char);
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

  mi := StrToInt(Copy(xfdesde, 4, 2));  // armar mes inicial
  mf := StrToInt(Copy(xfhasta, 4, 2));  // armar mes final

  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, normal, 14');
  list.Titulo(0, 0, 'Informe Cobro de Aportes entre ' + xfdesde + ' y ' + xfhasta, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, '', 1, 'Arial, normal, 5');

  list.Titulo(0, 0, 'Entidad', 1, 'Arial, cursiva, 8');
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

  aportesMC.IndexFieldNames := 'Idtitular;Anio;Mes';

  difanios := StrToInt(Copy(utiles.sExprFecha2000(xfhasta), 1, 4)) - StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4));
  anioini  := StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4));

  for k := 1 to difanios + 1 do Begin

    if k > 1 then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    list.Linea(0, 0, 'Año: ' + IntToStr(anioini), 1, 'Arial, normal, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

    datosdb.Filtrar(aportesMC, 'anio = ' + IntToStr(anioini));

    aportesMC.First; xidanter := ''; l := False;
    For i := 1 to 12 do meses[i] := '0';
    while not aportesMC.Eof do Begin
      if (StrToInt(aportesMC.FieldByName('anio').AsString + aportesMC.FieldByName('mes').AsString) >= StrToInt(Copy(utiles.sExprFecha2000(xfdesde), 1, 4) + Copy(xfdesde, 4, 2))) and (StrToInt(aportesMC.FieldByName('anio').AsString + aportesMC.FieldByName('mes').AsString) <= StrToInt(Copy(utiles.sExprFecha2000(xfhasta), 1, 4) + Copy(xfhasta, 4, 2))) and (utiles.verificarItemsLista(titSel, aportesMC.FieldByName('idtitular').AsString)) then Begin
        if Length(Trim(xidanter)) = 0 then xidanter := aportesMC.FieldByName('idtitular').AsString;
        if aportesMC.FieldByName('idtitular').AsString <> xidanter then Begin
          linea(xidanter, mi, salida);
          xidanter := aportesMC.FieldByName('idtitular').AsString;
          For i := 1 to 12 do meses[i] := '0';
        end;
        if aportesMC.FieldByName('estado').AsString = 'P' then Begin
          meses[StrToInt(aportesMC.FieldByName('mes').AsString)] := Copy(aportesMC.FieldByName('fecha').AsString, 7, 2) + '/' + Copy(aportesMC.FieldByName('fecha').AsString, 5, 2); //utiles.FormatearNumero(aportesMC.FieldByName('monto').AsString);
          totales[2] := totales[2] + aportesMC.FieldByName('monto').AsFloat;
          totales[4] := totales[4] + aportesMC.FieldByName('monto').AsFloat;
        end;
        if aportesMC.FieldByName('estado').AsString > '' then totales[3] := totales[3] + 1;

      end;

      aportesMC.Next;
    end;

    linea(xidanter, mi, salida);

    datosdb.QuitarFiltro(aportesMC);
    Inc(anioini);
  end;

  aportesMC.IndexFieldNames := 'Anio;Idtitular;Mes';

  if not l then list.Linea(0, 0, 'No existen datos para listar', 1, 'Arial, normal, 9', salida, 'S') else TotalesFinales(salida);
  list.FinList;
end;

procedure TTPagosMunicipio_Asociacion.Linea(xidanter: String; xmi: Integer; salida: Char);
var
  i, j, q: Integer;
Begin
  municipio.getDatos(xidanter);
  list.Linea(0, 0, Copy(municipio.nombre, 1, 35), 1, 'Arial, normal, 8', salida, 'N');
  j := 35; q := 1;
  For i := xmi to 12 do Begin   // Desde el mes inicial hasta fin de año
    Inc(q);
    if meses[i] = '0' then list.Linea(j-3, list.Lineactual, '', q, 'Arial, normal, 8, clBlack', salida, 'N') else list.Linea(j-3, list.Lineactual, meses[i], q, 'Arial, normal, 8', salida, 'N');  //if meses[i] = '0' then list.Importe(j, list.Lineactual, '##,##', StrToFloat(meses[i]), q, 'Arial, normal, 8') else list.Importe(j, list.Lineactual, '', StrToFloat(meses[i]), q, 'Arial, normal, 8');
    j := j + 5;
  end;
  For i := 1 to xmi-1 do Begin   // Desde el mes inicial del año siguiente hasta el principio del primero
    Inc(q);
    if meses[i] = '0' then list.Linea(j-3, list.Lineactual, '', q, 'Arial, normal, 8, clBlack', salida, 'N') else list.Linea(j-3, list.Lineactual, meses[i], q, 'Arial, normal, 8', salida, 'N');  //if meses[i] = '0' then list.Importe(j, list.Lineactual, '##,##', StrToFloat(meses[i]), q, 'Arial, normal, 8') else list.Importe(j, list.Lineactual, '', StrToFloat(meses[i]), q, 'Arial, normal, 8');
    j := j + 5;
  end;

  Inc(q);
  list.importe(99, list.Lineactual, '', totales[4],q ,'Arial, negrita, 8');
  Inc(q);
  list.Linea(99, list.Lineactual, '',q ,'Arial, negrita, 8', salida, 'S');

  totales[1] := totales[1] + 1;
  totales[4] := 0;

  l := True;
end;

procedure  TTPagosMunicipio_Asociacion.TotalesFinales(salida: char);
// Objetivo...: Totales estadísticos
Begin
  list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
  list.Linea(0, 0, 'Cantidad de aportes:', 1, 'Arial, negrita, 9', salida, 'N');
  list.Importe(99, list.Lineactual, '#####', totales[1], 2, 'Arial, negrita, 9');
  list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, 'Monto Total Cobrado:', 1, 'Arial, negrita, 9', salida, 'N');
  list.Importe(99, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
  list.Linea(99, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
end;

{*******************************************************************************}

procedure TTPagosMunicipio_Asociacion.ListarCuotasImpagas(xfdesde, xfhasta, xmeses: String; titSel: TStringList; salida: char);
// Objetivo...: Listar Cuotas atrazadas
var
  per: String; i: Integer;
Begin
  for i := 1 to cantt do totales[i] := 0;
  if salida <> 'T' then Begin
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, empresa.RSocial, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, 'Informe de Aportes Atrazados al ' + xfdesde, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Entidad', 1, 'Arial, cursiva, 8');
    List.Titulo(27, List.lineactual, 'Cuotas Adeudadas', 2, 'Arial, cursiva, 8');
    List.Titulo(88, List.lineactual, 'Cant.', 3, 'Arial, cursiva, 8');
    List.Titulo(94, List.lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    List.LineaTxt(' ', True);
    List.LineaTxt(empresa.RSocial, True);
    List.LineaTxt('Informe de Aportes Atrazados al ' + xfdesde, True);
    List.LineaTxt(' ', True);
    List.LineaTxt('Municipalidad o Comuna         Cuotas Atrazadas                Cant.     Monto', True);
    List.LineaTxt('------------------------------------------------------------------------------', True);
    List.LineaTxt(' ', True);
  end;

  per := utiles.RestarPeriodo(xfdesde, xmeses);
  aportesMC.IndexFieldNames := 'Idtitular;Anio;Mes';
  aportesMC.First; idanter0 := ''; l := False; totales[4] := 0; idanter1 := '';
  detalle := TStringList.Create;
  while not aportesMC.Eof do Begin
    if (aportesMC.FieldByName('anio').AsString + aportesMC.FieldByName('mes').AsString <= Copy(xfdesde, 4, 4) + Copy(xfdesde, 1, 2)) and (aportesMC.FieldByName('estado').AsString = 'I') and (utiles.verificarItemsLista(titSel, aportesMC.FieldByName('idtitular').AsString)) and (aportesMC.FieldByName('anio').AsString + aportesMC.FieldByName('mes').AsString <= Copy(utiles.sExprFecha2000(xfhasta), 1, 6)) then Begin
      if aportesMC.FieldByName('idtitular').AsString <> idanter0 then listLineaAtrazos(idanter0, salida);
      detalle.Add(aportesMC.FieldByName('mes').AsString + '/' + Copy(aportesMC.FieldByName('anio').AsString, 3, 2));
      municipio.getDatos(aportesMC.FieldByName('idtitular').AsString);
      totales[1] := totales[1] + 1;
      totales[2] := totales[2] + municipio.Tarifa;
      idanter0 := aportesMC.FieldByName('idtitular').AsString;
    end;
    aportesMC.Next;
  end;

  aportesMC.IndexFieldNames := 'Anio;Idtitular;Mes';

  listLineaAtrazos(idanter0, salida);

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

procedure TTPagosMunicipio_Asociacion.listLineaAtrazos(xidtitular: String; salida: char);
var
  i, j, k, m, it: Integer;
Begin
  if salida <> 'T' then it := 10 else it := 6;

  if totales[1] > 0 then Begin
    if idanter1 <> xidtitular then Begin
      municipio.getDatos(xidtitular);
      if salida <> 'T' then list.Linea(0, 0, Copy(municipio.nombre, 1, 27), 1, 'Arial, normal, 8', salida, 'N') else list.LineaTxt(Copy(municipio.Nombre, 1, 27) + utiles.espacios(28 - (Length(TrimRight(Copy(municipio.Nombre, 1, 27))))), False);
    end else
      if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');// else list.LineaTxt(utiles.espacios(28), False);

    j := 21; k := 1; m := 0;
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
    if salida <> 'T' then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S') else list.LineaTxt('', True);
  end;
  detalle.Clear;
  totales[1] := 0;
  totales[2] := 0;
end;

function TTPagosMunicipio_Asociacion.verificarSiElTitularTieneOperaciones(xidtitular: String): Boolean;
// Objetivo...: Verificar si el titular tiene o no operaciones registradas
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM aportesMC WHERE Idtitular = ' + '"' + xidtitular + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function  TTPagosMunicipio_Asociacion.verificarSiElTitularTienePlan(xidtitular, xanio: String): Boolean;
// Objetivo...: verificar si el titular tiene el plan definido
Begin
  if aportesMC.IndexFieldNames <> 'Idtitular;Anio' then aportesMC.IndexFieldNames := 'Idtitular;Anio';
  Result := datosdb.Buscar(aportesMC, 'Idtitular', 'Anio', xidtitular, xanio);
  aportesMC.IndexFieldNames := 'Idtitular;Anio;Mes';
end;

function TTPagosMunicipio_Asociacion.setFechaPrimerPago(xidtitular: String): String;
// Objetivo...: Devolver primer pago efectuado
var
  r: TQuery;
Begin
  r := datosdb.tranSQL('SELECT * FROM aportesMC WHERE idtitular = ' + '"' +  xidtitular + '"' + ' ORDER BY anio, mes');
  r.Open;
  if r.RecordCount > 0 then Result := r.FieldByName('mes').AsString + '/' + r.FieldByName('anio').AsString else Result := '';
  r.Close; r.Free;
end;

procedure TTPagosMunicipio_Asociacion.ExportarInforme(xarchivo: String);
Begin
  list.ExportarInforme(dbs.DirSistema + '\attach\' + xarchivo + '.txt');
end;

// -----------------------------------------------------------------------------

function    TTPagosMunicipio_Asociacion.BuscarCobro(xsucursal, xnumero: String): Boolean;
// Objetivo...: Buscar un cobro
Begin
  Result := datosdb.Buscar(distribucioncobros, 'sucursal', 'numero', xsucursal, xnumero);
end;

procedure   TTPagosMunicipio_Asociacion.RegistrarCobro(xsucursal, xnumero, xexpediente, xfecha: String; xefectivo, xcheque: Real);
// Objetivo...: Registrar Cobros
Begin
  if BuscarCobro(xsucursal, xnumero) then distribucioncobros.Edit else distribucioncobros.Append;
  distribucioncobros.FieldByName('sucursal').AsString   := xsucursal;
  distribucioncobros.FieldByName('numero').AsString     := xnumero;
  if Length(Trim(xfecha)) = 8 then distribucioncobros.FieldByName('fecha').AsString := utiles.sExprFecha2000(xfecha);
  distribucioncobros.FieldByName('expediente').AsString := xexpediente;
  distribucioncobros.FieldByName('efectivo').AsFloat    := xefectivo;
  distribucioncobros.FieldByName('cheques').AsFloat     := xcheque;
  try
    distribucioncobros.Post
   except
    distribucioncobros.Cancel
  end;
  datosdb.refrescar(distribucioncobros);

  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Distribución Cobro Mun/Com. ' + xsucursal + '-' + xnumero + '  ' + xexpediente);
end;

procedure   TTPagosMunicipio_Asociacion.getDatosCobro(xsucursal, xnumero: String);
// Objetivo...: Recuperar los datos de un cobro
Begin
  if BuscarCobro(xsucursal, xnumero) then Begin
    Sucursal    := distribucioncobros.FieldByName('sucursal').AsString;
    Numero      := distribucioncobros.FieldByName('numero').AsString;
    efectivo    := distribucioncobros.FieldByName('efectivo').AsFloat;
    cheques     := distribucioncobros.FieldByName('cheques').AsFloat;
    ccodprest   := Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 5);
    cexpediente := Copy(distribucioncobros.FieldByName('expediente').AsString, 7, 4);
    Fechacobro  := utiles.sFormatoFecha(distribucioncobros.FieldByName('fecha').AsString);
    if BuscarReciboCobro(xsucursal, xnumero, '01') then Begin
      Idrec       := recibos_detalle.FieldByName('idc').AsString;
      Tiporec     := recibos_detalle.FieldByName('tipo').AsString;
      Sucrec      := recibos_detalle.FieldByName('sucrec').AsString;
      Numrec      := '-' + recibos_detalle.FieldByName('numrec').AsString;
    end;
  end else Begin
    ccodprest := ''; cexpediente := ''; fechaCobro := ''; Sucursal := ''; Numero := '';
    efectivo := 0; cheques := 0; idrec := ''; tiporec := ''; sucrec := ''; numrec := '';
  end;
end;

procedure   TTPagosMunicipio_Asociacion.getDatosCobro(xsucursal, xnumero, xitems, xfecha, xcodigo: String);
// Objetivo...: Recuperar los datos de un cobro
Begin
  if BuscarCobro(xsucursal, xnumero) then Begin
    Sucursal    := distribucioncobros.FieldByName('sucursal').AsString;
    Numero      := distribucioncobros.FieldByName('numero').AsString;
    efectivo    := distribucioncobros.FieldByName('efectivo').AsFloat;
    cheques     := distribucioncobros.FieldByName('cheques').AsFloat;
    ccodprest   := Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 5);
    cexpediente := Copy(distribucioncobros.FieldByName('expediente').AsString, 7, 4);
    Fechacobro  := utiles.sFormatoFecha(distribucioncobros.FieldByName('fecha').AsString);
  end else Begin
    ccodprest := ''; cexpediente := ''; fechaCobro := ''; Sucursal := ''; Numero := '';
    efectivo := 0; cheques := 0; idrec := ''; tiporec := ''; sucrec := ''; numrec := '';
  end;

  datosdb.Filtrar(recibos_detalle, 'numero >= ' + '''' + Copy(xnumero, 1, 9) + '01' + '''' + ' and numero <= ' + '''' + Copy(xnumero, 1, 9) + '12' + '''');
  recibos_detalle.First;
  while not recibos_detalle.Eof do begin
    if  (recibos_detalle.FieldByName('fecha').AsString = xfecha) and (Copy(recibos_detalle.FieldByName('numero').AsString, 6, 4) = xcodigo) then begin
      Idrec       := recibos_detalle.FieldByName('idc').AsString;
      Tiporec     := recibos_detalle.FieldByName('tipo').AsString;
      Sucrec      := recibos_detalle.FieldByName('sucrec').AsString;
      Numrec      := '-' + recibos_detalle.FieldByName('numrec').AsString;
      Break;
    end;
    recibos_detalle.Next;
  end;
  {if length(trim(Numrec)) = 0 then begin
   numrec := xsucursal + ' ' + xnumero;
   utiles.msgerror('sucursal = ' + '''' + xsucursal + '''' + ' and numero >= ' + '''' + Copy(xnumero, 1, 9) + '01' + '''' + ' and numero <= ' + '''' + Copy(xnumero, 1, 9) + '12' + '''' + '        ' + xnumero + '  ' + xitems);
  end;}

  datosdb.QuitarFiltro(recibos_detalle); 
end;


procedure   TTPagosMunicipio_Asociacion.BorrarCobro(xsucursal, xnumero: String);
// Objetivo...: Borrar un cobro
Begin
  if BuscarCobro(xsucursal, xnumero) then
    if BuscarReciboCobro(xsucursal, xnumero, '01') then Begin
      distribucioncobros.Delete;
      datosdb.closeDB(distribucioncobros); distribucioncobros.Open;
      // Borramos los registros vinculados
      datosdb.tranSQL('delete from recibos_detalleMC where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"');
      datosdb.closeDB(recibos_detalle); recibos_detalle.Open;
      datosdb.tranSQL('delete from cheques_movMC where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"');
      datosdb.closeDB(cheques_mov); cheques_mov.Open;
      logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Borrando Cobro ' + xsucursal + ' ' + xnumero);
    end;
end;

function TTPagosMunicipio_Asociacion.BuscarReciboCobro(xsucursal, xnumero, xitems: String): Boolean;
// Objetivo...: registrar recibos de pago
Begin
  Result := datosdb.Buscar(recibos_detalle, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems);
end;

procedure TTPagosMunicipio_Asociacion.RegistrarRecibo(xsucursal, xnumero, xitems, xconcepto, xidc, xtipo, xsucrec, xnumrec, xfecha, xmodo, xtipomov: String; xmonto: Real; xcantitems: Integer);
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
  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Registrando Detalle Recibo Mun/Com. ' + xsucursal + ' ' + xnumero);
end;

function  TTPagosMunicipio_Asociacion.setRecibosPago(xsucursal, xnumero: String): TQuery;
// Objetivo...: Recuperar recibos de pago
Begin
  Result := datosdb.tranSQL('select * from recibos_detalleMC where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' order by items');
end;

function  TTPagosMunicipio_Asociacion.BuscarReciboPorNumeroImpresion(xidc, xtipo, xsucursal, xnumero: String): Boolean;
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

procedure TTPagosMunicipio_Asociacion.AnularReciboPago(xidc, xtipo, xsucursal, xnumero, xanular: String);
// Objetivo...: Anular/Activar Recibo
Begin
  datosdb.tranSQL('update recibos_detalleMC set anulado = ' + '"' + xanular + '"' + ' where idc = ' + '"' + xidc + '"' + ' and tipo = ' + '"' + xtipo + '"' + ' and sucrec = ' + '"' + xsucursal + '"' + ' and numrec = ' + '"' + xnumero + '"');
end;

procedure TTPagosMunicipio_Asociacion.RegistrarCheque(xsucursal, xnumero, xitems, xnrocheque, xfecha, xcodbanco, xfilial: String; xmonto: real; xcantitems: Integer);
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
  cheques_mov.FieldByName('monto').AsFloat      := xmonto;
  try
    cheques_mov.Post
   except
    cheques_mov.Cancel
  end;
  if utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') = xitems then datosdb.tranSQL('delete from cheques_mov where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantitems), 2, '0') + '"');
  logsist.RegistrarLog(usuario.usuario, 'Aportes MC', 'Registrando Cheque Mun/Com. ' + xnumero + '-' + xsucursal);
end;

function  TTPagosMunicipio_Asociacion.setCheques(xsucursal, xnumero: String): TQuery;
// Objetivo...: Devolver set de cheques
Begin
  Result := datosdb.tranSQL('select * from cheques_movMC where sucursal = ' + '"' + xsucursal + '"' + ' and numero = ' + '"' + xnumero + '"' + ' order by items');
end;

procedure TTPagosMunicipio_Asociacion.getDatosCheque(xsucursal, xnumero, xitems: String);
// Objetivo...: Recuperar datos del cheque
Begin
  if datosdb.Buscar(cheques_mov, 'sucursal', 'numero', 'items', xsucursal, xnumero, xitems) then Begin
    ChequesFecha := utiles.sFormatoFecha(cheques_mov.FieldByName('fecha').AsString);
  end else Begin
    ChequesFecha := '';
  end;
end;

procedure TTPagosMunicipio_Asociacion.ImprimirRecibo(xsucursal, xnumero: String; salida: char);
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

  municipio.getDatos(ccodprest);
  totales[1] := Efectivo + Cheques;
  if Length(Trim(margenIzq)) = 0 then margenIzq := '0';
  esp := espacios + StrToInt(margenIzq);

  for i := 1 to strtoint(margensup) do list.Linea(0, 0, '     ', 1, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(63, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + Fechacobro, 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 60, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + Fechacobro, 3, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');

  list.Linea(0, 0, '        ' + utiles.espacios(StrToInt(margenIzq)) + 'Aportes Municipales y Comunales', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, '        ' + utiles.espacios(StrToInt(margenIzq)) + 'Aportes Municipales y Comunales', 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '     ', 1, 'Arial, normal, 20', salida, 'S');
  list.Linea(0, 0, '     ', 1, 'Arial, normal, 18', salida, 'S');

  list.Linea(0, 0, utiles.espacios(esp + 5) + municipio.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + municipio.nombre, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp + 5) + municipio.domicilio, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + municipio.domicilio, 2, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp + 5) + municipio.localidad, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(60, list.lineactual, utiles.espacios(StrToInt(margenIzq)) + municipio.codpost, 2, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + municipio.localidad, 3, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 60, list.Lineactual, utiles.espacios(StrToInt(margenIzq)) + municipio.codpost, 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, '  ', 1, 'Arial, normal, 12', salida, 'S');
  if Length(Trim(municipio.Cuit)) = 13 then list.Linea(0, 0, utiles.espacios(esp + 5) + municipio.cuit, 1, 'Arial, normal, 9', salida, 'N') else list.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(45, list.lineactual, municipio.Codpfis, 2, 'Arial, normal, 9', salida, 'N');
  if Length(Trim(municipio.Cuit)) = 13 then list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp) + municipio.cuit, 3, 'Arial, normal, 9', salida, 'N') else list.Linea(StrToInt(lineadiv), list.Lineactual, '', 3, 'Arial, normal, 9', salida, 'N');
  list.Linea(StrToInt(lineadiv) + 45, list.Lineactual, municipio.codpfis, 4, 'Arial, normal, 9', salida, 'S');

  list.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');


  list.Linea(0, 0, utiles.espacios(esp - 18) + 'Recibí(mos) la suma de Pesos:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 18) + 'Recibí(mos) la suma de Pesos:', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp - 17) + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[1])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[1])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 1, 2) + ' ctvos.', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 17) + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[1])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[1])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[1])))) - 1, 2) + ' ctvos.', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(esp - 18) + 'En Concepto de:', 1, 'Arial, normal, 8', salida, 'N');
  list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 18) + 'En Concepto de:', 2, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  BuscarReciboCobro(xsucursal, xnumero, '01');
  idanter[1] := recibos_detalle.FieldByName('sucursal').AsString;
  idanter[2] := recibos_detalle.FieldByName('numero').AsString;
  l := 0; totales[1] := 0;
  while not recibos_detalle.Eof do Begin  // Detalle de Cobros
    if (recibos_detalle.FieldByName('sucursal').AsString <> idanter[1]) or (recibos_detalle.FieldByName('numero').AsString <> idanter[2]) then Break;
    list.Linea(0, 0, utiles.espacios(esp - 17) + recibos_detalle.FieldByName('concepto').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.importe(65, list.Lineactual, '', recibos_detalle.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
    list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 17) + recibos_detalle.FieldByName('concepto').AsString, 3, 'Arial, normal, 8', salida, 'S');
    list.importe(StrToInt(lineadiv) + 65, list.Lineactual, '', recibos_detalle.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(StrToInt(lineadiv) + 66, list.Lineactual, ' ', 5, 'Arial, normal, 8', salida, 'S');
    Inc(l);
    idanter[1] := recibos_detalle.FieldByName('sucursal').AsString;
    idanter[2] := recibos_detalle.FieldByName('numero').AsString;
    totales[1] := totales[1] + recibos_detalle.FieldByName('monto').AsFloat;
    recibos_detalle.Next;
  end;

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
      tcuotas[i, 2] := entbcos.descrip;
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
        list.Linea(20 + ((esp - 7) div 3), list.Lineactual,tcuotas[j, 1], 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(30 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 2], 3, 'Arial, normal, 8', salida, 'N');
        list.importe(67 + ((esp - 7) div 3), list.Lineactual, '', StrToFloat(tcuotas[j, 3]), 4, 'Arial, normal, 8');

        if j = 2 then list.Linea(StrToInt(lineadiv), list.Lineactual, utiles.espacios(esp - 7) + 'En Cheques:', 5, 'Arial, normal, 8', salida, 'N') else list.Linea(StrToInt(lineadiv), list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'N');
        list.Linea(StrToInt(lineadiv) + 20 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 1], 6, 'Arial, normal, 8', salida, 'N');
        list.Linea(StrToInt(lineadiv) + 30 + ((esp - 7) div 3), list.Lineactual, tcuotas[j, 2], 7, 'Arial, normal, 8', salida, 'N');
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

  list.FinList;
  if salida = 'I' then list.ImprimirVetical;
end;

procedure TTPagosMunicipio_Asociacion.getFormatoImpresion;
// Objetivo...: Recuperar Modelo de Impresión
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

procedure TTPagosMunicipio_Asociacion.ListarControlRecibos(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Control de Recibos
var
  r, rsql: TQuery;
  f: Byte;
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Control de Ingresos por Cobro de Aportes de Municipios/Comunas - Período: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  List.Titulo(1, list.Lineactual, 'Nº de Recibo', 2, 'Arial, cursiva, 8');
  List.Titulo(20, list.Lineactual, 'Expediente      Prestatario', 3, 'Arial, cursiva, 8');
  List.Titulo(74, list.Lineactual, 'Efectivo', 4, 'Arial, cursiva, 8');
  List.Titulo(88, list.Lineactual, 'Cheques', 5, 'Arial, cursiva, 8');
  List.Titulo(96, list.Lineactual, 'An.', 6, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  totales[1] := 0; totales[2] := 0; idanter[1] := ''; idanter[2] := '';

  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, 'Control Recibos de Pagos de Municipios y Comunas', 1, 'Arial, normal, 14', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  rsql := datosdb.tranSQL('select distinct * from recibos_detalleMC where fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha, idc, tipo, sucrec, numrec');
  rsql.Open; idanter[1] := 'N';
  idanter[3] := rsql.FieldByName('fecha').AsString;
  while not rsql.Eof do Begin
    if rsql.FieldByName('fecha').AsString <> idanter[3] then TotalPorDia(salida);
    if rsql.FieldByName('idc').AsString + rsql.FieldByName('tipo').AsString + rsql.FieldByName('sucrec').AsString + rsql.FieldByName('numrec').AsString <> idanter[2] then Begin
      BuscarCobro(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString);
      municipio.getDatos(Copy(distribucioncobros.FieldByName('expediente').AsString, 1, 4));
      list.Linea(0, 0, rsql.FieldByName('idc').AsString + '  ' + rsql.FieldByName('tipo').AsString + '  ' + rsql.FieldByName('sucrec').AsString + '  ' + rsql.FieldByName('numrec').AsString, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(20, list.Lineactual, distribucioncobros.FieldByName('expediente').AsString + '  ' + Copy(municipio.nombre, 1, 30), 2, 'Arial, normal, 9', salida, 'N');
      list.importe(80, list.Lineactual, '', distribucioncobros.FieldByname('efectivo').AsFloat, 3, 'Arial, normal, 9');
      list.importe(95, list.Lineactual, '', distribucioncobros.FieldByname('cheques').AsFloat, 4, 'Arial, normal, 9');
      list.Linea(96, list.Lineactual, rsql.FieldByName('anulado').AsString, 5, 'Arial, normal, 9', salida, 'S');
      r := datosdb.tranSQL('select * from cheques_movMC where sucursal = ' + '"' + rsql.FieldByName('sucursal').AsString + '"' + ' and numero = ' + '"' + rsql.FieldByName('numero').AsString + '"');
      r.Open; f := 0;
      while not r.Eof do Begin
        f := 1;
        list.Linea(0, 0, '     ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(12, list.Lineactual, r.FieldByName('nrocheque').AsString, 2, 'Arial, normal, 8', salida, 'N');
        entbcos.getDatos(r.FieldByName('codbanco').AsString);
        list.Linea(22, list.Lineactual, entbcos.descrip, 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(55, list.Lineactual, r.FieldByName('filial').AsString, 4, 'Arial, normal, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', r.FieldByName('monto').AsFloat, 5, 'Arial, normal, 8');
        list.Linea(96, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'N');
        r.Next;
      end;
      r.Close; r.Free;

      if Length(Trim(rsql.FieldByName('anulado').AsString)) = 0 then Begin
        totales[1] := totales[1] + distribucioncobros.FieldByname('efectivo').AsFloat;
        totales[2] := totales[2] + distribucioncobros.FieldByname('cheques').AsFloat;
        totales[3] := totales[3] + distribucioncobros.FieldByname('efectivo').AsFloat;
        totales[4] := totales[4] + distribucioncobros.FieldByname('cheques').AsFloat;
      end;
      idanter[1] := 'S';

      if f = 1 then list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      idanter[2] := rsql.FieldByName('idc').AsString + rsql.FieldByName('tipo').AsString + rsql.FieldByName('sucrec').AsString + rsql.FieldByName('numrec').AsString;
    end;
    idanter[3] := rsql.FieldByName('fecha').AsString;

    rsql.Next;
  end;
  rsql.Close; rsql := Nil;

  TotalPorDia(salida);

  if (totales[1] + totales[2] > 0) or (idanter[1] = 'S') then Begin
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
  end;

  if idanter[1] = 'N' then list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 10', salida, 'S');
  idanter[2] := '';

  list.FinList;
end;

procedure TTPagosMunicipio_Asociacion.TotalPorDia(salida: char);
// Objetivo...: Ruptura por Fecha
Begin
  if totales[3] + totales[4] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Subtotal Fecha ' + utiles.sFormatoFecha(idanter[3]) + ':', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(80, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 9');
    list.importe(95, list.Lineactual, '', totales[4], 3, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
  totales[3] := 0; totales[4] := 0;
end;

procedure TTPagosMunicipio_Asociacion.ListarControlChequesRecibidos(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Control de Recibos
Begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Control de Cheques Recibos - Período: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  List.Titulo(0, 0, '', 1, 'Arial, cursiva, 8');
  List.Titulo(1, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  List.Titulo(10, list.Lineactual, 'Nº Cheque', 3, 'Arial, cursiva, 8');
  List.Titulo(19, list.Lineactual, 'Entidad Bancaria', 4, 'Arial, cursiva, 8');
  List.Titulo(43, list.Lineactual, 'Filial', 5, 'Arial, cursiva, 8');
  List.Titulo(57, list.Lineactual, 'Prestatario', 6, 'Arial, cursiva, 8');
  List.Titulo(91, list.Lineactual, 'Monto', 7, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  list.Linea(0, 0, 'Cheques de Pagos de Créditos - Municipios y Comunas', 1, 'Arial, normal, 14', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  if rsql = Nil then rsql := datosdb.tranSQL('select * from cheques_movMC where fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha, codbanco');
  rsql.Open; totales[1] := 0;
  idanter[1] := rsql.FieldByName('fecha').AsString;
  while not rsql.Eof do Begin
    if rsql.FieldByName('fecha').AsString <> idanter[1] then TotalDiaCheque(salida);
    getDatosCheque(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString, rsql.FieldByName('items').AsString);
    list.Linea(0, 0, '     ' + ChequesFecha, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.Lineactual, rsql.FieldByName('nrocheque').AsString, 2, 'Arial, normal, 8', salida, 'N');
    entbcos.getDatos(rsql.FieldByName('codbanco').AsString);
    getDatosCobro(rsql.FieldByName('sucursal').AsString, rsql.FieldByName('numero').AsString);
    municipio.getDatos(ccodprest);
    list.Linea(19, list.Lineactual, Copy(entbcos.descrip, 1, 30), 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(43, list.Lineactual, Copy(rsql.FieldByName('filial').AsString, 1, 20), 4, 'Arial, normal, 8', salida, 'N');
    list.Linea(57, list.Lineactual, Copy(municipio.nombre, 1, 35), 5, 'Arial, normal, 8', salida, 'N');
    list.importe(96, list.Lineactual, '', rsql.FieldByName('monto').AsFloat, 6, 'Arial, normal, 8');
    list.Linea(97, list.Lineactual, '', 7, 'Arial, normal, 8', salida, 'N');
    totales[1] := totales[1] + rsql.FieldByname('monto').AsFloat;
    totales[2] := totales[2] + rsql.FieldByname('monto').AsFloat;
    idanter[1] := rsql.FieldByName('fecha').AsString;
    rsql.Next;
  end;
  rsql.Close; rsql.Free; rsql := Nil;

  TotalDiaCheque(salida);

  if totales[1] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Total:', 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(96, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 8', salida, 'S');
  end;

  if totales[1] = 0 then list.Linea(0, 0, 'No se Registraron Operaciones', 1, 'Arial, normal, 10', salida, 'S');

  list.FinList;
end;

procedure TTPagosMunicipio_Asociacion.TotalDiaCheque(salida: char);
// Objetivo...: Agregar un items
Begin
  if totales[2] > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, '     Total Fecha ' + utiles.sFormatoFecha(idanter[1]), 1, 'Arial, negrita, 9', salida, 'N');
    list.importe(96, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  totales[2] := 0;
end;

procedure TTPagosMunicipio_Asociacion.ListarControlChequesRecibosFechaRecepcion(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar control por fecha de recepcion
Begin
  rsql := datosdb.tranSQL('select distribucioncobrosMC.sucursal, distribucioncobrosMC.numero, distribucioncobrosMC.fecha AS fecha1, cheques_movMC.* from distribucioncobrosMC, cheques_movMC ' +
                          'where distribucioncobrosMC.sucursal = cheques_movMC.sucursal and distribucioncobrosMC.numero = cheques_movMC.numero and distribucioncobrosMC.fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and distribucioncobrosMC.fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha, codbanco');
  ListarControlChequesRecibidos(xdfecha, xhfecha, salida);
end;

function TTPagosMunicipio_Asociacion.setRecibosFechas(xdesde, xhasta: String): TQuery;
// Objetivo...: devolver recibos fecha
Begin
  Result := datosdb.tranSQL('select recibos_detallemc.sucursal, recibos_detallemc.numero, recibos_detallemc.items, recibos_detallemc.idc, recibos_detallemc.tipo, recibos_detallemc.sucrec, recibos_detallemc.numrec, recibos_detallemc.fecha, ' +
                            'distribucioncobrosmc.expediente from recibos_detallemc, distribucioncobrosmc where recibos_detallemc.sucursal = distribucioncobrosmc.sucursal and recibos_detallemc.numero = distribucioncobrosmc.numero and recibos_detallemc.items = ' +
                            '''' + '01' + '''' + ' and recibos_detallemc.fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and recibos_detallemc.fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' +
                            ' order by numrec');
end;

procedure TTPagosMunicipio_Asociacion.AjustarNumeroRecibo(xsucursalrecibo, xnumerorecibo, xnumerocorrelativo: String);
// Objetivo...: Ajustar Número de Recibo
Begin
  datosdb.tranSQL('update recibos_detallemc set numrec = ' + '''' + xnumerocorrelativo + '''' + ' where sucursal = ' + '''' + xsucursalrecibo + '''' + ' and numero = ' + '''' + xnumerorecibo + '''');
  datosdb.closeDB(recibos_detalle); recibos_detalle.Open;
end;

function TTPagosMunicipio_Asociacion.setCodigoBarras: Boolean;
Begin
  codigo_barras.First;
  if codigo_barras.FieldByName('activar').AsInteger = 1 then codigobarras := True else codigobarras := False;
  Result := codigobarras;
end;

//------------------------------------------------------------------------------

procedure TTPagosMunicipio_Asociacion.IniciarExpedientes;
// Objetivo...: Iniciar Expedientes
Begin
  idanter2 := '';
end;

procedure TTPagosMunicipio_Asociacion.Transferir_Work(xperiodo, xidtitular: String);
// Objetivo...: Transferir datos a area temporal
var
  tabla: TTable;
Begin
  if xperiodo + xidtitular <> idanter2 then Begin
    tabla := datosdb.openDB('aportesMC_Work', '');
    tabla.Open;
    datosdb.tranSQL('delete from ' + tabla.TableName + ' where anio = ' + '''' + xperiodo + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
    datosdb.Filtrar(aportesMC, 'anio = ' + '''' + xperiodo + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
    aportesMC.First;
    while not aportesMC.Eof do Begin
      if datosdb.Buscar(tabla, 'anio', 'idtitular', aportesMC.FieldByName('anio').AsString, aportesMC.FieldByName('idtitular').AsString) then tabla.Edit else tabla.Append;
      tabla.FieldByName('anio').AsString      := aportesMC.FieldByName('anio').AsString;
      tabla.FieldByName('idtitular').AsString := aportesMC.FieldByName('idtitular').AsString;
      tabla.FieldByName('mes').AsString       := aportesMC.FieldByName('mes').AsString;
      tabla.FieldByName('fecha').AsString     := aportesMC.FieldByName('fecha').AsString;
      tabla.FieldByName('recibo').AsString    := aportesMC.FieldByName('recibo').AsString;
      tabla.FieldByName('concepto').AsString  := aportesMC.FieldByName('concepto').AsString;
      tabla.FieldByName('monto').AsFloat      := aportesMC.FieldByName('monto').AsFloat;
      tabla.FieldByName('recargo').AsFloat    := aportesMC.FieldByName('recargo').AsFloat;
      tabla.FieldByName('estado').AsString    := aportesMC.FieldByName('estado').AsString;
      try
        tabla.Post
       except
        tabla.Cancel
      end;
      aportesMC.Next;
    end;

    datosdb.QuitarFiltro(aportesMC);
    datosdb.closeDB(tabla);

    idanter2 := xperiodo + xidtitular;
  end;
end;

procedure TTPagosMunicipio_Asociacion.Restaurar_Work(xperiodo, xidtitular: String);
// Objetivo...: Transferir datos a area temporal
var
  tabla: TTable;
Begin
  tabla := datosdb.openDB('aportesMC_Work', '');
  tabla.Open;
  datosdb.tranSQL('delete from ' + aportesMC.TableName + ' where anio = ' + '''' + xperiodo + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
  datosdb.Filtrar(tabla, 'anio = ' + '''' + xperiodo + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if datosdb.Buscar(aportesMC, 'anio', 'idtitular', tabla.FieldByName('anio').AsString, tabla.FieldByName('idtitular').AsString) then aportesMC.Edit else aportesMC.Append;
    aportesMC.FieldByName('anio').AsString      := tabla.FieldByName('anio').AsString;
    aportesMC.FieldByName('idtitular').AsString := tabla.FieldByName('idtitular').AsString;
    aportesMC.FieldByName('mes').AsString       := tabla.FieldByName('mes').AsString;
    aportesMC.FieldByName('fecha').AsString     := tabla.FieldByName('fecha').AsString;
    aportesMC.FieldByName('recibo').AsString    := tabla.FieldByName('recibo').AsString;
    aportesMC.FieldByName('concepto').AsString  := tabla.FieldByName('concepto').AsString;
    aportesMC.FieldByName('monto').AsFloat      := tabla.FieldByName('monto').AsFloat;
    aportesMC.FieldByName('recargo').AsFloat    := tabla.FieldByName('recargo').AsFloat;
    aportesMC.FieldByName('estado').AsString    := tabla.FieldByName('estado').AsString;
    try
      aportesMC.Post
     except
      aportesMC.Cancel
    end;
    tabla.Next;
  end;

  datosdb.closeDB(tabla);
  datosdb.refrescar(aportesMC);
end;

procedure TTPagosMunicipio_Asociacion.Transferir_WorkActualizado(xcodigobarra, xfecha, xhora, xperiodo, xidtitular: String);
// Objetivo...: Transferir datos a area temporal
var
  tabla: TTable;
Begin
  tabla := datosdb.openDB('aportesMC_CB', '');
  tabla.Open;
  datosdb.tranSQL('delete from ' + tabla.TableName + ' where anio = ' + '''' + xperiodo + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
  datosdb.Filtrar(aportesMC, 'anio = ' + '''' + xperiodo + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
  aportesMC.First;
  while not aportesMC.Eof do Begin
    if datosdb.Buscar(tabla, 'codigobarra', 'fechac', 'hora', 'anio', 'idtitular', xcodigobarra, utiles.sExprFecha2000(xfecha), xhora, aportesMC.FieldByName('anio').AsString, aportesMC.FieldByName('idtitular').AsString) then tabla.Edit else tabla.Append;
    tabla.FieldByName('codigobarra').AsString := xcodigobarra;
    tabla.FieldByName('fechac').AsString      := utiles.sExprFecha2000(xfecha);
    tabla.FieldByName('hora').AsString        := xhora;
    tabla.FieldByName('anio').AsString        := aportesMC.FieldByName('anio').AsString;
    tabla.FieldByName('idtitular').AsString   := aportesMC.FieldByName('idtitular').AsString;
    tabla.FieldByName('mes').AsString         := aportesMC.FieldByName('mes').AsString;
    tabla.FieldByName('fecha').AsString       := aportesMC.FieldByName('fecha').AsString;
    tabla.FieldByName('recibo').AsString      := aportesMC.FieldByName('recibo').AsString;
    tabla.FieldByName('concepto').AsString    := aportesMC.FieldByName('concepto').AsString;
    tabla.FieldByName('monto').AsFloat        := aportesMC.FieldByName('monto').AsFloat;
    tabla.FieldByName('recargo').AsFloat      := aportesMC.FieldByName('recargo').AsFloat;
    tabla.FieldByName('estado').AsString      := aportesMC.FieldByName('estado').AsString;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    aportesMC.Next;
  end;

  datosdb.QuitarFiltro(aportesMC);
  datosdb.closeDB(tabla);

end;

procedure TTPagosMunicipio_Asociacion.Restaurar_WorkActualizado(xcodigobarra, xfecha, xhora, xperiodo, xidtitular: String);
// Objetivo...: Transferir datos a area temporal
var
  tabla: TTable;
Begin
  tabla := datosdb.openDB('aportesMC_CB', '');
  tabla.Open;
  datosdb.Filtrar(tabla, 'codigobarra = ' + '''' + xcodigobarra + '''' + ' and idtitular = ' + '''' + xidtitular + '''');
  tabla.First;
  while not tabla.Eof do Begin
    if Buscar(tabla.FieldByName('anio').AsString, tabla.FieldByName('idtitular').AsString, tabla.FieldByName('mes').AsString) then aportesMC.Edit else aportesMC.Append;
    aportesMC.FieldByName('anio').AsString        := tabla.FieldByName('anio').AsString;
    aportesMC.FieldByName('idtitular').AsString   := tabla.FieldByName('idtitular').AsString;
    aportesMC.FieldByName('mes').AsString         := tabla.FieldByName('mes').AsString;
    aportesMC.FieldByName('fecha').AsString       := tabla.FieldByName('fecha').AsString;
    aportesMC.FieldByName('recibo').AsString      := tabla.FieldByName('recibo').AsString;
    aportesMC.FieldByName('concepto').AsString    := tabla.FieldByName('concepto').AsString;
    aportesMC.FieldByName('monto').AsFloat        := tabla.FieldByName('monto').AsFloat;
    aportesMC.FieldByName('recargo').AsFloat      := tabla.FieldByName('recargo').AsFloat;
    aportesMC.FieldByName('estado').AsString      := tabla.FieldByName('estado').AsString;
    try
      aportesMC.Post
     except
      aportesMC.Cancel
    end;
    tabla.Next;
  end;

  datosdb.QuitarFiltro(tabla);
  datosdb.closeDB(tabla);
  datosdb.refrescar(aportesMC);

end;

procedure TTPagosMunicipio_Asociacion.AgregarItemsRecibo(xitems, xconcepto, xmonto: String);
// Objetivo...: Anexar Items a Recibos
var
  i, j: integer;
Begin
  if xitems = '01' then Begin
    For i := 1 to 50 do
      For j := 1 to 3 do mov[i, j] := '';
    itbol := 0;
  end;

  Inc(itbol);
  mov[itbol, 1] := xitems;
  mov[itbol, 2] := xconcepto;
  mov[itbol, 3] := xmonto;
end;

procedure TTPagosMunicipio_Asociacion.ListarRecibo(xcodprest, xperiodo, xcuentabcaria, xfechaemis, xfechavto1, xmontovto1, xfechavto2, xmontovto2, xidcredito: String; salida: char; xtipo_recibo, xidc, xtipo, xsucursal, xnumero: String);
// Objetivo...: Listar Recibo
var
  i, ldet, items: Integer;
  codigobarra, fecha, hora: String;
  espacios_en_det, li: Integer;
  difmontos: Real;
  archivo: TextFile;
Begin
  list.Setear(salida);
  getFormatoImpresion;
  list.NoImprimirPieDePagina;
  if Length(Trim(margenIzq)) = 0 then margenIzq := '0';

  lineasdet := '10';

  list.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', 'ADR', 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  municipio.getDatos(xcodprest);

  // 1º Cuerpo
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'Municipio/Comuna: ' + xcodprest + '  ' + municipio.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(75, list.Lineactual, 'Fecha: ' + xfechaemis, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + ' ', 1, 'Arial, normal, 9', salida, 'N');

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  difmontos   := StrToFloat(xmontovto2) - StrToFloat(xmontovto1);
  codigobarra := excluirexpedientes.Ente + xcuentabcaria + utiles.sLlenarIzquierda(xcodprest, 4, '0') + '00' + Copy(xfechavto1, 7,2) + utiles.sLlenarIzquierda(utiles.setFechaJuliana(xfechavto1), 3, '0') + utiles.setMontoSinSignosDecimales(xmontovto1, 7) +
                 utiles.sLlenarIzquierda(excluirexpedientes.Intervalo, 2, '0') + utiles.setMontoSinSignosDecimales(FloatToStr(difmontos), 7);
  codigobarra := codigobarra + digitoverificador.setDigitoVerificador(codigobarra);


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

  List.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + '1º Vto.: ' + xfechavto1, 1, 'Arial, normal, 9', salida, 'N');
  list.importe(30, list.Lineactual, '', StrToFloat(xmontovto1), 2, 'Arial, normal, 9');
  list.Linea(50, list.Lineactual, '2º Vto.: ' + xfechavto2, 3, 'Arial, normal, 9', salida, 'N');
  list.importe(80, list.Lineactual, '', StrToFloat(xmontovto2), 4, 'Arial, normal, 9');
  list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

  List.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, normal, 14', salida, 'N');
  List.Linea(2, list.Lineactual, '!' + codigobarra + '!', 2, 'IDAutomationCode39, normal, 14', salida, 'S');

  For i := 1 to 5 do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  // 2º Cuerpo
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', 'Mun/Com.', 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  For i := 1 to StrToInt(lineassep) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'Municipio/Comuna: ' + xcodprest + '  ' + municipio.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(75, list.Lineactual, 'Fecha: ' + utiles.setFechaActual, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + ' ', 1, 'Arial, normal, 9', salida, 'N');

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

  List.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + '1º Vto.: ' + xfechavto1, 1, 'Arial, normal, 9', salida, 'N');
  list.importe(30, list.Lineactual, '', StrToFloat(xmontovto1), 2, 'Arial, normal, 9');
  list.Linea(50, list.Lineactual, '2º Vto.: ' + xfechavto2, 3, 'Arial, normal, 9', salida, 'N');
  list.importe(80, list.Lineactual, '', StrToFloat(xmontovto2), 4, 'Arial, normal, 9');
  list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

  For i := 1 to 5 do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');

  // 3º Cuerpo
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
  list.derecha(95, list.Lineactual, '', 'Banco', 2, 'Arial, normal, 8');
  list.Linea(96, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  For i := 1 to StrToInt(lineassep) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + 'Prestatario: ' + xcodprest + '  ' + municipio.nombre, 1, 'Arial, normal, 9', salida, 'N');
  list.Linea(75, list.Lineactual, 'Fecha: ' + utiles.setFechaActual, 2, 'Arial, normal, 9', salida, 'S');
  list.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + ' ', 1, 'Arial, normal, 9', salida, 'N');

  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');

  List.Linea(0, 0, utiles.espacios(StrToInt(margenIzq)) + '1º Vto.: ' + xfechavto1, 1, 'Arial, normal, 9', salida, 'N');
  list.importe(30, list.Lineactual, '', StrToFloat(xmontovto1), 2, 'Arial, normal, 9');
  list.Linea(50, list.Lineactual, '2º Vto.: ' + xfechavto2, 3, 'Arial, normal, 9', salida, 'N');
  list.importe(80, list.Lineactual, '', StrToFloat(xmontovto2), 4, 'Arial, normal, 9');
  list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

  AssignFile(archivo, 'c:\codigobarra.txt');
  Rewrite(archivo);
  WriteLn(archivo, codigobarra);
  closeFile(archivo);

  if xtipo_recibo <> 'NNN' then Begin
    fecha := utiles.setFechaActual;
    hora  := utiles.setHoraActual24;

    if salida = 'I' then Begin      // Rgistramos la transacción
      // Transferimos el Expediente Actualizado
      Transferir_WorkActualizado(codigobarra, fecha, hora, xperiodo, xcodprest);

      For i := 1 to itbol do Begin
        if Length(Trim(mov[i, 1])) = 0 then Break;
        //boleta.RegistrarBoletaCodigoBarras(codigobarra, fecha, hora, xcodprest, '0000', xfechaemis, xfechavto1, xfechavto2, xcuentabcaria, StrToFloat(xmontovto1), StrToFloat(xmontovto2), mov[i, 1], mov[i, 2], xtipo_recibo, xidc, xtipo, xsucursal, xnumero, StrToFloat(mov[i, 3]), items);
      end;
    end;
  end;

  list.FinList;
end;

procedure TTPagosMunicipio_Asociacion.ReimprimirRecibo(xcodigobarra, xfecha, xhora: String; salida: char);
// Obejtivo...: listar recibo
Begin
  boleta.getDatosBoletaCodigoBarras(xcodigobarra, xfecha, xhora);
  lineasdet := '10';
  ListarRecibo(boleta.codprest, boleta.expediente, boleta.ctactebcaria, boleta.fechaemis, boleta.fechavto1, FloatToStr(boleta.montovto1), boleta.fechavto2, FloatToStr(boleta.montovto2), '', salida, 'NNN', boleta.Idc, boleta.Tipo, boleta.Sucursal, boleta.Numero);
end;

//------------------------------------------------------------------------------

procedure TTPagosMunicipio_Asociacion.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  ctactebcos.conectar;
  municipio.conectar;
  empresa.conectar;
  entbcos.conectar;
  excluirexpedientes.conectar;
  if conexiones = 0 then Begin
    if not aportesMC.Active then aportesMC.Open;
    if not distribucioncobros.Active then distribucioncobros.Open;
    if not recibos_detalle.Active then recibos_detalle.Open;
    if not cheques_mov.Active then cheques_mov.Open;
    if not formato_Impresion.Active then formato_Impresion.Open;
    if not codigo_barras.Active then codigo_barras.Open;
  end;
  Inc(conexiones);
end;

procedure TTPagosMunicipio_Asociacion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  ctactebcos.desconectar;
  municipio.desconectar;
  empresa.desconectar;
  entbcos.desconectar;
  excluirexpedientes.desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(aportesMC);
    datosdb.closeDB(distribucioncobros);
    datosdb.closeDB(recibos_detalle);
    datosdb.closeDB(cheques_mov);
    datosdb.closeDB(formato_Impresion);
    datosdb.closeDB(codigo_barras);
  end;
end;

{===============================================================================}

function aportesMC: TTPagosMunicipio_Asociacion;
begin
  if xaportesMC = nil then
    xaportesMC := TTPagosMunicipio_Asociacion.Create;
  Result := xaportesMC;
end;

{===============================================================================}

initialization

finalization
  xaportesMC.Free;

end.
