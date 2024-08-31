unit CInformesGastos_CCSR;

interface

uses CLotes_CCSRural, CRegGastos_CCSR, CRegGastosParticulares_CCSR, CRegGastosComunes_CCSR,
     CPropitarios_CCSRural, CGastosParticulares_CCSRural, CGastosComunes_CCSRural, CBDT, SysUtils,
     DBTables, CUtiles, CListar, CIDBFM, CUtilidadesArchivos, Classes;

const
  posiciones = 4;

type

TTInformesGastosCCSR = class(TTRegistracionGastos)
  TotalDeLotes, PorcentajeLC, superficieLotes, Interes2vto: Real;
  Leyenda1, Leyenda2, tamanio_fuente, Diavto1, Diavto2: String;
  ruptura: Boolean;
  TipoLiquidacion, Lineastalon: Integer;
  parametro1, parametro2, parametro3, parametro4, parametro5, parametro6, parametro7: string;
  cobros, totalesbco, parametros: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  procedure InfLiquidacionExpensas(xperiodo, xnroliq, xfechavto: String; listSel: TStringList; xmargenIzquierdo, xtipoLiquidacion: Integer; xcantlotes, xsuplotes: Real; xliquidartalon: Boolean; salida: char);
  procedure InfEtiquetasExpensas(xperiodo: String; listSel: TStringList; xmargenIzquierdo: Integer; salida: char);
  procedure InfDetalladoDeGastos(xperiodo, xnroliq, xfechavto: String; listSel: TStringList; salida: char);
  procedure InfResumenDeGastos(xperiodo, xnroliq, xfechavto: String; listSel: TStringList; salida: char);
  procedure InfPlanillaDeGastos(xperiodo, xnroliq: String; listSel: TStringList; salida: char);
  procedure InformePlanillaMediciones(salida: char);
  procedure InfDetalleConsumoElectricoAnual(xperiodo, xnroliq: String; salida: char);
  procedure InformeDeMediciones(xperiodo, xnroliq: String; salida: char);
  procedure InformeMedicionesAgua(xperiodo, xnroliq: String; salida: char);

  function  setCobros(xperiodo: String): TStringList;
  procedure RegistrarCobro(xperiodo, xidpropiet, xfecha, xobservacion: String); overload;
  procedure InformeCobros(xperiodo: String; xactivo: Boolean; salida: char);
  procedure InformeCobrosPendientes(xperiodo: String; xactivo: Boolean; salida: char);
  procedure InformeCobrosAnual(xperiodo: String; xestado: Boolean; salida: char);
  procedure InformeCobrosAnualAdeudado(xperiodo: String; xestado: Boolean; salida: char);
  procedure CargarParametros(xid: integer);
  procedure GuardarParametros(xid: integer; parametro1, parametro2, parametro3, parametro4, parametro5, parametro6, parametro7: string);

  function  getMontosRedBancaria(xperiodo: string): TQuery;
 private
  { Declaraciones Privadas }
  listItems: array[1..50, 1..5] of String;
  totales: array[1..posiciones] of Real;
  resanual: array[1..150, 1..13] of String;
  items: Integer; idanter: String; nl, ocultardetalle: Boolean;
  mizq: String;
  totgral: Real;
  procedure listGastosComunes(xperiodo, xidpropiet, xnroliq, fuente: String; salida: char);
  procedure listGastosParticulares(xperiodo, xidpropiet, fuente: String; salida: char);
  procedure listDetCom(idanter, fuente: String; salida: Char);
  procedure listDetPar(idanter, fuente: String; salida: Char);
  procedure Inf_Gastos(xperiodo, xnroliq, xfechavto, xtitulo: String; listSel: TStringList; salida: char);
  procedure RegistrarCobro(xperiodo, xidpropiet, xnombre: String; xmonto: Real); overload;
  procedure InfCobros(xperiodo, xtipo_inf: String; xactivo: Boolean; salida: char);
  procedure InfCobrosAnual(xanio, xtipo_inf: String; xestado: Boolean; salida: char);
  function  setProp(xidpropiet: String): Integer;
  procedure IniciarArreglos;
end;

function infgastos: TTInformesGastosCCSR;

implementation

var
  xinfgastos: TTInformesGastosCCSR = nil;

constructor TTInformesGastosCCSR.Create;
// Objetivo...: Cosntruir la instancia de un objeto
begin
  inherited Create;
  cobros      := datosdb.openDB('cobros', '');
  totalesbco  := datosdb.openDB('totalesbcos', '');
  parametros  := datosdb.openDB('parametrosbcos', '');
  LineasTalon := 40;
end;

procedure TTInformesGastosCCSR.InfLiquidacionExpensas(xperiodo, xnroliq, xfechavto: String; listSel: TStringList; xmargenIzquierdo, xtipoLiquidacion: Integer; xcantlotes, xsuplotes: Real; xliquidartalon: Boolean; salida: char);
// Objetivo...: Listar Informe de Liquidaci�n de Expensas
var
  i, j, r: Integer; et: Boolean;
  interes, tasaint: Real;
  ffuente, lin, mesper, anper, v1, v2, v3: String;

  procedure guardarTotalesBanco(xperiodo, xidpropiet, xfecha1, xfecha2: string; xmonto1, xmonto2: real);
  begin
    if (datosdb.Buscar(totalesbco, 'periodo', 'idpropiet', xperiodo, xidpropiet)) then totalesbco.edit else totalesbco.append;
    totalesbco.fieldbyname('periodo').asstring := xperiodo;
    totalesbco.fieldbyname('idpropiet').asstring := xidpropiet;
    totalesbco.fieldbyname('fechavto1').asstring := utiles.sExprFecha2000(xfecha1);
    totalesbco.fieldbyname('fechavto2').asstring := utiles.sExprFecha2000(xfecha2);
    totalesbco.fieldbyname('fechavto3').asstring := utiles.sExprFecha2000(xfecha2);
    totalesbco.fieldbyname('monto1').asfloat     := xmonto1;
    totalesbco.fieldbyname('monto2').asfloat     := xmonto2;
    totalesbco.fieldbyname('monto3').asfloat     := xmonto2;
    totalesbco.fieldbyname('msgticket').asstring := parametro3 + ' ' + xperiodo;
    totalesbco.fieldbyname('msgpantalla').asstring := parametro4;
    try
      totalesbco.post
    except
      totalesbco.cancel
    end;
    datosdb.refrescar(totalesbco);
  end;

