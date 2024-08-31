unit CSolAnalisisFabrissinInternacion;

interface

uses CSolAnalisis, CPaciente, CProfesional, CPlantanalisis, DBTables, CIDBFM, CBDT, CUtiles, SysUtils, CListar, CTitulos, CNomecla, CObrasSociales,
     CSanatoriosLaboratorios, Classes;

const
  fuenteres = 'Arial, normal, 9';
  fuentetit = 'Arial, negrita, 9';

type

TTSolicitudAnalisisFabrissinInternacion = class(TTSolicitudAnalisis)
  existePlantilla: Boolean;
  Idquederiv: String;
  plantillasIMP: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  procedure   GuardarDatosComplementariosSolicitud(xprotocolo, xabona: string; xtotal, xentrega: real; xfechaent, xretirafecha, xretirahora: string);

  procedure   getDatos(xnrosolicitud: string); overload;

  function    BuscarPlantilla(xidplantilla: string): boolean;
  procedure   GuardarPlantilla(xidplantilla, xplantilla, xfuente: string);
  procedure   getDatosPlantilla(xidplantilla: string);
  procedure   BorrarPlantilla(xidplantilla: string);
  function    setPlantillas: TQuery;

  procedure   ListHojaDeTrabajo(xnrosolicitud: string; salida: char);
  procedure   ImprimirSobre(xnombre: string; salida: char); //override;
  procedure   ListarSolicitudesQueDerivaron(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);

  procedure   ListarResultado(xdnrosol, xhnrosol: string; detSel: array of String; xidsanatorio: String; salida: char); overload;
  procedure   ListarResultadoEnLote(xlistaprotocolos: TStringList; xidsanatorio: String; salida: char); overload;

  procedure   ListarSolicitudesRegistradasInternaciones(xdfecha, xhfecha: String; salida: char);

  function    setSolicitudesEntidad(xdfecha, xhfecha, xcodsan: String): TQuery;

  procedure   RegistrarMonto(xnrosolicitud: String; xmonto: Real);

  procedure   ListarControlOrdenesDerivadas(xdesde, xhasta, xcodentidad: String; salida: char);

  procedure   Depurar(xprotocolo: string);
  procedure   FinalizarDepuracion;

  procedure   ConsultarHistorico;
  procedure   DesconectarHistorico;

  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  procedure   TituloSol(salida: char); override;
  procedure   ListSol(xcodpac, xidprof: string; salida: char); override;
  procedure   TituloSolInt(salida: char);
  procedure   ListSolInt(xcodpac, xidprof: string; salida: char);
  procedure   ListDetSol(xnrosolicitud: string; detSel: Array of String; salida: char); override;
 private
  { Declaraciones Privadas }                   
  conexiones: shortint;
  idsanatorio: String;
  procedure   EncabezadoDePagina(salida: char);
  procedure   InstanciarTablas;
  function    setSolicitudes(xdfecha, xhfecha: String): TQuery;
end;

function solanalisisint: TTSolicitudAnalisisFabrissinInternacion;

implementation

var
  xsolanalisisint: TTSolicitudAnalisisFabrissinInternacion = nil;

constructor TTSolicitudAnalisisFabrissinInternacion.Create;
begin
  inherited Create;
  fuenteObservac := 'Arial, cursiva, 8';
  InstanciarTablas;
end;

destructor TTSolicitudAnalisisFabrissinInternacion.Destroy;
begin
  inherited Destroy;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.GuardarDatosComplementariosSolicitud(xprotocolo, xabona: string; xtotal, xentrega: real; xfechaent, xretirafecha, xretirahora: string);
// Objetivo...: Guardar datos complementarios de la solicitud
begin
  if inherited Buscar(xprotocolo) then Begin
    solicitud.Edit;
    solicitud.FieldByName('abona').AsString       := xabona;
    solicitud.FieldByName('total').AsFloat        := xtotal;
    solicitud.FieldByName('entrega').AsFloat      := xentrega;
    solicitud.FieldByName('fechaent').AsString    := utiles.sExprFecha(xfechaent);
    solicitud.FieldByName('retirafecha').AsString := utiles.sExprFecha(xretirafecha);
    solicitud.FieldByName('retirahora').AsString  := xretirahora;
    try
      solicitud.Post
    except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud); 
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getDatos(xnrosolicitud: string);
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
    if Length(Trim(solicitud.FieldByName('fechaent').AsString)) = 8 then fechaEntrega := utiles.sFormatoFecha(solicitud.FieldByName('fechaent').AsString) else fechaEntrega := utiles.sFormatoFecha(utiles.sExprFecha(DateToStr(Now())));
    sanatorio.getDatos(Idquederiv);
    NSanatorio   := sanatorio.Descrip;
  end else Begin
    abona := ''; fechaEntrega := utiles.sFormatoFecha(utiles.sExprFecha(DateToStr(Now()))); retiraFecha := ''; retiraHora := ''; total := 0; entrega := 0; Idquederiv := '000'; NSanatorio := '';
  end;
