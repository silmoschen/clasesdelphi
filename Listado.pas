unit Listado;

interface

uses Forms, Printers, SysUtils, Dialogs, Classes, Graphics, scrReporte, DB, DBTables, ConfigurarImpresora, CConfigimpresora, cutiles;

const
  colores= 16;
  color1 : array[1..colores] of TColor = (clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal, clGray, clSilver, clRed, clLime, clYellow, clBlue, clFuchsia, clAqua, clWhite);
  color2 : array[1..colores] of string = ('clBlack', 'clMaroon', 'clGreen', 'clOlive', 'clNavy', 'clPurple', 'clTeal', 'clGray', 'clSilver', 'clRed', 'clLime', 'clYellow', 'clBlue', 'clFuchsia', 'clAqua', 'clWhite');

type
  TTListado = class(TObject)
     alto, linea, altolinea, largo, x, i, tamanio, alx, posicion, resolImpr, marg_izquierdo, marg_superior, cx: integer;
     salida: char;
     tipo_salto: byte;
     seteoiniciado, lineas_impresas, NoMostrarMsg, ExistenDatos: boolean;    // Controla que no se inicie un listado mas de una vez

     constructor Create;
     destructor  Destroy; override;

     procedure   Setear(ts: char); overload;
     procedure   Setear(ts: char; xmargen_izquierdo: Integer); overload;
     procedure   inilist(ts: char);
     function    trazarLinea(salida: char; largo: integer): string;
     function    altodepagina(salida: char): integer;
     procedure   detalle (detalle: string; columna: byte; fuente: string);                     {Imprimir linea de detalle e incrementar en Nro. de Pixeles}
     procedure   implinea(h: integer; v: integer; detalle: string; columna: byte; fuente: string); {Imprime línea de detalle sin incrementar el Nro. de Pixeles}
     procedure   impimporte(h: integer; v: integer; mascara: string; importe: real; columna: byte; fuente: string); {Imprime importe Formateado y alineado a la derecha}
     procedure   impderecha(h: integer; v: integer; mascara: string; linea: string; columna: byte; fuente: string); {Dibuja un valor comenzando por la derecha}
     procedure   Finlistado(ts: char);                                   {Finalizar Impresión}
     function    linea_actual: integer;
     function    altolineaimpresa: integer;
     procedure   Preliminar;
     procedure   NuevaPagina;
     procedure   TituloListado(tiposalida: char; titulo: string);
     procedure   FijarSaltoManual;
     procedure   CantidadDeCopias(xcantcopias: integer);
     procedure   AjustarResolImpresora(xresolucion: integer; salida: char);
     function    IndiceColores(xcolor: TColor): integer;
     function    NombreDelColor(xcolor: Integer): TColor;
     procedure   EstablecerTiempo(xtiempo: Integer);
    private
     lineasimpresas, itemsimpresos, resolucionModificada, tiempo: integer; f: boolean;
     titlist, tipofuente, estilo, color: string;
     function  indiceColor(xcolor: string): integer;
     procedure TipoLetra(fuente: string);
end;

function reporte: TTListado;

implementation

var
  xreporte: TTListado = nil;

{==============================================================================}

constructor TTListado.Create;
begin
  inherited Create;
  alto := 0; linea := 0; altolinea := 0; largo := 0; x := 0; i := 0; tamanio := 0; alx := 0; posicion := 0; resolImpr := 0; marg_izquierdo := 0; marg_superior := 0; cx := 0;
  tipo_salto := 1;   // 1- Automatico; 2- Manual / Permite realizar cierres de Página en Forma Manual
end;

destructor TTListado.Destroy;
begin
  inherited Destroy;
end;

{===============================================================================}

function TTListado.linea_actual: integer;
{Objetivo...: Devolver el Nro. de linea Impreso en el Canvas}
begin
  Result := linea - altolinea;
end;

function TTListado.altolineaimpresa: integer;
{Objetivo...: Devolver el alto de la linea Impresa en la Canva}
begin
  Result := alx;
end;

function  TTListado.trazarLinea(salida: char; largo: integer): string;
// Objetivo...: dada una longitud, dibujar una línea
var
  strlinea: string;
  j       : integer;
begin
  For j := 1 to largo do strlinea := strlinea +  '_';
  Result := strlinea;