Begin
  tipoLiquidacion := xtipoLiquidacion;
  superficieLotes := xsuplotes;
  for i := 1 to posiciones do totales[i] := 0;
  if xmargenizquierdo > 0 then mizq := utiles.espacios(xmargenizquierdo) else mizq := '';
  et := formatosimpr.Active;
  if not et then formatosimpr.Open;
  getFormatoImpresion('F01');
  if salida <> 'T' then list.Setear(salida) else list.IniciarImpresionModoTexto;
  list.NoImprimirPieDePagina;

  datosdb.tranSQL('delete from totalesbcos where periodo = ' + '''' + xperiodo + '''');
  totalesbco.open;
  CargarParametros(1);

  if xliquidartalon then Begin
    list.ReservarLineasParaSubtotales(lineastalon);
    r := list.LineasSubtotales;
    list.ReservarLineasParaSubtotales(0);
  end;

  For i := 1 to listSel.Count do Begin
    if Length(Trim(listSel.Strings[i-1])) = 0 then Break;
    if salida <> 'T' then
      if ruptura then list.IniciarNuevaPagina;
    propietario.getDatos(listSel.Strings[i-1]);
    lote.setLotesPropietario(listSel.Strings[i-1]);
    list.IniciarMemoImpresiones(formatosImpr, 'modelo', Tamanio);
    list.RemplazarEtiquetasEnMemo('#propietario', propietario.nombre);
    list.RemplazarEtiquetasEnMemo('#id', propietario.codigo);
    list.RemplazarEtiquetasEnMemo('#lote', lote.LotesPropietario);
    list.RemplazarEtiquetasEnMemo('#manzana', lote.ManzanasPropietario);
    list.RemplazarEtiquetasEnMemo('#vencimiento', xfechavto);
    list.RemplazarEtiquetasEnMemo('#mes', utiles.setMes(StrToInt(Copy(xperiodo, 1, 2))) + ' del ' + Copy(xperiodo, 4, 4));
    list.ListMemo('', Fuente, 0, salida, nil, tamanio, xmargenIzquierdo, '#parte1_inicio', '#parte1_fin');

    listGastosComunes(xperiodo, listSel.Strings[i-1], xnroliq, 'Arial, negrita, 8', salida);
    listGastosParticulares(xperiodo, listSel.Strings[i-1], 'Arial, negrita, 8', salida);

    if tipoLiquidacion = 1 then Begin
      list.RemplazarEtiquetasEnMemo('#deduccion', '(' + (utiles.FormatearNumero(FloatToStr(totales[4])) + ' / ' + (FloatToStr(TotalDeLotes)) + ') x ' + FloatToStr(lote.CantidadDeLotes)));
      list.RemplazarEtiquetasEnMemo('#importe_total', utiles.FormatearNumero(FloatToStr(totales[2])) + ' - ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[2])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[2])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[2])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[2])))) - 1, 2) + ' ctvos.');
    end;
    if tipoLiquidacion = 2 then Begin
      list.RemplazarEtiquetasEnMemo('#deduccion', '(' + (utiles.FormatearNumero(FloatToStr(totales[4])) + ' / ' + (FloatToStr(TotalDeLotes)) + ')'));
      list.RemplazarEtiquetasEnMemo('#importe_total', utiles.FormatearNumero(FloatToStr(totales[2])) + ' - ' + utiles.xIntToLletras(StrToInt(Copy(utiles.FormatearNumero(FloatToStr(totales[2])), 1, Length(Trim(utiles.FormatearNumero(FloatToStr(totales[2])))) - 3))) + ' con ' + Copy(utiles.FormatearNumero(FloatToStr(totales[2])), Length(Trim(utiles.FormatearNumero(FloatToStr(totales[2])))) - 1, 2) + ' ctvos.');
    end;

    list.ListMemo('', Fuente, 0, salida, nil, tamanio, xmargenIzquierdo, '#parte2_inicio', '#parte2_fin');

    if Length(Trim(tamanio_fuente)) = 0 then tamanio_fuente := '9';
    ffuente := 'Arial, normal, ' + tamanio_fuente;

    mesper := IntToStr(StrToInt(Copy(xperiodo, 1, 2)) + 0);
    anper  := Copy(xperiodo, 6, 2);
    if StrToInt(mesper) > 12 then Begin
      mesper := '01';
      anper  := IntToStr(StrToInt(anper) + 1);
    end;

    mesper := utiles.sLlenarIzquierda(mesper, 2, '0');
    anper  := utiles.sLlenarIzquierda(anper, 2, '0');

    // Deducimos vencimientos
    if Diavto1 = '' then Diavto1 := '10';
    if Diavto2 = '' then Diavto1 := '10';
    //v1 := Diavto1 + '/' + mesper + '/' + anper;
    v1 := xfechavto;
    if utiles.FechaDiaDeLaSemana(v1) = 'S�bado'  then v1 := utiles.FechaSumarDias(v1, 2);
    if utiles.FechaDiaDeLaSemana(v1) = 'Domingo' then v1 := utiles.FechaSumarDias(v1, 1);

    //v2 := IntToStr( StrToInt(Diavto1) + StrToInt(Diavto2) ) + '/' + mesper + '/' + anper;
    v2 := utiles.FechaSumarDias(v1, strtoint(Diavto2));
    if utiles.FechaDiaDeLaSemana(v2) = 'S�bado'  then v2 := utiles.FechaSumarDias(v2, 2);
    if utiles.FechaDiaDeLaSemana(v2) = 'Domingo' then v2 := utiles.FechaSumarDias(v2, 1);

    {v3 := utiles.FechaSumarMeses(utiles.sLlenarIzquierda(Diavto1, 2, '0') + '/' + mesper + '/' + anper, Diavto1, 1);
    if utiles.FechaDiaDeLaSemana(v3) = 'S�bado'  then v3 := utiles.FechaSumarDias(v3, 2);
    if utiles.FechaDiaDeLaSemana(v3) = 'Domingo' then v3 := utiles.FechaSumarDias(v3, 1);
    }
    if xliquidartalon then Begin
      if (salida = 'P') or (salida = 'I') or (salida = 'N') then Begin

        for j := 1 to 50 do Begin
          if list.Lineactual <= (list.altopag - r) then list.Linea(0, 0, '', 1, ffuente, salida, 'S') else Break;
        end;

        list.Linea(0, 0, ' Propietario', 1, ffuente, salida, 'N');
        list.Linea(15, list.Lineactual, 'Pr�ximo Vencimiento: ' + v3, 2, 'Arial, negrita, 10', salida, 'N');
        list.Linea(60, list.Lineactual, 'C�digo Pago Electr�nico Banelco: ' + propietario.codigo, 3, 'Arial, negrita, 10', salida, 'S');

        list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');

        list.Linea(0, 0, leyenda1 + ' - Banco', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'N');
        list.Linea(51, list.Lineactual, leyenda1 + ' - Empresa', 3, ffuente, salida, 'S');

        list.Linea(0, 0, leyenda2, 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'S');

        list.Linea(0, 0, '', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'S');

        list.Linea(0, 0, 'Propietario: ' + Copy(propietario.nombre, 1, 30), 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'S');
        list.Linea(51, list.Lineactual, 'Propietario: ' + Copy(propietario.nombre, 1, 30), 3, ffuente, salida, 'S');

        list.Linea(0, 0, 'Lote: ' + lote.LotesPropietario_IdNum_sc, 1, ffuente, salida, 'N');
        list.Linea(20, list.Lineactual, 'Manzana: ' + lote.ManzanasProp_Idnum_sc + '   Nro.Cliente: ' + propietario.codigo, 2, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 3, ffuente, salida, 'S');
        list.Linea(51, list.Lineactual, 'Lote: ' + lote.LotesPropietario_IdNum_sc {lote.LotesPropietario_IdNum}, 4, ffuente, salida, 'N');
        list.Linea(70, list.Lineactual, 'Manzana: ' + lote.ManzanasProp_Idnum_sc + '   Nro.Cliente: ' + propietario.codigo, 5, ffuente, salida, 'S');

        list.Linea(0, 0, '', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'S');

        list.Linea(0, 0, 'Liq. Expensa Per.: ' + xperiodo, 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'N');
        list.Linea(51, list.Lineactual, 'Liq. Expensa Per.: ' + xperiodo, 3, ffuente, salida, 'S');

        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

        list.Linea(0, 0, '1er. Vto.: ' + utiles.FechaCompleta(v1), 1, ffuente, salida, 'N');
        list.Linea(30, list.Lineactual, 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2])), 2, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 3, ffuente, salida, 'N');
        list.Linea(51, list.Lineactual, '1er. Vto.: ' + utiles.FechaCompleta(v1), 4, ffuente, salida, 'N');
        list.Linea(80, list.Lineactual, 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2])), 5, ffuente, salida, 'S');

        list.Linea(0, 0, '', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'S');
        list.Linea(0, 0, '', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'S');

        interes := ((totales[2] * (interes2vto * 0.01) ) / 30) * 7;

        list.Linea(0, 0, '2do. Vto.: ' + v2, 1, ffuente, salida, 'N');
        list.Linea(30, list.Lineactual, 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2] + interes)), 2, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 3, ffuente, salida, 'N');
        list.Linea(51, list.Lineactual, '2do. Vto.: ' + v2, 4, ffuente, salida, 'N');
        list.Linea(80, list.Lineactual, 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2] + interes)), 5, ffuente, salida, 'S');

        list.Linea(0, 0, '', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 3, ffuente, salida, 'S');

        list.Linea(0, 0, 'Si el vencimiento de la presente factura resultare feriado', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'N');
        list.Linea(51, list.Lineactual, 'Si el vencimiento de la presente factura resultare feriado', 3, ffuente, salida, 'S');

        list.Linea(0, 0, 'pasa autom�ticamente al h�bil siguiente', 1, ffuente, salida, 'N');
        list.Linea(50, list.Lineactual, '|', 2, ffuente, salida, 'N');
        list.Linea(51, list.Lineactual, 'pasa autom�ticamente al h�bil siguiente', 3, ffuente, salida, 'S');

      end;

      //------------------------------------------------------------------------

      if (salida = 'T') then Begin

        lin := utiles.sLlenarIzquierda(lin, 80, '-');

        list.LineaTxt('', True);
        list.LineaTxt('  Propietario - Pr�ximo Vencimiento: ' + v3, True);

        list.LineaTxt(lin, True);

        list.LineaTxt(utiles.StringLongitudFija(leyenda1 + ' - Banco', 35) + ' | ', False);
        list.LineaTxt(utiles.StringLongitudFija(leyenda1 + ' - Empresa', 35), True);

        list.LineaTxt(utiles.StringLongitudFija(leyenda2, 35), True);

        list.LineaTxt(utiles.StringLongitudFija('Propietario: ' + Copy(propietario.nombre, 1, 30), 35) + ' | ', False);
        list.LineaTxt(utiles.StringLongitudFija('Propietario: ' + Copy(propietario.nombre, 1, 30), 35) + ' | ', True);

        list.LineaTxt(utiles.StringLongitudFija('Lote: ' + lote.LotesPropietario_IdNum_sc + ' ' + 'Manzana: ' + lote.ManzanasProp_Idnum_sc, 35) + ' | ', False);
        list.LineaTxt(utiles.StringLongitudFija('Lote: ' + lote.LotesPropietario_IdNum_sc + ' ' + 'Manzana: ' + lote.ManzanasProp_Idnum_sc, 35), True);

        list.LineaTxt(utiles.espacios(36) + ' | ', True);

        list.LineaTxt(utiles.StringLongitudFija('Liq. Expensa Per.: ' + xperiodo, 35) + ' | ', False);
        list.LineaTxt(utiles.StringLongitudFija('Liq. Expensa Per.: ' + xperiodo, 35), True);

        list.LineaTxt(utiles.espacios(36) + ' | ', True);

        list.LineaTxt(utiles.StringLongitudFija('1er. Vto.: ' + v1 + '  ' + 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2])), 35) + ' | ', False);
        list.LineaTxt(utiles.StringLongitudFija('1er. Vto.: ' + v1 + '  ' + 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2])), 35), True);

        list.LineaTxt(utiles.espacios(36) + ' | ', True);

        interes := totales[2];
        tasaint := (interes2vto / 360) * 0.01;
        interes := (totales[2] * tasaint) * 10;

        list.LineaTxt(utiles.espacios(36) + ' | ', True);

        list.LineaTxt(utiles.StringLongitudFija('2do. Vto.: ' + v2 + '  ' + 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2] + interes)), 35) + ' | ', False);
        list.LineaTxt(utiles.StringLongitudFija('2do. Vto.: ' + v2 + '  ' + 'Monto: ' + utiles.FormatearNumero(FloatToStr(totales[2] + interes)), 35), True);

      end;

      if (totales[2] <> 0) then guardarTotalesBanco(xperiodo, propietario.codigo, v1, v2, totales[2], totales[2] + interes);

    end;

    if salida <> 'T' then Begin
      if ruptura then list.CompletarPagina else list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
    end;
    list.LiberarMemoImpresiones;

    RegistrarCobro(xperiodo, propietario.codigo, propietario.nombre, totales[2]);
  end;

  formatosimpr.Active := et;

  if i > 0 then
    if (salida = 'P') or (salida = 'I') then list.FinList;

  if salida = 'T' then Begin
    list.FinalizarImpresionModoTexto(0);
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\list.txt', dbs.DirSistema + '\liq' + Copy(xperiodo, 1, 2) + '_' + Copy(xperiodo, 4, 4) + '.txt');
  end;

  if (salida = 'N') then list.m := 0;
  

  datosdb.closeDB(totalesbco);
