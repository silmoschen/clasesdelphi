unit CListar;

interface

uses SysUtils, CUtiles, scrReporte, Listado, Printers, CConfigImpresora, DBTables, contenedorMemo,
     Forms, WinProcs, CBDT, CTitulos, CUtilidadesArchivos, Graphics, Classes, IBTable;

const
  it = 50; st = 30;

type
  xx = array[1..it] of integer; yy = array[1..it] of integer; ly = array[1..it] of string; nc = array[1..it] of integer; fu = array[1..it] of string;
  sx = array[1..st] of integer; sy = array[1..st] of integer; sl = array[1..st] of string; sc = array[1..st] of integer; su = array[1..st] of string;

TTListar = class(TObject)            // Superclase
  altopag, m, pagina, reserva, esp, altotit, LineasSubtotales, largoImpresionMemo: integer; Comprimida, visruptura, exportar_rep: Boolean;
  ancho_doble_seleccionar, ancho_doble_cancelar, modo_resaltado_seleccionar, modo_resaltado_cancelar, doble_trazo_seleccionar, doble_trazo_cancelar,
  modo_cursivo_seleccionar, modo_cursivo_cancelar, modo_subrayado_seleccionar, modo_subrayado_cancelar: String;
  tipolist: char;
 public
  { Declaraciones Públicas }
  constructor Create(x1, x2, x3: integer; ts: char);
  destructor  Destroy; override;

  procedure   Linea(h, v: integer; detalle: string; columna: byte; fuente: string; tiposalida, chequearsalto: char);
  function    PrintLn(h, v: integer; detalle: string; columna: byte; fuente: string): integer;
  procedure   importe(h: integer; v: integer; mascara: string; importe: real; columna: byte; fuente: string);
  procedure   derecha(h: integer; v: integer; mascara: string; linea: string; columna: byte; fuente: string);
  procedure   IniciarNuevaPagina;
  procedure   Titulo(h, v: integer; detalle: string; columna: byte; fuente: string);
  procedure   CambiarLeyendaTitulo(xtitulo: string; xindice: integer);
  procedure   IniciarTitulos;
  procedure   ListTitulos;
  procedure   SubTitulo(h, v: integer; detalle: string; columna: byte; fuente: string);
  procedure   ListSubTitulos;
  function    Linealargopagina(salida: char): string; overload;
  function    Linealargopagina(caracter: string; salida: char): string; overload;
  function    nroPagina: integer;
  function    Lineactual: integer;
  function    SaltoPagina: boolean;
  function    EfectuoSaltoPagina: boolean;
  procedure   FinList;
  procedure   FinList1;
  procedure   FinListLeyendaFinal(leyenda: string); overload;
  procedure   FinListLeyendaFinal(leyenda1, leyenda2: string); overload;
  procedure   CompletarPagina;
  procedure   CompletarPaginaConNumeracion;
  procedure   CompletarPaginaPie(leyenda_pie: string); overload;
  procedure   CompletarPaginaPie(leyenda_pie1, leyenda_pie2: string); overload;
  procedure   FijarSaltoManual;
  procedure   Setear(salida: char); overload;
  procedure   Setear(salida: char; xmargen_izquierdo: Integer); overload;
  procedure   CantidadDeCopias(xcantcopias: integer); overload;
  procedure   ResolucionImpresora(xresolucion: integer);
  procedure   AjustarResolImpresora(xresolucion: integer; salida: char);
  procedure   SeleccionarImpresora(ximpresora: integer; xnombre: string);
  procedure   NumeroPrimeraHoja(xnropag: integer);
  function    RealizarSaltoPagina(xlargo: integer): boolean;
  procedure   NoImprimirPieDePagina;
  procedure   SaltarHojaSinNumerarPagina;
  procedure   SaltarHojaSinSubrayar;
  procedure   ImprimirVetical;
  procedure   ImprimirHorizontal;
  procedure   ReservarLineasParaSubtotales(xcantidad: Integer);

 { Gestion para la Impresión de Memos }
  procedure   ListMemo(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer); overload;
  function    ListMemoTitulos(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer): Integer;
  procedure   ListMemoRecortandoStringIzquierda(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
  procedure   ListMemoRecortandoEspaciosVericales(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
  procedure   ListMemoRecortandoEspaciosHorizontales_Verticales(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
  procedure   ListMemo(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto, MargenIzquierdo: integer; xrotulo_inicio, xrotulo_fin: String); overload;
  procedure   RemplazarEtiquetasEnMemo(xetiqueta, xvalor: string);
  procedure   RemplazarTodasLasEtiquetasEnMemo(xetiqueta, xvalor: string);
  function    ExtraerItemsMemoImp(xitems: integer): string;
  procedure   IniciarMemoImpresiones(xtabla: TTable; xcampo: string; largoDelTexto: integer);
  procedure   IniciarMemoImpresionesIBase(xtabla: TIBTable; xcampo: string; largoDelTexto: integer);
  procedure   IniciarMemoImpresionesDesdeArchivo(xarchivo: string; largoDelTexto: integer);
  procedure   LiberarMemoImpresiones;
  function    NumeroLineasMemo: integer;
  function    EspaciosMemo(xitems: integer): integer;
  procedure   ListMemoRecortandoStringIzquierda_Titulos(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
  procedure   ListarMemo(xcampo, xfuente: String; xtabla: TTable; largoTexto, cordX, columnaInicial: Integer; salida: char);
  function    setContenidoMemo(xtabla: TTable; xcampo: string; largoDelTexto: integer): TStringList; overload;
  function    setContenidoMemoQuery(xtabla: TQuery; xcampo: string; largoDelTexto: integer): TStringList; overload;
  function    setContenidoMemoIBase(xtabla: TIBTable; xcampo: string; largoDelTexto: integer): TStringList;
  function    setContenidoMemo: TStringList; overload;
  function    BuscarContenidoMemo(xexpresion: String): Boolean;
  { Texto Enriquecido }
  procedure   IniciarRichEdit(xarchivo: String; xlineas_al_final: Integer; salida: char);
  procedure   RemplazarEtiquetasEnRichEdit(xetiqueta, xvalor: string);
  procedure   ListarRichEdit(xarchivo: String; xlineas_al_final: Integer; salida: char);
  procedure   ListarRichEdit_Titulo(xarchivo: String; xlineas_al_final: Integer; salida: char);
  { Agregados para los titulos }

  { Gestion para la Impresión en modo Texto al estilo DOS }
  procedure   IniciarImpresionModoTexto; overload;
  procedure   TituloTxt(linea: String; salto: Boolean);
  procedure   IniciarImpresionModoTexto(xaltopagina: Integer); overload;
  procedure   LineaTxt(linea: string; salto: boolean);
  procedure   ImporteTxt(valor: real; enteros, decimales: integer; salto: boolean);
  procedure   FinalizarImpresionModoTexto(xcopias: shortint);
  procedure   FinalizarImpresionModoTextoSinSaltarPagina(xcopias: shortint);
  function    AltoPagTxt: ShortInt;
  function    ImpresionModoTexto: Boolean;
  procedure   ExportarInforme(xarchivo: String); overload;
  procedure   ExportarInforme(xarchivo, xdestino: String); overload;
  procedure   FinalizarExportacion;
  function    IsPrinter : Boolean;

  procedure   EstablecerTiempoConsulta(xtiempo: Integer);

  procedure   SetearCaracteresTexto;
  procedure   AnularCaracteresTexto;
 private
  { Declaraciones Privadas }
  lxx: xx; lyy: yy; lly: ly; lnc: nc; lfu: fu; items: integer;
  sxx: sx; syy: sy; sly: sl; snc: sc; slf: su; sitems: integer;

  no_saltar_pagina, saltar_pagina, salto_de_pagina, memo_iniciado, list_seteado, saltar_sinnumerar, no_subrayar: boolean;
  archivo: TextFile;
  procedure IniciarPag;
  procedure LimpiarArray;
  procedure PrintTxt;
 protected
  { Declaraciones Protegidas }
end;

function list: TTListar;

implementation

var
  xlistar: TTListar = nil;

constructor TTListar.Create(x1, x2, x3: integer; ts: char);
begin
  inherited Create;
  altopag  := x1;  m := x2; pagina := x3;
  tipolist := ts; items := 0; sitems := 0; reserva := 0; esp := 0; pagina := 0; LineasSubtotales := 0;
  no_saltar_pagina := False;   // Controla que la página no salte cuando imprime el Pie Final de la misma
  SetearCaracteresTexto;
end;

destructor TTListar.Destroy;
begin
  inherited Destroy;
end;

procedure TTListar.Titulo(h, v: integer; detalle: string; columna: byte; fuente: string);
//Objetivo....: Mantener los Parámetros para las diversas Emisiones de Títulos que se deban hacer
begin
  if items < it then Inc(items);
  lxx[items] := h;
  lyy[items] := v;
  lly[items] := detalle;
  lnc[items] := columna;
  lfu[items] := fuente;
end;

procedure TTListar.CambiarLeyendaTitulo(xtitulo: string; xindice: integer);
// Objetivo...: Sobreescribir un titulo (leyenda);
begin
  lly[xindice] := xtitulo;
end;

procedure TTListar.IniciarTitulos;
//Objetivo....: Re-Inicializar Titulos
begin
  items := 0; sitems := 0;
end;

procedure TTListar.ListTitulos;
//Objetivo....: Emitir Títulos
var
  i, j, l: integer;
  s, expr, aux: string;
begin
  j := 0;
  if (tipoList = 'P') or (tipoList = 'I') then Begin
    if items = 0 then Begin
      PrintLn(0, 0, ' ', 1, 'Arial, negrita, 14');
      reserva := reporte.altolineaimpresa;
    end else
      For l := 1 to items do begin
        if lxx[l] = 0 then j := 0 else j := reporte.linea_actual;  // Gestiono la Coordenada Vertical
        aux := lly[l];
        i := pos('#pagina', lly[l]);   // Averiguamos si hay expresiones, las mismas comienzan con #
        if i > 0 then begin
          s := lly[l];
          delete(s, i, Length(Trim('#pagina')));
          j := pos('#pagina', s);
          Inc(pagina);
          expr := copy(s, i, j-i) + utiles.sLlenarIzquierda(IntToStr(Pagina), 4, '0');
          delete(s, i, j-1);
          lly[l] := s + expr;
        end;

        PrintLn(lxx[l], j, lly[l], lnc[l], lfu[l]);
        lly[l] := aux;
        if lxx[l] = 0 then j := m;
        if l = 1 then reserva := reporte.altolineaimpresa;
        if l = 1 then altotit := reporte.altolineaimpresa;
      end;
    if Printer.Orientation = PoLandscape then LineasSubtotales := reserva * 2;

    if sitems > 0 then ListSubTitulos;    // Listamos, si hay, el Subtitulo
  end;
end;

procedure TTListar.SubTitulo(h, v: integer; detalle: string; columna: byte; fuente: string);
//Objetivo....: Mantener los Parámetros para las diversas Emisiones de Subtitulos
begin
  Inc(sitems);
  sxx[sitems] := h;
  syy[sitems] := v;
  sly[sitems] := detalle;
  snc[sitems] := columna;
  slf[sitems] := fuente;
end;

procedure TTListar.ListSubTitulos;
//Objetivo....: Emitir Subtitulos
var
  i, j, l: integer;
  s, expr, aux: string;
begin
  j := 0;
  For l := 1 to sitems do Begin
    if sxx[l] = 0 then j := 0 else j := reporte.linea_actual;  // Gestiono la Coordenada Vertical
    PrintLn(sxx[l], j, sly[l], snc[l], slf[l]);
    sly[l] := aux;
    if sxx[l] = 0 then j := m;
  end;
end;

function TTListar.PrintLn(h, v: integer; detalle: string; columna: byte; fuente: string): integer;
{Objetivo...: Gestionar la impresión de una línea}
begin
  if Length(trim(detalle)) = 0 then detalle := ' ';
  if columna = 1 then
    begin
      reporte.detalle(detalle, 1, fuente);
      m := m + reporte.altolineaimpresa;
    end
  else reporte.implinea(h, v, detalle, columna, fuente);
  Result := m;
end;

procedure TTListar.Linea(h, v: integer; detalle: string; columna: byte; fuente: string; tiposalida, chequearsalto: char);
{Objetivo...: Largar una línea y controlar los saltos de páginas}
begin
  saltar_pagina := False;   // Control para los saltos de página manuales
  tipolist := tiposalida;
  salto_de_pagina := False;
  if not list_seteado then list.Setear(tiposalida);
  if reporte.tipo_salto <> 1 then   // Calculamos los renglones a reservar para los saltos manuales
    if m > (altopag - LineasSubtotales) then saltar_pagina := True;

  if altopag = 0 then
    begin
      {Seteos de Inicio de Impresión}
      no_saltar_pagina := False;
      altopag := reporte.altodepagina(tiposalida) - LineasSubtotales;
      if not reporte.seteoiniciado then reporte.Setear(tipolist);
      ListTitulos;
    end;

  {Emitimos una Linea de detalle}
  if (PrintLn(h, v, detalle, columna, fuente) > altopag) and (chequearsalto = 'S') then
    begin
      if reporte.tipo_salto = 1 then   // Salto de Página Automático
        begin
          {Salto de Página}
          if not saltar_sinnumerar then Begin
            if not (no_subrayar) then
              PrintLn(h, v, linealargopagina(tipolist), 1, 'Arial, normal, 11')
            else
              PrintLn(h, v, '', 1, 'Arial, normal, 11');
            PrintLn(h, v, 'Pág.: ' + utiles.sLlenarIzquierda(IntToStr(nroPagina), 4, '0'), 1, 'Times New Roman, normal, 8');
          end else Begin
            if not (no_subrayar) then
              PrintLn(h, v, linealargopagina(tipolist), 1, 'Arial, normal, 11')
            else
              PrintLn(h, v, '', 1, 'Arial, normal, 11');
            PrintLn(h, v, '', 1, 'Times New Roman, normal, 8');
          end;
          salto_de_pagina := True;
          IniciarNuevaPagina;   // Inicializamos la Nueva Página de Impesión
        end
      else
        salto_de_pagina := False;
    end;
end;

procedure TTListar.IniciarNuevaPagina;
// Objetivo...: Inicializar una página nueva
begin
  m := 0;
  {Si la salida se gestiona en la Impresora Avanzo a la siguiente Página}
  if tipolist = 'I' then
    if not no_saltar_pagina then reporte.NuevaPagina;
  if tipolist = 'P' then
    if not (no_saltar_pagina) and (visruptura) then
      if not salto_de_pagina then Begin
        CompletarPagina;
        if not (no_subrayar) then
          PrintLn(0, 0, linealargopagina(tipolist), 1, 'Arial, normal, 11')
        else
          PrintLn(0, 0, '', 1, 'Arial, normal, 11');
        PrintLn(0, 0, 'Pág.: ' + utiles.sLlenarIzquierda(IntToStr(nroPagina), 4, '0'), 1, 'Times New Roman, normal, 8');
      end;
  ListTitulos;
end;

procedure TTListar.importe(h: integer; v: integer; mascara: string; importe: real; columna: byte; fuente: string);
// Objetivo...: Listar Importes
begin
  if Length(trim(mascara)) = 0 then mascara := '###,###,##0.00';
  reporte.impimporte(h, v, mascara, importe, columna, fuente);
end;

procedure TTListar.derecha(h: integer; v: integer; mascara: string; linea: string; columna: byte; fuente: string);
// Objetivo...: Dibujar, por ejemplo, una línea de subtotal
begin
  if Length(trim(mascara)) = 0 then mascara := '###,###,##0.00';
  reporte.impderecha(h, v, mascara, linea, columna, fuente);
end;

function TTListar.linealargopagina(salida: char): string;
{Objetivo....: Devolver una linea de largo de Hoja}
var
  strlinea : string;
  j, z, l: integer;
begin
  z := impresora.ResolucionImpresora;
  j := z; strlinea := ''; l := Round(impresora.ext_resolucion(salida) * 3.8);
  // Dibujamos la línea de acuerdo a la Orientación de la Impresora
  if printer.Orientation = poLandscape then l := Round(impresora.ext_resolucion(salida) * 7);

  while j < l do Begin
    j := j + z;
    strlinea := strlinea + '_';
  end;
  Result := strlinea;
end;

function TTListar.linealargopagina(caracter: string; salida: char): string;
{Objetivo....: Devolver una linea de largo de Hoja}
var
  strlinea : string;
  j, z, l: integer;
begin
  ///z := impresora.resolucion('I');  // Resolución Impresora
  z := impresora.ResolucionImpresora;
  j := z; strlinea := ''; l := Round(impresora.ext_resolucion(salida) * 3.8);
  // Dibujamos la línea de acuerdo a la Orientación de la Impresora
  if printer.Orientation = poLandscape then l := Round(impresora.ext_resolucion(salida) * 7);

  while j < l do Begin
    j := j + z;
    strlinea := strlinea + caracter;
  end;
  Result := strlinea;
end;

procedure TTListar.CompletarPagina;
// Objetivo...: Rellenar una Página hasta el Pie de la misma
var
  limite, altp: integer;
begin
  limite := m + reserva;
  altp   := reporte.altodepagina(tipolist) - LineasSubtotales;
  while limite < altp do Begin
    reporte.detalle(' ', 1, 'Arial, normal, 8');
    limite := limite + reporte.altolineaimpresa;
  end;
  reporte.detalle(' ', 1, 'Arial, normal, 8');
end;

procedure TTListar.CompletarPaginaConNumeracion;
// Objetivo...: Rellenar una Página hasta el Pie de la misma e Imprimir Numeración
Begin
  CompletarPagina;
  if not (no_subrayar) then begin
    PrintLn(0, 0, linealargopagina(tipolist), 1, 'Arial, normal, 11');
    PrintLn(0, 0, 'Pág.: ' + utiles.sLlenarIzquierda(IntToStr(nroPagina), 4, '0'), 1, 'Times New Roman, normal, 8');
  end else begin
    PrintLn(0, 0, '', 1, 'Arial, normal, 11');
    PrintLn(0, 0, '', 1, 'Times New Roman, normal, 8');
  end;
end;

procedure TTListar.CompletarPaginaPie(leyenda_pie: string);
begin
  CompletarPagina;
  PrintLn(0, 0, leyenda_pie, 1, 'Times New Roman, normal, 10');
end;

procedure TTListar.CompletarPaginaPie(leyenda_pie1, leyenda_pie2: string);
begin
  CompletarPagina;
  PrintLn(0, 0, leyenda_pie1, 1, 'Times New Roman, normal, 10');
  PrintLn(0, 0, leyenda_pie2, 1, 'Times New Roman, normal, 10');
end;


procedure TTListar.NoImprimirPieDePagina;
// Objetivo...: Impedir que se imprima el Pie de Página
begin
  reporte.tipo_salto := 3;
end;

procedure TTListar.SaltarHojaSinNumerarPagina;
// Ojetivo...: saltar de página sin numerarla
Begin
  saltar_sinnumerar := True;
end;

procedure TTListar.SaltarHojaSinSubrayar;
// Ojetivo...: saltar de página sin numerarla
Begin
  no_subrayar := True;
end;

procedure TTListar.FinList;
{Objetivo....: Completar la última Página del reporte}
begin
  if (tipolist = 'I') or (tipolist = 'P') then Begin
    no_saltar_pagina := True;   // Impide que salte al Listar las Líneas Finales

    if reporte.tipo_salto = 1 then Begin  // Salto automático
      CompletarPagina;            // Rellena hasta llegar al final de la página
      if not saltar_sinnumerar then Begin
        if not (no_subrayar) then
          reporte.detalle(linealargopagina(tipolist), 1, 'Arial, normal, 11')
        else
          reporte.detalle('', 1, 'Arial, normal, 11');
        reporte.detalle('Pág.: ' + utiles.sLlenarIzquierda(IntToStr(nroPagina), 4, '0') + utiles.espacios(100) + 'Impreso: ' + DateTimeToStr(Now), 1 , 'Times New Roman, normal, 8');
      end else Begin
        if not (no_subrayar) then
          reporte.detalle(linealargopagina(tipolist), 1, 'Arial, normal, 11')
        else
          reporte.detalle('', 1, 'Arial, normal, 11');
        reporte.detalle('', 1 , 'Times New Roman, normal, 8');
      end;
    end;
    if reporte.tipo_salto = 3 then CompletarPagina;   // Finaliza sin imprimir Pie

    if not reporte.ExistenDatos then utiles.msgError('No Existen Datos para Presentar en el Informe ...!') else reporte.Finlistado(tipolist);
    IniciarPag;
  end;
  if tipolist = 'I' then printer.Orientation := poPortrait;
  LimpiarArray;
  list_seteado      := False;
  saltar_sinnumerar := False;
  no_subrayar       := False;
end;

procedure TTListar.FinList1;
{Objetivo....: Completar la última Página del reporte}
begin
  no_saltar_pagina := True;   // Impide que salte al Listar las Líneas Finales

  if reporte.tipo_salto = 1 then Begin   // Salto automático
    CompletarPagina;            // Rellena hasta llegar al final de la página
    if not (no_subrayar) then    
      reporte.detalle(linealargopagina(tipolist), 1, 'Arial, normal, 11')
    else
      reporte.detalle('', 1, 'Arial, normal, 11');
  end;

  if not reporte.ExistenDatos then utiles.msgError('No Existen Datos para Presentar en el Informe ...!') else reporte.Finlistado(tipolist);
  IniciarPag;
  if tipolist = 'I' then printer.Orientation := poPortrait;
  LimpiarArray;
  list_seteado := False;
end;

procedure TTListar.FinListLeyendaFinal(leyenda: string);
{Objetivo....: Completar la última Página del reporte}
begin
  if (tipolist = 'I') or (tipolist = 'P') then Begin
    no_saltar_pagina := True;   // Impide que salte al Listar las Líneas Finales

    if reporte.tipo_salto = 1 then Begin  // Salto automático
      CompletarPagina;            // Rellena hasta llegar al final de la página
      reporte.detalle(leyenda, 1 , 'Times New Roman, normal, 10');
    end;
    if reporte.tipo_salto = 3 then begin
      CompletarPagina;   // Finaliza sin imprimir Pie
    end;

    if not reporte.ExistenDatos then utiles.msgError('No Existen Datos para Presentar en el Informe ...!') else reporte.Finlistado(tipolist);
    IniciarPag;
  end;
  if tipolist = 'I' then printer.Orientation := poPortrait;
  LimpiarArray;
  list_seteado      := False;
  saltar_sinnumerar := False;
  no_subrayar       := False;
end;

procedure TTListar.FinListLeyendaFinal(leyenda1, leyenda2: string);
{Objetivo....: Completar la última Página del reporte}
begin
  if (tipolist = 'I') or (tipolist = 'P') then Begin
    no_saltar_pagina := True;   // Impide que salte al Listar las Líneas Finales

    if reporte.tipo_salto = 1 then Begin  // Salto automático
      CompletarPagina;            // Rellena hasta llegar al final de la página
      reporte.detalle(leyenda1, 1 , 'Times New Roman, normal, 10');
      reporte.detalle(leyenda2, 1 , 'Times New Roman, normal, 10');
    end;
    if reporte.tipo_salto = 3 then begin
      CompletarPagina;   // Finaliza sin imprimir Pie
    end;

    if not reporte.ExistenDatos then utiles.msgError('No Existen Datos para Presentar en el Informe ...!') else reporte.Finlistado(tipolist);
    IniciarPag;
  end;
  if tipolist = 'I' then printer.Orientation := poPortrait;
  LimpiarArray;
  list_seteado      := False;
  saltar_sinnumerar := False;
  no_subrayar       := False;
end;


procedure TTListar.IniciarPag;
// Objetivo...: Estado inicial para la próxima imporesión
begin
  altopag := 0;
  m       := 0;
  items   := 0;
  sitems  := 0;
  if pagina <> 0 then pagina  := 0;
end;

function TTListar.nroPagina: integer;
// Objetivo...: Retornar Nro. de Página
begin
  Inc(pagina);
  Result := pagina;
end;

function TTListar.Lineactual: integer;
// Objetivo...: Retornar la línea que se está imprimiendo
begin
  Result := reporte.Linea_actual;
end;

procedure TTListar.FijarSaltoManual;
// Objetivo...: Fijar el tipo de salto de página
begin
  reporte.FijarSaltoManual;
end;

function  TTListar.SaltoPagina: boolean;
// Objetivo...: Notificar cuando se debe realizar un salto de página, para el caso en que los saltos sean manuales
begin
  Result := saltar_pagina;
end;

function TTListar.EfectuoSaltoPagina: boolean;
// Objetivo...: Informar si se salto a la página siguiente
begin
  Result := salto_de_pagina;
end;

procedure TTListar.setear(salida: char);
// Objetivo...: Setear atributos para la emisión de informes
begin
  reporte.Setear(salida);
  list_seteado := True;
  //LimpiarArray; // 05-2006
end;

procedure TTListar.setear(salida: char; xmargen_izquierdo: Integer);
// Objetivo...: Setear atributos para la emisión de informes
begin
  reporte.Setear(salida, xmargen_izquierdo);
  list_seteado := True;
end;

procedure TTListar.CantidadDeCopias(xcantcopias: integer);
// Objetivo...: Fijar la cantidad de copias a imprimir
begin
  reporte.CantidadDeCopias(xcantcopias);
end;

procedure  TTListar.ResolucionImpresora(xresolucion: integer);
// Objetivo...: Fijar la resolución para la impresora
begin
  if tipolist = 'I' then reporte.resolImpr := xresolucion;
end;

procedure  TTListar.AjustarResolImpresora(xresolucion: integer; salida: char);
// Objetivo...: Fijar la resolución para la impresora
begin
  reporte.AjustarResolImpresora(xresolucion, salida);
end;

procedure TTListar.SeleccionarImpresora(ximpresora: integer; xnombre: string);
// Objetivo...: Seleccionar Impresora
begin
  Impresora.SeleccionarImpresora(ximpresora, xnombre);
end;

procedure TTListar.NumeroPrimeraHoja(xnropag: integer);
// Objetivo...: Especificar Número 1º página
begin
  pagina := xnropag - 1;
end;

function TTListar.RealizarSaltoPagina(xlargo: integer): boolean;
// Objetivo...: Verificar si se debe realizar salto de pagina, para la siguiente impresion
begin
  if m + xlargo >= altopag then Result := True else Result := False;
end;

procedure TTListar.ImprimirVetical;
// Objetivo...: Imprimir Vertical
begin
  if not printer.Printing then printer.Orientation := poPortrait;
  impresora.cfgImpresora('V');
end;

procedure TTListar.ImprimirHorizontal;
// Objetivo...: Imprimir Horizontal
begin
  if not printer.Printing then printer.Orientation := poLandscape;
end;

procedure TTListar.ReservarLineasParaSubtotales(xcantidad: Integer);
var
  ms: Integer;
begin
  if impresora.msu > 0 then ms := StrToInt(FloatToStr(impresora.msu)) div 10 else ms := 1;
  if ms = 0 then ms := 1;
  LineasSubtotales := ((impresora.ResolucionImpresora div ms) - (impresora.ResolucionImpresora div 10)) * xcantidad;
  if xcantidad = 0 then LineasSubtotales := 0;
end;

procedure TTListar.ListMemo(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
// Objetivo...: Gestionar la Impresión de Memos
const
  c: string = '';
var
  lineas, i, j: integer; lm: String;
begin
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  lineas := fmGMemo.R.Lines.Count;

  For i := 1 to lineas do Begin
    j := pos('.', fmGMemo.R.Lines[i-1]);
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
    if j = 0 then List.Linea(0, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente, salida, 'S') else Begin
    if Copy(fmGMemo.R.Lines[i-1], j + 1, 1) < 'a' then Begin
      if cordX = 0 then List.Linea(cordX, 0, c + lm, 1, xfuente, salida, 'S') else Begin
      List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
      List.Linea(cordX, list.Lineactual, c + lm, 2, xfuente, salida, 'S');
    end end else Begin
      if cordX = 0 then List.Linea(cordX, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente, salida, 'S') else Begin
      List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
      List.Linea(cordX, list.Lineactual, c + fmGMemo.R.Lines[i-1], 2, xfuente, salida, 'S');
    end end;

    // Verificamos Salto de Página; si el informe maneja saltos manuales
    if reporte.tipo_salto = 3 then
      if RealizarSaltoPagina(altotit) then IniciarNuevaPagina;
  end;
  end;
  LiberarMemoImpresiones;
end;

function TTListar.ListMemoTitulos(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer): Integer;
// Objetivo...: Gestionar la Impresión de Memos
const
  c: string = '';
var
  lineas, i, j, limp: integer; lm: String;
begin
  limp := 0;
  titulos.conectar;
  titulos.getDatos;
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  lineas := fmGMemo.R.Lines.Count;

  For i := 1 to lineas do Begin
    j := pos('.', fmGMemo.R.Lines[i-1]);
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
    if j = 0 then List.Titulo(0, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente) else Begin
    if Copy(fmGMemo.R.Lines[i-1], j + 1, 1) < 'a' then Begin
      if cordX = 0 then Begin
        if salida <> 'T' then List.Titulo(cordX, 0, c + lm, 1, xfuente);
        if salida = 'T' then Begin
          list.LineaTxt(c + lm, True);
          Inc(limp);
        end;
      end else Begin
        if salida <> 'T' then Begin
          List.Titulo(0, 0, ' ', 1, xfuente);
          List.Titulo(cordX, list.Lineactual, c + lm, 2, xfuente);
        end else Begin
          List.LineaTxt(' ', True);
          List.LineaTxt(c + lm, True);
          limp := limp + 2;
        end;
    end end else Begin
      if cordX = 0 then Begin
        if salida <> 'T' then List.Titulo(cordX, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente);
        if salida = 'T' then Begin
          List.LineaTxt(c + fmGMemo.R.Lines[i-1], True);
          Inc(limp);
        end;
      end else Begin
        if salida <> 'T' then Begin
          List.Titulo(0, 0, ' ', 1, xfuente);
          List.Titulo(cordX, 0, c + fmGMemo.R.Lines[i-1], 2, xfuente);
        end else Begin
          List.LineaTxt('  ', True);
          List.LineaTxt(c + fmGMemo.R.Lines[i-1], True);
          limp := limp + 2;
        end;
    end end;

    // Verificamos Salto de Página; si el informe maneja saltos manuales
    if salida <> 'T' then
      if reporte.tipo_salto = 3 then
        if RealizarSaltoPagina(altotit) then IniciarNuevaPagina;
  end;
  end;
  LiberarMemoImpresiones;
  titulos.desconectar;
  Result := limp;
end;

procedure TTListar.ListMemoRecortandoStringIzquierda(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
// Objetivo...: Gestionar la Impresión de Memos - recortando espacios por la izquierda
const
  c: string = '';
var
  lineas, i, j: integer;
begin
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  lineas := fmGMemo.R.Lines.Count;

  For i := 1 to lineas do
    begin
      j := pos('.', fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if j = 0 then List.Linea(0, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente, salida, 'S') else Begin
      if Copy(fmGMemo.R.Lines[i-1], j + 1, 1) < 'a' then Begin
        if cordX = 0 then List.Linea(cordX, 0, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 1, xfuente, salida, 'S') else Begin
          List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
          List.Linea(cordX, list.Lineactual, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 2, xfuente, salida, 'S');
        end end else Begin
          if cordX = 0 then List.Linea(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 1, xfuente, salida, 'S') else Begin
          List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
          List.Linea(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 2, xfuente, salida, 'S');
        end end;
      end;
    // Verificamos Salto de Página; si el informe maneja saltos manuales
    if reporte.tipo_salto = 3 then
      if RealizarSaltoPagina(altotit) then IniciarNuevaPagina;
    end;
  LiberarMemoImpresiones;
end;

procedure TTListar.ListMemoRecortandoEspaciosVericales(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
// Objetivo...: Gestionar la Impresión de Memos - recortando espacios por la izquierda
const
  c: string = '';
var
  lineas, i, j: integer;
begin
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  lineas := fmGMemo.R.Lines.Count;

  For i := 1 to lineas do Begin
    if Length(Trim(fmGMemo.R.Lines[i-1])) > 0 then begin
      j := pos('.', fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if j = 0 then List.Linea(0, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente, salida, 'S') else Begin
      if Copy(fmGMemo.R.Lines[i-1], j + 1, 1) < 'a' then Begin
        if cordX = 0 then List.Linea(cordX, 0, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 1, xfuente, salida, 'S') else Begin
          List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
          List.Linea(cordX, list.Lineactual, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 2, xfuente, salida, 'S');
        end end else Begin
          if cordX = 0 then List.Linea(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 1, xfuente, salida, 'S') else Begin
          List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
          List.Linea(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 2, xfuente, salida, 'S');
        end end;
      end;
    end;
   // Verificamos Salto de Página; si el informe maneja saltos manuales
    if reporte.tipo_salto = 3 then
      if RealizarSaltoPagina(altotit) then IniciarNuevaPagina;
  end;
  LiberarMemoImpresiones;
end;

procedure TTListar.ListMemoRecortandoEspaciosHorizontales_Verticales(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
// Objetivo...: Gestionar la Impresión de Memos - recortando espacios por la izquierda
const
  c: string = '';
var
  lineas, i, j: integer;
begin
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  lineas := fmGMemo.R.Lines.Count;

  For i := 1 to lineas do Begin
    if Length(Trim(fmGMemo.R.Lines[i-1])) > 0 then begin
      j := pos('.', fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if j = 0 then List.Linea(0, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente, salida, 'S') else Begin
      if Copy(fmGMemo.R.Lines[i-1], j + 1, 1) < 'a' then Begin
        if cordX = 0 then List.Linea(cordX, 0, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 1, xfuente, salida, 'S') else Begin
          List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
          List.Linea(cordX, list.Lineactual, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 2, xfuente, salida, 'S');
        end end else Begin
          if cordX = 0 then List.Linea(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 1, xfuente, salida, 'S') else Begin
          List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
          List.Linea(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 2, xfuente, salida, 'S');
        end end;
      end;
    end;
    // Verificamos Salto de Página; si el informe maneja saltos manuales
    if reporte.tipo_salto = 2 then
      if RealizarSaltoPagina(altotit) then IniciarNuevaPagina;
  end;
  LiberarMemoImpresiones;
end;

procedure TTListar.ListMemo(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto, MargenIzquierdo: integer; xrotulo_inicio, xrotulo_fin: String);
// Objetivo...: Gestionar la Impresión de Memos entre dos rotulos
var
  c: string;
  lineas, i, j, limp: integer; lm: String; f: Boolean;
begin
  if MargenIzquierdo > 0 then c := utiles.espacios(MargenIzquierdo) else c := '';
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  if largoDelTexto > 0 then fmGMemo.R.Width := largoDelTexto;

  lineas := fmGMemo.R.Lines.Count;

  For i := 1 to lineas do Begin
    if f then
      if Copy(fmGMemo.R.Lines[i-1], 1, Length(xrotulo_fin)) = xrotulo_fin then f := False;
    if f then Begin
      j := pos('.', fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
      if j = 0 then Begin
        if salida <> 'T' then List.Linea(0, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente, salida, 'S');
        if salida = 'T' then Begin
          List.LineaTxt(c + fmGMemo.R.Lines[i-1], True);
          Inc(limp);
        end;
      end else Begin
      if Copy(fmGMemo.R.Lines[i-1], j + 1, 1) < 'a' then Begin
        if salida <> 'T' then Begin
          if cordX = 0 then List.Linea(cordX, 0, c + lm, 1, xfuente, salida, 'S') else Begin
            List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
            List.Linea(cordX, list.Lineactual, c + lm, 2, xfuente, salida, 'S');
          end;
        end;
        if salida = 'T' then Begin
          List.LineaTxt(c + lm, True);
          Inc(limp);
        end;
      end else Begin
        if salida <> 'T' then Begin
          if cordX = 0 then List.Linea(cordX, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente, salida, 'S') else Begin
            List.Linea(0, 0, ' ', 1, xfuente, salida, 'N');
            List.Linea(cordX, 0, c + fmGMemo.R.Lines[i-1], 2, xfuente, salida, 'S');
          end;
        end;
        if salida = 'T' then Begin
          List.LineaTxt(c + fmGMemo.R.Lines[i-1], True);
          Inc(limp);
        end;
      end;
      end;
    end;

    if Copy(fmGMemo.R.Lines[i-1], 1, Length(xrotulo_inicio)) = xrotulo_inicio then f := True;

    // Verificamos Salto de Página; si el informe maneja saltos manuales
    if salida <> 'T' then
      if reporte.tipo_salto = 3 then
        if RealizarSaltoPagina(altotit) then IniciarNuevaPagina;
  end;
end;

procedure TTListar.RemplazarEtiquetasEnMemo(xetiqueta, xvalor: string);
// Objetivo...: Remplazar Etiquetas en Memos
var
  SelPos: integer;
begin
  SelPos := Pos(xetiqueta, fmGMemo.R.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.R.SelStart  := SelPos - 1;
    fmGMemo.R.SelLength := Length(xetiqueta);
    fmGMemo.R.SelText   := xvalor;      { Replace selected text with ReplaceText }
  end;
end;

function  TTListar.BuscarContenidoMemo(xexpresion: String): Boolean;
// Objetivo...: Buscar contenido en Memo
var
  SelPos: integer;
begin
  SelPos := Pos(xexpresion, fmGMemo.R.Lines.Text);
  if SelPos > 0 then Result := True else Result := False;
end;

procedure TTListar.RemplazarTodasLasEtiquetasEnMemo(xetiqueta, xvalor: string);
// Objetivo...: Remplazar Etiquetas en Memos
var
  SelPos, i: integer;
begin
  For i := 1 to fmGMemo.R.Lines.Count do Begin
    SelPos := Pos(xetiqueta, fmGMemo.R.Lines.Text);
    if SelPos > 0 then Begin
      fmGMemo.R.SelStart  := SelPos - 1;
      fmGMemo.R.SelLength := Length(xetiqueta);
      fmGMemo.R.SelText   := xvalor;      { Replace selected text with ReplaceText }
    end;
  end;
end;

procedure TTListar.IniciarMemoImpresiones(xtabla: TTable; xcampo: string; largoDelTexto: integer);
// Objetivo...: Iniciar Memo Luego de las Impresiones
begin
  Application.CreateForm(TfmGMemo, fmGMemo);
  if largoDelTexto > 0 then fmGMemo.R.Width := largoDelTexto;
  fmGMemo.DTS.DataSet := xtabla;
  fmGMemo.R.DataField := xcampo;
  memo_iniciado       := True;
end;

procedure TTListar.IniciarMemoImpresionesIBase(xtabla: TIBTable; xcampo: string; largoDelTexto: integer);
// Objetivo...: Iniciar Memo Luego de las Impresiones
begin
  Application.CreateForm(TfmGMemo, fmGMemo);
  if largoDelTexto > 0 then fmGMemo.R.Width := largoDelTexto;
  fmGMemo.DTS.DataSet := xtabla;
  fmGMemo.R.DataField := UpperCase(xcampo);
  memo_iniciado       := True;
end;

procedure TTListar.IniciarMemoImpresionesDesdeArchivo(xarchivo: string; largoDelTexto: integer);
// Objetivo...: Iniciar Memo Luego de las Impresiones
var
  l: TStringList;
  i: Integer;
begin
  Application.CreateForm(TfmGMemo, fmGMemo);
  if largoDelTexto > 0 then fmGMemo.R.Width := largoDelTexto;
  l := TStringList.Create;
  if FileExists(xarchivo) then Begin
    l.LoadFromFile(xarchivo);
    For i := 1 to l.Count do fmGMemo.R.Lines.Add(l.Strings[i-1]);
  end;
  l.Destroy;
  memo_iniciado       := True;
end;

procedure TTListar.LiberarMemoImpresiones;
// Objetivo...: Liberar Memo Luego de las Impresiones
begin
  if Assigned(fmGMemo) then Begin
    fmGMemo.DTS.DataSet := nil; fmGMemo.R.DataField := '';
    fmGMemo.Release; fmGMemo := nil;
    memo_iniciado := False;
  end;
end;

function TTListar.ExtraerItemsMemoImp(xitems: integer): string;
// Objetivo...: Extraer un itmes del memo
begin
  Result := fmGMemo.R.Lines[xitems];
end;

function TTListar.NumeroLineasMemo: integer;
// Objetivo...: devolver el número de lineas del memo
begin
  Result := fmGMemo.R.Lines.Count;
end;

function TTListar.EspaciosMemo(xitems: integer): integer;
// Objetivo...: devolver la cantidad de espacios antes de una etiqueta
var
  i: integer;
begin
  Result := 0;
  For i := 1 to Length(fmGMemo.R.Lines[xitems]) do
    if Length(Trim(Copy(fmGMemo.R.Lines[xitems], i, 1))) > 0 then Begin
      Result := i - 1;
      Break;
    end;
end;

procedure TTListar.ListMemoRecortandoStringIzquierda_Titulos(xcampo, xfuente: string; cordX: byte; salida: char; xtabla: TTable; largoDelTexto: integer);
// Objetivo...: Gestionar la Impresión de Memos - recortando espacios por la izquierda
const
  c: string = '';
var
  lineas, i, j: integer;
begin
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  lineas := fmGMemo.R.Lines.Count;

  For i := 1 to lineas do Begin
    if Length(Trim(fmGMemo.R.Lines[i-1])) > 0 then Begin
      j := pos('.', fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if j = 0 then List.Titulo(0, 0, c + fmGMemo.R.Lines[i-1], 1, xfuente) else Begin
      if Copy(fmGMemo.R.Lines[i-1], j + 1, 1) < 'a' then Begin
        if cordX = 0 then List.Titulo(cordX, 0, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 1, xfuente) else Begin
          List.Titulo(0, 0, ' ', 1, xfuente);
          List.Titulo(cordX, list.Lineactual, c + TrimLeft(Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2))), 2, xfuente);
        end end else Begin
          if cordX = 0 then List.Titulo(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 1, xfuente) else Begin
          List.Titulo(0, 0, ' ', 1, xfuente);
          List.Titulo(cordX, 0, c + TrimLeft(fmGMemo.R.Lines[i-1]), 2, xfuente);
        end end;
      end;
    end;
  end;
  LiberarMemoImpresiones;
end;

procedure TTListar.ListarMemo(xcampo, xfuente: String; xtabla: TTable; largoTexto, cordX, columnaInicial: Integer; salida: char);
// Objetivo...: Listar datos
var
  l: TStringList;
  i, j: Integer;
  lm: String;
Begin
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoTexto);
  l := TStringList.Create;
  for i := 1 to fmGMemo.R.Lines.Count do Begin
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
    l.Add(lm);
  end;
  for i := 1 to l.Count do Begin
    if i = 1 then Begin
      if cordX = 0 then Linea(0, 0, l.Strings[i-1], 1, xfuente, salida, 'S') else
         Linea(cordX, list.Lineactual, l.Strings[i-1], columnaInicial, xfuente, salida, 'S');
    end else Begin
      if cordX = 0 then Linea(0, 0, l.Strings[i-1], 1, xfuente, salida, 'S') else Begin
         Linea(0, 0, '', 1, xfuente, salida, 'N');
         Linea(cordX, list.Lineactual, l.Strings[i-1], 2, xfuente, salida, 'S');
      end;
    end;
  end;
  LiberarMemoImpresiones;
end;

function  TTListar.setContenidoMemo(xtabla: TTable; xcampo: string; largoDelTexto: integer): TStringList;
// Objetivo...: Cargar las Lineas de un Memo en un StringList y devolverlas
var
  l: TStringList;
  i, j: Integer;
  lm: String;
Begin
  if not memo_iniciado then IniciarMemoImpresiones(xtabla, xcampo, largoDelTexto);
  l := TStringList.Create;
  for i := 1 to fmGMemo.R.Lines.Count do Begin
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
    l.Add(lm);
  end;
  LiberarMemoImpresiones;

  Result := l;
end;

function  TTListar.setContenidoMemoQuery(xtabla: TQuery; xcampo: string; largoDelTexto: integer): TStringList;
// Objetivo...: Cargar las Lineas de un Memo en un StringList y devolverlas
var
  l: TStringList;
  i, j: Integer;
  lm: String;
Begin
  if not memo_iniciado then begin
    Application.CreateForm(TfmGMemo, fmGMemo);
    if largoDelTexto > 0 then fmGMemo.R.Width := largoDelTexto;
    fmGMemo.DTS.DataSet := xtabla;
    fmGMemo.R.DataField := xcampo;
    memo_iniciado       := True;
  end;
  l := TStringList.Create;
  for i := 1 to fmGMemo.R.Lines.Count do Begin
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
    l.Add(lm);
  end;
  LiberarMemoImpresiones;

  Result := l;
end;

function  TTListar.setContenidoMemoIBase(xtabla: TIBTable; xcampo: string; largoDelTexto: integer): TStringList;
// Objetivo...: Cargar las Lineas de un Memo en un StringList y devolverlas
var
  l: TStringList;
  i, j: Integer;
  lm: String;
Begin
  if not memo_iniciado then IniciarMemoImpresionesIBase(xtabla, xcampo, largoDelTexto);
  l := TStringList.Create;
  for i := 1 to fmGMemo.R.Lines.Count do Begin
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
    l.Add(lm);
  end;
  LiberarMemoImpresiones;

  Result := l;
end;

function  TTListar.setContenidoMemo: TStringList;
// Objetivo...: Cargar las Lineas de un Memo en un StringList y devolverlas
var
  l: TStringList;
  i, j: Integer;
  lm: String;
Begin
  l := TStringList.Create;
  for i := 1 to fmGMemo.R.Lines.Count do Begin
    if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then j := Length(fmGMemo.R.Lines[i-1]);
      if Copy(fmGMemo.R.Lines[i-1], Length(fmGMemo.R.Lines[i-1]) - 1, 1) < 'a' then lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 2)) else lm := Copy(fmGMemo.R.Lines[i-1], 1, (Length(fmGMemo.R.Lines[i-1]) - 1));
    l.Add(lm);
  end;
  LiberarMemoImpresiones;

  Result := l;
end;

procedure TTListar.IniciarRichEdit(xarchivo: String; xlineas_al_final: Integer; salida: char);
var
  i, t: Integer; fuent, estilo: String;
begin
  if FileExists(xarchivo) then Begin
    if altopag = 0 then list.Setear(salida);
    Application.CreateForm(TfmGMemo, fmGMemo);
    if largoImpresionMemo = 0 then fmGMemo.RichEdit1.Width := 600 else fmGMemo.RichEdit1.Width := largoImpresionMemo;
    fmGMemo.RichEdit1.Lines.LoadFromFile(xarchivo);
  End;
end;

procedure TTListar.RemplazarEtiquetasEnRichEdit(xetiqueta, xvalor: string);
// Objetivo...: Remplazar Etiquetas en RichEdit's
var
  SelPos: integer;
begin
  SelPos := Pos(xetiqueta, fmGMemo.RichEdit1.Lines.Text);
  if SelPos > 0 then Begin
    fmGMemo.RichEdit1.SelStart  := SelPos - 1;
    fmGMemo.RichEdit1.SelLength := Length(xetiqueta);
    fmGMemo.RichEdit1.SelText   := xvalor;      { Replace selected text with ReplaceText }
  end;
end;

procedure TTListar.ListarRichEdit(xarchivo: String; xlineas_al_final: Integer; salida: char);
var
  i, t: Integer; fuent, estilo: String;
begin
  if (FileExists(xarchivo)) or (xarchivo = '---') then Begin
    if (xarchivo <> '---') then Begin
      if altopag = 0 then list.Setear(salida);
      Application.CreateForm(TfmGMemo, fmGMemo);
      if largoImpresionMemo = 0 then fmGMemo.RichEdit1.Width := 600 else fmGMemo.RichEdit1.Width := largoImpresionMemo;
      fmGMemo.RichEdit1.Lines.LoadFromFile(xarchivo);
    End;
    for i := 1 to fmGMemo.RichEdit1.Lines.Count do Begin
      if fmGMemo.RichEdit1.Lines.Count = 0 then Break;
      fmGMemo.RichEdit1.SelStart := 0;
      fmGMemo.RichEdit1.SelLength := Length(TrimRight(fmGMemo.RichEdit1.Lines[0]));
      fuent := fmGMemo.RichEdit1.SelAttributes.Name;
      t := fmGMemo.RichEdit1.SelAttributes.Size;
      estilo := 'normal';
      if fmGMemo.RichEdit1.SelAttributes.Style = [fsBold] then estilo := 'negrita';
      if fmGMemo.RichEdit1.SelAttributes.Style = [fsItalic] then estilo := 'cursiva';
      if fmGMemo.RichEdit1.SelAttributes.Style = [fsUnderline] then estilo := 'subrayado';

      list.Linea(0, 0, fmGMemo.RichEdit1.Lines[0], 1, fuent + ', ' + estilo + ',' + IntToStr(t), salida, 'S');
      fmGMemo.RichEdit1.Lines.Delete(0);
      fuent := ''; estilo := '';
    end;
    fmGMemo.RichEdit1.Lines.Clear;
    fmGMemo.Release; fmGMemo := Nil;

    for i := 1 to xlineas_al_final do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
end;

procedure TTListar.ListarRichEdit_Titulo(xarchivo: String; xlineas_al_final: Integer; salida: char);
var
  i, t: Integer; fuent, estilo: String;
begin
  if FileExists(xarchivo) then Begin
    if altopag = 0 then list.Setear(salida);
    Application.CreateForm(TfmGMemo, fmGMemo);
    if largoImpresionMemo = 0 then fmGMemo.RichEdit1.Width := 600 else fmGMemo.RichEdit1.Width := largoImpresionMemo;
    fmGMemo.RichEdit1.Lines.LoadFromFile(xarchivo);
    for i := 1 to fmGMemo.RichEdit1.Lines.Count do Begin
      if fmGMemo.RichEdit1.Lines.Count = 0 then Break;
      fmGMemo.RichEdit1.SelStart := 0;
      fmGMemo.RichEdit1.SelLength := Length(fmGMemo.RichEdit1.Lines[0]);
      fuent := fmGMemo.RichEdit1.SelAttributes.Name;
      t := fmGMemo.RichEdit1.SelAttributes.Size;
      estilo := 'normal';
      if fmGMemo.RichEdit1.SelAttributes.Style = [fsBold] then estilo := 'negrita';
      if fmGMemo.RichEdit1.SelAttributes.Style = [fsItalic] then estilo := 'cursiva';
      if fmGMemo.RichEdit1.SelAttributes.Style = [fsUnderline] then estilo := 'subrayado';

      list.Titulo(0, 0, fmGMemo.RichEdit1.Lines[0], 1, fuent + ', ' + estilo + ',' + IntToStr(t));
      fmGMemo.RichEdit1.Lines.Delete(0);
    end;
    fmGMemo.RichEdit1.Lines.Clear;
    fmGMemo.Release; fmGMemo := Nil;

    for i := 1 to xlineas_al_final do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
end;

{******************************************************************************}

{ Gestion para la Impresión en modo Texto al estilo DOS }
procedure TTListar.IniciarImpresionModoTexto;
begin
  AssignFile(archivo, dbs.DirSistema + '\list.txt');
  Rewrite(archivo);
  items := 0; sitems := 0;
end;

procedure TTListar.ExportarInforme(xarchivo: String);
begin
  AssignFile(archivo, xarchivo);
  Rewrite(archivo);
end;

procedure TTListar.ExportarInforme(xarchivo, xdestino: String);
// Objetivo...: Copiar un archivo a otro
Begin
  utilesarchivos.CopiarArchivos(xarchivo, xdestino);
end;

procedure TTListar.TituloTxt(linea: String; salto: Boolean);
begin
  Inc(items);
  lly[items] := linea;
  if salto then lxx[items] := 1 else lxx[items] := 0;
end;

procedure TTListar.IniciarImpresionModoTexto(xaltopagina: Integer);
begin
  IniciarImpresionModoTexto;
  altopag := xaltopagina;
end;

procedure TTListar.LineaTxt(linea: string; salto: boolean);
begin
  if pos('CHR(15)', UpperCase(linea)) > 0 then Comprimida := True;
  if pos('CHR(18)', UpperCase(linea)) > 0 then Comprimida := False;

  if (exportar_rep) then linea := utiles.StringRemplazarCaracteres(linea, CHR(15), '');
  if (exportar_rep) then linea := utiles.StringRemplazarCaracteres(linea, CHR(18), '');

  if salto then WriteLn(archivo, utiles.StrQuitarCaracteresEspeciales(linea)) else Write(archivo, utiles.StrQuitarCaracteresEspeciales(linea));
  if salto then Inc(items);
end;

procedure TTListar.ImporteTxt(valor: real; enteros, decimales: integer; salto: boolean);
begin
  if salto then WriteLn(archivo, valor:enteros:decimales) else Write(archivo, valor:enteros:decimales);
  if salto then Inc(items);
end;

procedure TTListar.FinalizarImpresionModoTexto(xcopias: shortint);
var
  i: shortint;
begin
  if reporte.tipo_salto <> 3 then lineaTxt(CHR(12), True);
  FinalizarImpresionModoTextoSinSaltarPagina(xcopias);
end;

procedure TTListar.FinalizarImpresionModoTextoSinSaltarPagina(xcopias: shortint);
var
  i: shortint;
Begin
  CloseFile(archivo);
  if IsPrinter then
    For i := 1 to xcopias do PrintTxt    //utilesarchivos.WinExecNoWait32(PChar(dbs.DirSistema + '\list.bat'), 0)
  else
    utiles.msgError('Se ha Producido un Error al Escribir en la Impresora,' + chr(13) + 'verifique que este Encendida.');
  items  := 0;
  sitems := 0;
end;

procedure TTListar.PrintTxt;
var
  PrnFile, archivo : TextFile;
  linea: String;
begin
  AssignFile(archivo, dbs.DirSistema + '\list.txt');
  reset(archivo);
  AssignFile(PrnFile, impresora.Puerto);
  Rewrite(PrnFile);
  while not eof(archivo) do Begin
    ReadLn(archivo, linea);
    Writeln(PrnFile, linea);
  end;
  System.CloseFile(PrnFile);
  closeFile(archivo);
end;

procedure TTListar.FinalizarExportacion;
begin
  CloseFile(archivo);
end;

function TTListar.AltoPagTxt: ShortInt;
begin
  Result := impresora.LineasModoTexto;
end;

function TTListar.ImpresionModoTexto: Boolean;
begin
  Result := impresora.ImprimeEnModoTexto;
end;

procedure TTListar.LimpiarArray;
var
  i: Integer;
begin
  For i := 1 to it do Begin
    lxx[i] := 0; lyy[i] := 0; lly[i] := ''; lnc[i] := 0; lfu[i] := '';
  end;
  largoImpresionMemo := 0;
end;

function TTListar.IsPrinter: Boolean;
{var
  IMpresora: TextFile;}
begin
{AssignFile(Impresora,'lpt1');   // Impresora : TExtFile;
{$I-}
{Rewrite(Impresora);
{$I+}
{if ioresult<>0 then Result := False else Result := True;}
Result := True;
end;

procedure TTListar.EstablecerTiempoConsulta(xtiempo: Integer);
Begin
  reporte.EstablecerTiempo(xtiempo);
end;

procedure TTListar.SetearCaracteresTexto;
// Control de Fuentes Impresión Modo Texto
Begin
  ancho_doble_seleccionar    := CHR(14);
  ancho_doble_cancelar       := CHR(14);
  modo_resaltado_seleccionar := CHR(27) + 'E';
  modo_resaltado_cancelar    := CHR(27) + 'F';
  doble_trazo_seleccionar    := CHR(27) + 'G';
  doble_trazo_cancelar       := CHR(27) + 'H';
  modo_cursivo_seleccionar   := CHR(27) + '4';
  modo_cursivo_cancelar      := CHR(27) + '5';
  modo_subrayado_seleccionar := CHR(27) + '-1';
  modo_subrayado_cancelar    := CHR(27) + '-0';
end;

procedure TTListar.AnularCaracteresTexto;
// Control de Fuentes Impresión Modo Texto
Begin
  ancho_doble_seleccionar    := '';
  ancho_doble_cancelar       := '';
  modo_resaltado_seleccionar := '';
  modo_resaltado_cancelar    := '';
  doble_trazo_seleccionar    := '';
  doble_trazo_cancelar       := '';
  modo_cursivo_seleccionar   := '';
  modo_cursivo_cancelar      := '';
  modo_subrayado_seleccionar := '';
  modo_subrayado_cancelar    := '';
end;

{===============================================================================}

function list: TTListar;
begin
  if xlistar = nil then
    xlistar := TTListar.Create(0, 0, 0, 'P');
  Result := xlistar;
end;

{===============================================================================}

initialization

finalization
  xlistar.Free;

end.