end;

function  TTListado.altodepagina(salida: char): integer;
{Objetivo...: Definir el alto de la hoja de impresion}
begin
  alto   := 0;
  if (salida = 'P') and (printer.Orientation = poPortrait)  then alto := impresora.Alto_Pag - 30;
  if (salida = 'P') and (printer.Orientation = poLandscape) then alto := impresora.Largo_Pag - 10;
  if (salida = 'I') and (printer.Orientation = poPortrait)  then alto := impresora.Alto_Pag - (8 * impresora.ResolucionImpresora);
  if (salida = 'I') and (printer.Orientation = poLandscape) then alto := impresora.Largo_Pag - (alx * 3);
  Result := alto;
end;

procedure TTListado.detalle(detalle: string; columna: byte; fuente: string);
{Objetivo...: Gestionar Impresión de líneas de detalle}
begin
  i := i + 1;
  implinea(0, linea, detalle, columna, fuente);
  altolinea := printer.Canvas.TextHeight(detalle);
  linea     := linea + altolinea;
  ExistenDatos := True;
end;

procedure TTListado.implinea(h: integer; v: integer; detalle: string; columna: byte; fuente: string);
{Objetivo...: Imprimir una línea en el reporte}
var
  indice, cx: integer;
begin
  // Determinamos la Dirección de la coordenada X
  if h = 0 then cx := h else cx := (h * resolImpr);

  if salida = 'I' then
    begin
      cx := cx + marg_Izquierdo;
      TipoLetra(fuente);   {Seteamos el tipo de Fuente antes de la Emisión}
      printer.Canvas.TextOut(cx, v, detalle); // Línea de detalle convencional
    end;
  if salida = 'P' then
    if Assigned(scrList) then begin
      x := x + 1;
      //Visualizamos un Formulario de Preparación del Informe

      if columna = 1 then
        begin
          scrList.ListBox1.Items.Add('');
          scrList.tipoletra1.Items.Add('');
          scrList.ListBox2.Items.Add('');
          scrList.col2.Items.Add('');
          scrList.tipoletra2.Items.Add('');
          scrList.ListBox3.Items.Add('');
          scrList.col3.Items.Add('');
          scrList.tipoletra3.Items.Add('');
          scrList.ListBox4.Items.Add('');
          scrList.col4.Items.Add('');
          scrList.tipoletra4.Items.Add('');
          scrList.ListBox5.Items.Add('');
          scrList.col5.Items.Add('');
          scrList.tipoletra5.Items.Add('');
          scrList.ListBox6.Items.Add('');
          scrList.col6.Items.Add('');
          scrList.tipoletra6.Items.Add('');
          scrList.ListBox7.Items.Add('');
          scrList.col7.Items.Add('');
          scrList.tipoletra7.Items.Add('');
          scrList.ListBox8.Items.Add('');
          scrList.col8.Items.Add('');
          scrList.tipoletra8.Items.Add('');
          scrList.ListBox9.Items.Add('');
          scrList.col9.Items.Add('');
          scrList.tipoletra9.Items.Add('');
          scrList.ListBox10.Items.Add('');
          scrList.col10.Items.Add('');
          scrList.tipoletra10.Items.Add('');
          scrList.ListBox11.Items.Add('');
          scrList.col11.Items.Add('');
          scrList.tipoletra11.Items.Add('');
          scrList.ListBox12.Items.Add('');
          scrList.col12.Items.Add('');
          scrList.tipoletra12.Items.Add('');
          scrList.ListBox13.Items.Add('');
          scrList.col13.Items.Add('');
          scrList.tipoletra13.Items.Add('');
          scrList.ListBox14.Items.Add('');
          scrList.col14.Items.Add('');
          scrList.tipoletra14.Items.Add('');
          scrList.ListBox15.Items.Add('');
          scrList.col15.Items.Add('');
          scrList.tipoletra15.Items.Add('');
          scrList.ListBox16.Items.Add('');
          scrList.col16.Items.Add('');
          scrList.tipoletra16.Items.Add('');
          scrList.ListBox17.Items.Add('');
          scrList.col17.Items.Add('');
          scrList.tipoletra17.Items.Add('');
          scrList.ListBox18.Items.Add('');
          scrList.col18.Items.Add('');
          scrList.tipoletra18.Items.Add(''); 
          scrList.ListBox19.Items.Add('');
          scrList.col19.Items.Add('');
          scrList.tipoletra19.Items.Add('');
          scrList.ListBox20.Items.Add('');
          scrList.col20.Items.Add('');
          scrList.tipoletra20.Items.Add('');
          scrList.ListBox21.Items.Add('');
          scrList.col21.Items.Add('');
          scrList.tipoletra21.Items.Add('');
          scrList.ListBox22.Items.Add('');
          scrList.col22.Items.Add('');
          scrList.tipoletra22.Items.Add('');
          scrList.ListBox23.Items.Add('');
          scrList.col23.Items.Add('');
          scrList.tipoletra23.Items.Add('');
          scrList.ListBox24.Items.Add('');
          scrList.col24.Items.Add('');
          scrList.tipoletra24.Items.Add('');
          scrList.ListBox25.Items.Add('');
          scrList.col25.Items.Add('');
          scrList.tipoletra25.Items.Add('');
          scrList.ListBox26.Items.Add('');
          scrList.col26.Items.Add('');
          scrList.tipoletra26.Items.Add('');
          scrList.ListBox27.Items.Add('');
          scrList.col27.Items.Add('');
          scrList.tipoletra27.Items.Add('');
          scrList.ListBox28.Items.Add('');
          scrList.col28.Items.Add('');
          scrList.tipoletra29.Items.Add('');
          scrList.ListBox29.Items.Add('');
          scrList.col29.Items.Add('');
          scrList.tipoletra29.Items.Add('');
          scrList.ListBox30.Items.Add('');
          scrList.col30.Items.Add('');
          scrList.tipoletra30.Items.Add('');
        end;

        indice := scrList.ListBox1.Items.Count - 1;

        Case columna of
          1: begin
              scrList.ListBox1.Items[indice] := {inttostr(linea) + ' ' +}  detalle;
              scrList.tipoletra1.Items[indice] := fuente;
            end;
          2: begin
              scrList.ListBox2.Items[indice] := detalle;
              scrList.col2.Items[indice] := IntToStr(cx);
              scrList.tipoletra2.Items[indice] := fuente;
            end;
          3: begin
              scrList.ListBox3.Items[indice] := detalle;
              scrList.col3.Items[indice] := IntToStr(cx);
              scrList.tipoletra3.Items[indice] := fuente;
            end;
          4: begin
              scrList.ListBox4.Items[indice] := detalle;
              scrList.col4.Items[indice] := IntToStr(cx);
              scrList.tipoletra4.Items[indice] := fuente;
           end;
          5: begin
              scrList.ListBox5.Items[indice] := detalle;
              scrList.col5.Items[indice] := IntToStr(cx);
              scrList.tipoletra5.Items[indice] := fuente;
            end;
          6: begin
              scrList.ListBox6.Items[indice] := detalle;
              scrList.col6.Items[indice] := IntToStr(cx);
              scrList.tipoletra6.Items[indice] := fuente;
            end;
          7: begin
              scrList.ListBox7.Items[indice] := detalle;
              scrList.col7.Items[indice] := IntToStr(cx);
              scrList.tipoletra7.Items[indice] := fuente;
            end;
          8: begin
              scrList.ListBox8.Items[indice] := detalle;
              scrList.col8.Items[indice] := IntToStr(cx);
              scrList.tipoletra8.Items[indice] := fuente;
            end;
          9: begin
              scrList.ListBox9.Items[indice] := detalle;
              scrList.col9.Items[indice] := IntToStr(cx);
              scrList.tipoletra9.Items[indice] := fuente;
            end;
         10: begin
              scrList.ListBox10.Items[indice] := detalle;
              scrList.col10.Items[indice] := IntToStr(cx);
              scrList.tipoletra10.Items[indice] := fuente;
            end;
         11: begin
              scrList.ListBox11.Items[indice] := detalle;
              scrList.col11.Items[indice] := IntToStr(cx);
              scrList.tipoletra11.Items[indice] := fuente;
             end;
         12: begin
              scrList.ListBox12.Items[indice] := detalle;
              scrList.col12.Items[indice] := IntToStr(cx);
              scrList.tipoletra12.Items[indice] := fuente;
            end;
         13: begin
              scrList.ListBox13.Items[indice] := detalle;
              scrList.col13.Items[indice] := IntToStr(cx);
              scrList.tipoletra13.Items[indice] := fuente;
            end;
         14: begin
              scrList.ListBox14.Items[indice] := detalle;
              scrList.col14.Items[indice] := IntToStr(cx);
              scrList.tipoletra14.Items[indice] := fuente;
             end;
         15: begin
              scrList.ListBox15.Items[indice] := detalle;
              scrList.col15.Items[indice] := IntToStr(cx);
              scrList.tipoletra15.Items[indice] := fuente;
             end;
         16: begin
              scrList.ListBox16.Items[indice] := detalle;
              scrList.col16.Items[indice] := IntToStr(cx);
              scrList.tipoletra16.Items[indice] := fuente;
             end;
          17: begin
              scrList.ListBox17.Items[indice] := detalle;
              scrList.col17.Items[indice] := IntToStr(cx);
              scrList.tipoletra17.Items[indice] := fuente;
             end;
          18: begin
              scrList.ListBox18.Items[indice] := detalle;
              scrList.col18.Items[indice] := IntToStr(cx);
              scrList.tipoletra18.Items[indice] := fuente;
             end;
          19: begin
              scrList.ListBox19.Items[indice] := detalle;
              scrList.col19.Items[indice] := IntToStr(cx);
              scrList.tipoletra19.Items[indice] := fuente;
             end;
          20: begin
              scrList.ListBox20.Items[indice] := detalle;
              scrList.col20.Items[indice] := IntToStr(cx);
              scrList.tipoletra20.Items[indice] := fuente;
             end;
          21: begin
              scrList.ListBox21.Items[indice] := detalle;
              scrList.col21.Items[indice] := IntToStr(cx);
              scrList.tipoletra21.Items[indice] := fuente;
             end;
          22: begin
              scrList.ListBox22.Items[indice] := detalle;
              scrList.col22.Items[indice] := IntToStr(cx);
              scrList.tipoletra22.Items[indice] := fuente;
             end;
          23: begin
              scrList.ListBox23.Items[indice] := detalle;
              scrList.col23.Items[indice] := IntToStr(cx);
              scrList.tipoletra23.Items[indice] := fuente;
             end;
          24: begin
              scrList.ListBox24.Items[indice] := detalle;
              scrList.col24.Items[indice] := IntToStr(cx);
              scrList.tipoletra24.Items[indice] := fuente;
             end;
          25: begin
              scrList.ListBox25.Items[indice] := detalle;
              scrList.col25.Items[indice] := IntToStr(cx);
              scrList.tipoletra25.Items[indice] := fuente;
             end;
          26: begin
              scrList.ListBox26.Items[indice] := detalle;
              scrList.col26.Items[indice] := IntToStr(cx);
              scrList.tipoletra26.Items[indice] := fuente;
             end;
          27: begin
              scrList.ListBox27.Items[indice] := detalle;
              scrList.col27.Items[indice] := IntToStr(cx);
              scrList.tipoletra27.Items[indice] := fuente;
             end;
          28: begin
              scrList.ListBox28.Items[indice] := detalle;
              scrList.col28.Items[indice] := IntToStr(cx);
              scrList.tipoletra28.Items[indice] := fuente;
             end;
          29: begin
              scrList.ListBox29.Items[indice] := detalle;
              scrList.col29.Items[indice] := IntToStr(cx);
              scrList.tipoletra29.Items[indice] := fuente;
             end;
          30: begin
              scrList.ListBox30.Items[indice] := detalle;
              scrList.col30.Items[indice] := IntToStr(cx);
              scrList.tipoletra30.Items[indice] := fuente;
             end;
        end;
     end;

     if salida = 'P' then
       begin
         {Solamente Emulamos la salida para el salto de Hoja en el Formulario}
         scrList.TipoLetra(fuente);
         scrList.Canvas.TextOut(0, 0, detalle);
       end;
   alx := printer.Canvas.TextHeight(detalle);  //Obtenemos el Alto de la Línea Impresa a partir del Canvas de la Impresora
   lineas_impresas := True;

   if columna = 1 then Inc(lineasimpresas);
   Inc(itemsimpresos);