end;

{ Tratamiento de Plantillas }

function TTSolicitudAnalisisFabrissinInternacion.BuscarPlantilla(xidplantilla: string): boolean;
// Objetivo...: Buscar una plantilla
begin
  existePlantilla := plantillasIMP.FindKey([xidplantilla]);
  Result := existePlantilla;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.GuardarPlantilla(xidplantilla, xplantilla, xfuente: string);
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

procedure TTSolicitudAnalisisFabrissinInternacion.getDatosPlantilla(xidplantilla: string);
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

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarPlantilla(xidplantilla: string);
// Objetivo...: Borrar una plantilla
begin
  if BuscarPlantilla(xidplantilla) then plantillasIMP.Delete;
end;

function TTSolicitudAnalisisFabrissinInternacion.setPlantillas: TQuery;
// Objetivo...: retornar un set de plantillas creadas
begin
  Result := datosdb.tranSQL('SELECT * FROM plantillasIMP ORDER BY idplantilla');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.TituloSol(salida: char);
// Objetivo...: Listar t�tulos de resultados de an�lisis
begin
  if sanatorio.Listprot = 'I' then Begin
    list.Setear(salida); list.NoImprimirPieDePagina;
    titulos.conectar;
    list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, TrimLeft(titulos.titulo), 1, 'Arial, negrita, 14');
    list.Titulo(0, 0, 'Sanatorio/Ent.: ' + NSanatorio, 1, 'Arial, normal, 12');
    list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
    list.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');
    titulos.desconectar;
  end;
  if sanatorio.Listprot = 'A' then TituloSolInt(salida);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.EncabezadoDePagina(salida: char);
// Objetivo...: Listar el inicio de la Nueva p�gina
begin
  list.IniciarNuevaPagina;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListSol(xcodpac, xidprof: string; salida: char);
// Objetivo...: Listar datos de la solictud - Paciente y Profesional
var
  i: integer;