end;

procedure TTInformesGastosCCSR.listGastosComunes(xperiodo, xidpropiet, xnroliq, fuente: String; salida: char);
// Objetivo...: Listar Detalle de Gastos Comunes
var
  r: TQuery;
  sup_lotes, gl: Real;
  listar, calcular: boolean;
  gg: string;
  _lote: integer;
Begin
  if salida <> 'T' then Begin
    list.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, mizq + 'Gastos comunes', 1, 'Arial, negrita, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  end else Begin
    list.LineaTxt('', True);
    list.LineaTxt(mizq + 'Gastos comunes', True);
    list.LineaTxt('', True);
  end;

  _lote := lote.getCantidadLotesPorcentaje(xidpropiet);

  IniciarArreglos;
  r := reggastoscom.setItems(xperiodo, xnroliq);
  r.Open; items := 0; totales[1] := 0; totales[2] := 0; totales[3] := 0;
  idanter := r.FieldByName('idgasto').AsString;

  while not r.Eof do Begin
    listar := true;
    if r.FieldByName('idgasto').AsString <> idanter then listDetCom(idanter, fuente, salida);
    gastoscom.getDatos(r.FieldByName('idgasto').AsString);

    if (gastoscom.Recresiduos = 'S') and (lote.getCantidadLotesSinRecoleccionResiduos(xidpropiet) > 0) then listar := false;

    if (listar) then begin

      calcular := true;
      gl := gastoscom.PorLote;

      if (_lote > 0) and (gl > 0) then gg := ' (' + FloatToStr(gastoscom.PorLote) + '%)' else gg := '';

      Inc(items);
      listItems[items, 1] := utiles.sFormatoFecha(r.FieldByName('fecha').AsString);
      listItems[items, 2] := r.FieldByName('comprob').AsString;
      listItems[items, 3] := r.FieldByName('concepto').AsString + gg;

      if (_lote > 0) and (gl > 0) then begin
        totales[1] := totales[1] + ((r.FieldByName('importe').AsFloat * gastoscom.PorLote) / 100);
        totales[3] := totales[3] + ((r.FieldByName('importe').AsFloat * gastoscom.PorLote) /100);
        listItems[items, 4] := FloatToStr((r.FieldByName('importe').AsFloat * gastoscom.PorLote) /100);
        listItems[items, 5] := '';
        calcular := false;
      end;

      if (calcular) then begin
        if (gastoscom.Porcentaje = 0) or (gastoscom.Porcentaje = 100) then Begin
          totales[1] := totales[1] + r.FieldByName('importe').AsFloat;
          totales[3] := totales[3] + r.FieldByName('importe').AsFloat;
          listItems[items, 4] := r.FieldByName('importe').AsString;
          listItems[items, 5] := '';
        end else Begin
          totales[1] := totales[1] + (r.FieldByName('importe').AsFloat * (gastoscom.Porcentaje * 0.01));
          totales[3] := totales[3] + (r.FieldByName('importe').AsFloat * (gastoscom.Porcentaje * 0.01));
          listItems[items, 4] := utiles.FormatearNumero( FloatToStr ((r.FieldByName('importe').AsFloat * (gastoscom.Porcentaje * 0.01)) ));
          listItems[items, 5] := '(' + utiles.FormatearNumero(r.FieldByName('importe').AsString) + ' * ' + utiles.FormatearNumero(FloatToStr(gastoscom.Porcentaje)) + ' = ' + utiles.FormatearNumero( FloatToStr ((r.FieldByName('importe').AsFloat * (gastoscom.Porcentaje * 0.01)) )) + ')';
        end;
      end;
    end;
    idanter := r.FieldByName('idgasto').AsString;
    r.Next;
  end;
  listDetCom(idanter, fuente, salida);
  r.Close; r.Free;
  totales[4] := totales[3];
  if totales[3] > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
      list.derecha(90, list.Lineactual, '', '----------------------', 2, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, mizq + '   Total Gastos Comunes:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(90, list.Lineactual, '', totales[3], 2, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');

      // Porcentaje de Lotes No Construidos
      if PorcentajeLC > 0 then Begin
        if not lote.setLoteConstruido(xidpropiet) then Begin
          totales[4] := totales[4] * (porcentajeLC * 0.01);
        end;
      end;

      if tipoLiquidacion = 1 then Begin
        if not nl then list.Linea(0, 0, mizq + '   Su participaci�n:  ' + '(' + (utiles.FormatearNumero(FloatToStr(totales[4])) + ' / ' + (FloatToStr(TotalDeLotes)) + ') x ' + FloatToStr(lote.CantidadDeLotes)) + '  -  ' +
                                '(' + utiles.FormatearNumero(FloatToStr(totales[3] / TotalDeLotes)) + ' x ' + FloatToStr(lote.CantidadDeLotes) + ')   =   ' + utiles.FormatearNumero(FloatToStr((totales[3] / TotalDeLotes) * lote.CantidadDeLotes)), 1, 'Arial, cursiva, 8', salida, 'N');
        list.importe(85, list.Lineactual, '', (totales[3] / TotalDeLotes) * lote.CantidadDeLotes, 2, 'Arial, cursiva, 8');
      end;
      if tipoLiquidacion = 2 then Begin
        sup_lotes := lote.setSuperficieLotesPropietario(xidpropiet);
        if not nl then list.Linea(0, 0, mizq + '   Su participaci�n:  ' + '(' + (utiles.FormatearNumero(FloatToStr(totales[4])) + ' / ' + utiles.FormatearNumero(FloatToStr(superficieLotes)) + ') x ' + utiles.FormatearNumero(FloatToStr(sup_lotes))) + '  -  ' +
                                '(' + utiles.FormatearNumero(FloatToStr(totales[4] / superficieLotes), '####0.00000') + ' x ' + utiles.FormatearNumero( FloatToStr(sup_lotes) ) + ')' {  =   ' + utiles.FormatearNumero(FloatToStr((totales[3] / TotalDeLotes) * sup_lotes ))}, 1, 'Arial, cursiva, 8', salida, 'N');
        list.importe(95, list.Lineactual, '', (StrToFloat( utiles.FormatearNumero( FloatToStr ( (totales[4] / superficielotes) * sup_lotes ), '####0.00000'))) , 2, 'Arial, cursiva, 8');
      end;

      list.Linea(95, list.Lineactual, '', 3, 'Arial, cursiva, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt('', True);
      list.LineaTxt('                                                 ----------------------', True);
      list.LineaTxt('', True);
      list.LineaTxt(mizq + '   Total Gastos Comunes:                                ', False);
      list.importeTxt(totales[3], 10, 2, True);
      list.LineaTxt('', True);
      list.LineaTxt('', True);

      // Porcentaje de Lotes No Construidos
      if PorcentajeLC > 0 then Begin
        if not lote.setLoteConstruido(xidpropiet) then Begin
          totales[4] := totales[4] * (porcentajeLC * 0.01);
        end;
      end;

      if tipoLiquidacion = 1 then Begin
        if not nl then list.LineaTxt(mizq + ' Su participaci�n: ' + '(' + (utiles.FormatearNumero(FloatToStr(totales[4])) + ' / ' + (FloatToStr(TotalDeLotes)) + ') x ' + FloatToStr(lote.CantidadDeLotes)) + ' - ' +
                                '(' + utiles.FormatearNumero(FloatToStr(totales[3] / TotalDeLotes)) + ' x ' + FloatToStr(lote.CantidadDeLotes) + ')' { = ' + utiles.FormatearNumero(FloatToStr((totales[3] / TotalDeLotes) * lote.CantidadDeLotes))}, False);
        list.importeTxt((totales[3] / TotalDeLotes) * lote.CantidadDeLotes, 13, 2, True);
      end;
      if tipoLiquidacion = 2 then Begin
        sup_lotes := lote.setSuperficieLotesPropietario(xidpropiet);
        if not nl then list.LineaTxt(mizq + ' Su participaci�n: ' + '(' + (utiles.FormatearNumero(FloatToStr(totales[4])) + ' / ' + (FloatToStr(superficieLotes)) + ') x ' + FloatToStr(sup_lotes)) + ' - ' +
                                '(' + utiles.FormatearNumero(FloatToStr(totales[3] / superficieLotes)) + ' x ' + FloatToStr(sup_lotes) + ') = ' + utiles.FormatearNumero(FloatToStr((totales[3] / TotalDeLotes) * sup_lotes)), False);


        list.importeTxt((StrToFloat( utiles.FormatearNumero( FloatToStr ( (totales[4] / superficielotes) * sup_lotes ), '####0.00000'))), 13, 2, True);

      end;

      list.LineaTxt('', True);
      list.LineaTxt('', True);
    end;
  end;
  if tipoLiquidacion = 1 then totales[3] := (totales[3] / TotalDeLotes) * lote.CantidadDeLotes;    // Valor a pagar por cada lote
  if tipoLiquidacion = 2 then totales[3] := (totales[4] / superficielotes) * sup_lotes; // Valor por superficie
end;

procedure TTInformesGastosCCSR.listGastosParticulares(xperiodo, xidpropiet, fuente: String; salida: char);
// Objetivo...: Listar Detalle de Gastos Particulares
var
  r: TQuery;
Begin
  if not nl then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, mizq + 'Gastos particulares', 1, 'Arial, negrita, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
    end else Begin
      list.LineaTxt('', True);
      list.LineaTxt(mizq + 'Gastos particulares', True);
      list.LineaTxt('', True);
    end;
  end;

  IniciarArreglos;
  r := reggastospart.setItems(xperiodo, xidpropiet);
  r.Open; items := 0; totales[1] := 0;
  idanter := r.FieldByName('idgasto').AsString;
  while not r.Eof do Begin
    if r.FieldByName('idgasto').AsString <> idanter then listDetPar(idanter, fuente, salida);
    Inc(items);
    listItems[items, 1] := utiles.sFormatoFecha(r.FieldByName('fecha').AsString);
    listItems[items, 2] := r.FieldByName('comprob').AsString;
    listItems[items, 3] := r.FieldByName('concepto').AsString;
    listItems[items, 4] := r.FieldByName('importe').AsString;
    totales[1] := totales[1] + r.FieldByName('importe').AsFloat;
    totales[2] := totales[2] + r.FieldByName('importe').AsFloat;
    totgral := totgral + r.FieldByName('importe').AsFloat;
    idanter := r.FieldByName('idgasto').AsString;
    r.Next;
  end;
  listDetPar(idanter, fuente, salida);
  r.Close; r.Free;
  if totales[2] > 0 then Begin
    if salida <> 'T' then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 9', salida, 'N');
      list.derecha(90, list.Lineactual, '', '----------------------', 2, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, mizq + '   Total Gastos Particulares:', 1, 'Arial, negrita, 9', salida, 'N');
      list.importe(90, list.Lineactual, '', totales[2], 2, 'Arial, negrita, 9');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    end else Begin
      list.LineaTxt('', True);
      list.LineaTxt('                                                 ----------------------', True);
      list.LineaTxt('', True);
      list.LineaTxt(mizq + '   Total Gastos Particulares:                           ', False);
      list.importeTxt(totales[2], 10, 2, True);
      list.LineaTxt('', True);
    end;
  end;

  // Averiguamos la cantidad de lotes que tiene el propietario
  if tipoLiquidacion = 1 then totales[3] := totales[3] * lote.CantidadDeLotes;   // Multiplicamos por la cantidad de lotes que tiene
  totales[2] := totales[2] + totales[3];
end;

procedure TTInformesGastosCCSR.listDetCom(idanter, fuente: String; salida: Char);
// Objetivo...: Listar Detalle
var
  i: Integer;
Begin
  gastoscom.getDatos(idanter);
  if salida <> 'T' then Begin
    if (totales[1] <> 0) then begin
      list.Linea(0, 0, mizq + '   ' + gastoscom.Descrip, 1, fuente, salida, 'N');
      list.importe(90, list.Lineactual, '', totales[1], 2, fuente);
      list.Linea(95, list.Lineactual, '', 3, fuente, salida, 'S');
    end;
    if not ocultardetalle then Begin
      For i := 1 to items do Begin
        list.Linea(0, 0, '         ' + mizq + listItems[i, 1], 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(17, list.Lineactual, listItems[i, 2], 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(34, list.Lineactual, listItems[i, 3], 3, 'Arial, normal, 8', salida, 'N');
        list.importe(85, list.Lineactual, '', StrToFloat(listItems[i, 4]), 4, 'Arial, normal, 8');
        list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
        if Length(Trim(listItems[i, 5])) > 0 then Begin
          list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(34, list.Lineactual, listItems[i, 5], 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        end;
      end;
    end;
  end;
  if salida = 'T' then Begin
    if (totales[1] <> 0) then begin
      list.LineaTxt(mizq + Copy(gastoscom.Descrip, 1, 40) + utiles.espacios(58-Length(TrimRight(Copy(gastoscom.Descrip, 1, 40)))), False);
      list.importeTxt(totales[1], 12, 2, True);
      list.LineaTxt(' ', True);
    end;
    if not ocultardetalle then Begin
      For i := 1 to items do Begin
        list.LineaTxt(mizq + '  ' + listItems[i, 1], False);
        list.LineaTxt(listItems[i, 2] + '  ', False);
        list.LineaTxt(listItems[i, 3] + utiles.espacios(42-Length(TrimRight(Copy(listItems[i, 3], 1, 35)))), False);
        list.importeTxt(StrToFloat(listItems[i, 4]), 12, 2, True);
      end;
    end;
  end;
  items := 0; totales[1] := 0;
end;

procedure TTInformesGastosCCSR.listDetPar
(idanter, fuente: String; salida: Char);
// Objetivo...: Listar Detalle
var
  i: Integer;
Begin
  if totales[1] <> 0 then Begin
    gastospart.getDatos(idanter);
    if salida <> 'T' then Begin
      if not ocultardetalle then list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, mizq + '   ' + gastospart.Descrip, 1, fuente, salida, 'N');
      list.importe(90, list.Lineactual, '', totales[1], 2, fuente);
      list.Linea(95, list.Lineactual, '', 3, fuente, salida, 'S');
      if not ocultardetalle then Begin
        For i := 1 to items do Begin
          list.Linea(0, 0, '         ' + mizq + listItems[i, 1], 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(17, list.Lineactual, mizq + listItems[i, 2], 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(34, list.Lineactual, mizq + listItems[i, 3], 3, 'Arial, normal, 8', salida, 'N');
          if StrToFloat(listItems[i, 4]) <> 0 then list.importe(85, list.Lineactual, '', StrToFloat(listItems[i, 4]), 4, 'Arial, normal, 8') else
            list.importe(85, list.Lineactual, '###,###,###.##', StrToFloat(listItems[i, 4]), 4, 'Arial, normal, 8');
          list.Linea(90, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
        end;
      end;
    end;
    if salida = 'T' then Begin
      if not ocultardetalle then list.LineaTxt('', True);
      list.LineaTxt(mizq + Copy(gastospart.Descrip, 1, 40) + utiles.espacios(58-Length(TrimRight(Copy(gastospart.Descrip, 1, 40)))), False);
      list.importeTxt(totales[1], 12, 2, True);
      list.LineaTxt(' ', True);
      if not ocultardetalle then Begin
        For i := 1 to items do Begin
          list.LineaTxt(mizq + '  ' + listItems[i, 1], False);
          list.LineaTxt(listItems[i, 2] + '  ', False);
          list.LineaTxt(listItems[i, 3] + utiles.espacios(42-Length(TrimRight(Copy(listItems[i, 3], 1, 35)))), False);
          list.importeTxt(StrToFloat(listItems[i, 4]), 12, 2, True);
        end;
      end;
    end;
  end;
  items := 0; totales[1] := 0;
end;

{*******************************************************************************}

procedure TTInformesGastosCCSR.InfEtiquetasExpensas(xperiodo: String; listSel: TStringList; xmargenIzquierdo: Integer; salida: char);
// Objetivo...: Listar la parte frontal de las cartas
var
  i: Integer; et: Boolean;
Begin
  if xmargenizquierdo > 0 then mizq := utiles.espacios(xmargenizquierdo) else mizq := '';
  et := formatosimpr.Active;
  if not et then formatosimpr.Open;
  getFormatoImpresion('F02');
  list.Setear(salida);
  list.NoImprimirPieDePagina;

  For i := 1 to listSel.Count do Begin
    if Length(Trim(listSel.Strings[i-1])) = 0 then Break;
    if ruptura then list.IniciarNuevaPagina;
    propietario.getDatos(listSel.Strings[i-1]);
    lote.setLotesPropietario(listSel.Strings[i-1]);
    list.IniciarMemoImpresiones(formatosImpr, 'modelo', Tamanio);
    list.RemplazarEtiquetasEnMemo('#nombre', propietario.nombre);
    list.RemplazarEtiquetasEnMemo('#direccion', propietario.domicilio);
    list.RemplazarEtiquetasEnMemo('#telefono', propietario.Telefono);
    list.RemplazarEtiquetasEnMemo('#lote', lote.LotesPropietario);
    list.RemplazarEtiquetasEnMemo('#manzana', lote.ManzanasPropietario);
    list.ListMemo('', Fuente, 0, salida, nil, tamanio);
    if ruptura then list.CompletarPagina else list.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
    list.LiberarMemoImpresiones;
  end;

  formatosimpr.Active := et;

  if i > 0 then list.FinList;
end;

{*******************************************************************************}

procedure TTInformesGastosCCSR.Inf_Gastos(xperiodo, xnroliq, xfechavto, xtitulo: String; listSel: TStringList; salida: char);
// Objetivo...: Generar un Informe detallado de Gastos
var
  i, j: Integer;
Begin
  nl := True; totgral := 0;
  list.Setear(salida);
  list.Titulo(0, 0, xtitulo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, '      Fecha', 1, 'Arial, cursiva, 8');
  list.Titulo(12, list.Lineactual, 'Comprobante', 2, 'Arial, cursiva, 8');
  list.Titulo(28, list.Lineactual, 'Concepto Operaci�n', 3, 'Arial, cursiva, 8');
  list.Titulo(90, list.Lineactual, 'Importe', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  listGastosComunes(xperiodo, xnroliq, '', 'Arial, negrita, 8', salida);
  list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  list.Linea(0, 0, 'Gastos particulares', 1, 'Arial, negrita, 11', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  For i := 1 to listSel.Count do Begin
    if Length(Trim(listSel.Strings[i-1])) = 0 then Break;
    lote.setLotesPropietario(listSel.Strings[i-1]);
    propietario.getDatos(listSel.Strings[i-1]);
    list.Linea(0, 0, 'Propietario: ' + propietario.nombre, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
    list.Linea(60, list.Lineactual, 'Lote: ' + lote.LotesPropietario, 2, 'Arial, negrita, 9, clNavy', salida, 'N');
    list.Linea(75, list.Lineactual, 'Manzana: ' + lote.ManzanasPropietario, 3, 'Arial, negrita, 9, clNavy', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    listGastosParticulares(xperiodo, listSel.Strings[i-1], 'Arial, negrita, 8', salida);
    list.Linea(0, 0, list.Linealargopagina('--', salida), 1, 'Arial, normal, 10', salida, 'S');
    for j := 1 to posiciones do totales[j] := 0;
  end;
  if i > 0 then Begin
    if totgral > 0 then Begin
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      list.Linea(0, 0, 'Total General de Gastos Particulares:', 1, 'Arial, negrita, 10', salida, 'N');
      list.importe(90, list.Lineactual, '', totgral, 2, 'Arial, negrita, 10');
      list.Linea(95, list.Lineactual, '', 3, 'Arial, negrita, 10', salida, 'S');
    end;
    list.FinList;
  end;
  nl := False;
end;

{*******************************************************************************}

procedure TTInformesGastosCCSR.InformePlanillaMediciones(salida: char);
// Objetivo...: Generar Informe Planilla de Mediciones
var
  r: TQuery;
Begin
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Mediciones de Energia El�ctrica', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  list.Titulo(0, 0, 'Fecha:  ......../......../........', 1, 'Arial, normal, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 12');

  r := propietario.setPropietarios;
  r.Open; nl := False;
  while not r.Eof do Begin
    list.Linea(0, 0, r.FieldByName('nombre').AsString, 1, 'Arial, normal, 12', salida, 'N');
    list.Linea(70, list.Lineactual, '.........................Kw', 2, 'Arial, normal, 12', salida, 'S');
    list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
    r.Next;
    nl := True;
  end;
  r.Close; r.Free;

  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 22', salida, 'S');
  list.Linea(0, 0, 'Consumo total', 1, 'Arial, normal, 12', salida, 'N');
  list.Linea(70, list.Lineactual, '.........................Kw', 2, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  list.Linea(0, 0, 'Alumb. P�blic y motor p/agua corriente', 1, 'Arial, normal, 12', salida, 'N');
  list.Linea(70, list.Lineactual, '.........................Kw', 2, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  list.Linea(0, 0, 'Condominos', 1, 'Arial, normal, 12', salida, 'N');
  list.Linea(70, list.Lineactual, '.........................Kw', 2, 'Arial, normal, 12', salida, 'S');

  if nl then list.FinList else utiles.msgError('No Existen Datos para Listar ...!');
end;

{*******************************************************************************}

procedure TTInformesGastosCCSR.InfDetalleConsumoElectricoAnual(xperiodo, xnroliq: String; salida: char);
// Objetivo...: Generar Informe Detalle de Mediciones Anuales
var
  r: TQuery; i, j: Integer;
Begin
  list.ImprimirHorizontal;
  list.Setear(salida);
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Detalle Anual de Consumo de Energia El�ctrica', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'A�o:  ' + Copy(xperiodo, 4, 4), 1, 'Arial, negrita, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, 'Propietario', 1, 'Arial, cursiva, 8');
  j := 25;
  For i := 1 to 12 do Begin
    j := j + 8;
    list.Titulo(j, list.Lineactual, utiles.setMes(i), i+1, 'Arial, cursiva, 8');
  end;
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');

  r := propietario.setPropietarios;
  r.Open; nl := False;
  while not r.Eof do Begin
    list.Linea(0, 0, r.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
    j := 30;
    For i := 1 to 12 do Begin
      reggastospart.getDatosConsumoEnergiaElectrica(utiles.sLlenarIzquierda(IntToStr(i), 2, '0') + Copy(xperiodo, 3, 5), r.FieldByName('idpropiet').AsString, xnroliq);
      j := j + 8;
      list.Importe(j, list.Lineactual, '######', reggastospart.Lectura, i+1, 'Arial, normal, 8');
    end;
    list.Linea(j+5, list.Lineactual, '', i+1, 'Arial, normal, 8', salida, 'S');
    r.Next;
    nl := True;
  end;
  r.Close; r.Free;

  if nl then list.FinList else utiles.msgError('No Existen Datos para Listar ...!');
  list.ImprimirVetical;
end;

procedure TTInformesGastosCCSR.InfDetalladoDeGastos(xperiodo, xnroliq, xfechavto: String; listSel: TStringList; salida: char);
// Objetivo...: Generar un Informe detallado de Gastos
Begin
  Inf_Gastos(xperiodo, xnroliq, xfechavto, 'Informe Detallado de Gastos', listSel, salida);
end;

{*******************************************************************************}

procedure TTInformesGastosCCSR.InformeDeMediciones(xperiodo, xnroliq: String; salida: char);
// Objetivo...: Generar Informe Planilla de Mediciones
var
  r: TQuery;
Begin
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Detalle de Mediciones de Energia El�ctrica', 1, 'Arial, negrita, 14');
  r := propietario.setPropietarios;
  r.Open; nl := False; totales[1] := 0; totales[2] := 0;
  reggastospart.getDatosConsumoEnergiaElectrica(xperiodo, r.FieldByName('idpropiet').AsString, xnroliq);
  list.Titulo(0, 0, 'Fecha: ' + reggastospart.FechaReg, 1, 'Arial, normal, 12');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Propietario', 1, 'Arial, cursiva, 9');
  list.Titulo(41, list.Lineactual, 'Lect.Anterior', 2, 'Arial, cursiva, 9');
  list.Titulo(62, list.Lineactual, 'Lect.Actual', 3, 'Arial, cursiva, 9');
  list.Titulo(82, list.Lineactual, 'Cons.Total', 4, 'Arial, cursiva, 9');
  list.Titulo(94, list.Lineactual, 'Fecha', 5, 'Arial, cursiva, 9');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  reggastospart.getDatosConsumoEnergiaElectrica(xperiodo, '0000', xnroliq);
  totales[1] := reggastospart.LecturaTotal - reggastospart.LecturaAnt_Total;
  while not r.Eof do Begin
    if r.FieldByName('idpropiet').AsString > '0000' then Begin
      if reggastospart.BuscarConsumoEnergiaElectrica(xperiodo, r.FieldByName('idpropiet').AsString, xnroliq) then Begin
        reggastospart.getDatosConsumoEnergiaElectrica(xperiodo, r.FieldByName('idpropiet').AsString, xnroliq);
        list.Linea(0, 0, r.FieldByName('nombre').AsString, 1, 'Arial, normal, 9', salida, 'N');
        list.importe(50, list.Lineactual, '', reggastospart.LecturaAnterior, 2, 'Arial, normal, 9');
        list.importe(70, list.Lineactual, '', reggastospart.Lectura, 3, 'Arial, normal, 9');
        if (reggastospart.Lectura - reggastospart.LecturaAnterior) > 0 then list.importe(87, list.Lineactual, '##########', reggastospart.Lectura - reggastospart.LecturaAnterior, 4, 'Arial, normal, 9') else
          list.importe(87, list.Lineactual, '', 0, 4, 'Arial, normal, 9');
        list.Linea(88, list.Lineactual, 'Kw.', 5, 'Arial, normal, 9', salida, 'S');
        list.Linea(93, list.Lineactual, '......../......../........', 6, 'Arial, normal, 9', salida, 'S');
        if (reggastospart.Lectura - reggastospart.LecturaAnterior) > 0 then totales[2] := totales[2] + (reggastospart.Lectura - reggastospart.LecturaAnterior);
      end;
    end;
    r.Next;
    nl := True;
  end;
  r.Close; r.Free;


  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  {
  list.Linea(0, 0, 'Consumo total', 1, 'Arial, normal, 12', salida, 'N');
  list.importe(80, list.Lineactual, '', totales[1], 2, 'Arial, normal, 12');
  list.Linea(82, list.Lineactual, 'Kw.', 3, 'Arial, normal, 12', salida, 'S');
  list.Linea(0, 0, 'Alumb. P�blic y motor p/agua corriente', 1, 'Arial, normal, 12', salida, 'N');
  list.importe(80, list.Lineactual, '', totales[1] - totales[2], 2, 'Arial, normal, 12');
  list.Linea(82, list.Lineactual, 'Kw.', 3, 'Arial, normal, 12', salida, 'S');
   }
  list.Linea(0, 0, 'Total Consumido:', 1, 'Arial, normal, 12', salida, 'N');
  list.Importe(80, list.Lineactual, '', totales[2], 2, 'Arial, normal, 12');
  list.Linea(82, list.Lineactual, 'Kw.', 3, 'Arial, normal, 12', salida, 'S');
  if nl then list.FinList else utiles.msgError('No Existen Datos para Listar ...!');
end;

procedure TTInformesGastosCCSR.InformeMedicionesAgua(xperiodo, xnroliq: String; salida: char);
// Objetivo...: Generar Informe Planilla de Mediciones
var
  r: TQuery;
  total: real;
Begin
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, 'Detalle de Mediciones de Agua', 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Fecha', 1, 'Arial, cursiva, 8');
  list.Titulo(10, list.Lineactual, 'Propietario', 2, 'Arial, cursiva, 8');
  list.Titulo(55, list.Lineactual, 'Medidor', 3, 'Arial, cursiva, 8');
  list.Titulo(63, list.Lineactual, 'L. Anterior', 4, 'Arial, cursiva, 8');
  list.Titulo(74, list.Lineactual, 'L. Actual', 5, 'Arial, cursiva, 8');
  list.Titulo(83, list.Lineactual, 'Consumo', 6, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, '', 1, 'Arial, negrita, 5');

  r := reggastospart.getListConsumoAgua(xperiodo, xnroliq);
  r.open; total := 0;
  while not r.Eof do Begin
    propietario.getDatos(r.FieldByName('idpropiet').AsString);
    list.Linea(0, 0, utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(10, list.lineactual, propietario.nombre, 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(57, list.lineactual, r.FieldByName('medidor').AsString, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(70, list.Lineactual, '', r.FieldByName('lecturaanter').AsFloat, 4, 'Arial, normal, 8');
    list.importe(80, list.Lineactual, '', r.FieldByName('lectura').AsFloat, 5, 'Arial, normal, 8');
    list.importe(90, list.Lineactual, '', r.FieldByName('lectura').AsFloat - r.FieldByName('lecturaanter').AsFloat, 6, 'Arial, normal, 8');
    list.Linea(96, list.lineactual, '', 7, 'Arial, normal, 8', salida, 'S');
    total := total + (r.FieldByName('lectura').AsFloat - r.FieldByName('lecturaanter').AsFloat);

    r.Next;
  end;
  r.Close; r.Free;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Total Consumido:', 1, 'Arial, negrita, 8', salida, 'N');
  list.importe(90, list.Lineactual, '', total, 2, 'Arial, negrita, 8');
  list.Linea(95, list.lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');

  list.FinList;
end;


{*******************************************************************************}

procedure TTInformesGastosCCSR.InfResumenDeGastos(xperiodo, xnroliq, xfechavto: String; listSel: TStringList; salida: char);
// Objetivo...: Generar un Informe detallado de Gastos
Begin
  ocultardetalle := True;
  Inf_Gastos(xperiodo, xnroliq, xfechavto, 'Resumen de Gastos', listSel, salida);
  ocultardetalle := False;
end;

{*******************************************************************************}

procedure TTInformesGastosCCSR.InfPlanillaDeGastos(xperiodo, xnroliq: String; listSel: TStringList; salida: char);
// Objetivo...: Listar Planilla Resumen de Gastos
var
  i: Integer;
  r: TQuery;
  t, s, sup_lotes: Real;
Begin
  if salida <> 'N' then Begin
    list.Setear(salida);
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Planilla Resumen de Gastos, Per�odo: ' + xperiodo, 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    list.Titulo(0, 0, 'Propietario', 1, 'Arial, cursiva, 8');
    list.Titulo(35, list.Lineactual, 'Lotes', 2, 'Arial, cursiva, 8');
    list.Titulo(64, list.Lineactual, 'Dist. (GG + GP)', 3, 'Arial, cursiva, 8');
    list.Titulo(89, list.Lineactual, 'Total Lotes', 4, 'Arial, cursiva, 8');
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  end;

  cobros.Open;

  totales[4] := 0;
  For i := 1 to listSel.Count do Begin
    if Length(Trim(listSel.Strings[i-1])) = 0 then Break;
    propietario.getDatos(listSel.Strings[i-1]);
    lote.setLotesPropietario(listSel.Strings[i-1]);

    { Deducci�n de Gastos en Lotes }
    r := reggastoscom.setItems(xperiodo, xnroliq);
    r.Open; totales[1] := 0; totales[2] := 0; totales[3] := 0;
    while not r.Eof do Begin
      gastoscom.getDatos(r.FieldByName('idgasto').AsString);
      if (gastoscom.Porcentaje = 0) or (gastoscom.Porcentaje = 100) then Begin
        totales[1] := totales[1] + r.FieldByName('importe').AsFloat;
        totales[3] := totales[3] + r.FieldByName('importe').AsFloat;
      end else Begin
        totales[1] := totales[1] + (r.FieldByName('importe').AsFloat * (gastoscom.Porcentaje * 0.01));
        totales[3] := totales[3] + (r.FieldByName('importe').AsFloat * (gastoscom.Porcentaje * 0.01));
      end;
      r.Next;
    end;

    // Porcentaje de Lotes No Construidos
    if PorcentajeLC > 0 then Begin
      if not lote.setLoteConstruido(listSel.Strings[i-1]) then Begin
        totales[3] := totales[3] * (porcentajeLC * 0.01);
      end;
    end;

    if tipoLiquidacion = 1 then totales[3] := totales[3] / TotalDeLotes;    // Valor a pagar por cada lote
    if tipoLiquidacion = 2 then Begin
      sup_lotes   := lote.setSuperficieLotesPropietario(listSel.Strings[i-1]);
      totales [3] := (totales[3] / superficielotes) * sup_lotes;
    end;

    t := totales[3];
    r.Close; r.Free;
    r := reggastospart.setItems(xperiodo, listSel.Strings[i-1]);
    r.Open; totales[1] := 0;
    while not r.Eof do Begin
      totales[1] := totales[1] + r.FieldByName('importe').AsFloat;
      totales[2] := totales[2] + r.FieldByName('importe').AsFloat;
      totgral := totgral + r.FieldByName('importe').AsFloat;
      idanter := r.FieldByName('idgasto').AsString;
      r.Next;
    end;
    r.Close; r.Free;
    s := totales[2];
    if tipoLiquidacion = 1 then totales[3] := totales[3] * lote.CantidadDeLotes;   // Multiplicamos por la cantidad de lotes que tiene
    totales[2] := totales[2] + totales[3];

    if totales[2] > 0 then Begin
      if salida <> 'N' then Begin
        list.Linea(0, 0, propietario.codigo, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(6, list.lineactual, copy(propietario.nombre, 1, 28), 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(35, list.Lineactual, lote.LotesPropietario, 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(65, list.Lineactual, '(' + (utiles.FormatearNumero(FloatToStr(t)) + ' x ' + FloatToStr(lote.CantidadDeLotes)) + ')' + ' + ' + utiles.FormatearNumero(FloatToStr(s)), 4, 'Arial, normal, 8', salida, 'N');
        list.importe(97, list.Lineactual, '', totales[2], 5, 'Arial, normal, 8');
        list.Linea(97, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
      end;
      totales[4] := totales[4] + totales[2];
      RegistrarCobro(xperiodo, propietario.codigo, propietario.nombre, totales[2]);
    end;
  end;

  if salida <> 'N' then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total General:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(97, list.Lineactual, '', totales[4], 2, 'Arial, negrita, 8');
    list.Linea(97, list.Lineactual, '', 3, 'Arial, negrita, 9', salida, 'S');
    list.FinList;
  end;

  datosdb.closeDB(cobros);
end;

procedure TTInformesGastosCCSR.RegistrarCobro(xperiodo, xidpropiet, xnombre: String; xmonto: Real);
// Objetivo...: Registrar un Gasto para su posterior cobro
Begin
  if cobros.IndexFieldNames <> 'Periodo;Idpropiet' then cobros.IndexFieldNames := 'Periodo;Idpropiet';
  if datosdb.Buscar(cobros, 'Periodo', 'Idpropiet', xperiodo, xidpropiet) then cobros.Edit else cobros.Append;
  cobros.FieldByName('periodo').AsString   := xperiodo;
  cobros.FieldByName('idpropiet').AsString := xidpropiet;
  cobros.FieldByName('nombre').AsString    := xnombre;
  cobros.FieldByName('monto').AsFloat      := xmonto;
  try
    cobros.Post
   except
    cobros.Cancel
  end;
  datosdb.refrescar(cobros);
end;

function TTInformesGastosCCSR.setCobros(xperiodo: String): TStringList;
// Objetivo...: Recuperar los cobros de un periodo
var
  l: TStringList;
Begin
  l := TStringList.Create;
  cobros.Open;
  datosdb.Filtrar(cobros, 'periodo = ' + '''' + xperiodo + '''');
  cobros.IndexFieldNames := 'nombre';
  cobros.First;
  while not cobros.Eof do Begin
    l.Add(cobros.FieldByName('idpropiet').AsString + cobros.FieldByName('monto').AsString + ';1' + utiles.sFormatoFecha(cobros.FieldByName('fecha').AsString) + ';2' + cobros.FieldByName('observacion').AsString);
    cobros.Next;
  end;
  datosdb.QuitarFiltro(cobros);
  cobros.Close;
  Result := l;
end;

procedure TTInformesGastosCCSR.RegistrarCobro(xperiodo, xidpropiet, xfecha, xobservacion: String);
// Objetivo...: Registrar un Pago
Begin
  cobros.Open;
  if cobros.IndexFieldNames <> 'Periodo;Idpropiet' then cobros.IndexFieldNames := 'Periodo;Idpropiet';
  if datosdb.Buscar(cobros, 'Periodo', 'Idpropiet', xperiodo, xidpropiet) then Begin
    cobros.Edit;
    cobros.FieldByName('fecha').AsString       := utiles.sExprFecha2000(xfecha);
    cobros.FieldByName('observacion').AsString := xobservacion;
    try
      cobros.Post
     except
      cobros.Cancel
    end;
  end;
  datosdb.closedb(cobros);
end;

procedure TTInformesGastosCCSR.InformeCobros(xperiodo: String; xactivo: Boolean; salida: char);
// Objetivo...: Listar Estado de Cobros
Begin
  InfCobros(xperiodo, 'T', xactivo, salida);
end;

procedure TTInformesGastosCCSR.InformeCobrosPendientes(xperiodo: String; xactivo: Boolean; salida: char);
// Objetivo...: Listar Cobros Pendientes
Begin
  InfCobros(xperiodo, 'P', xactivo, salida);
end;

procedure TTInformesGastosCCSR.InfCobros(xperiodo, xtipo_inf: String; xactivo: Boolean; salida: char);
// Objetivo...: Listar Cobros
var
  lista, lista1: Boolean;
Begin
  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  if xtipo_inf = 'T' then list.Titulo(0, 0, 'Estado de Cobros Per�odo: ' + xperiodo, 1, 'Arial, negrita, 14');
  if xtipo_inf = 'P' then list.Titulo(0, 0, 'Cobros Pendientes Per�odo: ' + xperiodo, 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Propietario', 1, 'Arial, cursiva, 8');
  list.Titulo(40, list.Lineactual, 'Monto', 2, 'Arial, cursiva, 8');
  list.Titulo(50, list.Lineactual, 'Fecha', 3, 'Arial, cursiva, 8');
  list.Titulo(60, list.Lineactual, 'Observaciones', 4, 'Arial, cursiva, 8');
  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  totales[1] := 0; totales[2] := 0; totales[3] := 0;
  cobros.Open;
  datosdb.Filtrar(cobros, 'Periodo = ' + '''' + xperiodo + '''');
  cobros.IndexFieldNames := 'Nombre';
  cobros.First;
  while not cobros.Eof do Begin
    lista := False;
    if xtipo_inf = 'T' then lista := True;
    if xtipo_inf = 'P' then
      if Length(Trim(cobros.FieldByName('fecha').AsString)) = 0 then lista := True;

    lista1 := False;
    if not xactivo then lista1 := True else Begin
      propietario.getDatos(cobros.FieldByName('Idpropiet').AsString);
      if propietario.Activo = 'S' then lista1 := True;
    end;

    if (lista) and (lista1) then Begin
      list.Linea(0, 0, cobros.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.importe(45, list.Lineactual, '', cobros.FieldByName('monto').AsFloat, 2, 'Arial, normal, 8');
      if Length(Trim(cobros.FieldByName('fecha').AsString)) > 0 then list.Linea(50, list.Lineactual, utiles.sFormatoFecha(cobros.FieldByName('fecha').AsString), 3, 'Arial, normal, 8', salida, 'N') else
        list.Linea(50, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(60, list.Lineactual, cobros.FieldByName('observacion').AsString, 4, 'Arial, normal, 8', salida, 'S');

      totales[1] := totales[1] + cobros.FieldByName('monto').AsFloat;
      if Length(Trim(cobros.FieldByName('fecha').AsString)) > 0 then totales[2] := totales[2] + cobros.FieldByName('monto').AsFloat;
    end;
    cobros.Next;
  end;

  if xtipo_inf = 'T' then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total a Cobrar / Cobrado / Adeudado:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(45, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.importe(60, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.importe(75, list.Lineactual, '', totales[1] - totales[2], 4, 'Arial, negrita, 8');
    list.Linea(75, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
  end;
  if xtipo_inf = 'P' then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total a Cobrar:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(45, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(65, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;
  cobros.Close;

  list.FinList;
end;

procedure TTInformesGastosCCSR.InformeCobrosAnual(xperiodo: String; xestado: Boolean; salida: char);
// Objetivo...: Listar Resumen de Cobros Anual
Begin
  InfCobrosAnual(xperiodo, 'P', xestado, salida);
end;

procedure TTInformesGastosCCSR.InformeCobrosAnualAdeudado(xperiodo: String; xestado: Boolean; salida: char);
// Objetivo...: Listar Resumen de Cobros Anual Deudas
Begin
  InfCobrosAnual(xperiodo, 'I', xestado, salida);
end;

procedure TTInformesGastosCCSR.InfCobrosAnual(xanio, xtipo_inf: String; xestado: Boolean; salida: char);
// Objetivo...: Listar Resumen de Cobros Anual
var
  i, j, k, m, n: Integer;
  l: TStringList;
  lista: Boolean;
  anio: String;
  totanual: array[1..12] of Real;
  monto: Real;
Begin
  anio := Copy(xanio, 4, 4);
  for i := 1 to 150 do
    for j := 1 to 13 do
      if j = 1 then resanual[i, j] := '' else resanual[i, j] := '0';

  if xestado then l := propietario.setListaPropietariosActivos else l := propietario.setListaPropietarios;
  For i := 1 to l.Count do
    resanual[i+1, 1] := l.Strings[i-1];
  l.Destroy;

  resanual[1, 2] := '01/' + anio; resanual[1, 3] := '02/' + anio; resanual[1, 4] := '03/' + anio; resanual[1, 5] := '04/' + anio;
  resanual[1, 6] := '05/' + anio; resanual[1, 7] := '06/' + anio; resanual[1, 8] := '07/' + anio; resanual[1, 9] := '08/' + anio;
  resanual[1, 10] := '09/' + anio; resanual[1, 11] := '10/' + anio; resanual[1, 12] := '11/' + anio; resanual[1, 13] := '12/' + anio;

  list.Setear(salida);
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  if xtipo_inf = 'P' then list.Titulo(0, 0, 'Resumen Anual de Cobros - A�o ' + Copy(xanio, 4, 4), 1, 'Arial, negrita, 14');
  if xtipo_inf = 'I' then list.Titulo(0, 0, 'Resumen Anual Cobros Pendientes - A�o ' + Copy(xanio, 4, 4), 1, 'Arial, negrita, 14');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  list.Titulo(0, 0, 'Propietario', 1, 'Arial, cursiva, 8');
  list.Titulo(21,  list.Lineactual, 'Enero', 2, 'Arial, cursiva, 8');
  list.Titulo(26,  list.Lineactual, 'Febrero', 3, 'Arial, cursiva, 8');
  list.Titulo(33,  list.Lineactual, 'Marzo', 4, 'Arial, cursiva, 8');
  list.Titulo(39,  list.Lineactual, 'Abril', 5, 'Arial, cursiva, 8');
  list.Titulo(45,  list.Lineactual, 'Mayo', 6, 'Arial, cursiva, 8');
  list.Titulo(51,  list.Lineactual, 'Junio', 7, 'Arial, cursiva, 8');
  list.Titulo(57,  list.Lineactual, 'Julio', 8, 'Arial, cursiva, 8');
  list.Titulo(63, list.Lineactual, 'Agosto', 9, 'Arial, cursiva, 8');
  list.Titulo(69, list.Lineactual, 'Sept.', 10, 'Arial, cursiva, 8');
  list.Titulo(74, list.Lineactual, 'Octubre', 11, 'Arial, cursiva, 8');
  list.Titulo(80, list.Lineactual, 'Noviem.', 12, 'Arial, cursiva, 8');
  list.Titulo(87, list.Lineactual, 'Diciem.', 13, 'Arial, cursiva, 8');

  list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  cobros.Open;

  For m := 1 to 12 do Begin
    datosdb.Filtrar(cobros, 'Periodo = ' + '''' + utiles.sLlenarIzquierda(IntToStr(m), 2, '0') + '/' + anio + '''');
    cobros.First;
    while not cobros.Eof do Begin
      lista := False;
      if xtipo_inf = 'P' then
        if Length(Trim(cobros.FieldByName('fecha').AsString)) = 8 then lista := True;
      if xtipo_inf = 'I' then
        if Length(Trim(cobros.FieldByName('fecha').AsString)) < 8 then lista := True;

      if lista then Begin
        i := setProp(cobros.FieldByName('idpropiet').AsString);
        if i > 0 then
          resanual[i, StrToInt(Copy(cobros.FieldByName('periodo').AsString, 1, 2)) + 1] := cobros.FieldByName('monto').AsString;
      end;

      cobros.Next;
    end;
  end;

  cobros.Close;

  // Listamos la Matriz
  k := 0; n := 0;
  For i := 2 to 350 do Begin
    if Length(Trim(resanual[i, 1])) = 0 then Break;
    Inc(n);
    For j := 1 to 13 do Begin
      if j = 1 then Begin
        if k > 0 then list.Linea(96, list.Lineactual, '', 14, 'Arial, normal, 8', salida, 'S');
        propietario.getDatos(resanual[i, 1]);
        list.Linea(0, 0, Copy(propietario.nombre, 1, 22), 1, 'Arial, normal, 8', salida, 'N');
        k := 20;
      end else Begin
        k := k + 6;
        list.importe(k, list.Lineactual, '', StrToFloat(resanual[i, j]),j, 'Arial, normal, 8');
      end;
    end;
  end;

  // Subtotalizamos la Matriz
  k := 0;
  For i := 2 to 13 do Begin
    monto := 0;
    For j := 2 to n+1 do monto := monto + StrToFloat(resanual[j, i]);
    Inc(k);
    totanual[k] := monto;
  end;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Total General:', 1, 'Arial, normal, 8', salida, 'N');
  k := 20;
  For i := 1 to 12 do Begin
    k := k + 6;
    list.importe(k, list.Lineactual, '', totanual[i], i+1, 'Arial, normal, 8');
  end;
  list.Linea(95, list.Lineactual, '', 1, 'Arial, normal, 8', salida, 'S');

  list.FinList;
end;

function  TTInformesGastosCCSR.setProp(xidpropiet: String): Integer;
// Objetivo...: Buscar la ranura del propietario
var
  i: Integer;
Begin
  Result := 0;
  for i := 1 to 150 do Begin
    if resanual[i, 1] = xidpropiet then Begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TTInformesGastosCCSR.IniciarArreglos;
// Objetivo...: Iniciar arreglos
var
  i, j: Integer;
Begin
  For i := 1 to 50 do
    For j := 1 to 5 do listItems[i, j] := '';
end;

procedure TTInformesGastosCCSR.CargarParametros(xid: integer);
begin
  parametro1 := ''; parametro2 := ''; parametro3 := ''; parametro4 := ''; parametro5 := '';
  parametros.Open;
  if (parametros.FindKey([xid])) then begin
    parametro1 := parametros.FieldByName('parametro1').asstring;
    parametro2 := parametros.FieldByName('parametro2').asstring;
    parametro3 := parametros.FieldByName('parametro3').asstring;
    parametro4 := parametros.FieldByName('parametro4').asstring;
    parametro5 := parametros.FieldByName('parametro5').asstring;
  end;
end;

procedure TTInformesGastosCCSR.GuardarParametros(xid: integer; parametro1, parametro2, parametro3, parametro4, parametro5, parametro6, parametro7: string);
begin
  if not (parametros.Active) then parametros.Open;  
  if (parametros.FindKey([xid])) then parametros.edit else parametros.Append;
  parametros.FieldByName('id').asinteger        := xid;
  parametros.FieldByName('parametro1').asstring := parametro1;
  parametros.FieldByName('parametro2').asstring := parametro2;
  parametros.FieldByName('parametro3').asstring := parametro3;
  parametros.FieldByName('parametro4').asstring := parametro4;
  parametros.FieldByName('parametro5').asstring := parametro5;
  parametros.FieldByName('parametro6').asstring := parametro6;
  parametros.FieldByName('parametro7').asstring := parametro7;
  parametros.post;
  datosdb.closeDB(parametros);
end;

function TTInformesGastosCCSR.getMontosRedBancaria(xperiodo: string): TQuery;
begin
  result := datosdb.tranSQL('select * from totalesbcos where periodo = ' + '''' + xperiodo + '''');
end;

{===============================================================================}

function infgastos: TTInformesGastosCCSR;
begin
  if xinfgastos = nil then
    xinfgastos := TTInformesGastosCCSR.Create;
  Result := xinfgastos;
end;

{===============================================================================}

initialization

finalization
  xinfgastos.Free;

end.