end;

procedure TTListado.impimporte(h: integer; v: integer; mascara: string; importe: real; columna: byte; fuente: string);
{Objetivo...: Formatear un Importe para Emitir}
var
  L: integer; imp: string;
begin
  cx := h * resolImpr;  // Convertimos la diagonal vertical en pixeles para su tratamiento
  imp  := FormatFloat(mascara, importe);

  if salida <> 'P' then Begin
    if Length(Trim(imp)) > 7 then imp := ' ' + imp;
    if Length(Trim(imp)) < 7 then imp := ' ' + imp;
  end;

  if salida = 'P' then
    begin
      L := scrList.Canvas.TextWidth(imp);
      implinea((((h * resolImpr) -L) div 7), v, imp, columna, fuente);
    end
  else
    begin
      L := Printer.Canvas.TextWidth(imp);
      implinea((((h * resolImpr) - L) div resolimpr), v, imp, columna, fuente);
    end;
end;

procedure TTListado.impderecha(h: integer; v: integer; mascara: string; linea: string; columna: byte; fuente: string);
{Objetivo...: Trazar una Linea de Subtotal desde la Derecha}
var
  L: integer; imp: string;
begin
  cx := h * resolImpr;  // Convertimos la diagonal vertical en pixeles para su tratamiento
  imp  := linea;
  if salida = 'P' then
    begin
      L := scrList.Canvas.TextWidth(imp);
      implinea((((h * resolImpr) -L) div 7), v, imp, columna, fuente);
    end
  else
    begin
      L := Printer.Canvas.TextWidth(imp);
      implinea((((h * resolImpr) - L) div resolimpr), v, imp, columna, fuente);
    end;