begin
  if sanatorio.Listprot = 'I' then Begin
    paciente.getDatos(xcodpac);
    profesional.getDatos(xidprof);

    List.Linea(0, 0, ' ', 1, 'Times New Roman, normal, 5', salida, 'S');

    List.Linea(0, 0, ' Paciente: ', 1, 'Times New Roman, normal, 11', salida, 'N');
    List.Linea(18, List.Lineactual, UpperCase(paciente.Nombre), 2, 'Times New Roman, normal, 11', salida, 'S');
    List.Linea(77, list.Lineactual, 'Protocolo Nro.: ' + solicitud.FieldByName('protocolo').AsString, 3, 'Times New Roman, normal, 11', salida, 'S');

    List.Linea(0, 0, ' Pedido del Dr/a.:', 1, 'Times New Roman, normal, 11', salida, 'N'); List.Linea(18, list.lineactual, profesional.Nombres, 2, 'Times New Roman, normal, 10', salida, 'N');
    List.Linea(77, list.Lineactual, 'Fecha Sol.: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 3, 'Times New Roman, normal, 11', salida, 'S');

    List.Linea(0, 0, ' ', 1, 'Times New Roman, normal, 8', salida, 'S');
  end;
  if sanatorio.Listprot = 'A' then Begin
    ListSolInt(xcodpac, xidprof, salida);
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListDetSol(xnrosolicitud: string; detSel: Array of String; salida: char);
// Objetivo...: Listar detalle de la solicitud
var
  r, t: TQuery; xcodanalisisanter, xnrosolanter, fuente: string; distancia: integer; f, imp, ls: boolean;
begin
  r := setResultados(xnrosolicitud); t := setResultados(xnrosolicitud);
  r.Open; r.First; xcodanalisisanter := ''; protocolo := xnrosolicitud;
  while not r.EOF do Begin
     ls := False;
     if Length(Trim(idsanatorio)) = 0 then ls := True else
       if r.FieldByName('entidaderiv').AsString = idsanatorio then ls := True;

     if (verificarItemsEnLista(detSel, r.FieldByName('codanalisis').AsString)) and (ls) then Begin
      if r.FieldByName('codanalisis').AsString <> xcodanalisisanter then Begin
        if Length(Trim(xcodanalisisanter)) > 0 then Begin // Observaciones de an�lisis
          List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
          if Buscar(xnrosolanter, xcodanalisisanter) then Begin
            list.ListMemo('observaciones', 'Arial, cursiva, 8', 0, salida, obsanalisis, 0); // Si existen observaciones
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
          end;
          if not List.EfectuoSaltoPagina then List.Linea(0, 0, '  ', 1, 'Arial, normal, 10', salida, 'S') else Begin // En la misma p�gina
            List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
            List.Linea(0, 0, ' ', 1, 'Arial, normal, 24', salida, 'S');
          end;
        end;
        nomeclatura.getDatos(r.FieldByName('codanalisis').AsString);

        if list.RealizarSaltoPagina(list.altotit) then EncabezadoDePagina(salida);
        List.Linea(0, 0, ' ' + UpperCase(nomeclatura.descrip), 1, fuentetit, salida, 'S');

        t.Open; t.First; f := False; { Impresi�n de Items paralelos - a la descripci�n del an�lisis }
        while not t.EOF do Begin
          plantanalisis.getDatos(t.FieldByName('codanalisis').AsString, t.FieldByName('items').AsString);
          if (plantanalisis.itemsParalelo = '00') and (t.FieldByName('codanalisis').AsString = r.FieldByName('codanalisis').AsString) then Begin  // Items paralelo a la descripci�n del an�lisis
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
            List.Linea(distancia, list.lineactual, plantanalisis.elemento + ':  ' + t.FieldByName('resultado').AsString, 2, fuenteres, salida, 'N');
            f := True;
          end;
          t.Next;
        end;
        t.Close;
        if not f then List.Linea(80, list.Lineactual, ' ', 3, 'Arial, negrita, 11', salida, 'S');
        { Fin Impresi�n de Items paralelos }
        List.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');
      end;

      plantanalisis.getDatos(r.FieldByName('codanalisis').AsString, r.FieldByName('items').AsString);
      if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
      // Impresi�n de Items independientes
      if plantanalisis.imputable = 'N' then Begin
        List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        List.Linea(0, 0, '  ' + plantanalisis.elemento, 1, fuentetit, salida, 'N');
      end else Begin
        if Length(Trim(plantanalisis.itemsParalelo)) = 0 then Begin  // Si es un items independiente lo imprimimos
          if Copy(plantanalisis.elemento, 1, 4) = uppercase(Copy(plantanalisis.elemento, 1, 4)) then fuente := fuenteres else fuente := fuentetit;
          if distancia = 0 then Begin
            List.Linea(0, 0, '  ' + plantanalisis.elemento, 1, fuente, salida, 'N');
            if Length(Trim(r.FieldByName('resultado').AsString)) > 0 then Begin
              List.derecha(47, list.lineactual, '##########################', r.FieldByName('resultado').AsString, 2, fuenteres);
              List.Linea(48, list.lineactual, ' ', 3, fuenteres, salida, 'S');
            end else
              if Length(Trim(r.FieldByName('valoresn').AsString)) > 0 then Begin
                List.derecha(distancia + 47, list.lineactual, '##########################', r.FieldByName('valoresn').AsString, 2, fuenteres);
                List.Linea(distancia + 48, list.lineactual, ' ', 3, fuenteres, salida, 'S');
              end
          end else Begin
            List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
            List.Linea(distancia, list.Lineactual, plantanalisis.elemento, 2, fuenteres, salida, 'N');
            if Length(Trim(plantanalisis.itemsParalelo)) = 0 then List.Linea(distancia + 15, list.lineactual, r.FieldByName('resultado').AsString, 3, 'Arial, normal, 10', salida, 'N') else List.Linea(distancia + 47, list.lineactual, r.FieldByName('resultado').AsString, 3, fuenteres, salida, 'N');
            if Length(Trim(r.FieldByName('valoresn').AsString)) > 0 then Begin
              List.derecha(distancia + 47, list.lineactual, '##########################', r.FieldByName('valoresn').AsString, 4, fuenteres);
              List.Linea(distancia + 48, list.lineactual, ' ', 5, fuenteres, salida, 'S');
            end else
              List.Linea(distancia + 15, list.lineactual, r.FieldByName('resultado').AsString, 3, fuenteres, salida, 'S');
          end;
        end;

        { Impresi�n de Items paralelos - a los items comunes }
        t.Open; t.First;
        while not t.EOF do Begin
          plantanalisis.getDatos(t.FieldByName('codanalisis').AsString, t.FieldByName('items').AsString);
          if (plantanalisis.itemsParalelo = r.FieldByName('items').AsString) and (t.FieldByName('codanalisis').AsString = r.FieldByName('codanalisis').AsString) then Begin
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
            List.Linea(distancia, list.lineactual, plantanalisis.elemento, 4, fuenteres, salida, 'N');
            if Length(Trim(t.FieldByName('resultado').AsString)) > 0 then Begin
              List.Derecha(distancia + 47, list.lineactual, '##########################', t.FieldByName('resultado').AsString, 5, fuenteres);
              List.Linea(distancia + 48, list.lineactual, ' ', 6, fuenteres, salida, 'S');
              imp := True;
            end;
            if Length(Trim(t.FieldByName('valoresn').AsString)) > 0 then Begin
              List.Derecha(distancia + 47, list.lineactual, '##########################', t.FieldByName('valoresn').AsString, 5, fuenteres);
              List.Linea(distancia + 48, list.lineactual, ' ', 6, fuenteres, salida, 'S');
              imp := True;
            end;
            if not imp then List.Linea(distancia + 48, list.lineactual, ' ', 5, fuenteres, salida, 'S');
            imp := False;
          end;
          t.Next;
        end;
        t.Close;
        { Fin Impresi�n de Items paralelos - a los items comunes }
      end;

      if list.RealizarSaltoPagina(list.altotit) then EncabezadoDePagina(salida);

      // Valores Normales cuando hay resultados
      if (Length(Trim(r.FieldByName('valoresn').AsString)) > 0) and (Length(Trim(r.FieldByName('resultado').AsString)) > 0) then List.Linea(52, list.Lineactual, 'V.N.: ' + r.FieldByName('valoresn').AsString, 6, 'Arial, normal, 8', salida, 'S') else List.Linea(50, list.Lineactual, ' ', 6, fuenteres, salida, 'S');

      // Observaciones de items
      if BuscarResultado(r.FieldByName('nrosolicitud').AsString, r.FieldByName('codanalisis').AsString, r.FieldByName('items').AsString) then list.ListMemo('observaciones', 'Arial, cursiva, 8', 5, salida, obsresul, 0);
      xcodanalisisanter := r.FieldByName('codanalisis').AsString;
      xnrosolanter      := r.FieldByName('nrosolicitud').AsString;

    end;

    r.Next;
  end;

  List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');

  if verificarItemsEnLista(detSel, xcodanalisisanter) then
    if Buscar(xnrosolanter, xcodanalisisanter) then list.ListMemo('observaciones', 'Arial, cursiva, 8', 12, salida, obsanalisis, 0); // Si existen observaciones

  if not r.EOF then List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  r.Close; r.Free; r := nil; t.Close; t.Free; t := nil;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListHojaDeTrabajo(xnrosolicitud: string; salida: char);
// Objetivo...: Listar hoja de trabajo
begin
  getDatos(xnrosolicitud);
  ListHDeTrabajo(xnrosolicitud, salida);
  list.CompletarPagina;
  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ImprimirSobre(xnombre: string; salida: char);
// Objetivo...: generar etiqueta de impresi�n de sobres
var
  i: integer;
begin
  list.ImprimirHorizontal;
  list.Setear(salida);
  list.NoImprimirPieDePagina;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 12');
  For i := 1 to 2 do List.Linea(0, 0, ' ', 1, 'Arial, negrita, 12', salida, 'S');
  titulos.conectar;
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 17', salida, 'S'); List.Linea(5, list.lineactual, TrimLeft(titulos.titulo), 2, 'Arial, negrita, 17', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 10', salida, 'S'); list.ListMemoRecortandoEspaciosHorizontales_Verticales('Subtitulo', 'Arial, cursiva, 9', 5, salida, titulos.tabla, 0);
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 17', salida, 'S'); list.ListMemoRecortandoEspaciosHorizontales_Verticales('Actividad', 'Arial, cursiva, 8', 5, salida, titulos.tabla, 0);
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 14', salida, 'S');
  titulos.desconectar;
  if Length(Trim(xnombre)) > 0 then List.Linea(0, 0, utiles.espacios(10) + 'Paciente:  ' + UpperCase(xnombre), 1, 'Times New Roman, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  list.FinList;
  list.ImprimirVetical;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesQueDerivaron(xdfecha, xhfecha: String; xresumen: Boolean; salida: char);
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
  List.Titulo(0, 0, 'N� Prot.', 1, 'Arial, cursiva, 8');
  List.Titulo(15, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(60, list.Lineactual, 'Entidad que Deriv�', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  r := datosdb.tranSQL(dir, 'SELECT protocolo, codpac, codos, fecha, entidadderiv FROM solicitud WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by entidadderiv, fecha, protocolo');
  r.Open; i := 0;
  estado := detsol.Active;
  if not detsol.Active then detsol.Open;
  sanatorio.conectar;
  while not r.Eof do Begin
    if r.FieldByName('fecha').AsString <> idanter then Begin
      if Length(Trim(idanter)) > 0 then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Fecha: ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, negrita, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      idanter := r.FieldByName('fecha').AsString;
    end;
    paciente.getDatos(r.FieldByName('codpac').AsString);
    sanatorio.getDatos(r.FieldByName('entidadderiv').AsString);

    if not xresumen then Fuente := 'Arial, negrita, 8' else Fuente := 'Arial, normal, 8';
    list.Linea(0, 0, r.FieldByName('protocolo').AsString, 1, Fuente, salida, 'N');
    list.Linea(15, list.Lineactual, paciente.Nombre, 2, Fuente, salida, 'N');
    list.Linea(60, list.Lineactual, sanatorio.Descrip, 3, Fuente, salida, 'S');
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
  sanatorio.desconectar;
  detsol.Active := estado;

  if i > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Protocolos Registrados:    ' + IntToStr(i), 1, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No se Registraron Protocolos', 1, 'Arial, normal, 8', salida, 'S');

  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.InstanciarTablas;
// Objetivo...: instanciar tablas
begin
  solicitud      := datosdb.openDB('solicitudint', 'nrosolicitud');
  detsol         := datosdb.openDB('detsolint', 'nrosolicitud;items');
  resultado      := datosdb.openDB('resultadoint', 'nrosolicitud;codanalisis;items');
  obsresul       := datosdb.openDB('refanalisisint', 'nrosolicitud;codanalisis;items');
  obsanalisis    := datosdb.openDB('obsanalisisint', 'nrosolicitud;codanalisis');
  plantillasIMP  := datosdb.openDB('plantillasimp', '');
  ultnro         := datosdb.openDB('ultnroint', '');
  movpagos       := datosdb.openDB('movpagosint', '');
  plantillasIMP  := datosdb.openDB('plantillasimp', '');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarResultado(xdnrosol, xhnrosol: string; detSel: array of String; xidsanatorio: String; salida: char);
// Objetivo...: Emitir Ficha con los resultados de los an�lisis - Filtro por Nro. solicitud
begin
  idsanatorio := xidsanatorio;
  ListarResultadoAC(xdnrosol, xhnrosol, detSel, salida, 'S');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarResultadoEnLote(xlistaprotocolos: TStringList; xidsanatorio: String; salida: char);
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

function TTSolicitudAnalisisFabrissinInternacion.setSolicitudes(xdfecha, xhfecha: String): TQuery;
// Objetivo...: devolver un set de registros con las solicitudes entre dos fechas
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT protocolo, codpac, codos, fecha, entidadderiv FROM ' + solicitud.TableName + ' WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha, protocolo');
end;

function TTSolicitudAnalisisFabrissinInternacion.setSolicitudesEntidad(xdfecha, xhfecha, xcodsan: String): TQuery;
// Objetivo...: devolver un set de registros con las solicitudes entre dos fechas
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT protocolo, codpac, codos, fecha, entidadderiv, monto FROM ' + solicitud.TableName + ' WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' and entidadderiv = ' + '"' + xcodsan + '"' + ' order by fecha, protocolo');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesRegistradasInternaciones(xdfecha, xhfecha: String; salida: char);
// Objetivo...: Listar Ordenes Registradas
var
  r: TQuery; i, j: Integer;
  idanter, lista: String;
  l: TStringList;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Protocolos Registrados en el Lapso: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  List.Titulo(0, 0, 'N� Prot.', 1, 'Arial, cursiva, 8');
  List.Titulo(7, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(28, list.Lineactual, 'Obra Social', 3, 'Arial, cursiva, 8');
  List.Titulo(50, list.Lineactual, 'Sanatorio/Entidad', 4, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Determinaciones', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  list.Linea(0, 0, '*** Pr�cticas Ambulatorias  ***', 1, 'Arial, negrita, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

  l := TStringList.Create;
  r := setSolicitudes(xdfecha, xhfecha);
  r.Open; i := 0; idanter := '';
  while not r.Eof do Begin
    sanatorio.getDatos(r.FieldByName('entidadderiv').AsString);
    if sanatorio.Listprot = 'A' then Begin
      if r.FieldByName('fecha').AsString <> idanter then Begin
        if Length(Trim(idanter)) > 0 then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Fecha: ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        idanter := r.FieldByName('fecha').AsString;
      end;
      paciente.getDatos(r.FieldByName('codpac').AsString);
      obsocial.getDatos(r.FieldByName('codos').AsString);

      lista := '';
      l := setDeterminaciones(r.FieldByName('protocolo').AsString);
      For j := 1 to l.Count do lista := lista + l.Strings[j-1] + ' ';
      list.Linea(0, 0, r.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(7, list.Lineactual, Copy(paciente.Nombre, 1, 25), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(28, list.Lineactual, Copy(obsocial.nombre, 1, 25), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, Copy(sanatorio.Descrip, 1, 25), 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(75, list.Lineactual, lista, 5, 'Arial, normal, 8', salida, 'S');
      Inc(i);
    end;

    r.Next;
  end;

  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, '*** Pr�cticas Internaciones  ***', 1, 'Arial, negrita, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  r.First; i := 0; idanter := '';
  while not r.Eof do Begin
    sanatorio.getDatos(r.FieldByName('entidadderiv').AsString);
    if sanatorio.Listprot = 'I' then Begin
      if r.FieldByName('fecha').AsString <> idanter then Begin
        if Length(Trim(idanter)) > 0 then list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Fecha: ' + utiles.sFormatoFecha(r.FieldByName('fecha').AsString), 1, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        idanter := r.FieldByName('fecha').AsString;
      end;
      paciente.getDatos(r.FieldByName('codpac').AsString);
      obsocial.getDatos(r.FieldByName('codos').AsString);

      lista := '';
      l := setDeterminaciones(r.FieldByName('protocolo').AsString);
      For j := 1 to l.Count do lista := lista + l.Strings[j-1] + ' ';
      list.Linea(0, 0, r.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(7, list.Lineactual, Copy(paciente.Nombre, 1, 25), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(28, list.Lineactual, Copy(obsocial.nombre, 1, 25), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(50, list.Lineactual, Copy(sanatorio.Descrip, 1, 25), 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(75, list.Lineactual, lista, 5, 'Arial, normal, 8', salida, 'S');
      Inc(i);
    end;

    r.Next;
  end;

  r.Close; r.Free;

  if i > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Protocolos Registrados:    ' + IntToStr(i), 1, 'Arial, negrita, 8', salida, 'S');
  end else
    list.Linea(0, 0, 'No se Registraron Protocolos', 1, 'Arial, normal, 8', salida, 'S');

  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListSolInt(xcodpac, xidprof: string; salida: char);
// Objetivo...: Listar datos de la solictud - Paciente y Profesional
var
  i: integer;
begin
  paciente.getDatos(xcodpac);
  profesional.getDatos(xidprof);
  if titulos.margenSup = '0' then Begin
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 24', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Arial, negrita, 20', salida, 'S');
  end else
    for i := 1 to StrToInt(Trim(titulos.margenSup)) do list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, '                   Paciente', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, List.Lineactual, ':  ' + UpperCase(paciente.Nombre), 2, 'Times New Roman, normal, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '                   Indicaci�n del Dr/a.', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, list.lineactual, ':  ' + profesional.Nombres, 2, 'Times New Roman, normal, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '                   Fecha', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, List.Lineactual, ':  ' + Copy(solicitud.FieldByName('fecha').AsString, 7, 2) + ' de ' + meses[StrToInt(Copy(solicitud.FieldByName('fecha').AsString, 5, 2))] + ' ' +  Copy(solicitud.FieldByName('fecha').AsString, 1, 4), 2, 'Times New Roman, normal, 12', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '                   Protocolo N�', 1, 'Times New Roman, normal, 12', salida, 'N'); List.Linea(30, List.Lineactual, ':  ' + solicitud.FieldByName('protocolo').AsString, 2, 'Times New Roman, normal, 12', salida, 'N');
  List.Linea(50, List.Lineactual, 'Entidad: ' + sanatorio.Descrip, 3, 'Times New Roman, normal, 12', salida, 'S');
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
end;

procedure TTSolicitudAnalisisFabrissinInternacion.TituloSolInt(salida: char);
// Objetivo...: Listar t�tulos de resultados de an�lisis
begin
  list.Setear(salida); list.NoImprimirPieDePagina;
  titulos.base_datos := dbs.baseDat_N;
  titulos.conectar;
  list.Titulo(0, 0, ' ', 1, 'Arial, negrita, 18');
  list.Titulo(0, 0, titulos.titulo, 1, titulos.fTitulo);
  list.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  list.Titulo(0, 0, titulos.subtitulo, 1, titulos.fSubtitulo);

  list.ListMemo('Actividad', titulos.fprofesion, 0, salida, titulos.tabla, 0);
  list.ListMemo('Direccion', titulos.fdirtel, 0, salida, titulos.tabla, 0);

  list.Linea(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');

  titulos.desconectar;

  // Subtitulo
  list.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  List.Subtitulo(0, 0, '                   ', 1, 'Times New Roman, normal, 9');
  List.Subtitulo(0, 0, '                   Paciente', 1, 'Times New Roman, normal, 12'); List.Subtitulo(30, List.Lineactual, ':  ' + UpperCase(paciente.Nombre), 2, 'Times New Roman, normal, 12');
  List.Subtitulo(0, 0, '                   Protocolo N�', 1, 'Times New Roman, normal, 12'); List.Subtitulo(30, List.Lineactual, ':  ' + protocolo, 2, 'Times New Roman, normal, 12');
  List.Subtitulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Subtitulo(0, 0, '                   ', 1, 'Times New Roman, normal, 24');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarMonto(xnrosolicitud: String; xmonto: Real);
// Objetivo...: registrar monto entidad
begin
  if Buscar(xnrosolicitud) then Begin
    solicitud.Edit;
    solicitud.FieldByName('monto').AsFloat := xmonto;
    try
      solicitud.Post
     except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.Depurar(xprotocolo: string);
// Objetivo...: Mover Instancias al registro hist�rico
var
  cantreg, i: Integer;
  fechadep: String;
begin
  histsolicitud   := datosdb.openDB('solicitudint_hist', 'fechadep;nrosolicitud');
  histdetsol      := datosdb.openDB('detsolint_hist', 'fechadep;nrosolicitud;items');
  histresultado   := datosdb.openDB('resultadoint_hist', 'fechadep;nrosolicitud;codanalisis;items');
  histrefanalisis := datosdb.openDB('refanalisisint_hist', 'fechadep;nrosolicitud;codanalisis;items');
  histobsanalisis := datosdb.openDB('obsanalisisint_hist', 'fechadep;nrosolicitud;codanalisis');
  histsolicitud.Open; histdetsol.Open; histresultado.Open; histrefanalisis.Open; histobsanalisis.Open;

  fechadep := utiles.setFechaActual;

  conectar;
  if (Buscar(xprotocolo)) then begin
    // Transferencias al historico
    datosdb.Filtrar(detsol, 'nrosolicitud = ' + '''' + solicitud.FieldByName('nrosolicitud').AsString + '''');
    detsol.First;
    while not detsol.Eof do Begin
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
      datosdb.tranSQL('DELETE FROM ' + detsol.TableName + ' WHERE nrosolicitud = ' + '"' + xprotocolo + '"');
      datosdb.tranSQL('DELETE FROM ' + resultado.TableName + ' WHERE nrosolicitud = ' + '"' + xprotocolo + '"');
      datosdb.tranSQL('DELETE FROM ' + obsresul.TableName + ' WHERE nrosolicitud = ' + '"' + xprotocolo + '"');
      datosdb.tranSQL('DELETE FROM ' + obsanalisis.TableName + ' WHERE nrosolicitud = ' + '"' + xprotocolo + '"');
      datosdb.tranSQL('DELETE FROM ' + solicitud.TableName + ' WHERE nrosolicitud = ' + '"' + xprotocolo + '"');
    end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.FinalizarDepuracion;
begin
  datosdb.closeDB(histdetsol); datosdb.closeDB(histresultado); datosdb.closeDB(histrefanalisis); datosdb.closeDB(histobsanalisis); datosdb.closeDB(histsolicitud);
  desconectar;
  dep_ini := false;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ConsultarHistorico;
// Objetivo...: cerrar tablas de persistencia
begin
  if not ModoHistorico then Begin
    datosdb.closeDB(solicitud); datosdb.closeDB(detsol); datosdb.closeDB(resultado); datosdb.closeDB(obsresul); datosdb.closeDB(obsanalisis);
    solicitud     := datosdb.openDB('solicitudint_hist', 'nrosolicitud', '');
    detsol        := datosdb.openDB('detsolint_hist', 'nrosolicitud;items');
    resultado     := datosdb.openDB('resultadoint_hist', 'nrosolicitud;codanalisis;items');
    obsresul      := datosdb.openDB('refanalisisint_hist', 'nrosolicitud;codanalisis;items');
    obsanalisis   := datosdb.openDB('obsanalisisint_hist', 'nrosolicitud;codanalisis');
    solicitud.Open; detsol.Open; resultado.Open; obsresul.Open; obsanalisis.Open;
  end;
  ModoHistorico := True;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.DesconectarHistorico;
// Objetivo...: Consultar Datos Normales
Begin
  datosdb.closeDB(solicitud); datosdb.closeDB(detsol); datosdb.closeDB(resultado); datosdb.closeDB(obsresul); datosdb.closeDB(obsanalisis);
  solicitud      := datosdb.openDB('solicitudint', 'nrosolicitud', '', dir);
  detsol         := datosdb.openDB('detsolint', 'nrosolicitud;items', '', dir);
  resultado      := datosdb.openDB('resultadoint', 'nrosolicitud;codanalisis;items', '', dir);
  obsresul       := datosdb.openDB('refanalisisint', 'nrosolicitud;codanalisis;items',  '', dir);
  obsanalisis    := datosdb.openDB('obsanalisisint', 'nrosolicitud;codanalisis',  '', dir);
  solicitud.Open; detsol.Open; resultado.Open; obsresul.Open; obsanalisis.Open;
  ModoHistorico := False;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarControlOrdenesDerivadas(xdesde, xhasta, xcodentidad: String; salida: char);
// Objetivo...: Listar Ordenes
var
  idanter: String;
  total: Real;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, 'Ordenes Derivadas por Otras Entidades en el Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, normal, 5');
  List.Titulo(0, 0, 'N� Prot.', 1, 'Arial, cursiva, 8');
  List.Titulo(7, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  List.Titulo(15, list.Lineactual, 'Paciente', 3, 'Arial, cursiva, 8');
  List.Titulo(75, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  idanter := ''; total := 0;
  datosdb.Filtrar(solicitud, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and entidadderiv = ' + '''' + xcodentidad + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if solicitud.FieldByName('entidadderiv').AsString <> idanter then Begin
      sanatorio.getDatos(solicitud.FieldByName('entidadderiv').AsString);
      list.Linea(0, 0, 'Entidad: ' + sanatorio.descrip, 1, 'Arial, negrita, 9', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
      idanter := solicitud.FieldByName('entidadderiv').AsString;
    end;
    paciente.getDatos(solicitud.FieldByName('codpac').AsString);
    list.Linea(0, 0, solicitud.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
    list.Linea(7, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(15, list.Lineactual, paciente.nombre, 3, 'Arial, normal, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', solicitud.FieldByName('monto').AsFloat, 4, 'Arial, normal, 8');
    list.Linea(85, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
    total := total + solicitud.FieldByName('monto').AsFloat;
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);

  if total > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'N');
    list.derecha(80, list.Lineactual, '', '-------------------------', 2, 'Arial, normal, 8');
    list.Linea(85, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, 'Subtotal:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(80, list.Lineactual, '', total, 2, 'Arial, negrita, 8');
    list.Linea(85, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.conectar;
// Objetivo...: conectar tablas de persistencia
begin
  inherited conectar;
  if conexiones = 0 then plantillasIMP.Open;
  Inc(conexiones);
  sanatorio.conectar;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.desconectar;
// Objetivo...: desconectar tablas de persistencia
begin
  inherited desconectar;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then datosdb.closeDB(plantillasIMP);
  sanatorio.desconectar;
end;

{===============================================================================}

function solanalisisint: TTSolicitudAnalisisFabrissinInternacion;
begin
  if xsolanalisisint = nil then
    xsolanalisisint := TTSolicitudAnalisisFabrissinInternacion.Create;
  Result := xsolanalisisint;
end;

{===============================================================================}

initialization

finalization
  xsolanalisisint.Free;

end.
