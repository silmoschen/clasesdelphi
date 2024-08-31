unit CSolAnalisisFabrissin;

interface

uses CSolAnalisis, CPaciente, CPlantanalisis, DBTables, CIDBFM, CBDT, CUtiles, SysUtils, CListar, CTitulosFabrissin, CNomecla, CObrasSocialesCCBInt,
     CEntidadesQueDerivanFabrissin, Classes, CDerivacionesAnalisis, CProfesionalFabrissin, Contnrs, IRaveReport, Forms, Graphics, CNBU;

type

TTSolicitudAnalisisFabrissin = class(TTSolicitudAnalisis)
  existePlantilla, ListarHora: Boolean;
  Idquederiv, Imagen, L1, L2, L3, L4: String;
  plantillasIMP, fotologo: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   GuardarDatosComplementariosSolicitud(xprotocolo, xabona: string; xtotal, xentrega: real; xfechaent, xretirafecha, xretirahora: string);

  procedure   getDatos(xnrosolicitud: string); overload;

  function    BuscarPlantilla(xidplantilla: string): boolean;
  procedure   GuardarPlantilla(xidplantilla, xplantilla, xfuente: string);
  procedure   getDatosPlantilla(xidplantilla: string);
  procedure   BorrarPlantilla(xidplantilla: string);
  function    setPlantillas: TQuery;

  procedure   ListHojaDeTrabajo(xnrosolicitud: string; xadicional: ShortInt; salida: char);
  procedure   ListHojaDeTrabajoDetallada(xnrosolicitud: string; xadicional: ShortInt; salida: char);
  procedure   ImprimirSobre(xnombre: string; xlineas, xmargeniz: Integer; salida: char); override;
  procedure   ImprimirSobreConFormato(xnombre, xfecha: string; xlineas, xmargeniz: Integer; salida: char);
  procedure   ListarSolicitudesQueDerivaron(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);
  procedure   ListarResultadoEnLote(xlistaprotocolos: TStringList; salida: char);
  procedure   ListarCarnet(xnrosolicitud: String; xcodanalisis: TStringList);

  procedure   RegistrarFormatoHojaTrabajo(xmodelo: String);
  function    setFormatoHojaTrabajo: TStringList;

  procedure   Depurar(xfecha: string);

  procedure   RegistrarFotoLogo(xid: Integer; xarchivo, xl1, xl2, xl3, xl4: String);
  procedure   BorrarFotoLogo(xid: Integer; xarchivo: String);
  procedure   getFotoLogo(xid: Integer);

  procedure   ConsultarHistorico;
  procedure   DesconectarHistorico;

  function    setResultado(xnrosolicitud, xcodanalisis, xitems: String): String;

  function    CalcularValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real; override;

  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  procedure   TituloSol(salida: char); override;
  procedure   ListSol(xcodpac, xidprof: string; salida: char); override;
  procedure   ListDetSol(xnrosolicitud: string; detSel: Array of String; salida: char); override;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  lin: String;
  l: TStringList;
  procedure   EncabezadoDePagina(salida: char);
  procedure   ListarHojaAdicional(xnrosolicitud: String; salida: char);
  procedure   ListHDeTrabajoSimple(xnrosolicitud: string; salida: char);
  procedure   InstanciarTablas;
end;

function solanalisis: TTSolicitudAnalisisFabrissin;

implementation

var
  xsolanalisis: TTSolicitudAnalisisFabrissin = nil;

constructor TTSolicitudAnalisisFabrissin.Create;
begin
  inherited Create;
  fuenteObservac := 'Arial, cursiva, 8';
  InstanciarTablas;
  lin := utiles.sLlenarIzquierda(lin, 80, '-');
end;

destructor TTSolicitudAnalisisFabrissin.Destroy;
begin
  inherited Destroy;
end;

procedure TTSolicitudAnalisisFabrissin.GuardarDatosComplementariosSolicitud(xprotocolo, xabona: string; xtotal, xentrega: real; xfechaent, xretirafecha, xretirahora: string);
// Objetivo...: Guardar datos complementarios de la solicitud
begin
  if inherited Buscar(xprotocolo) then Begin
    solicitud.Edit;
    solicitud.FieldByName('abona').AsString       := xabona;
    solicitud.FieldByName('total').AsFloat        := xtotal;
    solicitud.FieldByName('entrega').AsFloat      := xentrega;
    solicitud.FieldByName('fechaent').AsString    := utiles.sExprFecha2000(xfechaent);
    solicitud.FieldByName('retirafecha').AsString := utiles.sExprFecha2000(xretirafecha);
    solicitud.FieldByName('retirahora').AsString  := xretirahora;
    try
      solicitud.Post
    except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);
  end;
end;

procedure TTSolicitudAnalisisFabrissin.getDatos(xnrosolicitud: string);
// Objetivo...: Cargar los datos de la solicitud
begin
  inherited getDatos(xnrosolicitud);
  if exisolicitud then Begin
    abona        := solicitud.FieldByName('abona').AsString;
    retiraFecha  := utiles.sFormatoFecha(solicitud.FieldByName('retirafecha').AsString);
    retiraHora   := solicitud.FieldByName('retirahora').AsString;
    total        := solicitud.FieldByName('total').AsFloat;
    entrega      := solicitud.FieldByName('entrega').AsFloat;
    if Length(Trim(solicitud.FieldByName('entidadderiv').AsString)) > 0 then Idquederiv := solicitud.FieldByName('entidadderiv').AsString else Idquederiv := '000';
    if Length(Trim(solicitud.FieldByName('fechaent').AsString)) = 8 then fechaEntrega := utiles.sFormatoFecha(solicitud.FieldByName('fechaent').AsString) else fechaEntrega := utiles.sFormatoFecha(utiles.sExprFecha2000(DateToStr(Now())));
  end else Begin
    abona := ''; fechaEntrega := utiles.sFormatoFecha(utiles.sExprFecha2000(DateToStr(Now()))); retiraFecha := ''; retiraHora := ''; total := 0; entrega := 0; Idquederiv := '000';
  end;
end;

{ Tratamiento de Plantillas }

function TTSolicitudAnalisisFabrissin.BuscarPlantilla(xidplantilla: string): boolean;
// Objetivo...: Buscar una plantilla
begin
  existePlantilla := plantillasIMP.FindKey([xidplantilla]);
  Result := existePlantilla;
end;

procedure TTSolicitudAnalisisFabrissin.GuardarPlantilla(xidplantilla, xplantilla, xfuente: string);
// Objetivo...: Guardar los datos de una plantilla
begin
  if BuscarPlantilla(xidplantilla) then plantillasIMP.Edit else plantillasIMP.Append;
  plantillasIMP.FieldByName('idplantilla').AsString := xidplantilla;
  plantillasIMP.FieldByName('plantilla').Value      := xplantilla;
  plantillasIMP.FieldByName('fuente').AsString      := xfuente;
  try
    plantillasIMP.Post
  except
    plantillasIMP.Cancel
  end;
  datosdb.refrescar(plantillasIMP);
end;

procedure TTSolicitudAnalisisFabrissin.getDatosPlantilla(xidplantilla: string);
// Objetivo...: Cargar los atributos de una plantilla dada
begin
  if BuscarPlantilla(xidplantilla) then Begin
    idplantilla := plantillasIMP.FieldByName('idplantilla').AsString;
    plantilla   := plantillasIMP.FieldByName('plantilla').Value;
    fuente      := plantillasIMP.FieldByName('fuente').AsString;
  end else Begin
    idplantilla := ''; plantilla := ''; fuente := '';
  end;
end;

procedure TTSolicitudAnalisisFabrissin.BorrarPlantilla(xidplantilla: string);
// Objetivo...: Borrar una plantilla
begin
  if BuscarPlantilla(xidplantilla) then plantillasIMP.Delete;
end;

function TTSolicitudAnalisisFabrissin.setPlantillas: TQuery;
// Objetivo...: retornar un set de plantillas creadas
begin
  Result := datosdb.tranSQL('SELECT * FROM plantillasIMP ORDER BY idplantilla');
end;

procedure TTSolicitudAnalisisFabrissin.TituloSol(salida: char);
// Objetivo...: Listar títulos de resultados de análisis
var
  i: Integer;
begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida); list.NoImprimirPieDePagina;
  end;
  if salida = 'T' then list.IniciarImpresionModoTexto;
  titulos.base_datos := dbs.baseDat_N;
  titulos.conectar;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 18');
    list.Titulo(0, 0, titulos.titulo, 1, titulos.fTitulo);
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Titulo(0, 0, titulos.subtitulo, 1, titulos.fSubtitulo);

    list.ListMemo('Actividad', titulos.fprofesion, 0, salida, titulos.tabla, 0);
    list.ListMemo('Direccion', titulos.fdirtel, 0, salida, titulos.tabla, 0);

    list.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');
  end;
  if salida = 'T' then Begin
    list.LineaTxt('', True);
    list.LineaTxt(TrimLeft(titulos.titulo), True);
    list.LineaTxt('', True);
    list.LineaTxt(TrimLeft(titulos.subtitulo), True);

    l := list.setContenidoMemo(titulos.tabla, 'actividad', 1000);
    For i := 1 to l.Count do Begin
      if Length(Trim(l.Strings[i-1])) > 0 then list.LineaTxt(TrimLeft(l.Strings[i-1]), True);
    end;
    list.LineaTxt('', True);
    l := list.setContenidoMemo(titulos.tabla, 'Direccion', 1000);
    For i := 1 to l.Count do Begin
      if Length(Trim(l.Strings[i-1])) > 0 then list.LineaTxt(TrimLeft(l.Strings[i-1]), True);
    end;
    list.LineaTxt('', True);
  end;

  titulos.desconectar;

   if (salida = 'P') or (salida = 'I') then Begin
     // Subtitulo
     list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
     List.Subtitulo(0, 0, '                   ', 1, 'Times New Roman, normal, 9');
     List.Subtitulo(0, 0, '                   Paciente', 1, 'Times New Roman, normal, 12'); List.Subtitulo(30, List.Lineactual, ':  ' + UpperCase(paciente.Nombre), 2, 'Times New Roman, normal, 12');
     List.Subtitulo(0, 0, '                   Protocolo Nº', 1, 'Times New Roman, normal, 12'); List.Subtitulo(30, List.Lineactual, ':  ' + protocolo, 2, 'Times New Roman, normal, 12');
     List.Subtitulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
     List.Subtitulo(0, 0, '                   ', 1, 'Times New Roman, normal, 24');
   end;
end;

procedure TTSolicitudAnalisisFabrissin.EncabezadoDePagina(salida: char);
// Objetivo...: Listar el inicio de la Nueva página
begin
  if (salida = 'P') or (salida = 'I') then list.IniciarNuevaPagina;
end;

procedure TTSolicitudAnalisisFabrissin.ListSol(xcodpac, xidprof: string; salida: char);
// Objetivo...: Listar datos de la solictud - Paciente y Profesional
var
  i: integer;
  h: string;