end;

procedure TTListado.Finlistado(ts: char);
{Objetivo...: terminar emisión}
begin
  tipo_salto := 0;
  if ExistenDatos then Begin
    scrList.Caption := titlist;
    if ts = 'I' then printer.EndDoc;
    if ts = 'P' then Preliminar;
  end;
  if Assigned(scrList) then Begin
    scrList.Release; scrList := nil;
  end;
  seteoiniciado := False;
  f := False; ExistenDatos := False;
end;

procedure TTListado.Setear(ts: char);
// Objetivo...: Iniciar Reporte
begin
  alx    := 0;
  linea  := 0;
  salida := ts;
  altodepagina(salida);
  inilist(ts);
end;

procedure TTListado.Setear(ts: char; xmargen_izquierdo: Integer);
// Objetivo...: Iniciar Reporte
begin
  Setear(ts);
  marg_izquierdo := xmargen_izquierdo;
end;

procedure TTListado.inilist(ts: char);
{Objetivo...: Iniciar Emisión}
begin
  lineasimpresas := 0; itemsimpresos := 0;
  // Verificamos que existan Impresoras Instaladas
  if (ts = 'P') and not (Assigned(scrList)) then Application.CreateForm(TscrList, scrList);  // Constructor
  scrList.EstablecerTiempo(tiempo);
  if not impresora.VerifImprInstalada then fmConfigImpresora.ShowModal;
  ResolImpr := impresora.resolucion(salida);   // Recuperamos Reslución Impresora
  marg_izquierdo := impresora.Ext_Margen(salida, 'MI');
  if (tipo_salto = 0) then tipo_salto := 1;   // Por omisión, el salto es automático

  if ts = 'I' then
    begin
      Printer.Title := 'Informe shmSOFT';
      Printer.BeginDoc;
      linea := impresora.Ext_Margen(salida, 'MS');      // Para Iniciar una Nueva Página
    end;
  if ts = 'P' then
    begin
      i := 0;
      scrList.LimpiarArray;
    end;
  seteoiniciado   := True;
  lineas_impresas := False;
  salida := ts;
end;

procedure TTListado.AjustarResolImpresora(xresolucion: integer; salida: char);
begin
  f := True;
  ResolucionModificada := impresora.resolucion(xresolucion, salida);
end;

procedure TTListado.Preliminar;
{Objetivo...: Iniciar Emisión}
begin
  if Assigned(scrList) then scrList.ShowModal;
end;

procedure TTListado.TituloListado(tiposalida: char; titulo: string);
//Objetivo...: Dar un titulo al Gestor de Impresión
begin
  if tiposalida = 'I' then Printer.Title := titulo else scrList.Caption := titulo;
end;

procedure TTListado.TipoLetra(fuente: string);
{Objetivo...: Manejar las Fuentes en las Impresiones de Papel}
var
  strnueva: string;
begin
  color := '';
  if Length(Trim(fuente)) > 0 then
    begin
      {Buscamos la primer coma para obtener el Nombre de la Fuente}
      posicion  := 0;
      posicion  := Pos(',', fuente);
      tipofuente:= Copy(fuente, 1, posicion - 1);
      {Recortamos la Cadena para continuar la búsqueda del resto de los datos}
      strnueva  := Trim(Copy(fuente, posicion + 1, Length(fuente)));
      posicion  := Pos(',', strnueva);
      estilo    := Copy(strnueva, 1, posicion - 1);
      strnueva  := Copy(strnueva, posicion + 1, Length(strnueva));
      {Seteo del Color}
      posicion := Pos(',', strnueva);
      if Pos(',', strnueva) = 0 then tamanio := StrToInt(Trim(strnueva)) else
        begin
          tamanio  := StrToInt(Trim(Copy(strnueva, 1, posicion - 1)));
          strnueva := Trim(Copy(strnueva, posicion + 1, Length(strnueva)));
          color    := strnueva;
        end;

      {Eliminmamos todos los Estilos Existentes}
      with printer do
        begin
          Canvas.Font.Style := Canvas.Font.Style - [fsBold];
          Canvas.Font.Style := Canvas.Font.Style - [fsItalic];
          Canvas.Font.Style := Canvas.Font.Style - [fsUnderline];
          Canvas.Font.Style := Canvas.Font.Style - [fsStrikeOut];

          {Fijamos los Nuevos Estilos}
          if LowerCase(estilo) = 'negrita'    then Canvas.Font.Style := Canvas.Font.Style + [fsBold];
          if LowerCase(estilo) = 'cursiva'    then Canvas.Font.Style := Canvas.Font.Style + [fsItalic];
          if LowerCase(estilo) = 'subrrayado' then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
          if LowerCase(estilo) = 'tachado'    then Canvas.Font.Style := Canvas.Font.Style + [fsStrikeOut];

          {Fijamos el color}
          Canvas.Font.Color := color1[indiceColor(color)];

          Canvas.Font.Name := tipofuente;
          Canvas.Font.Size := tamanio;
        end;
    end;