begin
  if (ListarHora) then h := '   - Hora: ' +  solicitud.FieldByName('hora').AsString else h := '';
  
  paciente.getDatos(xcodpac);
  profesional.getDatos(xidprof);
  titulos.conectar;
  if (salida = 'P') or (salida = 'I') then Begin
    if not titulos.verificarDefinicionFormatoPaciente then Begin
      if titulos.margenSup = '0' then Begin
        List.Linea(0, 0, ' ', 1, 'Arial, negrita, 24', salida, 'S');
        List.Linea(0, 0, ' ', 1, 'Arial, negrita, 20', salida, 'S');
      end else
        for i := 1 to StrToInt(Trim(titulos.margenSup)) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      List.Linea(0, 0, '                   Paciente', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, List.Lineactual, ':  ' + UpperCase(paciente.Nombre), 2, 'Times New Roman, normal, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      List.Linea(0, 0, '                   Indicación del Dr/a.', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, list.lineactual, ':  ' + profesional.Nombres, 2, 'Times New Roman, normal, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      List.Linea(0, 0, '                   Fecha', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, List.Lineactual, ':  ' + Copy(solicitud.FieldByName('fecha').AsString, 7, 2) + ' de ' + meses[StrToInt(Copy(solicitud.FieldByName('fecha').AsString, 5, 2))] + ' ' +  Copy(solicitud.FieldByName('fecha').AsString, 1, 4) + h, 2, 'Times New Roman, normal, 12', salida, 'S');
      List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
      List.Linea(0, 0, '                   Protocolo Nº', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, List.Lineactual, ':  ' + solicitud.FieldByName('protocolo').AsString, 2, 'Times New Roman, normal, 12', salida, 'S');
      if titulos.margenInf = '0' then Begin
        List.Linea(0, 0, ' ', 1, 'Arial, normal, 10', salida, 'S');
        For i := 1 to titulos.lineas do List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');   // Lineas en blanco
      end;
      List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      if titulos.margenInf = '0' then Begin
        List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
        List.Linea(0, 0, ' ', 1, 'Arial, normal, 20', salida, 'S');
      end else
        for i := 1 to StrToInt(Trim(titulos.margenInf)) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end else Begin
      list.IniciarMemoImpresiones(titulos.tpac, 'definicion', 700);
      list.RemplazarEtiquetasEnMemo('#paciente', paciente.nombre);
      list.RemplazarEtiquetasEnMemo('#medico', profesional.nombres);
      list.RemplazarEtiquetasEnMemo('#fecha', Copy(solicitud.FieldByName('fecha').AsString, 7, 2) + ' de ' + meses[StrToInt(Copy(solicitud.FieldByName('fecha').AsString, 5, 2))] + ' ' +  Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
      list.RemplazarEtiquetasEnMemo('#protocolo', solicitud.FieldByName('protocolo').AsString);
      l := list.setContenidoMemo;
      For i := 1 to l.Count do list.Linea(0, 0, l.Strings[i-1], 1, 'Courier New, Normal, 11', salida, 'S');
      list.LiberarMemoImpresiones;
    end;
  end;

  if (salida = 'T') then Begin
    if not titulos.verificarDefinicionFormatoPaciente then Begin
      if titulos.margenSup = '0' then Begin
        List.LineaTxt(' ', True);
        List.LineaTxt(' ', True);
      end;
      List.LineaTxt(lin, True);
      List.LineaTxt('   Paciente            : ' + UpperCase(paciente.Nombre), True);
      List.LineaTxt('   Indicación del Dr/a.: ' + profesional.Nombres, True);
      List.LineaTxt('', True);
      List.LineaTxt('   Fecha               : ' + Copy(solicitud.FieldByName('fecha').AsString, 7, 2) + ' de ' + meses[StrToInt(Copy(solicitud.FieldByName('fecha').AsString, 5, 2))] + ' ' +  Copy(solicitud.FieldByName('fecha').AsString, 1, 4), True);
      List.LineaTxt('', True);
      List.LineaTxt('   Protocolo Nº        : ' + solicitud.FieldByName('protocolo').AsString, True);
      if titulos.margenInf = '0' then Begin
        List.LineaTxt('', True);
        For i := 1 to titulos.lineas do List.LineaTxt('', True);   // Lineas en blanco
      end;
      List.LineaTxt(lin, True);
      List.LineaTxt('', True);
      List.LineaTxt('', True);
    end else Begin
      list.IniciarMemoImpresiones(titulos.tpac, 'definicion', 700);
      list.RemplazarEtiquetasEnMemo('#paciente', paciente.nombre);
      list.RemplazarEtiquetasEnMemo('#medico', profesional.nombres);
      list.RemplazarEtiquetasEnMemo('#fecha', Copy(solicitud.FieldByName('fecha').AsString, 7, 2) + ' de ' + meses[StrToInt(Copy(solicitud.FieldByName('fecha').AsString, 5, 2))] + ' ' +  Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
      list.RemplazarEtiquetasEnMemo('#protocolo', solicitud.FieldByName('protocolo').AsString);
      l := list.setContenidoMemo;
      For i := 1 to l.Count do list.LineaTxt(l.Strings[i-1], True);
      list.LiberarMemoImpresiones;
    end;
  end;

  titulos.desconectar;
end;

procedure TTSolicitudAnalisisFabrissin.ListDetSol(xnrosolicitud: string; detSel: Array of String; salida: char);
// Objetivo...: Listar detalle de la solicitud
var
  r, t: TObjectList;
  xcodanalisisanter, xnrosolanter, fuente: string;
  f, imp, itp, itpp: boolean;
  i, j, k, m, n, distancia: Integer;
  objeto1, objeto2, objeto3, objeto4: TTSolicitudAnalisisFabrissin;
begin
  t := TObjectList.Create;
  r := setListaResultados(xnrosolicitud);
  for i := 1 to r.Count do Begin
    objeto2 := TTSolicitudAnalisisFabrissin.Create;
    objeto1 := TTSolicitudAnalisisFabrissin(r.Items[i-1]);
    objeto2.nrosolicitud := objeto1.nrosolicitud;
    objeto2.Codanalisis  := objeto1.Codanalisis;
    objeto2.Items        := objeto1.Items;
    objeto2.Resultados   := objeto1.Resultados;
    objeto2.Valoresn     := objeto1.Valoresn;
    objeto2.nroanalisis  := objeto1.nroanalisis;
    t.Add(objeto2);
  end;
  i := 0;
  xcodanalisisanter := ''; protocolo := xnrosolicitud;
  for j := 1 to r.Count do Begin
     objeto1 := TTSolicitudAnalisisFabrissin(r.Items[j-1]);
     if verificarItemsEnLista(detSel, objeto1.Codanalisis) then Begin
      if objeto1.Codanalisis <> xcodanalisisanter then Begin

        if Length(Trim(xcodanalisisanter)) > 0 then Begin // Observaciones de análisis

          if (salida = 'P') or (salida = 'I') then Begin
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
            if Buscar(xnrosolanter, xcodanalisisanter) then list.ListMemo('observaciones', 'Arial, cursiva, 9', 0, salida, obsanalisis, 0); // Si existen observaciones
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
            if not List.EfectuoSaltoPagina then List.Linea(0, 0, '  ', 1, 'Arial, normal, 10', salida, 'S') else Begin // En la misma página
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 24', salida, 'S');
            end;
          end;

          if salida = 'T' then Begin
            if Buscar(xnrosolanter, xcodanalisisanter) then Begin
              l := list.setContenidoMemo(obsanalisis, 'observaciones', 600);
              for i := 1 to l.Count do
                list.LineaTxt(l.Strings[i-1], True);
              list.LiberarMemoImpresiones;
              List.LineaTxt('', True);
            end;
          end;

        end;

        nomeclatura.getDatos(objeto1.Codanalisis);

        if (salida = 'P') or (salida = 'I') then
          if list.RealizarSaltoPagina(list.altotit) then EncabezadoDePagina(salida);

        if (salida = 'P') or (salida = 'I') then
          List.Linea(0, 0, ' ' + UpperCase(nomeclatura.descrip), 1, 'Arial, negrita, 11', salida, 'S');

        if (salida = 'T') then Begin
          List.LineaTxt('', True);
          List.LineaTxt(' ' + utiles.StringLongitudFija(UpperCase(nomeclatura.descrip), 30), True);
        end;

        f := False; // Impresión de Items paralelos - a la descripción del análisis
        for k := 1 to t.Count do Begin
          objeto2 := TTSolicitudAnalisisFabrissin(t.Items[k-1]);
          plantanalisis.getDatos(objeto2.Codanalisis, objeto2.Items);
          if (plantanalisis.itemsParalelo = '00') and (objeto2.Codanalisis = objeto1.Codanalisis) then Begin  // Items paralelo a la descripción del análisis
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);

            if (salida = 'P') or (salida = 'I') then
              List.Linea(distancia, list.lineactual, plantanalisis.elemento + ':  ' + objeto2.Resultados, 2, 'Arial, cursiva, 10', salida, 'N');
            if (salida = 'T') then
              List.LineaTxt(plantanalisis.elemento + ':  ' + utiles.StringLongitudFija(objeto2.Resultados, 30), False);

            f := True;
          end;
        end;

        if (salida = 'P') or (salida = 'I') then
          if not f then List.Linea(80, list.Lineactual, ' ', 3, 'Arial, negrita, 11', salida, 'S');

        if (salida = 'T') then
          if not f then List.LineaTxt('', True);

        // Fin Impresión de Items paralelos
        if (salida = 'P') or (salida = 'I') then
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');

        if (salida = 'T') then
          List.LineaTxt('', True);
      end;

      plantanalisis.getDatos(objeto1.Codanalisis, objeto1.Items);
      if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
      // Impresión de Items independientes
      if (plantanalisis.imputable = 'N') and (Length(Trim(plantanalisis.itemsParalelo)) = 0)  then Begin

        if (salida = 'P') or (salida = 'I') then Begin
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
          List.Linea(0, 0, '  ' + plantanalisis.elemento, 1, 'Arial, negrita, 10', salida, 'N');
        end;

        if (salida = 'T') then Begin
          //List.LineaTxt('', True);
          List.LineaTxt(utiles.StringLongitudFija(plantanalisis.elemento, 30), False);
        end;

        // Verificamos si hay algun Items Paralelo - NO Imputable
        for m := 1 to t.Count do Begin
          objeto3 := TTSolicitudAnalisisFabrissin(t.Items[m-1]);
          if (objeto1.Codanalisis = objeto3.Codanalisis) then Begin
            plantanalisis.getDatos(objeto3.Codanalisis, objeto3.Items);
            if (objeto1.Items = plantanalisis.itemsParalelo) and (plantanalisis.imputable = 'N') then Begin
              if (salida = 'P') or (salida = 'I') then
                List.Linea(48, list.lineactual, plantanalisis.elemento, 2, 'Arial, negrita, 10', salida, 'S');
              if (salida = 'T') then
                List.LineaTxt(utiles.StringLongitudFija(plantanalisis.elemento, 30), True);
            end;
          end;
        end;

      end else Begin

        if Length(Trim(plantanalisis.itemsParalelo)) = 0 then Begin  // Si es un items independiente lo imprimimos
          if Copy(plantanalisis.elemento, 1, 4) = uppercase(Copy(plantanalisis.elemento, 1, 4)) then fuente := 'Arial, normal, 10' else fuente := 'Arial, normal, 10';
          if distancia = 0 then Begin

            if (salida = 'P') or (salida = 'I') then
              List.Linea(0, 0, '  ' + plantanalisis.elemento, 1, fuente, salida, 'N');

            if (salida = 'T') then
              List.LineaTxt(utiles.StringLongitudFija(plantanalisis.elemento, 30), False);

            if Length(Trim(objeto1.Resultados)) > 0 then Begin
              if (salida = 'P') or (salida = 'I') then Begin
                List.derecha(47, list.lineactual, '##########################', objeto1.Resultados, 2, 'Arial, normal, 10');
                List.Linea(48, list.lineactual, ' ', 3, 'Arial, normal, 10', salida, 'S');
              end;
              if (salida = 'T') then Begin
                List.LineaTxt(utiles.StringLongitudFija(objeto1.Resultados, 30), True);
              end;
            end else
              if Length(Trim(objeto1.Valoresn)) > 0 then Begin

                if (salida = 'P') or (salida = 'I') then Begin
                  List.derecha(distancia + 47, list.lineactual, '##########################', objeto1.Valoresn, 2, 'Arial, normal, 10');
                  List.Linea(distancia + 48, list.lineactual, ' ', 3, 'Arial, normal, 10', salida, 'S');
                end;
                if (salida = 'T') then Begin
                  List.LineaTxt(utiles.StringLongitudFija(objeto1.Valoresn, 30), True);
                end;

               end else
                itp := True;
          end else Begin

            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              List.Linea(distancia, list.Lineactual, plantanalisis.elemento, 2, 'Arial, normal, 10', salida, 'N');
              if Length(Trim(plantanalisis.itemsParalelo)) = 0 then List.Linea(distancia + 15, list.lineactual, objeto1.Resultados, 3, 'Arial, normal, 10', salida, 'N') else List.Linea(distancia + 47, list.lineactual, objeto1.Resultados, 3, 'Arial, normal, 10', salida, 'N');
              if Length(Trim(objeto1.Valoresn)) > 0 then Begin
                List.derecha(distancia + 47, list.lineactual, '##########################', objeto1.Valoresn, 4, 'Arial, normal, 10');
                List.Linea(distancia + 48, list.lineactual, ' ', 5, 'Arial, normal, 10', salida, 'S');
              end else
                List.Linea(distancia + 15, list.lineactual, objeto1.Resultados, 3, 'Arial, normal, 10', salida, 'S');
            end;

            if (salida = 'T') then Begin
              List.LineaTxt(utiles.StringLongitudFija(plantanalisis.elemento, 30), False);
              if Length(Trim(plantanalisis.itemsParalelo)) = 0 then List.LineaTxt(utiles.StringLongitudFija(objeto1.Resultados, 30), False) else List.LineaTxt(utiles.StringLongitudFija(objeto1.Resultados, 30), False);
              if Length(Trim(objeto1.Valoresn)) > 0 then Begin
                List.LineaTxt(utiles.StringLongitudFija(objeto1.Valoresn, 30), True);
              end else
                List.LineaTxt(utiles.StringLongitudFija(objeto1.Resultados, 30), True);
            end;

          end;
        end;

        // Impresión de Items paralelos - a los items comunes

        for n := 1 to t.Count do Begin
          objeto4 := TTSolicitudAnalisisFabrissin(t.Items[n-1]);
          plantanalisis.getDatos(objeto4.Codanalisis, objeto4.Items);
          if (plantanalisis.itemsParalelo = objeto1.Items) and (objeto4.Codanalisis = objeto1.Codanalisis) then Begin
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
            itp := False;

            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(distancia, list.lineactual, plantanalisis.elemento, 4, 'Arial, normal, 10', salida, 'N');
              if Length(Trim(objeto4.Resultados)) > 0 then Begin
                List.Derecha(distancia + 47, list.lineactual, '##########################', objeto4.Resultados, 5, 'Arial, normal, 10');
                List.Linea(distancia + 48, list.lineactual, ' ', 6, 'Arial, normal, 10', salida, 'S');
                imp := True;
              end;
              if Length(Trim(objeto4.Valoresn)) > 0 then Begin
                List.Derecha(distancia + 47, list.lineactual, '##########################', objeto4.Valoresn, 5, 'Arial, normal, 10');
                List.Linea(distancia + 48, list.lineactual, ' ', 6, 'Arial, normal, 10', salida, 'S');
                imp := True;
              end;
              if not imp then List.Linea(distancia + 48, list.lineactual, ' ', 5, 'Arial, normal, 10', salida, 'S');
            end;

            if (salida = 'T') then Begin
              List.LineaTxt(utiles.StringLongitudFija(plantanalisis.elemento, 30), False);
              if Length(Trim(objeto4.resultados)) > 0 then Begin
                List.LineaTxt(utiles.StringLongitudFija(objeto4.Resultados, 30), True);
                imp := True;
              end;
              if Length(Trim(objeto4.Valoresn)) > 0 then Begin
                List.LineaTxt(utiles.StringLongitudFija(objeto4.Valoresn, 30), True);
                imp := True;
              end;
              if not imp then List.LineaTxt('', True);
            end;

            imp := False;
          end;
        end;

        if (salida = 'P') or (salida = 'I') then
          if itp then List.Linea(48, list.lineactual, ' ', 3, 'Arial, normal, 10', salida, 'S');
        if (salida = 'T') then
          if itp then List.LineaTxt('', True);


        // Fin Impresión de Items paralelos - a los items comunes
      end;

      if list.RealizarSaltoPagina(list.altotit) then EncabezadoDePagina(salida);

      // Valores Normales cuando hay resultados
      if (salida = 'P') or (salida = 'I') then
        if (Length(Trim(objeto1.Valoresn)) > 0) and (Length(Trim(objeto1.Resultados)) > 0) then List.Linea(52, list.Lineactual, 'V.N.: ' + objeto1.Valoresn, 6, 'Arial, normal, 8', salida, 'S') else List.Linea(50, list.Lineactual, ' ', 6, 'Arial, normal, 10', salida, 'S');
      if (salida = 'T') then
        if (Length(Trim(objeto1.Valoresn)) > 0) and (Length(Trim(objeto1.Resultados)) > 0) then List.LineaTxt(utiles.stringLongitudFija('V.N.: ' + objeto1.Valoresn, 30), True); // else List.LineaTxt('6', True);

      // Observaciones de items
      if BuscarResultado(objeto1.nrosolicitud, objeto1.Codanalisis, objeto1.Items) then Begin
        if (salida = 'P') or (salida = 'I') then
          list.ListMemo('observaciones', 'Arial, cursiva, 10', 5, salida, obsresul, 0);
        if (salida = 'T') then Begin
          l := list.setContenidoMemo(obsresul, 'observaciones', 600);
          for i := 1 to l.Count do
            list.LineaTxt(l.Strings[i-1], True);
          list.LiberarMemoImpresiones;
        end;
      end;
      xcodanalisisanter := objeto1.Codanalisis;
      xnrosolanter      := objeto1.nrosolicitud;

    end;
  end;

  if (salida = 'P') or (salida = 'I') then
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  if (salida = 'T') then
    List.LineaTxt('', True);

  if verificarItemsEnLista(detSel, xcodanalisisanter) then Begin
    if (salida = 'P') or (salida = 'I') then
      if Buscar(xnrosolanter, xcodanalisisanter) then list.ListMemo('observaciones', 'Arial, cursiva, 9', 12, salida, obsanalisis, 0); // Si existen observaciones
    if (salida = 'T') then Begin
      if Buscar(xnrosolanter, xcodanalisisanter) then Begin
        l := list.setContenidoMemo(obsanalisis, 'observaciones', 600);
        for i := 1 to l.Count do
          list.LineaTxt(l.Strings[i-1], True);
        list.LiberarMemoImpresiones;
      end;
    end;
  end;

  {if not r.EOF then Begin
    if (salida = 'P') or (salida = 'I') then
      List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
    if (salida = 'T') then
      List.LineaTxt('', True);
  end;}
  //r.Close; r.Free; r := nil; t.Close; t.Free; t := nil;


  r.Free; r := Nil;
  t.Free; t := Nil;
end;

procedure TTSolicitudAnalisisFabrissin.ListHojaDeTrabajo(xnrosolicitud: string; xadicional: ShortInt; salida: char);
// Objetivo...: Listar hoja de trabajo
begin
  getDatos(xnrosolicitud);
  case xadicional of
    1: ListHDeTrabajo(xnrosolicitud, salida);
    2: ListarHojaAdicional(xnrosolicitud, salida);
    3: ListHDeTrabajoSimple(xnrosolicitud, salida);
  end;
  list.CompletarPagina;
  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissin.ListHojaDeTrabajoDetallada(xnrosolicitud: string; xadicional: ShortInt; salida: char);
// Objetivo...: Listar hoja de trabajo
var
  r: TQuery;
begin
  getDatos(xnrosolicitud);
  case xadicional of
    1: ListHDeTrabajo(xnrosolicitud, salida);
    2: ListarHojaAdicional(xnrosolicitud, salida);
    3: ListHDeTrabajoSimple(xnrosolicitud, salida);
  end;

  // Ahora listamos las Determinaciones
  if datosdb.Buscar(detsol, 'nrosolicitud', 'items', xnrosolicitud, '01') then Begin
    while not detsol.Eof do Begin
      if detsol.FieldByName('nrosolicitud').AsString <> xnrosolicitud then Break;

      if plantanalisis.BuscarItemsSol(detsol.FieldByName('codanalisis').AsString, '01') then Begin

        nomeclatura.getDatos(detsol.FieldByName('codanalisis').AsString);
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Código: ' + nomeclatura.codigo + '  ' + nomeclatura.descrip, 1, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

        r := plantanalisis.setItemsSol(detsol.FieldByName('codanalisis').AsString);
        r.Open;
        while not r.Eof do Begin
          list.Linea(0, 0, r.FieldByName('columna1').AsString, 1, 'Arial, normal, 9', salida, 'N');
          list.Linea(50, list.Lineactual, r.FieldByName('columna2').AsString, 2, 'Arial, normal, 9', salida, 'S');
          r.Next;
        end;
        r.Close; r.Free;
      end;

      detsol.Next;
    end;
  end;

  list.CompletarPagina;
  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissin.ImprimirSobre(xnombre: string; xlineas, xmargeniz: Integer; salida: char);
// Objetivo...: generar etiqueta de impresión de sobres
var
  i: integer;
begin
  list.ImprimirHorizontal;
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 12');
  if xlineas > 0 then
    For i := 1 to xlineas do List.Linea(0, 0, ' ', 1, 'Arial, negrita, 12', salida, 'S');

  titulos.base_datos := dbs.baseDat_N;
  titulos.conectar;
  List.Linea(0, 0, utiles.espacios(xmargeniz), 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, utiles.espacios(xmargeniz), 1, 'Arial, negrita, 17', salida, 'S'); List.Linea(5, list.lineactual, TrimLeft(titulos.titulo), 2, 'Arial, negrita, 17', salida, 'S');
  List.Linea(0, 0, utiles.espacios(xmargeniz), 1, 'Arial, negrita, 10', salida, 'S'); list.ListMemoRecortandoEspaciosHorizontales_Verticales('Subtitulo', 'Arial, cursiva, 9', 5, salida, titulos.tabla, 0);
  List.Linea(0, 0, utiles.espacios(xmargeniz), 1, 'Arial, negrita, 17', salida, 'S'); list.ListMemoRecortandoEspaciosHorizontales_Verticales('Actividad', 'Arial, cursiva, 8', 5, salida, titulos.tabla, 0);
  List.Linea(0, 0, utiles.espacios(xmargeniz), 1, 'Arial, negrita, 14', salida, 'S');
  titulos.desconectar;
  if Length(Trim(xnombre)) > 0 then List.Linea(0, 0, utiles.espacios(xmargeniz) + utiles.espacios(10) + 'Paciente:  ' + UpperCase(xnombre), 1, 'Times New Roman, normal, 11', salida, 'S');
  List.Linea(0, 0, utiles.espacios(xmargeniz), 1, 'Arial, normal, 5', salida, 'S');
  list.FinList;
  list.ImprimirVetical;
end;

procedure TTSolicitudAnalisisFabrissin.ImprimirSobreConFormato(xnombre, xfecha: string; xlineas, xmargeniz: Integer; salida: char);
// Objetivo...: Imprimir Sobre con Formato
Begin
  if FileExists(dbs.DirSistema + '\formatosobre.rtf') then Begin
    list.ImprimirHorizontal;
    list.NoImprimirPieDePagina;
    list.largoImpresionMemo := 5000;
    list.IniciarRichEdit(dbs.DirSistema + '\formatosobre.rtf', 0, salida);
    list.RemplazarEtiquetasEnRichEdit('#paciente', xnombre);
    list.RemplazarEtiquetasEnRichEdit('#fecha', xfecha);
    list.ListarRichEdit('---', 0, salida);
    list.FinList;
    list.largoImpresionMemo := 0;
  end else
    utiles.msgError('No hay Formato de Impresión Definido ...!');
End;

procedure TTSolicitudAnalisisfabrissin.ListarSolicitudesQueDerivaron(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);
// Objetivo...: Listar Ordenes Registradas
var
  r: TQuery; i: Integer;
  idanter, Fuente: String;
  estado: Boolean;
begin
  //list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Entidades que Derivaron Protocolos en el Lapso: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  List.Titulo(0, 0, 'Nº Prot.', 1, 'Arial, cursiva, 8');
  List.Titulo(15, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'Entidad que Derivó', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  r := datosdb.tranSQL(dir, 'SELECT protocolo, codpac, codos, fecha, entidadderiv FROM solicitud WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by entidadderiv, fecha, protocolo');
  r.Open; i := 0;
  estado := detsol.Active;
  if not detsol.Active then detsol.Open;
  entidadderivadora.conectar;
  while not r.Eof do Begin
    if r.FieldByName('fecha').AsString <> idanter then Begin
      if Length(Trim(idanter)) > 0 then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Fecha: ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      idanter := r.FieldByName('fecha').AsString;
    end;
    paciente.getDatos(r.FieldByName('codpac').AsString);
    entidadderivadora.getDatos(r.FieldByName('entidadderiv').AsString);

    if not xresumen then Fuente := 'Arial, negrita, 8' else Fuente := 'Arial, normal, 8';
    list.Linea(0, 0, r.FieldByName('protocolo').AsString, 1, Fuente, salida, 'N');
    list.Linea(15, list.Lineactual, paciente.Nombre, 2, Fuente, salida, 'N');
    list.Linea(60, list.Lineactual, entidadderivadora.Descrip, 3, Fuente, salida, 'S');
    Inc(i);

    if not xresumen then Begin
      datosdb.Filtrar(detsol, 'nrosolicitud = ' + r.FieldByName('protocolo').AsString);
      while not detsol.Eof do Begin
        nomeclatura.getDatos(detsol.FieldByName('codanalisis').AsString);
        list.Linea(0, 0, '          ' + detsol.FieldByName('codanalisis').AsString + '   ' + nomeclatura.descrip, 1, 'Arial, normal, 8', salida, 'S');
        detsol.Next;
      end;
      datosdb.QuitarFiltro(detsol);
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;

    r.Next;
  end;
  r.Close; r.Free;
  entidadderivadora.desconectar;
  detsol.Active := estado;

  if i > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Protocolos Registrados:    ' + IntToStr(i), 1, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No se Registraron Protocolos', 1, 'Arial, normal, 8', salida, 'S');

  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissin.ListarHojaAdicional(xnrosolicitud: String; salida: char);
// Objetivo...: instanciar tablas de persistencia
var
  l: TStringList;
  r: TQuery;
begin
  getDatos(xnrosolicitud);
  paciente.getDatos(codpac);
  list.Linea(0, 0, '', 1, 'Arial, normal, 12', salida, 'S');
  list.IniciarMemoImpresiones(plantillasImp, 'plantilla', 700);
  list.RemplazarTodasLasEtiquetasEnMemo('#protocolo', nrosolicitud);
  list.RemplazarTodasLasEtiquetasEnMemo('#paciente', Copy(paciente.nombre, 1, 18));

  l := TStringList.Create;
  r := setAnalisis(xnrosolicitud);
  r.Open; r.First;
  while not r.EOF do Begin
    if not list.BuscarContenidoMemo(r.FieldByName('codanalisis').AsString) then Begin
      nomeclatura.getDatos(r.FieldByName('codanalisis').AsString);
      list.RemplazarEtiquetasEnMemo('#det', r.FieldByName('codanalisis').AsString + ' ' + Copy(nomeclatura.descrip, 1, 30));
    end;
    r.Next;
  end;
  r.Close; r.Free;

  list.RemplazarTodasLasEtiquetasEnMemo('#det', '');

  list.ListMemo('', 'Courier New, normal, 8', 0, salida, Nil, 700);
end;

procedure TTSolicitudAnalisisFabrissin.ListHDeTrabajoSimple(xnrosolicitud: string; salida: char);
// Objetivo...: Listar Observaciones de Solicitud
const
  c: string = ' ';
var
  r: TQuery; ls, x, s, edadpac: string; lineas, i, j: integer;
begin
  getDatos(xnrosolicitud);  // Cargamos la solicitud pedida

  list.Setear(salida);
  list.NoImprimirPieDePagina;

  List.Linea(0, 0, 'Hoja de Trabajo ', 1, 'Arial, negrita, 14', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');

  // 1º Línea
  List.Linea(0, 0, 'Nombre ', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + paciente.nombre, 2, 'Arial, normal, 9', salida, 'S');
  // 2º Línea
  if Copy(paciente.fenac, 7, 2) > '05' then s := '19' else s := '20';
  x := Copy(paciente.Fenac, 1, 6) + s + Copy(paciente.Fenac, 7, 2);
  if Length(Trim(paciente.fenac)) > 0 then edadpac := IntToStr(utiles.Edad(x)) else edadpac := '';
  List.Linea(0, 0, 'Edad ', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + edadpac, 2, 'Arial, normal, 9', salida, 'S');
  // 3º Línea
  List.Linea(0, 0, 'Nº Solicitud', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + solicitud.FieldByName('nrosolicitud').AsString, 2, 'Arial, normal, 10', salida, 'S');
  // 4º Línea
  List.Linea(0, 0, 'Fecha ', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + fecha, 2, 'Arial, normal, 9', salida, 'S');
  // 5º Línea
  List.Linea(0, 0, 'Profesional', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + profesional.nombres, 2, 'Arial, normal, 9', salida, 'S');
  // 6º Línea
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 4', salida, 'S');
  // 7º Línea
  List.Linea(0, 0, 'Abona', 1, 'Arial, cursiva, 8', salida, 'N'); List.Linea(6, list.Lineactual, ':', 2, 'Arial, cursiva, 8', salida, 'N'); List.importe(15, list.Lineactual, '', total, 3, 'Arial, cursiva, 8');
  List.Linea(16, list.Lineactual, 'Entrega', 4, 'Arial, normal, 8', salida, 'N'); List.Linea(22, list.Lineactual, ':', 5, 'Arial, normal, 8', salida, 'N'); List.importe(31, list.Lineactual, '', entrega, 6, 'Arial, normal, 8');
  List.Linea(34, list.Lineactual, 'Saldo', 7, 'Arial, normal, 8', salida, 'N'); List.Linea(39, list.Lineactual, ':', 8, 'Arial, normal, 8', salida, 'N'); List.importe(49, list.Lineactual, '', total - entrega, 9, 'Arial, normal, 8');

  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Prometido para el:  ' + retiraFecha + '  -  ' + retiraHora + ' Hs.', 1, 'Arial, normal, 9', salida, 'S');
  // 8º Línea
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Solicitud:', 1, 'Arial, cursiva, 9', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');

  // Obtenemos la lista de análisis
  r := setAnalisis(xnrosolicitud);
  r.Open; r.First;
  while not r.EOF do Begin
    nomeclatura.getDatos(r.FieldByName('codanalisis').AsString);
    obsocial.getDatos(r.FieldByName('codos').AsString);
    List.Linea(0, 0, '   ' + r.FieldByName('codanalisis').AsString + ' ' + Copy(nomeclatura.descrip, 1, 36), 1, 'Arial, normal, 9', salida, 'S');
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 10', salida, 'S');
    r.Next;
  end;
  r.Close; r.Free;

  list.ListMemo('observaciones', 'Arial, cursiva, 8', 0, salida, solicitud, 0);
end;

procedure TTSolicitudAnalisisFabrissin.InstanciarTablas;
// Objetivo...: instanciar tablas de persistencia
begin
  if dbs.BaseClientServ = 'N' then Begin
    solicitud      := datosdb.openDB('solicitud', 'nrosolicitud');
    detsol         := datosdb.openDB('detsol', 'nrosolicitud;items');
    resultado      := datosdb.openDB('resultado', 'nrosolicitud;codanalisis;items');
    obsresul       := datosdb.openDB('refanalisis', 'nrosolicitud;codanalisis;items');
    obsanalisis    := datosdb.openDB('obsanalisis', 'nrosolicitud;codanalisis');
    movpagos       := datosdb.openDB('movpagos', '');
    plantillasIMP  := datosdb.openDB('plantillasimp', '');
    fotologo       := datosdb.openDB('fotologo', '');
  end;
  if dbs.BaseClientServ = 'S' then Begin
    solicitud      := datosdb.openDB('solicitud', 'nrosolicitud', '', dbs.baseDat_N);
    detsol         := datosdb.openDB('detsol', 'nrosolicitud;items', '', dbs.baseDat_N);
    resultado      := datosdb.openDB('resultado', 'nrosolicitud;codanalisis;items', '', dbs.baseDat_N);
    obsresul       := datosdb.openDB('refanalisis', 'nrosolicitud;codanalisis;items',  '', dbs.baseDat_N);
    obsanalisis    := datosdb.openDB('obsanalisis', 'nrosolicitud;codanalisis',  '', dbs.baseDat_N);
    movpagos       := datosdb.openDB('movpagos', '',  '', dbs.baseDat_N);
    plantillasIMP  := datosdb.openDB('plantillasimp', '',  '', dbs.baseDat_N);
    if datosdb.verificarSiExisteTabla('fotologo', dbs.TDB1) then fotologo := datosdb.openDB('fotologo', '',  '', dbs.baseDat_N);
  end;
end;

procedure TTSolicitudAnalisisFabrissin.ListarResultadoEnLote(xlistaprotocolos: TStringList; salida: char);
// Objetivo...: Listar Resultados en Lote
var
  saltopag, listar, tit, datosOK: boolean;
  i: Integer;
  ldet: array[1..1] of String;
begin
  TituloSol(salida);

  saltopag := False; tit := False; datosOK := False;
  For i := 1 to xlistaprotocolos.Count do Begin

    getDatos(xlistaprotocolos.Strings[i-1]);
    listar := False;

    if not tit then ListSol(solicitud.FieldByName('codpac').AsString, solicitud.FieldByName('codprof').AsString, salida);
    tit := True;
    if saltopag then Begin
      list.CompletarPagina;
      list.PrintLn(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
      list.IniciarNuevaPagina;
      ListSol(solicitud.FieldByName('codpac').AsString, solicitud.FieldByName('codprof').AsString, salida);
    end;
    datosOK := True;
    ListDetSol(solicitud.FieldByName('nrosolicitud').AsString, ldet, salida);
    saltopag := True;
  end;

  if datosOK then list.FinList else utiles.msgError('No existen datos para listar ...!');
end;


procedure TTSolicitudAnalisisFabrissin.RegistrarFormatoHojaTrabajo(xmodelo: String);
// Objetivo...: definir formato hoja de trabajo
begin
  GuardarPlantilla('---hoja trab sec', xmodelo, '');
end;

function TTSolicitudAnalisisFabrissin.setFormatoHojaTrabajo: TStringList;
// Objetivo...: recuperar formato hoja de trabajo
begin
  if BuscarPlantilla('---hoja trab sec') then Result := list.setContenidoMemo(plantillasImp, 'plantilla', 700) else Result := Nil;
end;

procedure TTSolicitudAnalisisFabrissin.Depurar(xfecha: string);
// Objetivo...: Mover Instancias al registro histórico
var
  lista: TStringList;
  cantreg, i: Integer;
  histdetsol, histresultado, histrefanalisis, histobsanalisis, histsolicitud: TTable;
  nsol, fechadep: String;
begin
  if dbs.BaseClientServ = 'N' then drvhistorico := dbs.DirSistema + '\Historico' else Begin
    drvhistorico := 'Laboratoriohistorico';
    dbs.NuevaBaseDeDatos2(drvhistorico, 'sysdba', 'masterkey');
  end;

  histsolicitud   := datosdb.openDB('solicitud', 'fechadep;nrosolicitud', '', drvhistorico);
  histdetsol      := datosdb.openDB('detsol', 'fechadep;nrosolicitud;items', '', drvhistorico);
  histresultado   := datosdb.openDB('resultado', 'fechadep;nrosolicitud;codanalisis;items', '', drvhistorico);
  histrefanalisis := datosdb.openDB('refanalisis', 'fechadep;nrosolicitud;codanalisis;items', '', drvhistorico);
  histobsanalisis := datosdb.openDB('obsanalisis', 'fechadep;nrosolicitud;codanalisis', '', drvhistorico);
  histsolicitud.Open; histdetsol.Open; histresultado.Open; histrefanalisis.Open; histobsanalisis.Open;

  //cclab.conectar;

  lista    := TStringList.Create;
  fechadep := utiles.setFechaActual;

  conectar;
  datosdb.Filtrar(solicitud, 'fecha <= ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  cantreg := solicitud.RecordCount;
  solicitud.First; i := 0;
  while not solicitud.EOF do Begin
    if solicitud.FieldByName('fecha').AsString <=  utiles.sExprFecha2000(xfecha) then Begin
        Inc(i);
        utiles.MsgProcesandoDatos('Procesando Prot. Nº : ' + solicitud.FieldByName('nrosolicitud').AsString + '  -  ' + IntToStr(i) + ' de ' + IntToStr(cantreg) + '  a Depurar.');

        // Transferencias al historico
        datosdb.Filtrar(detsol, 'nrosolicitud = ' + '''' + solicitud.FieldByName('nrosolicitud').AsString + '''');
        detsol.First;
        while not detsol.Eof do Begin
          lista.Add(detsol.FieldByName('nrosolicitud').AsString);
          if datosdb.Buscar(histdetsol, 'Fechadep', 'Nrosolicitud', 'Items', fechadep, detsol.FieldByName('nrosolicitud').AsString, detsol.FieldByName('items').AsString) then histdetsol.Edit else histdetsol.Append;
          histdetsol.FieldByName('fechadep').AsString     := fechadep;
          histdetsol.FieldByName('nrosolicitud').AsString := detsol.FieldByName('nrosolicitud').AsString;
          histdetsol.FieldByName('items').AsString        := detsol.FieldByName('items').AsString;
          histdetsol.FieldByName('codanalisis').AsString  := detsol.FieldByName('codanalisis').AsString;
          histdetsol.FieldByName('codos').AsString        := detsol.FieldByName('codos').AsString;
          histdetsol.FieldByName('entorden').AsString     := detsol.FieldByName('entorden').AsString;
          histdetsol.FieldByName('identidad').AsString    := detsol.FieldByName('identidad').AsString;
          histdetsol.FieldByName('osub').AsString         := detsol.FieldByName('osub').AsString;
          histdetsol.FieldByName('osug').AsString         := detsol.FieldByName('osug').AsString;
          histdetsol.FieldByName('noub').AsString         := detsol.FieldByName('noub').AsString;
          histdetsol.FieldByName('noug').AsString         := detsol.FieldByName('noug').AsString;
          histdetsol.FieldByName('cfub').AsString         := detsol.FieldByName('cfub').AsString;
          histdetsol.FieldByName('cfug').AsString         := detsol.FieldByName('cfug').AsString;
          try
            histdetsol.Post
           except
            histdetsol.Cancel
          end;
          datosdb.refrescar(histdetsol);
          detsol.Next;
        end;
        datosdb.QuitarFiltro(detsol);

        // Transferencias al historico
        datosdb.Filtrar(resultado, 'nrosolicitud = ' + '''' + solicitud.FieldByName('nrosolicitud').AsString + '''');
        resultado.First;
        while not resultado.Eof do Begin
          if datosdb.Buscar(histresultado, 'fechadep', 'nrosolicitud', 'codanalisis', 'items', fechadep, resultado.FieldByName('nrosolicitud').AsString, resultado.FieldByName('codanalisis').AsString, resultado.FieldByName('items').AsString) then histresultado.Edit else histresultado.Append;
          histresultado.FieldByName('fechadep').AsString     := fechadep;
          histresultado.FieldByName('nrosolicitud').AsString := resultado.FieldByName('nrosolicitud').AsString;
          histresultado.FieldByName('codanalisis').AsString  := resultado.FieldByName('codanalisis').AsString;
          histresultado.FieldByName('items').AsString        := resultado.FieldByName('items').AsString;
          histresultado.FieldByName('resultado').AsString    := resultado.FieldByName('resultado').AsString;
          histresultado.FieldByName('valoresn').AsString     := resultado.FieldByName('valoresn').AsString;
          histresultado.FieldByName('nroanalisis').AsString  := resultado.FieldByName('nroanalisis').AsString;
          try
            histresultado.Post
           except
            histresultado.Cancel
          end;
          datosdb.refrescar(histresultado);
          resultado.Next;
        end;

        datosdb.QuitarFiltro(resultado);

        // Transferencias al historico
        datosdb.Filtrar(obsresul, 'nrosolicitud = ' + '''' + solicitud.FieldByName('nrosolicitud').AsString + '''');
        obsresul.First;
        while not obsresul.Eof do Begin
          if datosdb.Buscar(histrefanalisis, 'fechadep', 'nrosolicitud', 'codanalisis', 'items', fechadep, obsresul.FieldByName('nrosolicitud').AsString, obsresul.FieldByName('codanalisis').AsString, obsresul.FieldByName('items').AsString) then histrefanalisis.Edit else histrefanalisis.Append;
          histrefanalisis.FieldByName('fechadep').AsString      := fechadep;
          histrefanalisis.FieldByName('nrosolicitud').AsString  := obsresul.FieldByName('nrosolicitud').AsString;
          histrefanalisis.FieldByName('codanalisis').AsString   := obsresul.FieldByName('codanalisis').AsString;
          histrefanalisis.FieldByName('items').AsString         := obsresul.FieldByName('items').AsString;
          histrefanalisis.FieldByName('observaciones').AsString := obsresul.FieldByName('observaciones').AsString;
          try
            histrefanalisis.Post
           except
            histrefanalisis.Cancel
          end;
          datosdb.refrescar(histrefanalisis);
          obsresul.Next;
        end;
        datosdb.QuitarFiltro(obsresul);

        // Transferencias al historico
        datosdb.Filtrar(obsanalisis,  'nrosolicitud = ' + '''' + solicitud.FieldByName('nrosolicitud').AsString + '''');
        obsanalisis.First;
        while not obsanalisis.Eof do Begin
          if datosdb.Buscar(histobsanalisis, 'fechadep', 'nrosolicitud', 'codanalisis', fechadep, obsanalisis.FieldByName('nrosolicitud').AsString, obsanalisis.FieldByName('codanalisis').AsString) then histobsanalisis.Edit else histobsanalisis.Append;
          histobsanalisis.FieldByName('fechadep').AsString      := fechadep;
          histobsanalisis.FieldByName('nrosolicitud').AsString  := obsanalisis.FieldByName('nrosolicitud').AsString;
          histobsanalisis.FieldByName('codanalisis').AsString   := obsanalisis.FieldByName('codanalisis').AsString;
          histobsanalisis.FieldByName('observaciones').AsString := obsanalisis.FieldByName('observaciones').AsString;
          try
            histobsanalisis.Post
           except
            histobsanalisis.Cancel
          end;
          datosdb.refrescar(histobsanalisis);
          obsanalisis.Next;
        end;
        datosdb.QuitarFiltro(obsanalisis);

        // Transferencias al historico
        if datosdb.Buscar(histsolicitud, 'fechadep', 'nrosolicitud', fechadep, solicitud.FieldByName('nrosolicitud').AsString) then histsolicitud.Edit else histsolicitud.Append;
        histsolicitud.FieldByName('fechadep').AsString      := fechadep;
        histsolicitud.FieldByName('nrosolicitud').AsString  := solicitud.FieldByName('nrosolicitud').AsString;
        histsolicitud.FieldByName('protocolo').AsString     := solicitud.FieldByName('protocolo').AsString;
        histsolicitud.FieldByName('fecha').AsString         := solicitud.FieldByName('fecha').AsString;
        histsolicitud.FieldByName('hora').AsString          := solicitud.FieldByName('hora').AsString;
        histsolicitud.FieldByName('codpac').AsString        := solicitud.FieldByName('codpac').AsString;
        histsolicitud.FieldByName('codprof').AsString       := solicitud.FieldByName('codprof').AsString;
        histsolicitud.FieldByName('codos').AsString         := solicitud.FieldByName('codos').AsString;
        histsolicitud.FieldByName('observaciones').AsString := solicitud.FieldByName('observaciones').AsString;
        histsolicitud.FieldByName('entorden').AsString      := solicitud.FieldByName('entorden').AsString;
        histsolicitud.FieldByName('abona').AsString         := solicitud.FieldByName('abona').AsString;
        histsolicitud.FieldByName('total').AsString         := solicitud.FieldByName('total').AsString;
        histsolicitud.FieldByName('entrega').AsString       := solicitud.FieldByName('entrega').AsString;
        histsolicitud.FieldByName('fechaent').AsString      := solicitud.FieldByName('fechaent').AsString;
        histsolicitud.FieldByName('retirafecha').AsString   := solicitud.FieldByName('retirafecha').AsString;
        histsolicitud.FieldByName('retirahora').AsString    := solicitud.FieldByName('retirahora').AsString;
        histsolicitud.FieldByName('entidadderiv').AsString  := solicitud.FieldByName('entidadderiv').AsString;
        try
          histsolicitud.Post
         except
          histsolicitud.Cancel
        end;
        datosdb.refrescar(histsolicitud);

      // Eliminamos
      nsol := solicitud.FieldByName('nrosolicitud').AsString;
      datosdb.tranSQL('DELETE FROM ' + detsol.TableName + ' WHERE nrosolicitud = ' + '"' + nsol + '"');
      datosdb.tranSQL('DELETE FROM ' + resultado.TableName + ' WHERE nrosolicitud = ' + '"' + nsol + '"');
      datosdb.tranSQL('DELETE FROM ' + obsresul.TableName + ' WHERE nrosolicitud = ' + '"' + nsol + '"');
      datosdb.tranSQL('DELETE FROM ' + obsanalisis.TableName + ' WHERE nrosolicitud = ' + '"' + nsol + '"');
      datosdb.tranSQL('DELETE FROM ' + solicitud.TableName + ' WHERE nrosolicitud = ' + '"' + nsol + '"');
      // Depuramos los pagos
      //cclab.BorrarComprobante(solicitud.FieldByName('protocolo').AsString, solicitud.FieldByName('codpac').AsString, 'FAC', 'A', '0000', utiles.sLlenarIzquierda(solicitud.FieldByName('protocolo').AsString, 8, '0'));

      lista.Add(solicitud.FieldByName('nrosolicitud').AsString);
      solicitud.Next;
    end;
  end;

  //cclab.desconectar;

  datosdb.closeDB(histdetsol); datosdb.closeDB(histresultado); datosdb.closeDB(histrefanalisis); datosdb.closeDB(histobsanalisis); datosdb.closeDB(histsolicitud);
  desconectar;

  utiles.MsgFinalizarProcesandoDatos;
  dbs.desconectarDB2;
end;

procedure TTSolicitudAnalisisFabrissin.RegistrarFotoLogo(xid: Integer; xarchivo, xl1, xl2, xl3, xl4: String);
// Objetivo...: Registrar Foto
begin
  if fotologo = nil then fotologo := datosdb.openDB('fotologo', '',  '', dbs.baseDat_N);
  fotologo.open;
  if fotologo.FindKey([xid]) then fotologo.Edit else fotologo.Append;
  fotologo.FieldByName('id').AsInteger  := xid;
  fotologo.FieldByName('foto').AsString := xarchivo;
  fotologo.FieldByName('t1').AsString   := xl1;
  fotologo.FieldByName('t2').AsString   := xl2;
  fotologo.FieldByName('t3').AsString   := xl3;
  fotologo.FieldByName('t4').AsString   := xl4;

  try
    fotologo.Post
   except
    fotologo.Cancel
  end;
  datosdb.closedb(fotologo);
end;

procedure TTSolicitudAnalisisFabrissin.BorrarFotoLogo(xid: Integer; xarchivo: String);
// Objetivo...: Borrar Foto
begin
  if fotologo = nil then fotologo := datosdb.openDB('fotologo', '',  '', dbs.baseDat_N);
  fotologo.open;
  if fotologo.FindKey([xid]) then Begin
    fotologo.Delete;
    datosdb.refrescar(fotologo);
  end;
  datosdb.closedb(fotologo);
end;

procedure TTSolicitudAnalisisFabrissin.getFotoLogo(xid: Integer);
// Objetivo...: Devolver Foto
begin
  if fotologo = nil then fotologo := datosdb.openDB('fotologo', '',  '', dbs.baseDat_N);
  fotologo.open;
  if fotologo.FindKey([xid]) then Begin
    imagen := fotologo.FieldByName('foto').AsString;
    l1     := fotologo.FieldByName('t1').AsString;
    l2     := fotologo.FieldByName('t2').AsString;
    l3     := fotologo.FieldByName('t3').AsString;
    l4     := fotologo.FieldByName('t4').AsString;
  End else Begin
    imagen := ''; l1 := ''; l2 := ''; l3 := ''; l4 := '';
  End;
  datosdb.closedb(fotologo);
end;

procedure TTSolicitudAnalisisFabrissin.ConsultarHistorico;
// Objetivo...: cerrar tablas de persistencia
begin
  if not ModoHistorico then Begin
    if dbs.BaseClientServ = 'N' then drvhistorico := dbs.DirSistema + '\Historico' else Begin
      drvhistorico := 'Laboratoriohistorico';
      dbs.NuevaBaseDeDatos2(drvhistorico, 'sysdba', 'masterkey');
    end;
    datosdb.closeDB(solicitud); datosdb.closeDB(detsol); datosdb.closeDB(resultado); datosdb.closeDB(obsresul); datosdb.closeDB(obsanalisis);
    solicitud     := datosdb.openDB('solicitud', 'nrosolicitud', '', drvhistorico);
    detsol        := datosdb.openDB('detsol', 'nrosolicitud;items', '', drvhistorico);
    resultado     := datosdb.openDB('resultado', 'nrosolicitud;codanalisis;items', '', drvhistorico);
    obsresul      := datosdb.openDB('refanalisis', 'nrosolicitud;codanalisis;items', '', drvhistorico);
    obsanalisis   := datosdb.openDB('obsanalisis', 'nrosolicitud;codanalisis', '', drvhistorico);
    solicitud.Open; detsol.Open; resultado.Open; obsresul.Open; obsanalisis.Open;
    ModoHistorico := True;
    dir           := drvhistorico;
  end;
  ModoHistorico := True;
end;

procedure TTSolicitudAnalisisFabrissin.DesconectarHistorico;
// Objetivo...: Consultar Datos Normales
Begin
  datosdb.closeDB(solicitud); datosdb.closeDB(detsol); datosdb.closeDB(resultado); datosdb.closeDB(obsresul); datosdb.closeDB(obsanalisis);
  dbs.desconectarDB2;
  if dbs.BaseClientServ = 'S' then dir := dbs.baseDat_N else dir := dbs.DirSistema + '\arch';
  solicitud      := datosdb.openDB('solicitud', 'nrosolicitud', '', dir);
  detsol         := datosdb.openDB('detsol', 'nrosolicitud;items', '', dir);
  resultado      := datosdb.openDB('resultado', 'nrosolicitud;codanalisis;items', '', dir);
  obsresul       := datosdb.openDB('refanalisis', 'nrosolicitud;codanalisis;items',  '', dir);
  obsanalisis    := datosdb.openDB('obsanalisis', 'nrosolicitud;codanalisis',  '', dir);
  solicitud.Open; detsol.Open; resultado.Open; obsresul.Open; obsanalisis.Open;
  ModoHistorico := False;
end;

function TTSolicitudAnalisisFabrissin.setResultado(xnrosolicitud, xcodanalisis, xitems: String): String;
// Objetivo...: recuperar un items de resultado
begin
  if Buscar(xnrosolicitud, xcodanalisis, xitems) then Result := resultado.FieldByName('resultado').AsString else Result := '';
end;

procedure TTSolicitudAnalisisFabrissin.ListarCarnet(xnrosolicitud: String; xcodanalisis: TStringList);
// Objetivo...: Listar Resultado en Carnet
var
  cordx, cordy, linea, fuente, tamfuente: TStringList;
  Bitmap: TBitmap;
  i: Integer;
  c: Real;
  cs: String;
Begin
  Application.CreateForm(TIRR, IRR);

  getFotoLogo(1);
  getDatos(xnrosolicitud);
  cordx := TStringList.Create; cordy := TStringList.Create; linea := TStringList.Create; fuente := TStringList.Create; tamfuente := TStringList.Create;

  cordx.Add('3,7'); cordy.Add('0,5');
  linea.Add(L1);
  fuente.Add('Arial'); tamfuente.Add('12');

  cordx.Add('3,7'); cordy.Add('0,7');
  linea.Add(L2);
  fuente.Add('Arial'); tamfuente.Add('12');

  cordx.Add('3,7'); cordy.Add('1,1');
  linea.Add(L3);
  fuente.Add('Arial'); tamfuente.Add('11');

  cordx.Add('3,7'); cordy.Add('1,3');
  linea.Add(L4);
  fuente.Add('Arial'); tamfuente.Add('10');

  cordx.Add('3,7'); cordy.Add('1,7');
  linea.Add('Protocolo: ' + solanalisis.nrosolicitud + '    Fecha: ' + solanalisis.fecha);
  fuente.Add('Arial'); tamfuente.Add('11');
  cordx.Add('3,7'); cordy.Add('2,0');
  linea.Add('Paciente: ' + paciente.nombre);

  profesional.getDatos(solanalisis.codprof);
  cordx.Add('3,7'); cordy.Add('2,3');
  linea.Add('Médico: ' + profesional.nombres);
          
  c := 2.6;

  for i := 1 to xcodanalisis.Count do Begin
    c := c + 0.2;
    cs := FloatToStr(c);
    cs := utiles.StringRemplazarCaracteres(cs, '.', ',');
    fuente.Add('Arial'); tamfuente.Add('11');
    cordx.Add('3,7'); cordy.Add(cs); //cordy.Add('2,3');
    nomeclatura.getDatos(xcodanalisis.Strings[i-1]);
    linea.Add(TrimRight(nomeclatura.descrip) + ': ' + solanalisis.setResultado(xnrosolicitud, xcodanalisis.Strings[i-1], '01'));
    fuente.Add('Arial'); tamfuente.Add('11');
  End;

  IRR.PrintDetalle(cordx, cordy, linea, fuente, tamfuente, solanalisis.Imagen);

  IRR.Release; IRR := Nil;
End;

function TTSolicitudAnalisisFabrissin.CalcularValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
var
  i, j, v, porcentOS, unidadNBU: real; montoFijo: Boolean;
begin
  // Verificamos el porcentaje que paga la Obra Social
  if obsocial.porcentaje > 0 then porcentOS := (obsocial.porcentaje * 0.01) else porcentOS := (100 * 0.01);

  i := 0; j := 0; v9984 := 0; PorcentajeDifObraSocial := 0; PorcentajeDif9984 := 0;

  if obsocial.FactNBU = 'N' then Begin
    // 1º Verificamos que el analisis no tenga monto Fijo - Teniendo en cuenta períodos
    i := obsocial.setMontoFijo(xcodos, xcodanalisis, periodo);
    // 2º Verificamos que el analisis no tenga monto Fijo
    if i = 0 then i := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis);

    if i = 0 then Begin
      // Cálculamos el valor del análisis
      i := (xOSUB * xNOUB) + (xOSUG * xNOUG);
      montoFijo := False;
    end else montoFijo := True;
    // Calculamos el valor del codigo de toma y recepción
    if Length(Trim(nomeclatura.cftoma)) > 0 then Begin
      codftoma := nomeclatura.cftoma;  // Capturamos el código fijo de toma y recepcion
      nomeclatura.getDatos(codftoma);
      j := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, codftoma);   // Verificamos si el 9984 tiene Monto Fijo

      if j = 0 then Begin      // Deducimos en Forma Normal
        v9984   := ((obsocial.UG * nomeclatura.ub) + (obsocial.UB * nomeclatura.gastos));

        if obsocial.tope = 'S' then Begin
          v := v9984;
          if v < obsocial.topemin then Begin
            v9984 := v * 2;   // Si monto menor a topemin entonces se multiplica por 2
          end;
          if (v > obsocial.topemin) and (v < obsocial.topemax) then v9984 := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
        end;
      end else Begin               // Monto Fijo del 9984
        v9984   := j;
      end;
    end;

    v := i;
    if not montoFijo then Begin          // Obras sociales que trabajan con topes
      if obsocial.tope = 'S' then Begin
        if v < obsocial.topemin then i := i * 2;   // Si monto menor a topemin entonces se multiplica por 2
        if (v > obsocial.topemin) and (v < obsocial.topemax) then i := obsocial.topemax;  // Si esta comprendido entre los topes, toma el valor maximo
      end;
    end;
  end;

  if obsocial.FactNBU = 'S' then Begin
    nbu.getDatos(xcodanalisis);
    // Verificamos si tiene Monto Fijo
    i := obsocial.setMontoFijoNBU(xcodos, xcodanalisis, periodo);
    // Verificamos si tiene unidad diferencial
    unidadNBU := obsocial.setUnidadNBU(xcodos, xcodanalisis, periodo);
    if unidadNBU > 0 then i := nbu.unidad * unidadNBU;

    if i = 0 then i := nbu.unidad * obsocial.valorNBU;
  end;

  PorcentajeDifObraSocial := i     - (i     * porcentOS);    // Obtiene la Dif. a Pagar, por ejemplo, si cubre el 80% obtiene el 20%, la dif.
  PorcentajeDif9984       := v9984 - (v9984 * porcentOS);

  i := i * porcentOS;
  v9984 := v9984 * porcentOS;
  T9984 := T9984 + v9984;

  Result := i;
end;

procedure TTSolicitudAnalisisFabrissin.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then plantillasIMP.Open;
  Inc(conexiones);
  entidadderivadora.conectar;
  derivanalisis.conectar;
  profesional.conectar;
  plantanalisis.conectar;
  nbu.conectar;
end;

procedure TTSolicitudAnalisisFabrissin.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(plantillasIMP);
  entidadderivadora.desconectar;
  derivanalisis.desconectar;
  profesional.desconectar;
  plantanalisis.desconectar;
  nbu.desconectar;
end;

{===============================================================================}

function solanalisis: TTSolicitudAnalisisFabrissin;
begin
  if xsolanalisis = nil then
    xsolanalisis := TTSolicitudAnalisisFabrissin.Create;
  Result := xsolanalisis;
end;

{===============================================================================}

initialization

finalization
  xsolanalisis.Free;

end.