end;

function TTListado.indiceColor(xcolor: string): integer;
// Objetivo...: buscar el id del color asociado
var
  i: integer;
begin
  Result := 1;
  For i := 1 to colores do
    if Trim(lowercase(xcolor)) = Trim(lowercase(color2[i])) then Begin
      Result := i;
      Break;
    end;
end;

function TTListado.IndiceColores(xcolor: TColor): integer;
// Objetivo...: buscar el id del color asociado
var
  i: integer;
begin
  Result := 1;
  For i := 1 to colores do
    if xcolor = color1[i] then Begin
      Result := i;
      Break;
    end;
end;

function TTListado.NombreDelColor(xcolor: Integer): TColor;
Begin
  if (xcolor < 1) or (xcolor > 16) then Result := color1[1] else Result := color1[xcolor];
end;

procedure TTListado.NuevaPagina;
{Objetivo...: Preparar una Nueva Página para la Impresora}
begin
  Printer.NewPage;
  linea := 0;
end;

procedure TTListado.FijarSaltoManual;
// Objetivo...: Fijar que el salto de Página se realize en forma Manual
begin
  tipo_salto := 2;
end;

procedure TTListado.CantidadDeCopias(xcantcopias: integer);
// Objetivo...: Determinar la cantidad de copias a imprimir
begin
  Printer.Copies := xcantcopias;
end;

procedure TTListado.EstablecerTiempo(xtiempo: Integer);
// Objetivo...: Intervalo para el cierre del form
Begin
  tiempo := xtiempo;
end;

{===============================================================================}

function reporte: TTListado;
begin
  if xreporte = nil then
    xreporte := TTListado.Create;
  Result := xreporte;
end;

{===============================================================================}

initialization

finalization
  xreporte.Free;

end.
