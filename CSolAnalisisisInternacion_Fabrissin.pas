unit CSolAnalisisisInternacion_Fabrissin;

interface

uses CPacienteInternacion_Fabrissin, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     Classes, CObrasSocialesCCBInt, CSanatoriosLaboratorios, CNomeclaCCB, CPlantAnalisis_Int,
     CProfesionalFabrissinInternado, CNBU, Contnrs, CRefinos, CServers2000_Excel, CRefinosAgrupados,
     CRefinosMixto, CEquivalenciasML, CProtocoloExport, CNomeclatura_ObraSocial;

const
  elementos = 10;
  esp = ' ';
type

TTSolicitudAnalisisFabrissinInternacion = class
  Protocolo, Items, Codigo, Fecha, Hora, Codpac, Codos, idprof, Codsan, Habitacion, Admision, Fealta, Febaja,
  Resultado_Analisis, Observacionitems, ObservacionFinal, Retiva, Muestra, Fechafact, Valoresn, Codref: String;
  LineasPag, lineas_blanco: Integer;
  Titulo: String; Subtitulo: TStringList;
  listdatossan, __imprimecodigos: Boolean;
  solicitud, detsol, admisiones, resultado, obsitems, obsfinal, confinf: TTable;
 public
  { Declaraciones P�blicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xprotocolo: String): Boolean;
  procedure   Registrar(xprotocolo, xfecha, xhora, xcodpac, xcodos, xidprof, xcodsan, xhabitacion, xadmision, xmuestra, xitems, xcodigo, xcodref: String; xcantitems: Integer);
  procedure   getDatos(xprotocolo: String);
  procedure   Borrar(xprotocolo: String);
  function    setItems(xprotocolo: String): TObjectList;
  function    NuevoProtocolo: String;
  function    setProtocolosPaciente(xcodpac: String): TObjectList;
  function    setProtocolosPacientePorNro(xcodpac: String): TObjectList;
  function    setProtocolosFecha(xfecha: String): TObjectList; overload;
  function    setProtocolosFecha(xdesde, xhasta, xcodsan: String): TObjectList; overload;
  function    getProtocolosFecha(xdesde, xhasta: String): TQuery; overload;
  procedure   BorrarAdmisionProtocolo(xprotocolo: String);

  function    BuscarAdmision(xcodpac, xadmision: String): Boolean;
  procedure   RegistrarAdmision(xprotocolo, xcodpac, xadmision, xfealta, xfebaja, xfechafact: String);
  procedure   getDatosAdmision(xcodpac, xadmision: String);
  procedure   BorrarAdmision(xcodpac, xadmision: String);
  procedure   RegistrarAdmisionProtocolo(xprotocolo, xcodpac, xadmision, xfealta, xfebaja, xretiva, xfechafact: String);
  procedure   RegistrarMuestra(xprotocolo, xmuestra: String);
  function    verificarMuestra(xfecha, xmuestra: String): String;
  function    verificarSiElPacienteFueInternado(xcodpac: String): Boolean;

  // -- Informes --

  procedure   ListarSolicitudes(xcodsan, xdesde, xhasta: String; lista: TStringList; salida: char);
  procedure   ListarEgresosPacientes(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesPorAdmision(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
  procedure   ListarSolicitudesValorizadas(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesPorAdmisionValorizadas(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
  procedure   ListarSolicitudesCodigosPorAdmision(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
  procedure   ListarSolicitudesValorizadasPorObraSocial(xcodsan, xcodos, xdesde, xhasta: String; salida: char);
  procedure   ListarCodigosSolicitudesPorObraSocial(xcodsan, xcodos, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesValorizadasPorFechaFacturacion(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesValorizadasPorFechaFacturacionResumidas(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarCodigosSolicitudes(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);

  // -- Estad�sticas --

  procedure   ListarPracticasRealizadas(xcodos, xdesde, xhasta: string; salida: char);
  procedure   ListPacientesObraSocial(xcodos, xdesde, xhasta: string; salida: char);

  // -- Resultados --

  function    BuscarResultado(xprotocolo, xcodanalisis, xitems: String): Boolean;
  procedure   GuardarResultado(xprotocolo, xcodanalisis, xitems, xresultado, xvaloresn, xnroanalisis: string; xcantidaditems: Integer);
  procedure   BorrarResultado(xprotocolo: string);
  procedure   BorrarResultadoDeterminacion(xprotocolo, xcodanalisis: string); overload;
  procedure   getResultado(xprotocolo, xcodanalisis, xitems: String);

  function    BuscarObservacionItems(xprotocolo, xcodanalisis, xitems: String): Boolean;
  procedure   GuardarObservacionItems(xprotocolo, xcodanalisis, xitems, xobservacion: string);
  procedure   getObservacionItems(xprotocolo, xcodanalisis, xitems: String);

  function    BuscarObservacionFinal(xprotocolo: String): Boolean;
  procedure   GuardarObservacionFinal(xprotocolo, xobservacion: string);
  procedure   getObservacionFinal(xprotocolo: String);

  procedure   ReordenarDeterminacion(xnrosolicitud, xcodanalisis, xnroanalisis: String);
  procedure   ListarResultados(xcodsan, xdfecha, xhfecha: String; xprotocolos: TStringList; salida: char);
  procedure   ListarProtocolo(xprotocolo: String; xdeterminaciones: TStringList; salida: char);
  procedure   ListarResultadoPorAdmision(xcodsan, xcodpac: String; xadmisiones: TStringList; salida: char);

  function    CalcularValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): Real;
  function    setValorAnalisis(xcodos, xcodanalisis, xperiodo: string): Real;
  function    Precio9984: Real;
  function    Total9984: Real;

  // -- Par�metros de Informes
  function    BuscarParametroInf(xid: String): Boolean;
  procedure   RegistrarParametroInf(xid: String; xalto, xsep: Integer);
  procedure   getDatosParametrosInf(xid: String);

  function    setProtocolosAdmision(xnroadmision: String): TObjectList;

  function    setAnalisis(xnrosolicitud: string): TQuery;

  procedure   ExportarOrdenesML(xlista: TStringList; xruta: string);

  procedure   RegistrarResultadoML(xprotocolo, xsigla, xvalor: string);

  procedure   EstadisticaPracticasRealizadas(xcodos, xdesde, xhasta: string; salida: char);

  function    getProtocolosItems(xprotocolo: string): TQuery;

  function    getProtocolos(xdesde, xhasta: string): TQuery;

  function    getProtocolosItemsResultado(xprotocolo, xcodanalisis, xitems: string): TQuery;

  function    getProtocolosItemsResultadoObservaciones(xprotocolo, xcodanalisis, xitems: string): TQuery;

  procedure   RegistrarResultadoCM(xprotocolo, xitems, xvalor: string; copiarTemplate: boolean);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  pag, lineas, sm: Integer;
  CHR18, CHR15, Caracter, Lin: String;
  listdat: Boolean;
  lcodsan, ldfecha, lhfecha, Periodo, codftoma, RI, __c: String;
  v9984, PorcentajeDifObraSocial, PorcentajeDif9984, t9984: Real;
  totales: array[1..elementos] of Real;
  ressql: TQuery;
  __codigos, __practicas: TStringList;

  function    BuscarDetSol(xprotocolo, xitems: String): Boolean;
  function    ControlarSalto: boolean;
  procedure   RealizarSalto;
  procedure   titulo1(xdesde, xhasta: String);
  procedure   ListDetSol(xnrosolicitud: string; detSel: TStringList; salida: char);
  function    setResultados(xnrosolicitud: string): TObjectList;
  procedure   TituloResultado(xcodsan, xdfecha, xhfecha: String; salida: char);
  procedure   ListTituloResultado(xcodsan, xdfecha, xhfecha: String; salida: char);
  procedure   TituloResultado1(xcodsan, xdfecha, xhfecha: String; salida: char);
  procedure   ListDatosPaciente(salida: char);
  procedure   ListMemo(xcampo: String; xtabla: TTable; salida: char);
  procedure   titulo2;
  procedure   IniciarArreglos;
  procedure   titulo3(xcodos: String);
  function    getCantidadItemsOrden(xnrosolicitud: string): integer;
  function    getNroAnalisis(xprotocolo, xcodigo: string): string;
  function    setImportePacientePor_ObraSocial(xcodpac, xcodob, xdfecha, xhfecha: string): real;
  function    getCodigos(xprotocolo: string): string;
end;

function solanalisisint: TTSolicitudAnalisisFabrissinInternacion;

implementation

var
  xsolanalisisint: TTSolicitudAnalisisFabrissinInternacion = nil;

constructor TTSolicitudAnalisisFabrissinInternacion.Create;
begin
  solicitud  := datosdb.openDB('solicitudint', '');
  detsol     := datosdb.openDB('detsolint', '');
  admisiones := datosdb.openDB('admisiones', '');
  resultado  := datosdb.openDB('resultadoint', '');
  obsitems   := datosdb.openDB('obsitemsint', '');
  obsfinal   := datosdb.openDB('obsresultadoint', '');
  confinf    := datosdb.openDB('confinf', '');
  LineasPag  := 65;
  chr18      := chr(18);
  chr15      := chr(15);
  Caracter   := '-';
  Subtitulo  := TStringList.Create;
  __codigos  := TStringList.Create;
end;

destructor TTSolicitudAnalisisFabrissinInternacion.Destroy;
begin
  inherited Destroy;
end;

function  TTSolicitudAnalisisFabrissinInternacion.Buscar(xprotocolo: String): Boolean;
// Objetivo...: buscar una instancia
begin
  if solicitud.IndexFieldNames <> 'protocolo' then solicitud.IndexFieldNames := 'protocolo';
  Result := solicitud.FindKey([xprotocolo]);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.Registrar(xprotocolo, xfecha, xhora, xcodpac, xcodos, xidprof, xcodsan, xhabitacion, xadmision, xmuestra, xitems, xcodigo, xcodref: String; xcantitems: Integer);
// Objetivo...: registrar una instancia
begin
  if xitems = '001' then Begin
    if Buscar(xprotocolo) then solicitud.Edit else solicitud.Append;
    solicitud.FieldByName('protocolo').AsString  := xprotocolo;
    solicitud.FieldByName('fecha').AsString      := utiles.sExprFecha2000(xfecha);
    solicitud.FieldByName('hora').AsString       := xhora;
    solicitud.FieldByName('codpac').AsString     := xcodpac;
    solicitud.FieldByName('codos').AsString      := xcodos;
    solicitud.FieldByName('idprof').AsString     := xidprof;
    solicitud.FieldByName('codsan').AsString     := xcodsan;
    solicitud.FieldByName('habitacion').AsString := xhabitacion;
    solicitud.FieldByName('admision').AsString   := xadmision;
    solicitud.FieldByName('muestra').AsString    := xmuestra;
    try
      solicitud.Post
     except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);
  end;

  if BuscarDetSol(xprotocolo, xitems) then detsol.Edit else detsol.Append;
  detsol.FieldByName('protocolo').AsString := xprotocolo;
  detsol.FieldByName('items').AsString     := xitems;
  detsol.FieldByName('codigo').AsString    := xcodigo;
  detsol.FieldByName('codref').AsString    := xcodref;
  try
    detsol.Post
   except
    detsol.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    //datosdb.refrescar(detsol);
    //datosdb.refrescar(solicitud);
    datosdb.tranSQL('delete from ' + detsol.TableName + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(solicitud); datosdb.closeDB(detsol);
    solicitud.Open; detsol.Open;
    //datosdb.refrescar(detsol);
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getDatos(xprotocolo: String);
// Objetivo...: recuperar una instancia
begin
  if Buscar(xprotocolo) then Begin
    protocolo  := solicitud.FieldByName('protocolo').AsString;
    fecha      := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
    hora       := solicitud.FieldByName('hora').AsString;
    codpac     := trim(solicitud.FieldByName('codpac').AsString);
    codos      := solicitud.FieldByName('codos').AsString;
    idprof     := solicitud.FieldByName('idprof').AsString;
    codsan     := solicitud.FieldByName('codsan').AsString;
    habitacion := solicitud.FieldByName('habitacion').AsString;
    admision   := solicitud.FieldByName('admision').AsString;
    Muestra    := solicitud.FieldByName('muestra').AsString;
    Retiva     := solicitud.FieldByName('retiva').AsString;
  end else Begin
    protocolo := ''; fecha := utiles.setFechaActual; hora := utiles.setHoraActual24; codpac := ''; codos := ''; idprof := ''; codsan := ''; habitacion := ''; admision := ''; muestra := ''; retiva := '';
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.Borrar(xprotocolo: String);
// Objetivo...: borrar una instancia
var
  cp, ad: String;
  ca: Integer;
begin
  if Buscar(xprotocolo) then Begin
    // Verificamos las admisiones
    cp := solicitud.FieldByName('codpac').AsString;
    ad := solicitud.FieldByName('admision').AsString;
    ca := 0;
    solicitud.IndexFieldNames := 'codpac';
    while not solicitud.Eof do Begin
      if solicitud.FieldByName('codpac').AsString <> cp then Break;
      if solicitud.FieldByName('admision').AsString = ad then Inc(ca);
      solicitud.Next;
    end;
    if ca = 1 then BorrarAdmision(cp, ad);  // Significa que solo tiene un protocolo en la admisi�n, lo borramos

    Buscar(xprotocolo);
    solicitud.Delete;
    datosdb.tranSQL('delete from ' + detsol.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
    datosdb.closeDB(solicitud); datosdb.closeDB(detsol);
    solicitud.Open; detsol.Open;

    // Borramos los resultados
    datosdb.tranSQL('delete from ' + resultado.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
    datosdb.tranSQL('delete from ' + obsitems.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
    datosdb.tranSQL('delete from ' + obsfinal.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
    datosdb.closeDB(resultado); datosdb.closeDB(obsitems); datosdb.closeDB(obsfinal);
    resultado.Open; obsitems.Open; obsfinal.Open;

    solicitud.IndexFieldNames := 'protocolo';
  end;
end;

function  TTSolicitudAnalisisFabrissinInternacion.BuscarDetSol(xprotocolo, xitems: String): Boolean;
// Objetivo...: Buscar Detalle Solicitud
begin
  if detsol.IndexFieldNames <> 'protocolo;items' then detsol.IndexFieldNames := 'protocolo;items';
  Result := datosdb.Buscar(detsol, 'protocolo', 'items', xprotocolo, xitems);
  //solicitud.IndexFieldNames := 'protocolo';
end;

function  TTSolicitudAnalisisFabrissinInternacion.setItems(xprotocolo: String): TObjectList;
// Objetivo...: recuperar items
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
Begin
  l := TObjectList.Create;
  if BuscarDetSol(xprotocolo, '001') then Begin
    while not detsol.Eof do Begin
      if detsol.FieldByName('protocolo').AsString <> xprotocolo then Break;
      objeto           := TTSolicitudAnalisisFabrissinInternacion.Create;
      objeto.Protocolo := detsol.FieldByName('protocolo').AsString;
      objeto.Items     := detsol.FieldByName('items').AsString;
      objeto.Codigo    := detsol.FieldByName('codigo').AsString;
      objeto.Codref    := detsol.FieldByName('codref').AsString;
      l.Add(objeto);
      detsol.Next;
    end;
  end;
  Result := l;
end;

function  TTSolicitudAnalisisFabrissinInternacion.NuevoProtocolo: String;
// Objetivo...: obtener un nuevo protocolo
var
  filtro: Boolean;
begin
  solicitud.IndexFieldNames := 'protocolo';
  filtro             := solicitud.Filtered;
  solicitud.Filtered := False;
  if solicitud.RecordCount = 0 then Result := '1' else Begin
    solicitud.Last;
    Result := IntToStr(solicitud.FieldByName('protocolo').AsInteger + 1);
  end;
  solicitud.Filtered := filtro;
end;

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosPaciente(xcodpac: String): TObjectList;
// Objetivo...: devolver los protocolos
var
  l, x: TObjectList;
  s: TStringList;
  objeto, objeto1: TTSolicitudAnalisisFabrissinInternacion;
  j: Integer;
  rsolicitud: TQuery;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TObjectList.Create;
  s := TStringList.Create;
  x := TObjectList.Create;

  rsolicitud := datosdb.tranSQL(solicitud.DatabaseName, 'select protocolo, codpac, fecha, codos, idprof, admision, retiva, muestra, codsan from solicitudint where codpac = ' +
  '''' + trim(xcodpac) + '''' + ' order by codpac');

  rsolicitud.Open; rsolicitud.First;
  j := 0;
  while not rsolicitud.Eof do Begin
    objeto           := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo := rsolicitud.FieldByName('protocolo').AsString;
    objeto.Fecha     := utiles.sFormatoFecha(rsolicitud.FieldByName('fecha').AsString);
    objeto.Codos     := rsolicitud.FieldByName('codos').AsString;
    objeto.idprof    := rsolicitud.FieldByName('idprof').AsString;
    objeto.Admision  := rsolicitud.FieldByName('admision').AsString;
    objeto.Retiva    := rsolicitud.FieldByName('retiva').AsString;
    objeto.Muestra   := rsolicitud.FieldByName('muestra').AsString;
    s.Add(rsolicitud.FieldByName('protocolo').AsString + IntToStr(j));
    l.Add(objeto);
    Inc(j);
    rsolicitud.Next;
  end;
  rsolicitud.Close; rsolicitud.Free;

  {
  solicitud.IndexFieldNames := 'Codpac';
  if not solicitud.FindKey([xcodpac]) then Begin
    datosdb.Filtrar(solicitud, 'codpac = ' + '''' + xcodpac + '''');
    solicitud.First;
  End;
  j := 0;
  while not solicitud.Eof do Begin
    if solicitud.FieldByName('codpac').AsString <> xcodpac then Break;
    objeto           := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo := solicitud.FieldByName('protocolo').AsString;
    objeto.Fecha     := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
    objeto.Codos     := solicitud.FieldByName('codos').AsString;
    objeto.idprof    := solicitud.FieldByName('idprof').AsString;
    objeto.Admision  := solicitud.FieldByName('admision').AsString;
    objeto.Retiva    := solicitud.FieldByName('retiva').AsString;
    objeto.Muestra   := solicitud.FieldByName('muestra').AsString;
    s.Add(solicitud.FieldByName('protocolo').AsString + IntToStr(j));
    l.Add(objeto);
    Inc(j);
    solicitud.Next;
  end;
  if solicitud.Filtered then datosdb.QuitarFiltro(solicitud);
  }
  Buscar(protocolo);

  s.Sort; // ordenamos la colecci�n
  for j := 1 to s.Count do Begin
    objeto1 := TTSolicitudAnalisisFabrissinInternacion(l.Items[StrToInt(Trim(Copy(s.Strings[j-1], 11, 3)))]);
    objeto  := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo := objeto1.Protocolo;
    objeto.Fecha     := objeto1.Fecha;
    objeto.Codos     := objeto1.Codos;
    objeto.idprof    := objeto1.Idprof;
    objeto.Admision  := objeto1.Admision;
    objeto.Retiva    := objeto1.Retiva;
    objeto.Muestra   := objeto1.Muestra;
    x.Add(objeto);
  End;

  Result := x;
end;

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosPacientePorNro(xcodpac: String): TObjectList;
// Objetivo...: devolver los protocolos
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  rsolicitud: TQuery;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TObjectList.Create;
  rsolicitud := datosdb.tranSQL(solicitud.DatabaseName, 'select protocolo, codpac, fecha, codos, idprof, admision, retiva, muestra, codsan from solicitudint where codpac = ' +
  '''' + trim(xcodpac) + '''' + ' order by protocolo');

  rsolicitud.Open; rsolicitud.First;
  while not rsolicitud.Eof do Begin
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo := rsolicitud.FieldByName('protocolo').AsString;
    objeto.Fecha     := utiles.sFormatoFecha(rsolicitud.FieldByName('fecha').AsString);
    objeto.Codos     := rsolicitud.FieldByName('codos').AsString;
    objeto.Idprof    := rsolicitud.FieldByName('idprof').AsString;
    objeto.Admision  := rsolicitud.FieldByName('admision').AsString;
    objeto.Retiva    := rsolicitud.FieldByName('retiva').AsString;
    objeto.Muestra   := rsolicitud.FieldByName('muestra').AsString;
    objeto.Codsan    := rsolicitud.FieldByName('codsan').AsString;
    l.Add(objeto);
    rsolicitud.Next;
  end;
  rsolicitud.Close; rsolicitud.Free;


  {
  if not (solicitud.FindKey([xcodpac])) then Begin
    datosdb.Filtrar(solicitud, 'codpac = ' + '''' + trim(xcodpac) + '''');
    solicitud.First;
  End;
  while not solicitud.Eof do Begin
    if solicitud.FieldByName('codpac').AsString <> xcodpac then Break;
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo := solicitud.FieldByName('protocolo').AsString;
    objeto.Fecha     := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
    objeto.Codos     := solicitud.FieldByName('codos').AsString;
    objeto.Idprof    := solicitud.FieldByName('idprof').AsString;
    objeto.Admision  := solicitud.FieldByName('admision').AsString;
    objeto.Retiva    := solicitud.FieldByName('retiva').AsString;
    objeto.Muestra   := solicitud.FieldByName('muestra').AsString;
    objeto.Codsan    := solicitud.FieldByName('codsan').AsString;
    l.Add(objeto);
    solicitud.Next;
  end;
  if solicitud.Filtered then datosdb.QuitarFiltro(solicitud);}
  Buscar(protocolo);
  Result := l;
end;

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosFecha(xfecha: String): TObjectList;
// Objetivo...: devolver los protocolos
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TObjectList.Create;
  solicitud.IndexFieldNames := 'Fecha;Muestra';
  datosdb.Filtrar(solicitud, 'fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo  := solicitud.FieldByName('protocolo').AsString;
    objeto.Fecha      := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
    objeto.Codos      := solicitud.FieldByName('codos').AsString;
    objeto.idprof     := solicitud.FieldByName('idprof').AsString;
    objeto.Admision   := solicitud.FieldByName('admision').AsString;
    objeto.Retiva     := solicitud.FieldByName('retiva').AsString;
    objeto.Muestra    := solicitud.FieldByName('muestra').AsString;
    objeto.Codpac     := solicitud.FieldByName('codpac').AsString;
    objeto.Habitacion := solicitud.FieldByName('habitacion').AsString;
    l.Add(objeto);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  Buscar(protocolo);
  Result := l;
end;

function  TTSolicitudAnalisisFabrissinInternacion.getProtocolosFecha(xdesde, xhasta: String): TQuery;
// Objetivo...: devolver los protocolos
begin
  result := datosdb.tranSQL('select * from ' + solicitud.TableName + ' where fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by protocolo');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarAdmisionProtocolo(xprotocolo: String);
// Objetivo...: borrar admisi�n desde protocolo
var
  nroadmision: String;
Begin
  if Buscar(xprotocolo) then Begin
    nroadmision := solicitud.FieldByName('admision').AsString;
    solicitud.Edit;
    solicitud.FieldByName('admision').AsString := '';
    try
      solicitud.Post
     except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);

    // Verificamos a ver si queda algun protocolo con esa admisi�n
    solicitud.IndexFieldNames := 'admision';
    if not solicitud.FindKey([nroadmision]) then Begin  // Significa que ya no queda ningun protocolo con ese nro. de admisi�n
      datosdb.tranSQL('delete from ' + admisiones.TableName + ' where admision = ' + '''' + nroadmision + '''');
      datosdb.refrescar(admisiones);
    end;
    solicitud.IndexFieldNames := 'protocolo';
  end;
end;

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosFecha(xdesde, xhasta, xcodsan: String): TObjectList;
// Objetivo...: devolver los protocolos
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TObjectList.Create;
  solicitud.IndexFieldNames := 'Fecha;Muestra';
  datosdb.Filtrar(solicitud, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and codsan = ' + '''' + xcodsan + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo := solicitud.FieldByName('protocolo').AsString;
    objeto.Codpac    := solicitud.FieldByName('codpac').AsString;
    objeto.Codos     := solicitud.FieldByName('codos').AsString;
    objeto.Muestra   := solicitud.FieldByName('muestra').AsString;
    l.Add(objeto);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  Buscar(protocolo);
  Result := l;
end;

function  TTSolicitudAnalisisFabrissinInternacion.BuscarAdmision(xcodpac, xadmision: String): Boolean;
// Objetivo...: recuperar una instancia
begin
  if admisiones.IndexFieldNames <> 'admision;codpac' then admisiones.IndexFieldNames := 'admision;codpac';
  Result := datosdb.Buscar(admisiones, 'admision', 'codpac', xadmision, xcodpac);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarAdmision(xprotocolo, xcodpac, xadmision, xfealta, xfebaja, xfechafact: String);
// Objetivo...: cerrar tablas de persistencia
begin
  if BuscarAdmision(xcodpac, xadmision) then admisiones.Edit else admisiones.Append;
  admisiones.FieldByName('admision').AsString  := xadmision;
  admisiones.FieldByName('codpac').AsString    := xcodpac;
  admisiones.FieldByName('fealta').AsString    := utiles.sExprFecha2000(xfealta);
  admisiones.FieldByName('febaja').AsString    := utiles.sExprFecha2000(xfebaja);
  admisiones.FieldByName('fechafact').AsString := utiles.sExprFecha2000(xfechafact);
  try
    admisiones.Post
   except
    admisiones.Cancel
  end;
  datosdb.closeDB(admisiones); admisiones.Open;

  // Registramos el nro. de admisi�n en el protocolo
  if Buscar(xprotocolo) then Begin
    solicitud.Edit;
    solicitud.FieldByName('admision').AsString := xadmision;
    try
      solicitud.Post
     except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);
   end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getDatosAdmision(xcodpac, xadmision: String);
Begin
  if BuscarAdmision(xcodpac, xadmision) then Begin
    Fealta    := utiles.sFormatoFecha(admisiones.FieldByName('fealta').AsString);
    Febaja    := utiles.sFormatoFecha(admisiones.FieldByName('febaja').AsString);
    Fechafact := utiles.sFormatoFecha(admisiones.FieldByName('fechafact').AsString);
  end else Begin
    Fealta := ''; Febaja := ''; Fechafact := '';
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarAdmision(xcodpac, xadmision: String);
Begin
  if BuscarAdmision(xcodpac, xadmision) then Begin
    admisiones.Delete;
    datosdb.refrescar(admisiones);
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarAdmisionProtocolo(xprotocolo, xcodpac, xadmision, xfealta, xfebaja, xretiva, xfechafact: String);
Begin
  if Buscar(xprotocolo) then Begin
    solicitud.Edit;
    solicitud.FieldByName('admision').AsString := xadmision;
    solicitud.FieldByName('retiva').AsString   := xretiva;
    try
      solicitud.Post
     except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);

    RegistrarAdmision(xprotocolo, xcodpac, xadmision, xfealta, xfebaja, xfechafact);
    paciente.ModificarRetencionIVA(xcodpac, xretiva);
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarMuestra(xprotocolo, xmuestra: String);
Begin
  if Buscar(xprotocolo) then Begin
    solicitud.Edit;
    solicitud.FieldByName('muestra').AsString := xmuestra;
    try
      solicitud.Post
     except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);
  end;
end;

// -----------------------------------------------------------------------------
function TTSolicitudAnalisisFabrissinInternacion.ControlarSalto: boolean;
// Objetivo...: salto de linea para las impresiones basadas en texto
var
  k: Integer;
begin
  Result := False;
  if lineas >= LineasPag then Begin
    //list.LineaTxt(inttostr(lineas), false);
    if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else
      for k := 1 to lineas_blanco do list.LineaTxt('', True);
    Result := True;
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RealizarSalto;
// Objetivo...: imprimir lineas en blanco hasta realizar salto de p�gina
var
  k: Integer;
begin
  if lineas_blanco = 0 then list.LineaTxt(CHR(12), True) else Begin
    for k := lineas + 1 to LineasPag do list.LineaTxt('', True);
    lineas := LineasPag + 5;
    ControlarSalto;
  end;
end;

// -----------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarEgresosPacientes(xcodsan, xdesde, xhasta: String; salida: char);
// Objetivo...: cerrar tablas de persistencia
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t: Integer;
begin
  listdat := False; pag := 0; sm := 3;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Egresos Lapso: ' + xdesde + ' - ' + xhasta + ' Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(9, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(17, List.lineactual, 'Paciente', 3, 'Arial, cursiva, 8');
    List.Titulo(35, List.lineactual, 'M�dico', 4, 'Arial, cursiva, 8');
    List.Titulo(55, List.lineactual, 'Obra Social', 5, 'Arial, cursiva, 8');
    List.Titulo(72, List.lineactual, 'Nro.Adm.', 6, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 7, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo1(xdesde, xhasta);
  end;

  datosdb.Filtrar(admisiones, 'fechafact >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechafact <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  admisiones.First;
  while not admisiones.Eof do Begin
    if BuscarAdmision(admisiones.FieldByName('codpac').AsString, admisiones.FieldByName('admision').AsString) then Begin

      datosdb.Filtrar(solicitud, 'admision = ' + '''' + admisiones.FieldByName('admision').AsString + '''');
      solicitud.First;

      while not solicitud.Eof do Begin
        det := setItems(solicitud.FieldByName('protocolo').AsString);
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        profesional.getDatos(solicitud.FieldByName('idprof').AsString);
        obsocial.getDatos(solicitud.FieldByName('codos').AsString);
        listdat := True;

        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(9, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
          list.Linea(17, list.Lineactual, Copy(paciente.nombre, 1, 17) + ' [' + paciente.retiva + ']', 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(35, list.Lineactual, Copy(profesional.nombres, 1, 20), 4, 'Arial, normal, 8', salida, 'N');
          list.Linea(55, list.Lineactual, Copy(obsocial.nombre, 1, 22), 5, 'Arial, normal, 8', salida, 'N');
          list.Linea(72, list.Lineactual, admisiones.FieldByName('admision').AsString, 6, 'Arial, normal, 8', salida, 'N');
          k := 6; j := 7; t := 0;
          For i := 1 to det.Count do Begin
            objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
            j := j + 4;
            Inc(k);
            Inc(t);
            if t < 4 then list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'N') else Begin
              list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'S');
              if i < det.Count then Begin
                list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
                j := 7; k := 1;
              end;
              t := 0;
            end;
          end;

          det.Free; det := Nil;

          if k <> 1 then list.Linea(97, list.Lineactual, '', k+1, 'Arial, normal, 8', salida, 'S');

        end;

        if (salida = 'T') then Begin
          list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
          list.LineaTxt(Copy(paciente.nombre, 1, 16) + '[' + paciente.retiva + '] ' + utiles.espacios(22 - (Length(Trim(copy(paciente.nombre, 1, 20))))), False);
          list.LineaTxt(Copy(profesional.nombres, 1, 20) + utiles.espacios(22 - (Length(Trim(Copy(profesional.nombres, 1, 20))))), False);
          list.LineaTxt(Copy(obsocial.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(obsocial.nombre, 1, 25))))), False);
          list.LineaTxt(admisiones.FieldByName('admision').AsString + utiles.espacios(18 - (Length(Trim(admisiones.FieldByName('admision').AsString)))), False);
          k := 5; j := 7; t := 0;
          For i := 1 to det.Count do Begin
            objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
            j := j + 4;
            Inc(k);
            Inc(t);
            if t < 4 then list.LineaTxt(objeto.Codigo + ' ', False) else Begin
              list.LineaTxt(objeto.Codigo + ' ', True);
              k := 1;
              if i < det.Count then Begin
                list.LineaTxt(utiles.espacios(107), False);
                j := 7; k := 1;
              end;
              t := 0;
            end;
          end;

          det.Free; det := Nil;

          if k <> 1 then list.LineaTxt('', True);

          Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
        end;

        solicitud.Next;
      end;

    end;

    datosdb.QuitarFiltro(solicitud);

    admisiones.Next;
  end;

  datosdb.QuitarFiltro(admisiones);

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.titulo1(xdesde, xhasta: String);
var
  i, j: Integer;
Begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  List.LineaTxt(TrimLeft(titulo) + CHR15, True);
  j := 0;
  For i := 1 to subtitulo.Count do Begin
    Inc(j);
    List.LineaTxt(TrimLeft(subtitulo.Strings[i-1]), True);
  end;
  list.LineaTxt(CHR18 + ' ', true);
  list.LineaTxt('Planilla de Ingresos Lapso: ' + xdesde + '-' + xhasta + utiles.espacios(10) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt('Sanatorio: ' + sanatorio.Descrip, true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  if sm = 1 then list.LineaTxt('Prot. N.M. Fecha    Nombre                Medico                Obra Social                Habitacion      Codigos' + CHR18, true);
  if sm = 2 then list.LineaTxt('Protocolo  Fecha    Nombre                Medico                Obra Social                Habitacion      Codigos' + CHR18, true);
  if sm = 3 then list.LineaTxt('Prot. Fecha    Nombre                Medico                Obra Social                Nro.Admision      Codigos' + CHR18, true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  lineas := 9 + j;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudes(xcodsan, xdesde, xhasta: String; lista: TStringList; salida: char);
// Objetivo...: cerrar tablas de persistencia
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c: Integer;
begin
  listdat := False; pag := 0; sm := 1; c := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Ingresos Lapso: ' + xdesde + ' - ' + xhasta + ' Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(11, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(17, List.lineactual, 'Paciente', 3, 'Arial, cursiva, 8');
    List.Titulo(37, List.lineactual, 'M�dico', 4, 'Arial, cursiva, 8');
    List.Titulo(57, List.lineactual, 'Obra Social', 5, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 6, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 7, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo1(xdesde, xhasta);
  end;

  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if (utiles.verificarItemsLista(lista, solicitud.FieldByName('codos').AsString)) then begin

      det := setItems(solicitud.FieldByName('protocolo').AsString);
      paciente.getDatos(solicitud.FieldByName('codpac').AsString);
      profesional.getDatos(solicitud.FieldByName('idprof').AsString);
      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      listdat := True;

      Inc(c);

      if (salida = 'P') or (salida = 'I') then Begin
        if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
        list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + ' ' + solicitud.FieldByName('muestra').AsString, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(11, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(18, list.Lineactual, Copy(paciente.nombre, 1, 15) + ' [' + RI + ']', 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(37, list.Lineactual, Copy(profesional.nombres, 1, 15), 4, 'Arial, normal, 8', salida, 'N');
        list.Linea(57, list.Lineactual, Copy(obsocial.nombre, 1, 22), 5, 'Arial, normal, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 6, 'Arial, normal, 8', salida, 'N');
        k := 6; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          j := j + 6;
          Inc(k);
          Inc(t);
          if t < 3 then list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'N') else Begin
            list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'S');
            if i < det.Count then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

        det.Free; det := Nil;

        if k <> 1 then list.Linea(97, list.Lineactual, '', k+1, 'Arial, normal, 8', salida, 'S');

      end;

    end;

    if (salida = 'T') then Begin
      if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
      list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + ' ' + solicitud.FieldByName('muestra').AsString + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
      list.LineaTxt(Copy(paciente.nombre, 1, 16) + '[' + RI + '] ' + utiles.espacios(22 - (Length(Trim(copy(paciente.nombre, 1, 20))))), False);
      list.LineaTxt(Copy(profesional.nombres, 1, 17) + utiles.espacios(22 - (Length(Trim(Copy(profesional.nombres, 1, 20))))), False);
      list.LineaTxt(Copy(obsocial.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(obsocial.nombre, 1, 25))))), False);
      list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), False);
      k := 5; j := 7; t := 0;
      For i := 1 to det.Count do Begin
        objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
        j := j + 4;
        Inc(k);
        Inc(t);
        if t < 4 then list.LineaTxt(objeto.Codigo + ' ', False) else Begin
          list.LineaTxt(objeto.Codigo + ' ', True);
          k := 1;
          if i < det.Count then Begin
            list.LineaTxt(utiles.espacios(107), False);
            j := 7; k := 1;
          end;
          t := 0;
        end;
      end;

      if k <> 1 then list.LineaTxt('', True);

      Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
    end;

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);

  if c > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Pacientes Listados: ' + IntToStr(c), 1, 'Arial, negrita, 9', salida, 'S');
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesPorAdmision(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t: Integer;
  codpacanter, admisionanter: String;
begin
  listdat := False; pag := 0;
  list.altopag := 0; list.m := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Ingresos por Admisi�n - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(75, List.lineactual, 'Habit./Muestra', 5, 'Arial, cursiva, 8');
    List.Titulo(90, List.lineactual, 'C�digos Pr�cticas', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo2;
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  solicitud.IndexFieldNames := 'codpac;admision';
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('admision').AsString) then Begin
      if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Admisi�n Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
          list.Linea(40, list.Lineactual, 'Paciente: ' + paciente.nombre, 2, 'Arial, negrita, 9, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo2;
          end;
          list.LineaTxt(CHR18 + 'Admision Nro.: ' +  solicitud.FieldByName('admision').AsString + utiles.espacios(12 - (Length(Trim(solicitud.FieldByName('admision').AsString)))), False);
          list.LineaTxt('Paciente: ' + paciente.nombre + CHR15, True);
          Inc(lineas); if controlarSalto then titulo2;
        end;

        admisionanter := solicitud.FieldByName('admision').AsString;
        codpacanter   := solicitud.FieldByName('codpac').AsString;
      end;

      det := setItems(solicitud.FieldByName('protocolo').AsString);

      profesional.getDatos(solicitud.FieldByName('idprof').AsString);
      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      listdat := True;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, solicitud.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, normal, 8', salida, 'N');
        list.Linea(75, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10) + ' / ' + solicitud.FieldByName('muestra').AsString, 5, 'Arial, normal, 8', salida, 'N');
        k := 5; j := 4; t := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          j := j + 6;
          Inc(k);
          Inc(t);
          if t < 4 then list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'N') else Begin
            list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'S');
            if i < det.Count then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              j := 4; k := 1;
            end;
            t := 0;
          end;
        end;

        det.Free; det := Nil;

        if k <> 1 then list.Linea(110, list.Lineactual, '', k+1, 'Arial, normal, 8', salida, 'S');

      end;

      if (salida = 'T') then Begin
        list.LineaTxt(solicitud.FieldByName('protocolo').AsString + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
        list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
        list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), False);
        k := 4; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.LineaTxt(objeto.Codigo + ' ', False) else Begin
            list.LineaTxt(objeto.Codigo + ' ', True);
            k := 1;
            if i < det.Count then Begin
              list.LineaTxt(utiles.espacios(107), False);
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

        det.Free; det := Nil;

        if k <> 1 then list.LineaTxt('', True);
        Inc(lineas); if controlarSalto then titulo2;
      end;
    end;

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  solicitud.IndexFieldNames := 'protocolo';

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);

  solicitud.IndexFieldNames := 'protocolo';
  Buscar(protocolo);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.titulo2;
var
  i, j: Integer;
Begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  List.LineaTxt(TrimLeft(titulo) + CHR15, True);
  j := 0;
  For i := 1 to subtitulo.Count do Begin
    Inc(j);
    List.LineaTxt(TrimLeft(subtitulo.Strings[i-1]), True);
  end;
  list.LineaTxt(CHR18 + ' ', true);
  list.LineaTxt('Planilla de Ingresos por Admision' + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt('Sanatorio: ' + sanatorio.Descrip, true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('Protocolo  Fecha    Medico                     Obra Social                     Habitacion      Codigos' + CHR18, true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  lineas := 9 + j;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesValorizadas(xcodsan, xdesde, xhasta: String; salida: char);
// Objetivo...: cerrar tablas de persistencia
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c: Integer;
  monto: Real;
begin
  listdat := False; pag := 0; sm := 2;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Detalle de Ingresos Lapso: ' + xdesde + ' - ' + xhasta + ' Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(17, List.lineactual, 'Paciente', 3, 'Arial, cursiva, 8');
    List.Titulo(37, List.lineactual, 'M�dico', 4, 'Arial, cursiva, 8');
    List.Titulo(57, List.lineactual, 'Obra Social', 5, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 6, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 7, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo1(xdesde, xhasta);
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  IniciarArreglos;
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin

    det := setItems(solicitud.FieldByName('protocolo').AsString);
    paciente.getDatos(solicitud.FieldByName('codpac').AsString);
    profesional.getDatos(solicitud.FieldByName('idprof').AsString);
    obsocial.getDatos(solicitud.FieldByName('codos').AsString);
    listdat := True;

    if (salida = 'P') or (salida = 'I') then Begin
      if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
      list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(17, list.Lineactual, Copy(paciente.nombre, 1, 20) + '[' + RI + ']', 3, 'Arial, negrita, 8', salida, 'N');
      list.Linea(37, list.Lineactual, Copy(profesional.nombres, 1, 20), 4, 'Arial, negrita, 8', salida, 'N');
      list.Linea(57, list.Lineactual, Copy(obsocial.nombre, 1, 25), 5, 'Arial, negrita, 8', salida, 'N');
      list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 6, 'Arial, negrita, 8', salida, 'S');

      k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
      For i := 1 to det.Count do Begin
        objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
        list.Linea(k, t, objeto.Codigo, c, 'Arial, cursiva, 8', salida, 'N');
        t := list.Lineactual;
        monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, objeto.Codigo, Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
        totales[1] := totales[1] + monto;
        list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
        c := c + 2;
        k := k + 15;
        if c > 10 then Begin
          list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
          k := 0; j := 0; t := 0; c := 1;
        end;
      end;

      det.Free; det := Nil;

      // Agregamos el 9984
      totales[2] := Total9984;
      if totales[2] > 0 then Begin
        list.Linea(k, t, codftoma, c, 'Arial, cursiva, 8', salida, 'N');
        t := list.Lineactual;
        monto := totales[2];
        totales[1] := totales[1] + monto;
        list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
        c := c + 2;
        k := k + 15;
        if c > 10 then Begin
          list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
          k := 0; j := 0; t := 0; c := 1;
        end;
      end;

      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;

    if (salida = 'T') then Begin
      if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
      list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
      list.LineaTxt(Copy(paciente.nombre, 1, 16) + '[' + RI + '] ' + utiles.espacios(22 - (Length(Trim(copy(paciente.nombre, 1, 20))))), False);
      list.LineaTxt(Copy(profesional.nombres, 1, 20) + utiles.espacios(22 - (Length(Trim(Copy(profesional.nombres, 1, 20))))), False);
      list.LineaTxt(Copy(obsocial.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(obsocial.nombre, 1, 25))))), False);
      list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), True);
      Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      k := 0; j := 0; t := 0; c := 1;
      For i := 1 to det.Count do Begin
        objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
        list.LineaTxt(objeto.Codigo, False);

        monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, objeto.Codigo, Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
        totales[1] := totales[1] + monto;
        totales[5] := totales[5] + monto;
        list.importeTxt(monto, 10, 2, False);
        list.LineaTxt(' ', False);
        c := c + 1;
        if c > 5 then Begin
          list.LineaTxt('', True);
          Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
          k := 0; j := 0; t := 0; c := 1;
        end;
      end;

      det.Free; det := Nil;

      // Agregamos el 9984
      totales[2] := Total9984;
      if totales[2] > 0 then Begin
        list.LineaTxt(codftoma, False);
        monto := totales[2];
        totales[1] := totales[1] + monto;
        totales[5] := totales[5] + monto;
        list.importeTxt(monto, 10, 2, False);
        list.LineaTxt(' ', False);
        c := c + 2;
        k := k + 15;
        if c > 5 then Begin
          list.LineaTxt('', True);
          Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
          k := 0; j := 0; t := 0; c := 1;
        end;
      end;

      list.LineaTxt('', True);
      Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
    end;

    if (obsocial.Retencioniva > 0) and (solicitud.FieldByName('retiva').AsString = 'S') then
      totales[3] := totales[3] + (totales[1] * (obsocial.Retencioniva * 0.01));

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);

    if totales[1] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Subtotal Facturado:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Retenci�n I.V.A.:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Total General:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1] + totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
    end;

    if (salida = 'T') then Begin
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
      list.LineaTxt(utiles.espacios(26) + 'Subtotal Facturado      :             ', False);
      list.ImporteTxt(totales[1], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      list.LineaTxt(utiles.espacios(26) + 'Retenci�n I.V.A.        :             ', False);
      list.ImporteTxt(totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      list.LineaTxt(utiles.espacios(26) + 'Total General           :             ', False);
      list.ImporteTxt(totales[1] + totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
    end;
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
  sm := 1;

  Buscar(protocolo);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesPorAdmisionValorizadas(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n Valorizadas
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c: Integer;
  codpacanter, admisionanter: String;
  monto: Real;
begin
  list.altopag := 0; list.m := 0;
  listdat := False; pag := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Ingresos por Admisi�n - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo2;
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  IniciarArreglos;
  solicitud.IndexFieldNames := 'codpac;admision';
  datosdb.Filtrar(solicitud, 'codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    //if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('admision').AsString) then Begin
    if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('protocolo').AsString) then Begin
      if (trim(solicitud.FieldByName('codpac').AsString) <> trim(codpacanter)) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Admisi�n Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
          list.Linea(40, list.Lineactual, 'Paciente: ' + paciente.nombre + ' [' + RI + ']', 2, 'Arial, negrita, 9, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo2;
          end;
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.LineaTxt(CHR18 + 'Admision Nro.: ' +  solicitud.FieldByName('admision').AsString + utiles.espacios(12 - (Length(Trim(solicitud.FieldByName('admision').AsString)))), False);
          list.LineaTxt('Paciente: ' + paciente.nombre + ' [' + RI + '] ' + CHR15, True);
          Inc(lineas); if controlarSalto then titulo2;
        end;

        admisionanter := solicitud.FieldByName('admision').AsString;
        codpacanter   := solicitud.FieldByName('codpac').AsString;
      end;

      det := setItems(solicitud.FieldByName('protocolo').AsString);

      profesional.getDatos(solicitud.FieldByName('idprof').AsString);
      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      listdat := True;
      totales[6] := 0;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'S');

        k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          list.Linea(k, t, objeto.Codigo, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, objeto.Codigo, Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
          totales[1] := totales[1] + monto;
          totales[6] := totales[6] + monto;
          list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
          c := c + 2;
          k := k + 15;
          if c > 10 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        // Agregamos el 9984
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          monto := totales[2];
          list.Linea(k, t, codftoma, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          totales[1] := totales[1] + monto;
          totales[6] := totales[6] + monto;
          list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
          //list.Linea(k + 14, t, FloatToStr(monto), c+1, 'Arial, cursiva, 8', salida, 'N');
          c := c + 2;
          k := k + 15;
          if c > 10 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;

      if (salida = 'T') then Begin
        list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 1, 5) + '      ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
        list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
        list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), True);

        k := 0; j := 0; t := 0; c := 1;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          list.LineaTxt(objeto.Codigo, False);

          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, objeto.Codigo, Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
          totales[1] := totales[1] + monto;
          totales[5] := totales[5] + monto;
          totales[6] := totales[6] + monto;
          list.importeTxt(monto, 10, 2, False);
          list.LineaTxt(' ', False);
          c := c + 1;
          if c > 5 then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo2;
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        // Agregamos el 9984
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          list.LineaTxt(codftoma, False);
          monto := totales[2];
          totales[1] := totales[1] + monto;
          totales[5] := totales[5] + monto;
          totales[6] := totales[6] + monto;
          list.importeTxt(monto, 10, 2, False);
          list.LineaTxt(' ', False);
          c := c + 2;
          k := k + 15;
          if c > 5 then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo2;
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        list.LineaTxt('', True);
        Inc(lineas); if controlarSalto then titulo2;
      end;

      if (obsocial.Retencioniva > 0) and (solicitud.FieldByName('retiva').AsString = 'S') then
        totales[3] := totales[3] + (totales[6] * (obsocial.Retencioniva * 0.01));
      totales[6] := 0;

      det.Free; det := Nil;

    end;

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  solicitud.IndexFieldNames := 'protocolo';

  if totales[1] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Subtotal Facturado:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Retenci�n I.V.A.:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Total General:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1] + totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
    end;

    if (salida = 'T') then Begin
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
      list.LineaTxt(utiles.espacios(26) + 'Subtotal Facturado      :             ', False);
      list.ImporteTxt(totales[1], 12, 2, True); Inc(lineas); if controlarSalto then titulo2;
      list.LineaTxt(utiles.espacios(26) + 'Retenci�n I.V.A.        :             ', False);
      list.ImporteTxt(totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo2;
      list.LineaTxt(utiles.espacios(26) + 'Total General           :             ', False);
      list.ImporteTxt(totales[1] + totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo2;
    end;
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);

  Buscar(protocolo);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesCodigosPorAdmision(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n Valorizadas
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c: Integer;
  codpacanter, admisionanter: String;
  monto: Real;
begin
  listdat := False; pag := 0;
  list.altopag := 0; list.m := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de C�digos por Admisi�n - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo2;
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  IniciarArreglos;
  solicitud.IndexFieldNames := 'codpac;admision';
  datosdb.Filtrar(solicitud, 'codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    //if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('admision').AsString) then Begin
    if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('protocolo').AsString) then Begin
      if (trim(solicitud.FieldByName('codpac').AsString) <> trim(codpacanter)) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Admisi�n Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
          list.Linea(40, list.Lineactual, 'Paciente: ' + paciente.nombre + ' [' + RI + ']', 2, 'Arial, negrita, 9, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo2;
          end;
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.LineaTxt(CHR18 + 'Admision Nro.: ' +  solicitud.FieldByName('admision').AsString + utiles.espacios(12 - (Length(Trim(solicitud.FieldByName('admision').AsString)))), False);
          list.LineaTxt('Paciente: ' + paciente.nombre + ' [' + RI + ']' + CHR15, True);
          Inc(lineas); if controlarSalto then titulo2;
        end;

        admisionanter := solicitud.FieldByName('admision').AsString;
        codpacanter   := solicitud.FieldByName('codpac').AsString;
      end;

      det := setItems(solicitud.FieldByName('protocolo').AsString);

      profesional.getDatos(solicitud.FieldByName('idprof').AsString);
      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      listdat := True;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'S');

        k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          list.Linea(k, t, objeto.Codigo, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := 0;
          list.importe(k + 14, t, '#', monto, c + 1, 'Arial, cursiva, 8');
          c := c + 2;
          k := k + 10;
          if c > 20 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        // Agregamos el 9984
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          list.Linea(k, t, codftoma, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := 0;
          list.importe(k + 14, t, '#', monto, c + 1, 'Arial, cursiva, 8');
          c := c + 2;
          k := k + 10;
          if c > 20 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;

      if (salida = 'T') then Begin
        list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 1, 5) + '      ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
        list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
        list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), True);

        k := 0; j := 0; t := 0; c := 1;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          list.LineaTxt(objeto.Codigo, False);

          monto := 0;
          totales[1] := totales[1] + monto;
          totales[5] := totales[5] + monto;
          list.LineaTxt('  ', False);
          c := c + 1;
          if c > 10 then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo2;
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        // Agregamos el 9984
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          list.LineaTxt(codftoma, False);
          monto := 0;
          list.LineaTxt('  ', False);
          c := c + 2;
          k := k + 15;
          if c > 10 then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo2;
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        det.Free; det := Nil;

        list.LineaTxt('', True);
        Inc(lineas); if controlarSalto then titulo2;
      end;

    end;

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  solicitud.IndexFieldNames := 'protocolo';

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);

  Buscar(protocolo);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesValorizadasPorObraSocial(xcodsan, xcodos, xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n Valorizadas
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c, cantpacientes, id: Integer;
  codpacanter, admisionanter, cod: String;
  monto: Real;

  procedure addCod(xcodigo, xcodos: string; xmonto: real);
  begin
    id := id + 1;
    datosdb.tranSQL('insert into estadisticas (id, codigo, monto, codos) values (' + inttostr(id) + ', ' + '''' + xcodigo + '''' + ', ' + utiles.StringRemplazarCaracteres( utiles.FormatearNumero(floattostr(xmonto), '##.##'), ',', '.') + ', ' + '''' + xcodos + '''' + ')');
  end;

  procedure addCodigo(xcodigo: string);
  var
    i: integer;
    f: boolean;
    c: string;
  begin
    c := refinosag.getCodigoInverso(xcodigo);
    if (c = '') then exit;

    f := false;
    for i := 1 to __codigos.Count do begin
      if (__codigos[i-1] = c) then begin
        f := true;
        break;
      end;
    end;

    if not (f) then __codigos.Add(c);
  end;

  procedure listarCodigos;
  var
    i: integer;
  begin
    k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
    For i := 1 to __codigos.Count do Begin
      objeto := TTSolicitudAnalisisFabrissinInternacion(__codigos[i-1]);
      __c := nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, __codigos[i-1]);
      if ( __c = '') then  __c := '* ' + __codigos[i-1];

      list.Linea(k, t, __c, c, 'Arial, cursiva, 8', salida, 'N');
      t := list.Lineactual;
      monto := setValorAnalisis(ressql.FieldByName('codos').AsString, __codigos[i-1], Copy(ressql.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(ressql.FieldByName('fecha').AsString, 1, 4));
      totales[1] := totales[1] + monto;
      list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
      c := c + 2;
      k := k + 15;
      if c > 10 then Begin
        list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
        k := 0; j := 0; t := 0; c := 1;
      end;

       if (salida = 'N') then addCod(__c, xcodos, monto);
    End;
    __codigos.Clear;
  end;

begin
  if (salida = 'N') then begin
    datosdb.tranSQL('delete from estadisticas');
    refinosag.conectar;
  end;

  listdat := False; pag := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Ingresos por Obra Social - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    obsocial.getDatos(xcodos);
    List.Titulo(0, 0, 'Obra Social: ' + obsocial.nombre, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo3(xcodos);
  end;

  IniciarArreglos;
  ressql := datosdb.tranSQL('select * from solicitudint where codsan = ' + '''' + xcodsan + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by codsan, codos, fecha');
  ressql.Open;
  while not ressql.Eof do Begin
    if (ressql.FieldByName('codpac').AsString <> codpacanter) or (ressql.FieldByName('admision').AsString <> admisionanter) then Begin
      paciente.getDatos(ressql.FieldByName('codpac').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        if (length(trim(ressql.FieldByName('retiva').AsString)) > 0) then RI := ressql.FieldByName('retiva').AsString else RI := 'N';
        list.Linea(0, 0, 'Admisi�n Nro.: ' + ressql.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
        list.Linea(40, list.Lineactual, 'Paciente: ' + paciente.nombre + ' [' + RI + ']', 2, 'Arial, negrita, 9, clNavy', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if (salida = 'T') then Begin
        if listdat then Begin
          list.LineaTxt(' ', True);
          Inc(lineas); if controlarSalto then titulo3(xcodos);
        end;
        list.LineaTxt(CHR18 + 'Admision Nro.: ' +  ressql.FieldByName('admision').AsString + utiles.espacios(12 - (Length(Trim(ressql.FieldByName('admision').AsString)))), False);
        if (length(trim(ressql.FieldByName('retiva').AsString)) > 0) then RI := ressql.FieldByName('retiva').AsString else RI := 'N';
        list.LineaTxt('Paciente: ' + paciente.nombre + ' [' + RI + ']' + CHR15, True);
        Inc(lineas); if controlarSalto then titulo3(xcodos);
      end;

      admisionanter := ressql.FieldByName('admision').AsString;
      codpacanter   := ressql.FieldByName('codpac').AsString;
    end;

    det := setItems(ressql.FieldByName('protocolo').AsString);

    profesional.getDatos(ressql.FieldByName('idprof').AsString);
    obsocial.getDatos(ressql.FieldByName('codos').AsString);
    listdat := True;

    if (salida = 'P') or (salida = 'I') or (salida = 'N') then Begin
      list.Linea(0, 0, Copy(ressql.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(10, list.Lineactual, utiles.sFormatoFecha(ressql.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
      list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
      list.Linea(77, list.Lineactual, Copy(ressql.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'S');

      k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
      For i := 1 to det.Count do Begin
        objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);

        if (obsocial.getOSDiferencial(ressql.FieldByName('codos').AsString) <> '') then begin
          __c := nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, objeto.Codigo);
          if ( __c = '') then  __c := '* ' + objeto.Codigo;
        end else
          __c := objeto.Codigo;
        //cod := refinosag.getCodigoInverso(objeto.Codigo);
        //if (cod = '') then
        cod := objeto.Codigo;

        if (refinosag.getCodigoInverso(objeto.Codigo) <> '') then __c := '-';

        // 01/12/2015 - No mostramos los codifgos dependientes
        if (__c <> '-') then begin

          list.Linea(k, t, __c, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;

          monto := setValorAnalisis(ressql.FieldByName('codos').AsString, cod, Copy(ressql.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(ressql.FieldByName('fecha').AsString, 1, 4));
          //if (refinosag.getCodigoInverso(objeto.Codigo) <> '') then monto := 0;

          totales[1] := totales[1] + monto;
          list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
          c := c + 2;
          k := k + 15;
          if c > 10 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;

          if (salida = 'N') then addCod(__c, xcodos, monto);
        end;

        addCodigo(objeto.Codigo);

      end;

      det.Free; det := Nil;

      listarCodigos();  // Equivalencias

      // Agregamos el 9984
      if (obsocial.Factnbu <> 'S') then begin
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          list.Linea(k, t, codftoma, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := totales[2];
          totales[1] := totales[1] + monto;
          list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
          c := c + 2;
          k := k + 15;
          if c > 10 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;
      end;

      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;

    if (salida = 'T') then Begin
      list.LineaTxt(Copy(ressql.FieldByName('protocolo').AsString, 6, 5) + '      ' + utiles.sFormatoFecha(ressql.FieldByName('fecha').AsString) + ' ', False);
      list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
      list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
      list.LineaTxt(Copy(ressql.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(ressql.FieldByName('habitacion').AsString)))), True);

      k := 0; j := 0; t := 0; c := 1;
      For i := 1 to det.Count do Begin
        objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
        list.LineaTxt(objeto.Codigo, False);

        monto := setValorAnalisis(ressql.FieldByName('codos').AsString, objeto.Codigo, Copy(ressql.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(ressql.FieldByName('fecha').AsString, 1, 4));
        totales[1] := totales[1] + monto;
        totales[5] := totales[5] + monto;
        list.importeTxt(monto, 10, 2, False);
        list.LineaTxt(' ', False);
        c := c + 1;
        if c > 5 then Begin
          list.LineaTxt('', True);
          Inc(lineas); if controlarSalto then titulo3(xcodos);
          k := 0; j := 0; t := 0; c := 1;
        end;
      end;

      det.Free; det := Nil;

      // Agregamos el 9984
      if (obsocial.Factnbu = 'S') then begin
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          list.LineaTxt(codftoma, False);
          monto := totales[2];
          totales[1] := totales[1] + monto;
          totales[5] := totales[5] + monto;
          list.importeTxt(monto, 10, 2, False);
          list.LineaTxt(' ', False);
          c := c + 2;
          k := k + 15;
          if c > 5 then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo3(xcodos);
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;
      end;

      list.LineaTxt('', True);
      Inc(lineas); if controlarSalto then titulo3(xcodos);
    end;

    if (obsocial.Retencioniva > 0) and (ressql.FieldByName('retiva').AsString = 'S') then Begin
      totales[4] := ((totales[5] + totales[2]) * (obsocial.Retencioniva * 0.01));
      totales[3] := totales[3] + totales[4];
    end;

    ressql.Next;
  end;
  ressql.close; ressql.free;

  ressql := datosdb.tranSQL('select distinct(codpac) from solicitudint where codsan = ' + '''' + xcodsan + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by codsan, codos, fecha');
  ressql.Open;
  cantpacientes := ressql.RecordCount;
  ressql.Close; ressql.Free;

  if totales[1] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Cantidad de Pacientes:', 2, 'Arial, normal, 10');
      list.derecha(94, list.Lineactual, '', FloatToStr(cantpacientes), 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Subtotal Facturado:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Retenci�n I.V.A.:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Total General:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1] + totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
    end;

    if (salida = 'T') then Begin
      list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
      list.LineaTxt(utiles.espacios(26) + 'Subtotal Facturado      :             ', False);
      list.ImporteTxt(totales[1], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      list.LineaTxt(utiles.espacios(26) + 'Retenci�n I.V.A.        :             ', False);
      list.ImporteTxt(totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      list.LineaTxt(utiles.espacios(26) + 'Total General           :             ', False);
      list.ImporteTxt(totales[1] + totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
    end;
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarCodigosSolicitudesPorObraSocial(xcodsan, xcodos, xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n Valorizadas
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c, cantpacientes: Integer;
  codpacanter, admisionanter, cod: String;
  monto: Real;

  procedure addCodigo(xcodigo: string);
  var
    i: integer;
    f: boolean;
    c: string;
  begin
    c := refinosag.getCodigoInverso(xcodigo);
    if (c = '') then exit;

    f := false;
    for i := 1 to __codigos.Count do begin
      if (__codigos[i-1] = c) then begin
        f := true;
        break;
      end;
    end;

    if not (f) then __codigos.Add(c);
  end;

  procedure listarCodigos;
  var
    i: integer;
  begin
    k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
    For i := 1 to __codigos.Count do Begin
      objeto := TTSolicitudAnalisisFabrissinInternacion(__codigos[i-1]);
      __c := nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, __codigos[i-1]);
      if ( __c = '') then  __c := '* ' + __codigos[i-1];

      list.Linea(k, t, __c, c, 'Arial, cursiva, 8', salida, 'N');
      t := list.Lineactual;
      monto := setValorAnalisis(ressql.FieldByName('codos').AsString, __codigos[i-1], Copy(ressql.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(ressql.FieldByName('fecha').AsString, 1, 4));
      totales[1] := totales[1] + monto;
      list.linea(k + 14, t, '', c + 1, 'Arial, cursiva, 8', salida, 'N');
      c := c + 2;
      k := k + 15;
      if c > 10 then Begin
        list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
        k := 0; j := 0; t := 0; c := 1;
      end;
    End;
    __codigos.Clear;
  end;

begin
  listdat := False; pag := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Ingresos por Obra Social - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    obsocial.getDatos(xcodos);
    List.Titulo(0, 0, 'Obra Social: ' + obsocial.nombre, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo3(xcodos);
  end;

  IniciarArreglos;
  ressql := datosdb.tranSQL('select * from solicitudint where codsan = ' + '''' + xcodsan + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by codsan, codos, fecha');
  ressql.Open;
  while not ressql.Eof do Begin
    if (ressql.FieldByName('codpac').AsString <> codpacanter) or (ressql.FieldByName('admision').AsString <> admisionanter) then Begin
      paciente.getDatos(ressql.FieldByName('codpac').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
        list.Linea(0, 0, 'Admisi�n Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
        list.Linea(30, list.Lineactual, 'Paciente: ' + paciente.nombre + ' [' + RI + ']', 2, 'Arial, negrita, 9, clNavy', salida, 'N');
        list.Linea(70, list.Lineactual, 'Nro.Doc.: ' + paciente.Nrodoc + ' Nro.Af.: ' + paciente.Idbeneficio, 3, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;

      admisionanter := ressql.FieldByName('admision').AsString;
      codpacanter   := ressql.FieldByName('codpac').AsString;
    end;

    det := setItems(ressql.FieldByName('protocolo').AsString);

    profesional.getDatos(ressql.FieldByName('idprof').AsString);
    obsocial.getDatos(ressql.FieldByName('codos').AsString);
    listdat := True;

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, Copy(ressql.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(10, list.Lineactual, utiles.sFormatoFecha(ressql.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
      list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
      list.Linea(77, list.Lineactual, Copy(ressql.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'S');

      k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
      For i := 1 to det.Count do Begin
        objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);

        if (obsocial.getOSDiferencial(ressql.FieldByName('codos').AsString) <> '') then begin
          __c := nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, objeto.Codigo);
          if ( __c = '') then  __c := '* ' + objeto.Codigo;
        end else
          __c := objeto.Codigo;
        //cod := refinosag.getCodigoInverso(objeto.Codigo);
        //if (cod = '') then
        cod := objeto.Codigo;

        if (refinosag.getCodigoInverso(objeto.Codigo) <> '') then __c := '-';

        // 01/12/2015 - No mostramos los codifgos dependientes
        if (__c <> '-') then begin

          list.Linea(k, t, __c, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;

          monto := setValorAnalisis(ressql.FieldByName('codos').AsString, cod, Copy(ressql.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(ressql.FieldByName('fecha').AsString, 1, 4));
          if (refinosag.getCodigoInverso(objeto.Codigo) <> '') then monto := 0;

          totales[1] := totales[1] + monto;
          list.Linea(k + 14, t, '', c + 1, 'Arial, cursiva, 8', salida, 'N');
          c := c + 2;
          k := k + 10;
          if c > 30 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;

        end;

        addCodigo(objeto.Codigo);

      end;

      det.Free; det := Nil;

      listarCodigos();  // Equivalencias

      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;

    ressql.Next;
  end;
  ressql.close; ressql.free;

  ressql := datosdb.tranSQL('select distinct(codpac) from solicitudint where codsan = ' + '''' + xcodsan + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by codsan, codos, fecha');
  ressql.Open;
  cantpacientes := ressql.RecordCount;
  ressql.Close; ressql.Free;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
    list.derecha(60, list.Lineactual, '', 'Cantidad de Pacientes:', 2, 'Arial, normal, 10');
    list.derecha(94, list.Lineactual, '', FloatToStr(cantpacientes), 3, 'Arial, normal, 10');
    list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;


{
procedure TTSolicitudAnalisisFabrissinInternacion.ListarCodigosSolicitudesPorObraSocial(xcodsan, xcodos, xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n Valorizadas
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c, cantidadpacientes: Integer;
  codpacanter, admisionanter, __c: String;
  monto: Real;

  procedure addCodigo(xcodigo: string);
  var
    i: integer;
    f: boolean;
    c: string;
  begin
    c := refinosag.getCodigoInverso(xcodigo);
    if (c = '') then exit;

    f := false;
    for i := 1 to __codigos.Count do begin
      if (__codigos[i-1] = c) then begin
        f := true;
        break;
      end;
    end;

    if not (f) then __codigos.Add(c);
  end;

  procedure listarCodigos;
  var
    i: integer;
  begin
    k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
    For i := 1 to __codigos.Count do Begin
      objeto := TTSolicitudAnalisisFabrissinInternacion(__codigos[i-1]);
      __c := nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, __codigos[i-1]);
      if ( __c = '') then  __c := '* ' + __codigos[i-1];

      utiles.msgerror(__c);

      list.Linea(k, t, __c, c, 'Arial, cursiva, 8', salida, 'N');
      t := list.Lineactual;
      monto := setValorAnalisis(ressql.FieldByName('codos').AsString, __codigos[i-1], Copy(ressql.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(ressql.FieldByName('fecha').AsString, 1, 4));
      totales[1] := totales[1] + monto;
      list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
      c := c + 2;
      k := k + 15;
      if c > 10 then Begin
        list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
        k := 0; j := 0; t := 0; c := 1;
      end;
    End;
    __codigos.Clear;
  end;

begin
  listdat := False; pag := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Ingresos por Obra Social - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    obsocial.getDatos(xcodos);
    List.Titulo(0, 0, 'Obra Social: ' + obsocial.nombre, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo3(xcodos);
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  IniciarArreglos;
  solicitud.IndexFieldNames := 'codsan;codos;fecha';
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
      paciente.getDatos(solicitud.FieldByName('codpac').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
        list.Linea(0, 0, 'Admisi�n Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
        list.Linea(30, list.Lineactual, 'Paciente: ' + paciente.nombre + ' [' + RI + ']', 2, 'Arial, negrita, 9, clNavy', salida, 'N');
        list.Linea(70, list.Lineactual, 'Nro.Doc.: ' + paciente.Nrodoc + ' Nro.Af.: ' + paciente.Idbeneficio, 3, 'Arial, negrita, 9', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if (salida = 'T') then Begin
        if listdat then Begin
          list.LineaTxt(' ', True);
          Inc(lineas); if controlarSalto then titulo3(xcodos);
        end;
        list.LineaTxt(CHR18 + 'Admision Nro.: ' +  solicitud.FieldByName('admision').AsString + utiles.espacios(12 - (Length(Trim(solicitud.FieldByName('admision').AsString)))), False);
        if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
        list.LineaTxt('Paciente: ' + paciente.nombre + ' [' + RI + ']' + CHR15, True);
        Inc(lineas); if controlarSalto then titulo3(xcodos);
      end;

      admisionanter := solicitud.FieldByName('admision').AsString;
      codpacanter   := solicitud.FieldByName('codpac').AsString;
    end;

    det := setItems(solicitud.FieldByName('protocolo').AsString);

    profesional.getDatos(solicitud.FieldByName('idprof').AsString);
    obsocial.getDatos(solicitud.FieldByName('codos').AsString);
    listdat := True;

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
      list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
      list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'S');

      k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
      For i := 1 to det.Count do Begin
        objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
        __c := nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, objeto.Codigo);
        if ( __c = '') then  __c := '* ' + objeto.Codigo;

        if (refinosag.getCodigoInverso(objeto.Codigo) <> '') then __c := '-';

        // 01/12/2015 - No mostramos los codifgos dependientes
        if (__c <> '-') then begin

          list.Linea(k, t, __c, c, 'Arial, cursiva, 8', salida, 'N');
          c := c + 1;
          k := k + 10;
          if (c > 1) then t := list.Lineactual;
          if c > 10 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
        end;

        addCodigo(objeto.Codigo);

      end;

      end;

      listarCodigos;

      det.Free; det := Nil;

      //list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;
    list.Linea(k+1, 90, '', c+1, 'Arial, cursiva, 8', salida, 'S');





    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  solicitud.IndexFieldNames := 'protocolo';



  ressql := datosdb.tranSQL('select distinct(codpac) from solicitudint where codsan = ' + '''' + xcodsan + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by codsan, codos, fecha');
  ressql.Open;
  cantidadpacientes := ressql.RecordCount;
  ressql.Close; ressql.Free;

  list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
  list.derecha(60, list.Lineactual, '', 'Cantidad de Pacientes:', 2, 'Arial, normal, 10');
  list.derecha(94, list.Lineactual, '', FloatToStr(cantidadpacientes), 3, 'Arial, normal, 10');
  list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);

  Buscar(protocolo);
end;
}

procedure TTSolicitudAnalisisFabrissinInternacion.titulo3(xcodos: String);
var
  i, j: Integer;
Begin
  Inc(pag);
  list.LineaTxt(CHR18 + '  ', true);
  List.LineaTxt(TrimLeft(titulo) + CHR15, True);
  j := 0;
  For i := 1 to subtitulo.Count do Begin
    Inc(j);
    List.LineaTxt(TrimLeft(subtitulo.Strings[i-1]), True);
  end;
  list.LineaTxt(CHR18 + ' ', true);
  list.LineaTxt('Planilla de Ingresos por Admision' + utiles.espacios(30) + 'Hoja Nro.: ' + IntToStr(pag), true);
  list.LineaTxt('Sanatorio: ' + sanatorio.Descrip, true);
  obsocial.getDatos(xcodos);
  list.LineaTxt('Obra Social: ' + obsocial.nombre, true);
  list.LineaTxt(' ', true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  list.LineaTxt('Protocolo  Fecha    Medico                     Obra Social                     Habitacion      Codigos' + CHR18, true);
  list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
  lineas := 10 + j;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesValorizadasPorFechaFacturacion(xcodsan, xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n Valorizadas
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c: Integer;
  codpacanter, admisionanter: String;
  monto: Real;

  //----------------------------------------------------------------------------

  procedure ListarTotalAdmision(salida: char);
  Begin
    if totales[9] >= 0 then Begin
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        list.Linea(0, 0, 'Subtotal Adm.:', 1, 'Arial, negrita, 8', salida, 'N');
        list.importe(25, list.Lineactual, '', totales[9], 2, 'Arial, negrita, 8');
        list.Linea(30, list.Lineactual, 'Ret. I.V.A.:', 3, 'Arial, negrita, 8', salida, 'S');
        list.importe(55, list.Lineactual, '', totales[10], 4, 'Arial, negrita, 8');
        list.Linea(70, list.Lineactual, 'Total Adm.:', 5, 'Arial, negrita, 8', salida, 'S');
        list.importe(95, list.Lineactual, '', totales[9] + totales[10], 6, 'Arial, negrita, 8');
        list.Linea(96, list.Lineactual, '', 7, 'Arial, negrita, 8', salida, 'S');
        list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;

      if (salida = 'T') then Begin
        list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
        Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
        list.LineaTxt(CHR18 + 'Subtotal Adm.: ', False);
        list.ImporteTxt(totales[9], 12, 2, False);
        list.LineaTxt('  Ret. I.V.A.: ', False);
        list.ImporteTxt(totales[10], 12, 2, False);
        list.LineaTxt('  Total Adm.: ', False);
        list.ImporteTxt(totales[9] + totales[10], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
        list.LineaTxt(CHR18 + utiles.sLlenarIzquierda(lin, 80, Caracter), True);
        Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      end;

      totales[9] := 0; totales[10] := 0;
    end;
  end;
  //----------------------------------------------------------------------------

begin
  listdat := False; pag := 0;
  sanatorio.getDatos(xcodsan);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  solicitud.IndexFieldNames := 'codpac;admision';

  IniciarArreglos;
  admisionanter := ''; codpacanter := '';

  datosdb.Filtrar(admisiones, 'fechafact >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechafact <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  admisiones.First;
  while not admisiones.Eof do Begin
    datosdb.Filtrar(solicitud, 'admision = ' + '''' + admisiones.FieldByName('admision').AsString + '''');
    solicitud.First;
    while not solicitud.Eof do Begin
      if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        if Length(Trim(admisionanter)) > 0 then ListarTotalAdmision(salida);
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        obsocial.getDatos(solicitud.FieldByName('codos').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Adm.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 8, clNavy', salida, 'N');
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.Linea(20, list.Lineactual, Copy(paciente.nombre, 1, 22) + ' [' + RI + ']', 2, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(60, list.Lineactual, 'In./Eg./Fact.: ' + utiles.sFormatoFecha(admisiones.FieldByName('fealta').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('febaja').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('fechafact').AsString), 3, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
          end;
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.LineaTxt(CHR18 + 'Adm.: ' +  solicitud.FieldByName('admision').AsString + ' ' + Copy(paciente.nombre, 1, 16) + ' [' + RI + ']' + utiles.espacios(32 - (Length(Trim(solicitud.FieldByName('admision').AsString + Copy(paciente.nombre, 1, 20))))), False);
          list.LineaTxt('In./En./Fa.: ' + utiles.sFormatoFecha(admisiones.FieldByName('fealta').AsString) + ' ' + utiles.sFormatoFecha(admisiones.FieldByName('febaja').AsString) + ' ' + utiles.sFormatoFecha(admisiones.FieldByName('fechafact').AsString) + CHR15, True);
          Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
        end;

        admisionanter := solicitud.FieldByName('admision').AsString;
        codpacanter   := solicitud.FieldByName('codpac').AsString;
      end;

      det := setItems(solicitud.FieldByName('protocolo').AsString);

      profesional.getDatos(solicitud.FieldByName('idprof').AsString);
      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      listdat := True;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'N');

        k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          list.Linea(k, t, objeto.Codigo, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, objeto.Codigo, Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
          totales[1] := totales[1] + monto;
          totales[9] := totales[9] + monto;
          list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
          c := c + 2;
          k := k + 15;
          if c > 10 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        det.Free; det := Nil;

        // Agregamos el 9984
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          list.Linea(k, t, codftoma, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := totales[2];
          totales[1] := totales[1] + monto;
          totales[9] := totales[9] + monto;
          list.importe(k + 14, t, '', monto, c + 1, 'Arial, cursiva, 8');
          c := c + 2;
          k := k + 15;
          if c > 10 then Begin
            list.Linea(k+1, t, '', c+1, 'Arial, cursiva, 8', salida, 'S');
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;

      if (salida = 'T') then Begin
        list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + '      ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
        list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
        list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), True);

        k := 0; j := 0; t := 0; c := 1;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          list.LineaTxt(objeto.Codigo, False);

          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, objeto.Codigo, Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
          totales[1] := totales[1] + monto;
          totales[5] := totales[5] + monto;
          totales[9] := totales[9] + monto;
          list.importeTxt(monto, 10, 2, False);
          list.LineaTxt(' ', False);
          c := c + 1;
          if c > 5 then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        det.Free; det := Nil;

        // Agregamos el 9984
        totales[2] := Total9984;
        if totales[2] > 0 then Begin
          list.LineaTxt(codftoma, False);
          monto := totales[2];
          totales[1] := totales[1] + monto;
          totales[5] := totales[5] + monto;
          totales[9] := totales[9] + monto;
          list.importeTxt(monto, 10, 2, False);
          list.LineaTxt(' ', False);
          c := c + 2;
          k := k + 15;
          if c > 5 then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
            k := 0; j := 0; t := 0; c := 1;
          end;
        end;

        list.LineaTxt('', True);
        Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
      end;

      if (obsocial.Retencioniva > 0) and (solicitud.FieldByName('retiva').AsString = 'S') then Begin
        totales[4]  := ((totales[5] + totales[2]) * (obsocial.Retencioniva * 0.01));
        totales[3]  := totales[3] + totales[4];
        totales[9]  := ((totales[5] + totales[2]) * (obsocial.Retencioniva * 0.01));
        totales[10] := totales[10] + totales[9];
      end;

      solicitud.Next;
    end;
    datosdb.QuitarFiltro(solicitud);
    solicitud.IndexFieldNames := 'protocolo';

    admisiones.Next;
  end;

  datosdb.QuitarFiltro(admisiones);

  ListarTotalAdmision(salida);

  if totales[1] > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 9', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Subtotal Facturado:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Retenci�n I.V.A.:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'N');
      list.derecha(60, list.Lineactual, '', 'Total General:', 2, 'Arial, normal, 10');
      list.importe(95, list.Lineactual, '', totales[1] + totales[3], 3, 'Arial, normal, 10');
      list.Linea(96, list.Lineactual, '', 4, 'Arial, normal, 10', salida, 'S');
    end;

    if (salida = 'T') then Begin
      list.LineaTxt(utiles.espacios(26) + 'Subtotal Facturado      :             ', False);
      list.ImporteTxt(totales[1], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      list.LineaTxt(utiles.espacios(26) + 'Retenci�n I.V.A.        :             ', False);
      list.ImporteTxt(totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      list.LineaTxt(utiles.espacios(26) + 'Total General           :             ', False);
      list.ImporteTxt(totales[1] + totales[3], 12, 2, True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
    end;
  end;

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);

  Buscar(protocolo);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesValorizadasPorFechaFacturacionResumidas(xcodsan, xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n Valorizadas
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t, c: Integer;
  codpacanter, admisionanter: String;
  monto: Real;
begin
  listdat := False; pag := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  solicitud.IndexFieldNames := 'codpac;admision';

  IniciarArreglos;
  datosdb.Filtrar(admisiones, 'fechafact >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fechafact <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  admisiones.First;
  while not admisiones.Eof do Begin
    datosdb.Filtrar(solicitud, 'admision = ' + '''' + admisiones.FieldByName('admision').AsString + '''');
    solicitud.First;
    while not solicitud.Eof do Begin
      if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        obsocial.getDatos(solicitud.FieldByName('codos').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Adm.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 8, clNavy', salida, 'N');
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.Linea(20, list.Lineactual, Copy(paciente.nombre, 1, 25) + ' [' + RI + ']', 2, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(60, list.Lineactual, 'In./Eg./Fact.: ' + utiles.sFormatoFecha(admisiones.FieldByName('fealta').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('febaja').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('fechafact').AsString), 3, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
          end;
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.LineaTxt(CHR18 + 'Adm.: ' +  solicitud.FieldByName('admision').AsString + ' ' + Copy(paciente.nombre, 1, 16) + ' [' + RI + '] ' + utiles.espacios(32 - (Length(Trim(solicitud.FieldByName('admision').AsString + Copy(paciente.nombre, 1, 20))))), False);
          list.LineaTxt('In./En./Fa.: ' + utiles.sFormatoFecha(admisiones.FieldByName('fealta').AsString) + ' ' + utiles.sFormatoFecha(admisiones.FieldByName('febaja').AsString) + ' ' + utiles.sFormatoFecha(admisiones.FieldByName('fechafact').AsString) + CHR15, True);
          Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
        end;

        admisionanter := solicitud.FieldByName('admision').AsString;
        codpacanter   := solicitud.FieldByName('codpac').AsString;
      end;

      det := setItems(solicitud.FieldByName('protocolo').AsString);

      profesional.getDatos(solicitud.FieldByName('idprof').AsString);
      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      listdat := True;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, normal, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, normal, 8', salida, 'N');

        k := 6; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'N') else Begin
            list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'S');
            if i < det.Count then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

        det.Free; det := Nil;

        if k <> 1 then list.Linea(97, list.Lineactual, '', k+1, 'Arial, normal, 8', salida, 'S');
      end;

      if (salida = 'T') then Begin
        list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + '      ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
        list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
        list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), False);

        k := 5; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.LineaTxt(objeto.Codigo + ' ', False) else Begin
            list.LineaTxt(objeto.Codigo + ' ', True);
            k := 1;
            if i < det.Count then Begin
              list.LineaTxt(utiles.espacios(107), False);
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

        if k <> 1 then list.LineaTxt('', True);

        Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      end;

      solicitud.Next;
   end;
   datosdb.QuitarFiltro(solicitud);
   solicitud.IndexFieldNames := 'protocolo';

   admisiones.Next;
  end;

  datosdb.QuitarFiltro(admisiones);

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);

  Buscar(protocolo);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarCodigosSolicitudes(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
// Objetivo...: Listar Solicitudes por Admisi�n
var
  det: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
  i, j, k, t: Integer;
  codpacanter, admisionanter: String;
begin
  listdat := False; pag := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    sanatorio.getDatos(xcodsan);
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    For i := 1 to subtitulo.Count do
      List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Planilla de Ingresos por Admisi�n - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'M�dico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitaci�n', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'C�digos', 6, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo2;
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  solicitud.IndexFieldNames := 'codpac;admision';
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('admision').AsString) then Begin
      if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Admisi�n Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.Linea(40, list.Lineactual, 'Paciente: ' + paciente.nombre + ' [' + RI + ']', 2, 'Arial, negrita, 9, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo2;
          end;
          list.LineaTxt(CHR18 + 'Admision Nro.: ' +  solicitud.FieldByName('admision').AsString + utiles.espacios(12 - (Length(Trim(solicitud.FieldByName('admision').AsString)))), False);
          if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
          list.LineaTxt('Paciente: ' + paciente.nombre + ' [' + RI + ']' + CHR15, True);
          Inc(lineas); if controlarSalto then titulo2;
        end;

        admisionanter := solicitud.FieldByName('admision').AsString;
        codpacanter   := solicitud.FieldByName('codpac').AsString;
      end;

      det := setItems(solicitud.FieldByName('protocolo').AsString);

      profesional.getDatos(solicitud.FieldByName('idprof').AsString);
      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      listdat := True;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, solicitud.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, normal, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, normal, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, normal, 8', salida, 'N');
        k := 5; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          objeto := TTSolicitudAnalisisFabrissinInternacion(det.Items[i-1]);
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'N') else Begin
            list.Linea(75 + j, list.Lineactual, objeto.Codigo, k, 'Arial, normal, 8', salida, 'S');
            if i < det.Count then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

        det.Free; det := Nil;

        if k <> 1 then list.Linea(97, list.Lineactual, '', k+1, 'Arial, normal, 8', salida, 'S');

      end;

      if (salida = 'T') then Begin
        list.LineaTxt(solicitud.FieldByName('protocolo').AsString + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
        list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
        list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), False);
        k := 4; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.LineaTxt(objeto.Codigo + ' ', False) else Begin
            list.LineaTxt(objeto.Codigo + ' ', True);
            k := 1;
            if i < det.Count then Begin
              list.LineaTxt(utiles.espacios(107), False);
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

        if k <> 1 then list.LineaTxt('', True);
        Inc(lineas); if controlarSalto then titulo2;
      end;
    end;

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  solicitud.IndexFieldNames := 'protocolo';

  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);

  solicitud.IndexFieldNames := 'protocolo';
  Buscar(protocolo);
end;

//------------------------------------------------------------------------------

function TTSolicitudAnalisisFabrissinInternacion.BuscarResultado(xprotocolo, xcodanalisis, xitems: String): Boolean;
// Objetivo...: Buscar una instancia perteneciente a resultados de un an�lisis
begin
  if resultado.IndexFieldNames <> 'protocolo;codanalisis;items' then resultado.IndexFieldNames := 'protocolo;codanalisis;items';
  Result := datosdb.Buscar(resultado, 'protocolo', 'codanalisis', 'items', xprotocolo, xcodanalisis, xitems);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.GuardarResultado(xprotocolo, xcodanalisis, xitems, xresultado, xvaloresn, xnroanalisis: string; xcantidaditems: Integer);
// Objetivo...: Almacenar las instancias pertenecientes a los resultados de un an�lisis
begin
  if BuscarResultado(xprotocolo, xcodanalisis, xitems) then resultado.Edit else resultado.Append;
  resultado.FieldByName('protocolo').AsString    := xprotocolo;
  resultado.FieldByName('codanalisis').AsString  := xcodanalisis;
  resultado.FieldByName('items').AsString        := xitems;
  resultado.FieldByName('resultado').AsString    := xresultado;
  resultado.FieldByName('valoresn').AsString     := xvaloresn;
  resultado.FieldByName('nroanalisis').AsString  := xnroanalisis;
  try
    resultado.Post
  except
    resultado.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantidaditems), 2, '0') then Begin
    datosdb.tranSQL('delete from ' + resultado.TableName + ' where protocolo = ' + '"' + xprotocolo + '"' + ' and codanalisis = ' + '"' + xcodanalisis + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantidaditems), 2, '0') + '"');
    //datosdb.closedb(resultado); resultado.Open;
    datosdb.refrescar(resultado);
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarResultado(xprotocolo: string);
// Objetivo...: Borrar las instancias pertenecientes a los resultados de un an�lisis
begin
  datosdb.tranSQL('delete from ' + resultado.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.tranSQL('delete from ' + obsitems.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.tranSQL('delete from ' + obsfinal.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.refrescar(resultado);
  datosdb.refrescar(obsitems);
  datosdb.refrescar(obsfinal);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarResultadoDeterminacion(xprotocolo, xcodanalisis: string);
// Objetivo...: Borrar las instancias pertenecientes a los resultados de un an�lisis
begin
  datosdb.tranSQL('delete from ' + resultado.TableName + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and codanalisis = ' + '''' + xcodanalisis + '''');
  datosdb.tranSQL('delete from ' + obsitems.TableName + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and codanalisis = ' + '''' + xcodanalisis + '''');
  datosdb.refrescar(resultado);
  datosdb.refrescar(obsitems);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getResultado(xprotocolo, xcodanalisis, xitems: String);
// Objetivo...: Recuperar una instancia de protocolos
Begin
  if BuscarResultado(xprotocolo, xcodanalisis, xitems) then Begin
    Resultado_Analisis   := resultado.FieldByName('resultado').AsString;
  end else Begin
    Resultado_Analisis   := '';
  end;
end;

function  TTSolicitudAnalisisFabrissinInternacion.BuscarObservacionItems(xprotocolo, xcodanalisis, xitems: String): Boolean;
// Objetivo...: Buscar una instancia observacion items
begin
  Result := datosdb.Buscar(obsitems, 'protocolo', 'codanalisis', 'items', xprotocolo, xcodanalisis, xitems);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.GuardarObservacionItems(xprotocolo, xcodanalisis, xitems, xobservacion: string);
// Objetivo...: Guardar una instancia observacion items
begin
  if Length(Trim(xobservacion)) = 0 then Begin
    if BuscarObservacionItems(xprotocolo, xcodanalisis, xitems) then obsitems.Delete;
  end else Begin
    if BuscarObservacionItems(xprotocolo, xcodanalisis, xitems) then obsitems.Edit else obsitems.Append;
    obsitems.FieldByName('protocolo').AsString   := xprotocolo;
    obsitems.FieldByName('codanalisis').AsString := xcodanalisis;
    obsitems.FieldByName('items').AsString       := xitems;
    obsitems.FieldByName('observacion').AsString := xobservacion;
    try
      obsitems.Post
     except
      obsitems.Cancel
    end;
  end;
  datosdb.closeDB(obsitems); obsitems.Open;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getObservacionItems(xprotocolo, xcodanalisis, xitems: String);
// Objetivo...: Recuperar una instancia observacion items
begin
  if BuscarObservacionItems(xprotocolo, xcodanalisis, xitems) then observacionitems := obsitems.FieldByName('observacion').AsString else observacionitems := '';
end;

function  TTSolicitudAnalisisFabrissinInternacion.BuscarObservacionFinal(xprotocolo: String): Boolean;
// Objetivo...: Buscar una instancia observacion final items
begin
  Result := obsfinal.FindKey([xprotocolo]);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.GuardarObservacionFinal(xprotocolo, xobservacion: string);
// Objetivo...: Guardar una instancia observacion items
begin
  if Length(Trim(xobservacion)) = 0 then Begin
    if BuscarObservacionFinal(xprotocolo) then obsfinal.Delete;
  end else Begin
    if BuscarObservacionFinal(xprotocolo) then obsfinal.Edit else obsfinal.Append;
    obsfinal.FieldByName('protocolo').AsString   := xprotocolo;
    obsfinal.FieldByName('observacion').AsString := xobservacion;
    try
      obsfinal.Post
     except
      obsfinal.Cancel
    end;
  end;
  datosdb.closeDB(obsfinal); obsfinal.Open;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getObservacionFinal(xprotocolo: String);
// Objetivo...: Recuperar una instancia observacion items
begin
  if BuscarObservacionFinal(xprotocolo) then observacionfinal := obsfinal.FieldByName('observacion').AsString else observacionfinal := '';
end;

function TTSolicitudAnalisisFabrissinInternacion.setResultados(xnrosolicitud: string): TObjectList;
// Objetivo...: devolver un set de registros con los resultados de an�lisis de una solicitud
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
begin
  l := TObjectList.Create;
  if not resultado.Active then resultado.Open;
  resultado.IndexFieldNames := 'protocolo;nroanalisis;items';
  if not datosdb.Buscar(resultado, 'protocolo', 'nroanalisis', 'items', xnrosolicitud, '001', '01') then Begin
    datosdb.Filtrar(resultado, 'protocolo = ' + '''' + xnrosolicitud + '''');
    resultado.First;
  End;
  while not resultado.Eof do Begin
    if resultado.FieldByName('protocolo').AsString <> xnrosolicitud then Break;
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo          := resultado.FieldByName('protocolo').AsString;
    objeto.Codigo             := resultado.FieldByName('codanalisis').AsString;
    objeto.Items              := resultado.FieldByName('items').AsString;
    objeto.Resultado_Analisis := resultado.FieldByName('resultado').AsString;
    objeto.Valoresn           := resultado.FieldByName('valoresn').AsString;
    l.Add(objeto);
    resultado.Next;
  end;
  if resultado.Filtered then datosdb.QuitarFiltro(resultado);
  resultado.IndexFieldNames := 'protocolo;codanalisis;items';
  Result := l;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ReordenarDeterminacion(xnrosolicitud, xcodanalisis, xnroanalisis: String);
// Objetivo...: Renumerar Determinaciones analisis - aquellas que se han insertado
Begin
  datosdb.tranSQL(solicitud.DatabaseName, 'update ' + resultado.TableName + ' set nroanalisis = ' + '"' + xnroanalisis + '"' + ' where protocolo = ' + '"' + xnrosolicitud + '"' + ' and codanalisis = ' + '"' + xcodanalisis + '"');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarResultados(xcodsan, xdfecha, xhfecha: String; xprotocolos: TStringList; salida: char);
// Objetivo...: Listar Resultados por fecha y sanatorio
var
  registros, i, j, k: Integer;
  r: TQuery;
  p1, p2, p3, _protocolos: string;
  _solicitud: TQuery;
const
  limite = 11;
Begin

  _protocolos := '';
  for k := 1 to xprotocolos.Count do _protocolos := _protocolos + '''' + xprotocolos[k-1] + '''' + ', ';
  _protocolos := copy(_protocolos, 0, length(_protocolos) - 2);

  if (_protocolos = '') then begin
    utiles.msgError('No hay Protocolos Seleccionados ...!');
    exit;
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
  end else
  lcodsan := xcodsan; ldfecha := xdfecha; lhfecha := xhfecha;
  ldfecha := ''; lhfecha := '';
  listdat := False;
  if salida = 'P' then Begin
    list.Setear(salida);
    list.m := 0;
    TituloResultado(codsan, '', '', salida);
  end;
  if salida = 'T' then TituloResultado(codsan, '', '', salida);
  list.NoImprimirPieDePagina;
  list.SaltarHojaSinSubrayar;


  // utiles.msgError('select * from ' + solicitud.TableName + ' where codsan = ' + '''' + xcodsan + '''' +
    // ' and protocolo in (' + _protocolos +  ') order by protocolo');

  _solicitud := datosdb.tranSQL('select * from ' + solicitud.TableName + ' where codsan = ' + '''' + xcodsan + '''' +
     ' and protocolo in (' + _protocolos +  ') order by protocolo');

  _solicitud.Open;
  registros := _solicitud.RecordCount;
  _solicitud.First; j := 0;
  while not _solicitud.Eof do Begin
    //if utiles.verificarItemsLista(xprotocolos, trim(solicitud.FieldByName('protocolo').AsString)) then begin
      Inc(j);
      if salida = 'I' then Begin
        list.Setear(salida);
        TituloResultado(codsan, '', '', salida);
      end;

    //if utiles.verificarItemsLista(xprotocolos, solicitud.FieldByName('protocolo').AsString) then begin
      r := datosdb.tranSQL('select items, codigo from detsolint where protocolo = ' + '''' +  _solicitud.FieldByName('protocolo').AsString + '''' + ' order by items');
      r.open;
      while not r.eof do begin
        solanalisisint.ReordenarDeterminacion(_solicitud.FieldByName('protocolo').AsString, r.FieldByName('codigo').AsString, r.FieldByName('items').AsString);
        r.next;
      end;
      r.close; r.free;

      getDatos(trim(_solicitud.FieldByName('protocolo').AsString));

      obsocial.getDatos(_solicitud.FieldByName('codos').AsString);
      if (obsocial.__imprimeCodigosPie = 'S') then __imprimecodigos := true else __imprimecodigos := false;

      ListDetSol(_solicitud.FieldByName('protocolo').AsString, Nil, salida);

      if (salida = 'P') or (salida = 'I') then Begin

        if (__imprimecodigos) then begin
          p1 := ''; p2 := '';
          p3 := getCodigos(_solicitud.FieldByName('protocolo').AsString);
          if (__imprimecodigos) then begin
            for i := 1 to __practicas.Count do begin
              if (i = limite) then break;
              p1 := p1 + __practicas[i-1] + ' . ';
            end;
            if (__practicas.Count > limite) then begin
              for i  := limite to __practicas.Count do p2 := p2 + __practicas[i-1] + ' . ';
          end;

          list.CompletarPaginaPie('Pr�cticas: ' + p1, p2);
        end else
          list.CompletarPaginaPie('');
        end;

      End;

      //end;
      if salida = 'T' then Begin
        RealizarSalto;
        if j < registros then TituloResultado(codsan, '', '', salida);
      end;
      if (salida = 'P') then Begin
        //list.CompletarPagina;
        ListTituloResultado(codsan, '', '', salida);
      end;

      if salida = 'I' then list.FinList;

    //end;

    _solicitud.Next;
  end;

  _solicitud.Close; _solicitud.Free;


  {
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  registros := solicitud.RecordCount;
  solicitud.First; j := 0;
  while not solicitud.Eof do Begin
    if utiles.verificarItemsLista(xprotocolos, trim(solicitud.FieldByName('protocolo').AsString)) then begin
      Inc(j);
      if salida = 'I' then Begin
        list.Setear(salida);
        TituloResultado(codsan, '', '', salida);
      end;

    //if utiles.verificarItemsLista(xprotocolos, solicitud.FieldByName('protocolo').AsString) then begin
      r := datosdb.tranSQL('select items, codigo from detsolint where protocolo = ' + '''' +  solicitud.FieldByName('protocolo').AsString + '''' + ' order by items');
      r.open;
      while not r.eof do begin
        solanalisisint.ReordenarDeterminacion(solicitud.FieldByName('protocolo').AsString, r.FieldByName('codigo').AsString, r.FieldByName('items').AsString);
        r.next;
      end;
      r.close; r.free;

      obsocial.getDatos(solicitud.FieldByName('codos').AsString);
      if (obsocial.__imprimeCodigosPie = 'S') then __imprimecodigos := true else __imprimecodigos := false;

      ListDetSol(solicitud.FieldByName('protocolo').AsString, Nil, salida);

      if (salida = 'P') or (salida = 'I') then Begin

        if (__imprimecodigos) then begin
          p1 := ''; p2 := '';
          p3 := getCodigos(solicitud.FieldByName('protocolo').AsString);
          if (__imprimecodigos) then begin
            for i := 1 to __practicas.Count do begin
              if (i = limite) then break;
              p1 := p1 + __practicas[i-1] + ' . ';
            end;
            if (__practicas.Count > limite) then begin
              for i  := limite to __practicas.Count do p2 := p2 + __practicas[i-1] + ' . ';
          end;

          list.CompletarPaginaPie('Pr�cticas: ' + p1, p2);
        end else
          list.CompletarPaginaPie('');
        end;

      End;

      //end;
      if salida = 'T' then Begin
        RealizarSalto;
        if j < registros then TituloResultado(codsan, '', '', salida);
      end;
      if (salida = 'P') then Begin
        //list.CompletarPagina;
        ListTituloResultado(codsan, '', '', salida);
      end;

      if salida = 'I' then list.FinList;

    end;

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  }
  if (salida = 'P') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

function TTSolicitudAnalisisFabrissinInternacion.getCodigos(xprotocolo: string): string;
var
  r: TQuery;
Begin
  __practicas := TStringList.Create;
  __c := '';
  r := datosdb.tranSQL('select distinct(codref) from detsolint where protocolo = ' + '''' + xprotocolo + '''');
  r.open;
  while not r.eof do Begin
    if (length(trim(r.fields[0].asstring)) > 0) then begin
      __c := __c + r.fields[0].asstring + ' - ';
      __practicas.Add(r.fields[0].asstring);
    end;

    r.Next;
  End;
  r.close; r.free;

  if (__c = '') then begin
    r := datosdb.tranSQL('select codigo from detsolint where protocolo = ' + '''' + xprotocolo + '''');
    r.open;
    while not r.eof do Begin
      __c := __c + r.fields[0].asstring + ' - ';
      __practicas.Add(r.fields[0].asstring);
      r.Next;
    End;
    r.close; r.free;
  end;

  result := copy(__c, 1, length(__c) - 2) ;
End;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarProtocolo(xprotocolo: String; xdeterminaciones: TStringList; salida: char);
// Objetivo...: Listar Protocolo Individual
var
  ts: char;
  i, j: integer;
  p1, p2, p3: string;
  const limite = 11;
Begin
  listdat := False;
  ts := salida;
  if salida = 'N' then list.AnularCaracteresTexto;
  if salida = 'N' then salida := 'T';
  if salida = 'T' then list.IniciarImpresionModoTexto(LineasPag) else list.Setear(salida);
  list.altopag := 0; list.m := 0;
  list.SaltarHojaSinNumerarPagina;
  list.SaltarHojaSinSubrayar;
  getDatos(xprotocolo);
  lcodsan := codsan; ldfecha := utiles.setFechaActual; lhfecha := utiles.setFechaActual;
  sanatorio.getDatos(lcodsan);
  TituloResultado(codsan, '', '', salida);
  ListDetSol(xprotocolo, xdeterminaciones, salida);
  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    p3 := getCodigos(xprotocolo);
    if (__imprimecodigos) then begin
      for i := 1 to __practicas.Count do begin
        if (i = limite) then break;
        p1 := p1 + __practicas[i-1] + ' . ';
      end;
      if (__practicas.Count > limite) then begin
        for i  := limite to __practicas.Count do p2 := p2 + __practicas[i-1] + ' . ';
      end;

      //list.Linea(0, 0, p3, 1, 'Arial, normal, 9', salida, 'S');
      //list.Linea(0, 0, p1 + '/' +p2, 1, 'Arial, normal, 9', salida, 'S');

      list.FinListLeyendaFinal('Pr�cticas: ' + p1, p2);
    end else
      list.FinListLeyendaFinal('');
  end;

  if salida = 'T' then Begin
    RealizarSalto;
    if ts = 'T' then list.FinalizarImpresionModoTextoSinSaltarPagina(1) else
      list.FinalizarExportacion;
  end;
  list.SetearCaracteresTexto;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarResultadoPorAdmision(xcodsan, xcodpac: String; xadmisiones: TStringList; salida: char);
// Objetivo...: Listar Resultados por Admisi�n
Begin
  listdat := False;
  if salida = 'T' then list.IniciarImpresionModoTexto(LineasPag) else list.Setear(salida);
  list.altopag := 0;
  TituloResultado(xcodsan, '', '', salida);
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if utiles.verificarItemsLista(xadmisiones, solicitud.FieldByName('admision').AsString) then ListDetSol(solicitud.FieldByName('protocolo').AsString, Nil, salida);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.TituloResultado(xcodsan, xdfecha, xhfecha: String; salida: char);
var
  i, j: Integer;
Begin
  j := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, '', 1, 'Arial, normal, 18');
    if Length(Trim(xdfecha)) = 8 then list.Titulo(0, 0, 'Informe de Resultados Lapso: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14') else Begin
      List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
      For i := 1 to subtitulo.Count do
        List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    end;
    if listdatossan then Begin
      list.Titulo(0, 0, '*** Sanatorio: ' + xcodsan + ' - ' + sanatorio.Descrip + ' ***', 1, 'Arial, normal, 12');
      list.Titulo(70, list.Lineactual, 'Tel�fono: ' + sanatorio.Telefono, 2, 'Arial, normal, 12');
    end;
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, normal, 8');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(CHR18 + esp + ' ', True);
    Lineas := 2;
    if Length(Trim(xdfecha)) = 8 then Begin
      list.LineaTxt(esp + 'Informe de Resultados Lapso: ' + xdfecha + '-' + xhfecha, True);
      Inc(Lineas);
    end else Begin
      list.LineaTxt(esp + list.ancho_doble_seleccionar + Titulo + list.ancho_doble_cancelar, True);
      Inc(lineas);
      For i := 1 to subtitulo.Count do Begin
       Inc(j);
       List.LineaTxt(esp + TrimLeft(subtitulo.Strings[i-1]), True);
      end;
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
      Inc(lineas);
      Lineas := Lineas + j;
    end;
    if listdatossan then Begin
      list.LineaTxt(esp + '*** Sanatorio: ' + sanatorio.Descrip + ' ***' + utiles.espacios(50 - (Length(Trim(Copy('*** Sanatorio: ' + sanatorio.Descrip + ' ***', 1, 52))))) + ' Tel.: ' + sanatorio.Telefono, True);
      Inc(lineas);
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
      Inc(Lineas);
    end;
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListTituloResultado(xcodsan, xdfecha, xhfecha: String; salida: char);
var
  i, j: Integer;
Begin
  j := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 18', salida, 'S');
    if Length(Trim(xdfecha)) = 8 then list.Linea(0, 0, 'Informe de Resultados Lapso: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14', salida, 'S') else Begin
      List.Linea(0, 0, titulo, 1, 'Arial, negrita, 14', salida, 'S');
      For i := 1 to subtitulo.Count do
        List.Linea(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9', salida, 'S');
    end;
    if listdatossan then Begin
      list.Linea(0, 0, '*** Sanatorio: ' + xcodsan + ' - ' + sanatorio.Descrip + ' ***', 1, 'Arial, normal, 12', salida, 'S');
      list.Linea(70, list.Lineactual, 'Tel�fono: ' + sanatorio.Telefono, 2, 'Arial, normal, 12', salida, 'S');
    end;
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(CHR18 + esp + ' ', True);
    Lineas := 2;
    if Length(Trim(xdfecha)) = 8 then Begin
      list.LineaTxt(esp + 'Informe de Resultados Lapso: ' + xdfecha + '-' + xhfecha, True);
      Inc(Lineas);
    end else Begin
      list.LineaTxt(esp + list.ancho_doble_seleccionar + Titulo + list.ancho_doble_cancelar, True);
      Inc(lineas);
      For i := 1 to subtitulo.Count do Begin
       Inc(j);
       List.LineaTxt(esp + TrimLeft(subtitulo.Strings[i-1]), True);
      end;
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
      Inc(lineas);
      Lineas := Lineas + j;
    end;
    if listdatossan then Begin
      list.LineaTxt(esp + '*** Sanatorio: ' + sanatorio.Descrip + ' ***' + utiles.espacios(50 - (Length(Trim(Copy('*** Sanatorio: ' + sanatorio.Descrip + ' ***', 1, 52))))) + ' Tel.: ' + sanatorio.Telefono, True);
      Inc(lineas);
      list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter) + CHR15, True);
      Inc(Lineas);
    end;
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.TituloResultado1(xcodsan, xdfecha, xhfecha: String; salida: char);
var
  i, j: Integer;
Begin
  j := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, '', 1, 'Arial, normal, 18');
    if Length(Trim(xdfecha)) = 8 then list.Titulo(0, 0, 'Informe de Resultados Lapso: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14') else Begin
      List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
      For i := 1 to subtitulo.Count do
        List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, 'Arial, normal, 9');
    end;
    if listdatossan then Begin
      list.Titulo(0, 0, '*** Sanatorio: ' + xcodsan + ' - ' + sanatorio.Descrip + ' ***', 1, 'Arial, normal, 12');
      list.Titulo(70, list.Lineactual, 'Tel�fono: ' + sanatorio.Telefono, 2, 'Arial, normal, 12');
    end;
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, normal, 8');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(CHR18 + esp + ' ', True);
    Lineas := 2;
    list.LineaTxt(esp + list.ancho_doble_seleccionar + Titulo + list.ancho_doble_cancelar, True);
    Inc(lineas);
    if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
    list.LineaTxt(CHR18 + esp + list.modo_resaltado_seleccionar + 'Paciente: ' + solicitud.FieldByName('codpac').AsString + ' ' + Copy(paciente.nombre, 1, 22) + ' [' + RI + '] ' + utiles.espacios(27 - (Length(Trim(Copy(paciente.nombre, 1, 25))))) + ' Fecha: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' Muestra: ' + solicitud.FieldByName('muestra').AsString, True);
    Inc(lineas);
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True);
    Inc(lineas);
    Lineas := Lineas + j;
    list.LineaTxt(CHR15 + ' ', True);
    Inc(Lineas);
  end;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListDatosPaciente(salida: char);
// Objetivo...: Listar datos del paciente
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    paciente.getDatos(solicitud.FieldByName('codpac').AsString);
    obsocial.getDatos(solicitud.FieldByName('codos').AsString);
    profesional.getDatos(solicitud.FieldByName('idprof').AsString);
    if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
    list.Linea(0, 0, '            Paciente: ' + paciente.nombre, 1, 'Arial, negrita, 10, clNavy', salida, 'N');
    list.Linea(55, list.Lineactual, 'Habit/Cama: ' + solicitud.FieldByName('habitacion').AsString, 2, 'Arial, negrita, 10, clNavy', salida, 'S');
    list.Linea(0, 0, '            Obra Social: ' + obsocial.codos + '  ' + obsocial.nombre, 1, 'Arial, negrita, 10, clNavy', salida, 'N');
    list.Linea(55, list.Lineactual, 'Prot/Adm.: ' + solicitud.FieldByName('protocolo').AsString + ' / ' + solicitud.FieldByName('admision').AsString, 2, 'Arial, negrita, 10, clNavy', salida, 'N');
    list.Linea(0, 0, '            Fecha: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 1, 'Arial, negrita, 10, clNavy', salida, 'N');
    list.Linea(26, list.Lineactual, 'Nro. Muestra: ' + solicitud.FieldByName('muestra').AsString, 2, 'Arial, negrita, 10, clNavy', salida, 'N');
    list.Linea(55, list.Lineactual, 'Dr.: ' + profesional.nombres, 3, 'Arial, negrita, 10, clNavy', salida, 'S');
    list.Linea(0, 0, '                 Hora de Impresi�n: ' + utiles.setHoraActual24, 1, 'Arial, normal, 7', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  end;
  if (salida = 'T') then Begin
    paciente.getDatos(solicitud.FieldByName('codpac').AsString);
    obsocial.getDatos(solicitud.FieldByName('codos').AsString);
    profesional.getDatos(solicitud.FieldByName('idprof').AsString);
    if (length(trim(solicitud.FieldByName('retiva').AsString)) > 0) then RI := solicitud.FieldByName('retiva').AsString else RI := 'N';
    list.LineaTxt(CHR18 + esp + list.modo_resaltado_seleccionar + 'Paciente: ' + Copy(paciente.nombre, 1, 21) + utiles.espacios(27 - (Length(Trim(Copy(paciente.nombre, 1, 25))))) + '       Habit/Cama: ' + solicitud.FieldByName('habitacion').AsString, True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(esp + 'Obra Social: ' + obsocial.codos + ' ' + Copy(obsocial.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(obsocial.nombre, 1, 25))))) + 'Prot./Ad.: ' + solicitud.FieldByName('protocolo').AsString + ' ' + solicitud.FieldByName('admision').AsString, True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(esp + 'Fecha: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' Nro. Muestra: ' + solicitud.FieldByName('muestra').AsString + '             Dr.: ' + profesional.nombres + list.modo_resaltado_cancelar + CHR(18), True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(CHR15, True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
  end;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListDetSol(xnrosolicitud: string; detSel: TStringList; salida: char);
// Objetivo...: Listar detalle de la solicitud
var
  r, t: TObjectList; xcodanalisisanter, xnrosolanter, fuente, codanter, itobs, tfuente: string; distancia, i, j, p1, k, col: integer; f, imp, itp, l_dat, seg_it, l_items: boolean;
  objeto1, objeto2, objeto3, objeto4: TTSolicitudAnalisisFabrissinInternacion;
begin
  r := setResultados(xnrosolicitud);
  t := TObjectList.Create;
  for i := 1 to r.Count do Begin
    objeto2 := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto1 := TTSolicitudAnalisisFabrissinInternacion(r.Items[i-1]);
    objeto2.Protocolo          := objeto1.Protocolo;
    objeto2.Codigo             := objeto1.Codigo;
    objeto2.Items              := objeto1.Items;
    objeto2.Resultado_Analisis := objeto1.Resultado_Analisis;
    objeto2.Valoresn           := objeto1.Valoresn;
    t.Add(objeto2);
  End;

  l_dat := False; tfuente := '10';
  xcodanalisisanter := ''; protocolo := xnrosolicitud;
  For i := 1 to r.Count do Begin
    objeto3 := TTSolicitudAnalisisFabrissinInternacion(r.Items[i-1]);
    if utiles.verificarItemsLista(detSel, objeto3.Codigo {Copy(r.Strings[i-1], 11, 4)}) then Begin

      if not (l_dat) then Begin  // Datos del Paciente
        ListDatosPaciente(salida);
        l_dat := True;
      end;

      listdat := True;
      l_items := True;

      if (objeto3.Codigo <> xcodanalisisanter) then Begin

        if Length(Trim(xcodanalisisanter)) > 0 then Begin // Observaciones de an�lisis
          if (salida = 'I') or (salida = 'P') then Begin
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
          end;
          if (salida = 'I') or (salida = 'P') then Begin
            {if not List.EfectuoSaltoPagina then List.Linea(0, 0, '  ', 1, 'Arial, normal, ' + tfuente, salida, 'S') else Begin // En la misma p�gina
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 24', salida, 'S');
            end;}
          end;
        end;

        if (Length(Trim(objeto3.Codigo)) = 4) then nomeclatura.getDatos(objeto3.Codigo);
        if (Length(Trim(objeto3.Codigo)) = 6) then nbu.getDatos(objeto3.Codigo);

        if (salida = 'I') or (salida = 'P') then Begin
          if (Length(Trim(objeto3.Codigo)) = 4) then List.Linea(0, 0, '            ' + UpperCase(nomeclatura.descrip), 1, 'Arial, negrita, ' + tfuente, salida, 'S');
          if (Length(Trim(objeto3.Codigo)) = 6) then List.Linea(0, 0, '            ' + UpperCase(nbu.descrip), 1, 'Arial, negrita,' + tfuente, salida, 'S');
          codanter := objeto3.Codigo;
        end else Begin
          if (objeto3.Codigo <> codanter) then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
            codanter := objeto3.Codigo;
          end;
          if (Length(Trim(objeto3.Codigo)) = 4) then list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + Copy(UpperCase(nomeclatura.descrip), 1, 35) + utiles.espacios(37 - (Length(Trim(Copy(UpperCase(nomeclatura.descrip), 1, 35))))) + list.modo_resaltado_cancelar, False);
          if (Length(Trim(objeto3.Codigo)) = 6) then list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + Copy(UpperCase(nbu.descrip), 1, 35) + utiles.espacios(37 - (Length(Trim(Copy(UpperCase(nbu.descrip), 1, 35))))) + list.modo_resaltado_cancelar, False);
        end;

        f := False; // Impresi�n de Items paralelos - a la descripci�n del an�lisis
        For j := 1 to t.Count do Begin
          objeto4 := TTSolicitudAnalisisFabrissinInternacion(t.Items[j-1]);
          if not (refinos.Buscar(objeto4.Codigo)) then
            plantanalisis.getDatos(objeto4.Codigo, objeto4.Items)      //(Copy(t.Strings[j-1], 11, 4), Copy(r.Strings[j-1], 15, 3));
          else Begin
            refinos.getDatos(objeto4.Codigo);
            plantanalisis.getDatos(refinos.Codigo, objeto4.Items)      //(Copy(t.Strings[j-1], 11, 4), Copy(r.Strings[j-1], 15, 3));
          End;

          if (plantanalisis.itemsParalelo = '00') and (objeto4.Codigo = objeto3.Codigo) {Copy(t.Strings[j-1], 11, 4) = Copy(r.Strings[i-1], 11, 4))} then Begin  // Items paralelo a la descripci�n del an�lisis
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
            if (salida = 'I') or (salida = 'P') then Begin
              if (objeto4.Resultado_Analisis <> '') then List.Linea(distancia, list.lineactual, plantanalisis.elemento + ':  ' + objeto4.Resultado_Analisis, 2, 'Arial, cursiva,' + tfuente, salida, 'S') else
                List.Linea(distancia, list.lineactual, '', 2, 'Arial, cursiva,' + tfuente, salida, 'S');
            end;
            if (salida = 'T') then Begin
              if (objeto4.Resultado_Analisis <> '') then List.LineaTxt(plantanalisis.elemento + ':  ' + objeto4.Resultado_Analisis + '  ', True) else
                List.LineaTxt('', True);
              Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
            end;

            f := True;
          end;
         end;

        if (salida = 'I') or (salida = 'P') then Begin
          if not f then List.Linea(80, list.Lineactual, ' ', 3, 'Arial, negrita, 11', salida, 'S');
          // Fin Impresi�n de Items paralelos
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if not f then Begin
            List.LineaTxt(' ', true);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
          end;
          // Fin Impresi�n de Items paralelos
        end;
      end;

      if not refinos.Buscar(objeto3.Codigo) then
        plantanalisis.getDatos(objeto3.Codigo, objeto3.Items)
      else Begin
        refinos.getDatos(objeto3.Codigo);
        plantanalisis.getDatos(refinos.Codigo, objeto3.Items);
      End;

      if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
      // Impresi�n de Items independientes
      if (plantanalisis.imputable = 'N') then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
          List.Linea(0, 0, '            ' + plantanalisis.elemento, 1, 'Arial, negrita,' + tfuente, salida, 'S');
        end;
        if (salida = 'T') then Begin
          List.LineaTxt(esp + esp + plantanalisis.elemento, True);
          Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
        end;
      end else Begin
        if Length(Trim(plantanalisis.itemsParalelo)) = 0 then Begin  // Si es un items independiente lo imprimimos
          if Copy(plantanalisis.elemento, 1, 4) = uppercase(Copy(plantanalisis.elemento, 1, 4)) then fuente := 'Arial, normal,' + tfuente else fuente := 'Arial, normal, ' + tfuente;
          if distancia = 0 then Begin
            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(0, 0, '             ' + plantanalisis.elemento, 1, fuente, salida, 'N')
            end;
            if (salida = 'T') then Begin  // Items Columna 1
              List.LineaTxt(CHR18 + ' ' + esp + Copy(TrimLeft(plantanalisis.elemento), 1, 20) + utiles.espacios(21 - (Length(Copy(TrimLeft(plantanalisis.elemento), 1, 20)))), False);
            end;

            if (salida = 'P') or (salida = 'I') then Begin
              if Length(Trim(objeto3.Resultado_Analisis {Copy(r.Strings[i-1], 17, p1-17)})) > 0 then Begin
                if {Copy(r.Strings[i-1], 17, p1-17) <> ';1'} (objeto3.Resultado_Analisis <> '') then List.derecha(47, list.lineactual, '##########################', objeto3.Resultado_Analisis {Copy(r.Strings[i-1], 17, p1-17)}, 2, 'Arial, normal, ' + tfuente) else
                  List.derecha(47, list.lineactual, '##########################', '', 2, 'Arial, normal, ' + tfuente);
                /////List.Linea(48, list.lineactual, ' ', 3, 'Arial, normal, ' + tfuente, salida, 'S');
                seg_it := False;
              end else
                if (objeto3.Valoresn <> '') then Begin
                  List.derecha(distancia + 47, list.lineactual, '##########################', objeto3.Valoresn {Copy(r.Strings[i-1], p1+2, 50)}, 2, 'Arial, normal, ' + tfuente);
                  List.Linea(distancia + 48, list.lineactual, ' ', 3, 'Arial, normal, ' + tfuente, salida, 'S');
                end else
                  itp := True;
            end;

            if (salida = 'T') then Begin
              if Length(Trim(objeto3.Resultado_Analisis {Copy(r.Strings[i-1], 17, p1-17)})) > 0 then Begin
                if (objeto3.Resultado_Analisis <> '') {Copy(r.Strings[i-1], 17, p1-17) <> ';1'} then Begin
                  List.LineaTxt(utiles.sLlenarIzquierda(objeto3.Resultado_Analisis {Copy(r.Strings[i-1], 17, p1-17)}, 12, ' '), False);
                  seg_it := False;
                end else
                  List.LineaTxt('', False);
              end else
                if Length(Trim(objeto3.Valoresn {Copy(r.Strings[i-1], p1+2, 50)})) > 0 then Begin
                  List.LineaTxt(esp + utiles.sLlenarIzquierda(objeto3.Valoresn {Copy(r.Strings[i-1], p1+2, 50)}, 15, ' '), False);
                  List.LineaTxt('', False);
                end else Begin
                  List.LineaTxt(utiles.sLlenarIzquierda(' ', 12, ' '), False);
                  itp := True;
                end;
            end;

          end else Begin
            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(0, 0, ' ', 1, 'Arial, normal, ' + tfuente, salida, 'N');
              List.Linea(distancia, list.Lineactual, plantanalisis.elemento, 2, 'Arial, normal, ' + tfuente, salida, 'N');
              if Length(Trim(plantanalisis.itemsParalelo)) = 0 then List.Linea(distancia + 15, list.lineactual, objeto3.valoresn {r.Strings[i-1], p1+2, 50)}, 3, 'Arial, normal, ' + tfuente, salida, 'N') else List.Linea(distancia + 47, list.lineactual, objeto3.Valoresn {Copy(r.Strings[i-1], p1+2, 50)}, 3, 'Arial, normal, ' + tfuente, salida, 'S');
              if Length(Trim(objeto3.Valoresn)) > 0 then Begin
                List.derecha(distancia + 47, list.lineactual, '##########################', objeto3.Valoresn, 4, 'Arial, normal, ' + tfuente);
                List.Linea(distancia + 48, list.lineactual, ' ', 5, 'Arial, normal, ' + tfuente, salida, 'S');
              end else
                List.Linea(distancia + 15, list.lineactual, objeto3.Valoresn, 3, 'Arial, normal, ' + tfuente, salida, 'S');
              end;
            end;
         end;

        // Impresi�n de Items paralelos - a los items comunes
        For k := 1 to t.Count do Begin
          objeto4 := TTSolicitudAnalisisFabrissinInternacion(t.Items[k-1]);

          if not refinos.Buscar(objeto4.Codigo) then
            plantanalisis.getDatos(objeto4.Codigo, objeto4.Items)
          else Begin
            refinos.getDatos(objeto4.Codigo);
            plantanalisis.getDatos(refinos.Codigo, objeto4.Items)
          End;

          if (plantanalisis.itemsParalelo = objeto3.Items) and (objeto3.Codigo = objeto4.Codigo) then Begin
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
            itp := False;

            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(distancia, list.lineactual, plantanalisis.elemento, 4, 'Arial, normal, ' + tfuente, salida, 'N');
              if Length(Trim(objeto4.Resultado_Analisis)) > 0 then Begin
                if (Length(Trim(objeto4.Resultado_Analisis)) > 0) then List.Derecha(distancia + 47, list.lineactual, '##########################', objeto4.Resultado_Analisis, 5, 'Arial, normal, ' + tfuente) else
                  List.Derecha(distancia + 47, list.lineactual, '##########################', '', 5, 'Arial, normal, ' + tfuente);
                List.Linea(99, list.lineactual, ' ', 6, 'Arial, normal, ' + tfuente, salida, 'S');
                imp := True;
                seg_it := True;
              end;

              if Length(Trim(objeto4.Valoresn)) > 0 then Begin
                List.Derecha(distancia + 47, list.lineactual, '##########################', objeto4.Valoresn, 6, 'Arial, normal, ' + tfuente);
                List.Linea(distancia + 48, list.lineactual, ' ', 7, 'Arial, normal, ' + tfuente, salida, 'S');
                imp := True;
              end;
              if not imp then List.Linea(distancia + 48, list.lineactual, ' ', 5, 'Arial, normal, ' + tfuente, salida, 'S');
              imp := False;
            end;

            if (salida = 'T') then Begin
              List.LineaTxt(' ' + Copy(TrimRight(plantanalisis.elemento), 1, 17) + utiles.espacios(18 - (Length(TrimLeft(Copy(plantanalisis.elemento, 1, 17))))), False);
              if Length(Trim(objeto4.Resultado_Analisis)) > 0 then Begin
                if (objeto4.Resultado_Analisis <> '') then List.LineaTxt(esp + utiles.sLlenarIzquierda(objeto4.Resultado_Analisis, 12, ' '), False) else
                  List.LineaTxt(' ', False);
                List.LineaTxt(' ', True);    // Salto
                Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
                imp := True;
                seg_it := True;
              end;
              if Length(Trim(objeto4.Valoresn)) > 0 then Begin
                List.LineaTxt(objeto4.Valoresn, False);
                List.LineaTxt(' ', False);
                imp := True;
              end;
              if not imp then Begin
                List.LineaTxt('', True);
                Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
              end;
              imp := False;
            end;

          end;
        end;

        if not (seg_it) and (salida = 'T') then Begin
          if (Length(Trim(objeto3.Valoresn)) > 0) and (Length(Trim(objeto3.Resultado_Analisis)) > 0) then Begin
            List.LineaTxt(' ', False);
          end else Begin
            List.LineaTxt('', True);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
          end;
          seg_it := True;
        end;

        if not (seg_it) and (salida = 'P') or (salida = 'I') then Begin
          if (Length(Trim(objeto3.Valoresn)) > 0) and (Length(Trim(objeto3.Resultado_Analisis)) > 0) then Begin
          end else Begin
            List.Linea(distancia + 48, list.lineactual, ' ', 5, 'Arial, normal, ' + tfuente, salida, 'S');
          end;
          seg_it := True;
        end;

        if itp then
          if (salida = 'P') or (salida = 'I') then List.Linea(48, list.lineactual, ' ', 3, 'Arial, normal, ' + tfuente, salida, 'S') else Begin
            List.LineaTxt('', True);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
          end;

        // Fin Impresi�n de Items paralelos - a los items comunes
      end;

      // Valores Normales cuando hay resultados

      if (Length(Trim(objeto3.Valoresn)) > 0) and (Length(Trim(objeto3.Resultado_Analisis)) > 0) then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          if not (imp) then begin
            if (objeto3.Resultado_Analisis <> '') then List.Linea(52, list.Lineactual, 'V.N.: ' + objeto3.Valoresn, 6, 'Arial, normal, ' + tfuente, salida, 'S') else
              List.Linea(52, list.Lineactual, ' ', 6, 'Arial, normal, ' + tfuente, salida, 'S');
          end;
        end;
        if (salida = 'T') then Begin
          if (objeto3.Resultado_Analisis <> '') then List.LineaTxt(chr18 + 'V.N.: ' + objeto3.Valoresn, True) else
            List.LineaTxt('', True);
          Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
        end;

      end;

      xcodanalisisanter := objeto3.Codigo;
      xnrosolanter      := objeto3.Protocolo;
      itobs             := objeto3.Items;
    end;

    // Observaciones de items
    if l_items then Begin
      if (salida = 'P') or (salida = 'I') then
        if BuscarObservacionItems(xnrosolanter, xcodanalisisanter, itobs) then list.ListMemo('observacion', 'Arial, cursiva, ' + tfuente, 5, salida, obsitems, 0);
      if (salida = 'T') then
        if BuscarObservacionItems(xnrosolanter, xcodanalisisanter, itobs) then ListMemo('observacion', obsitems, salida);
    end;
    l_items := False;
  end;

  if (salida = 'P') or (salida = 'I') then
    if BuscarObservacionFinal(xnrosolanter) then list.ListMemo('observacion', 'Arial, cursiva, ' + tfuente, 0, salida, obsfinal, 0); // Si existen observaciones  }
  if (salida = 'T') then
    if BuscarObservacionFinal(xnrosolanter) then ListMemo('observacion', obsfinal, salida);

  if r.Count > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
    end;
  end;

  r.Free; r := Nil;
  t.Free; t := Nil;

  if salida = 'N' then list.SetearCaracteresTexto;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListMemo(xcampo: String; xtabla: TTable; salida: char);
// Objetivo...: Listar contenido de un campo memo
var
  l: TStringList;
  i: Integer;
begin
  l := list.setContenidoMemo(xtabla, xcampo, 500);
  For i := 1 to l.Count do Begin
    List.LineaTxt(list.modo_cursivo_seleccionar + '   ' + l.Strings[i-1] + list.modo_cursivo_cancelar, True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
  end;
  l.Destroy;
end;

//------------------------------------------------------------------------------

function TTSolicitudAnalisisFabrissinInternacion.CalcularValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
var
  i, j, v, porcentOS, unidadNBU: real; montoFijo: Boolean;
begin
  // Verificamos el porcentaje que paga la Obra Social
  if obsocial.porcentaje > 0 then porcentOS := (obsocial.porcentaje * 0.01) else porcentOS := (100 * 0.01);

  i := 0; j := 0; v9984 := 0; PorcentajeDifObraSocial := 0; PorcentajeDif9984 := 0;

  if obsocial.FactNBU = 'N' then Begin
    // 1� Verificamos que el analisis no tenga monto Fijo - Teniendo en cuenta per�odos
    i := obsocial.setMontoFijo(xcodos, xcodanalisis, periodo);
    // 2� Verificamos que el analisis no tenga monto Fijo
    if i = 0 then i := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, xcodanalisis);

    if i = 0 then Begin
      // C�lculamos el valor del an�lisis
      i := (xOSUB * xNOUB) + (xOSUG * xNOUG);
      montoFijo := False;
    end else montoFijo := True;
    // Calculamos el valor del codigo de toma y recepci�n
    if Length(Trim(nomeclatura.cftoma)) > 0 then Begin
      codftoma := nomeclatura.cftoma;  // Capturamos el c�digo fijo de toma y recepcion
      nomeclatura.getDatos(codftoma);
      //j := obsocial.VerifcarSiElAnalisisTieneMontoFijo(xcodos, codftoma);   // Verificamos si el 9984 tiene Monto Fijo
         
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

    // Nomencladores Adicionales
    if (obsocial.Nomenclador <> '') then begin
      obsocial.SincronizarArancelNBU(xcodos, periodo);
      //nomeclaturaos.getDatos(obsocial.Nomenclador, nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, xcodanalisis));
      nomeclaturaos.getDatos(xcodos, xcodanalisis);  // 21/08/2019
      i := nomeclaturaos.unidad * obsocial.valorNBU;
      //utiles.msgError(xcodos + ' ' + xcodanalisis + '  ' + floattostr(nomeclaturaos.unidad) + '  ' + floattostr(obsocial.valorNBU));
    end;

  end;

  PorcentajeDifObraSocial := i     - (i     * porcentOS);    // Obtiene la Dif. a Pagar, por ejemplo, si cubre el 80% obtiene el 20%, la dif.
  PorcentajeDif9984       := v9984 - (v9984 * porcentOS);

  if (porcentOS > 0) and (porcentOS < 100) then begin
    i := i * porcentOS;
    v9984 := v9984 * porcentOS;
  end;
  T9984 := T9984 + v9984;

  Result := i;
end;

function TTSolicitudAnalisisFabrissinInternacion.setValorAnalisis(xcodos, xcodanalisis, xperiodo: string): real;
var
  cod: String;
begin
  Periodo := xperiodo;
  obsocial.getDatos(xcodos);
  if (obsocial.FactNBU = 'N') then begin
    obsocial.SincronizarArancel(xcodos, xperiodo);
    nomeclatura.getDatos(xcodanalisis);
    if Length(Trim(nomeclatura.codfact)) > 0 then cod := nomeclatura.codfact else cod := xcodanalisis;
    nomeclatura.getDatos(cod);   // Sincronizamos el c�digo de referencia para facturar
    if nomeclatura.RIE <> '*' then Result := CalcularValorAnalisis(xcodos, cod, obsocial.UB, nomeclatura.UB, obsocial.UG, nomeclatura.gastos) else Result := CalcularValorAnalisis(xcodos, cod, obsocial.RIEUB, nomeclatura.UB, obsocial.RIEUG, nomeclatura.gastos);
  end;
  if (obsocial.FactNBU = 'S') then begin
    obsocial.SincronizarArancelNBU(xcodos, xperiodo);
    nbu.getDatos(xcodanalisis);
    Result := CalcularValorAnalisis(xcodos, xcodanalisis, 0, 0, 0, 0);
  end;
  Periodo := '';
end;


function TTSolicitudAnalisisFabrissinInternacion.Precio9984: Real;
begin
  Result := v9984;
end;

function TTSolicitudAnalisisFabrissinInternacion.Total9984: Real;
begin
  Result := T9984;
  T9984  := 0;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.IniciarArreglos;
// Objetivo...: Iniciar Arreglos
var
  i: Integer;
Begin
  For i := 1 to elementos do Begin
    totales[i] := 0;
  end;
  T9984  := 0;
  __codigos.Clear;
end;

//------------------------------------------------------------------------------

function  TTSolicitudAnalisisFabrissinInternacion.BuscarParametroInf(xid: String): Boolean;
// Objetivo...: Registrar Par�metros
Begin
  Result := confinf.FindKey([xid]);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarParametroInf(xid: String; xalto, xsep: Integer);
// Objetivo...: Registrar Par�metros
Begin
  if confinf.FindKey([xid]) then confinf.Edit else confinf.Append;
  confinf.FieldByName('id').AsString    := xid;
  confinf.FieldByName('alto').AsInteger := xalto;
  confinf.FieldByName('sep').AsInteger  := xsep;
  try
    confinf.Post
   except
    confinf.Cancel
  end;
  datosdb.refrescar(confinf);
  getDatosParametrosInf(xid);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getDatosParametrosInf(xid: String);
// Objetivo...: recuperar par�metros de impresi�n
Begin
  if confinf.FindKey([xid]) then Begin
    LineasPag     := confinf.FieldByName('alto').AsInteger;
    lineas_blanco := confinf.FieldByName('sep').Asinteger;
  end else Begin
    LineasPag := 67; lineas_blanco := 7;
  end;
end;

function  TTSolicitudAnalisisFabrissinInternacion.verificarMuestra(xfecha, xmuestra: String): String;
// Objetivo...: Verificar Muestra
Begin
  solicitud.IndexFieldNames := 'Fecha;Muestra';
  if datosdb.Buscar(solicitud, 'fecha', 'muestra', utiles.sExprFecha2000(xfecha), xmuestra) then
    Result := solicitud.FieldByName('protocolo').AsString
  else
    Result := '';
  solicitud.IndexFieldNames := 'Protocolo';
end;

function TTSolicitudAnalisisFabrissinInternacion.verificarSiElPacienteFueInternado(xcodpac: String): Boolean;
// Objetivo...: Verificar si el paciente ya fue internado
Begin
  solicitud.IndexFieldNames := 'Codpac';
  Result := solicitud.FindKey([xcodpac]);
  solicitud.IndexFieldNames := 'Protocolo';
end;

function TTSolicitudAnalisisFabrissinInternacion.setProtocolosAdmision(xnroadmision: String): TObjectList;
// Objetivo...: devolver los protocolos
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TObjectList.Create;
  solicitud.IndexFieldNames := 'Protocolo';
  datosdb.Filtrar(solicitud, 'admision = ' + '''' + xnroadmision + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo := solicitud.FieldByName('protocolo').AsString;
    objeto.Fecha     := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
    objeto.Codos     := solicitud.FieldByName('codos').AsString;
    objeto.idprof    := solicitud.FieldByName('idprof').AsString;
    objeto.Admision  := solicitud.FieldByName('admision').AsString;
    objeto.Retiva    := solicitud.FieldByName('retiva').AsString;
    objeto.Muestra   := solicitud.FieldByName('muestra').AsString;
    objeto.Codpac    := solicitud.FieldByName('codpac').AsString;
    l.Add(objeto);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  Buscar(protocolo);
  Result := l;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarPracticasRealizadas(xcodos, xdesde, xhasta: string; salida: char);
var
  r: TQuery;
  descrip, codigoanter, c, cod: string;
  cant, i, m, id: integer;

  procedure addCodigo(xcodigo: string);
  var
    i: integer;
    f: boolean;
    c: string;
  begin
    c := refinosag.getCodigoInverso(xcodigo);
    if (c = '') then exit;

    f := false;
    for i := 1 to __codigos.Count do begin
      if (__codigos[i-1] = c) then begin
        f := true;
        break;
      end;
    end;

    if not (f) then __codigos.Add(c);
  end;

  procedure ListarLinea(xcodos, xcodigo, xdesde: string; salida: char);
  var
    precio: real;
    rt: TQuery;
  begin
    if (cant > 0) then begin
      if (length(trim(xcodigo)) = 6) then begin
        nbu.getDatos(xcodigo);
        descrip := nbu.Descrip;
      end else begin
        nomeclatura.getDatos(xcodigo);
        descrip := nomeclatura.descrip;
      end;

      rt := datosdb.tranSQL('select count(detsolint.codigo) from detsolint, solicitudint where solicitudint.protocolo = detsolint.protocolo and solicitudint.fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and solicitudint.fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and solicitudint.codos = ' + '''' + xcodos + '''' + ' and codigo = ' + '''' + xcodigo + '''');
      rt.open;
      cant := rt.Fields[0].AsInteger;
      rt.close; rt.free;

      cod := refinosag.getCodigoInverso(xcodigo);
      if (cod = '') then cod := xcodigo;

      obsocial.SincronizarArancelNBU(xcodos, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));
      nbu.getDatos(cod);
      precio := solanalisisint.setValorAnalisis(xcodos, cod, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));

       __c := nomeclaturaos.setCodigoNomeclaturaNacional(obsocial.Nomenclador, xcodigo);
       if ( __c = '') then  __c := xcodigo;

      if (salida = 'P') or (salida = 'I') then begin
        list.Linea(0, 0, __c, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(10, list.lineactual, descrip, 2, 'Arial, normal, 8', salida, 'N');
        list.importe(65, list.Lineactual, '######', cant, 3, 'Arial, normal, 8');
        list.importe(77, list.Lineactual, '', precio, 4, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', precio * cant, 5, 'Arial, normal, 8');
        list.Linea(95, list.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
      end;

      if (salida = 'X') then begin
        inc(i); c := inttostr(i);
        excel.setString('a' + c, 'a' + c, xcodigo, 'Arial, normal, 9');
        excel.setString('b' + c, 'b' + c, descrip, 'Arial, normal, 9');
        excel.setReal('c' + c, 'c' + c, cant, 'Arial, normal, 9');
        excel.setReal('d' + c, 'd' + c, precio, 'Arial, normal, 9');
        excel.setReal('e' + c, 'e' + c, precio * cant, 'Arial, normal, 9');
      end;

    end;
    cant := 0;
    precio := 0;
  end;

begin

  obsocial.getDatos(xcodos);
  if (obsocial.Factnbu = 'N') then obsocial.SincronizarArancel(xcodos, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));
  if (obsocial.Factnbu = 'S') then obsocial.SincronizarArancelNBU(xcodos, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));

  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Practicas Realizadas en el Per�odo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'C�digo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Determinaci�n', 2, 'Arial, cursiva, 8');
    List.Titulo(62, List.lineactual, 'Cant.', 3, 'Arial, cursiva, 8');
    List.Titulo(72, List.lineactual, 'Costo', 4, 'Arial, cursiva, 8');
    List.Titulo(91, List.lineactual, 'Total', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

    List.Titulo(0, 0, 'Obra Social: ' + obsocial.codos + ' ' + obsocial.Nombre, 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'X') then begin
    excel.setString('a1', 'a1', 'Practicas Realizadas en el Per�odo: ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 11');
    excel.setString('a2', 'a2', 'Obra Social: ' + obsocial.codos + '  ' + obsocial.Nombre, 'Arial, negrita, 10');
    excel.setString('a3', 'a3', 'C�digo', 'Arial, negrita, 9');
    excel.setString('b3', 'b3', 'Determinaci�n', 'Arial, negrita, 9');
    excel.setString('c3', 'c3', 'Cant.', 'Arial, negrita, 9');
    excel.setString('d3', 'd3', 'Costo', 'Arial, negrita, 9');
    excel.setString('e3', 'e3', 'Total', 'Arial, negrita, 9');
    excel.Alinear('c3', 'c3', 'D');
    excel.Alinear('d3', 'd3', 'D');
    excel.Alinear('e3', 'e3', 'D');
    excel.FijarAnchoColumna('b3', 'b3', 40);
  end;

  refinosag.conectar;
  __codigos.Clear;
  i := 3;
  r := datosdb.tranSQL('select distinct(detsolint.codigo) from detsolint, solicitudint where solicitudint.protocolo = detsolint.protocolo and solicitudint.fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and solicitudint.fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and solicitudint.codos = ' + '''' + xcodos + '''' + ' order by codigo');
  r.open;
  while not r.eof do begin
    cant := 1;
    ListarLinea(xcodos, r.Fields[0].asstring, xdesde, salida);
    //addCodigo(r.Fields[0].asstring);
    r.next;
  end;
  r.close; r.free;

  {cant := 1;
  for m := 1 to __codigos.Count do begin
    ListarLinea(xcodos, __codigos[m-1], xdesde, salida);
  end;}
  refinosag.desconectar;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if (salida = 'X') then begin
    excel.setString('d1', 'd1', '', 'Arial, negrita, 11');
    excel.Visulizar;
  end;
end;

function TTSolicitudAnalisisFabrissinInternacion.setImportePacientePor_ObraSocial(xcodpac, xcodob, xdfecha, xhfecha: string): real;
// Objetivo...: Calcular el importe de analisis de obras sociales para un solicitud dada
var
  t: real;
  cod: string;
begin
  t := 0;
  // Aislamos los pacientes por obra social y fecha
  datosdb.Filtrar(solicitud, 'codpac = ' + trim(xcodpac) + ' AND fecha >= ' + utiles.sExprFecha2000(xdfecha) + ' AND fecha <= ' + utiles.sExprFecha2000(xhfecha));
  solicitud.First;
  while not solicitud.EOF do Begin
    cod := solicitud.FieldByName('codos').AsString;
    datosdb.Filtrar(detsol, 'protocolo = ' + solicitud.FieldByName('protocolo').AsString);
    detsol.First;
    while not detsol.EOF do Begin // Extraemos los items de esa solicitud
      t := t + setValorAnalisis(cod, detsol.FieldByName('codigo').AsString, Copy(xdfecha, 1, 2) + '/' + Copy(utiles.sExprFecha2000(xdfecha), 1, 4));
      detsol.Next;
    end;
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  datosdb.QuitarFiltro(detsol);
  Result := t;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListPacientesObraSocial(xcodos, xdesde, xhasta: string; salida: char);
// Objetivo...: Listar los pacientes ingresados en el lapso de tiempo dado por obra social
var
  r: TQuery;
  descrip, codigoanter, c: string;
  cant, i: integer;
  fecha, medicoanter, protocolo: string;
  precio: real;

  procedure ListarLinea(xcodos, xcodigo, xdesde: string; salida: char);
  begin
    if (cant > 0) then begin
      if (length(trim(xcodigo)) = 6) then begin
        nbu.getDatos(xcodigo);
        descrip := nbu.Descrip;
      end else begin
        nomeclatura.getDatos(xcodigo);
        descrip := nomeclatura.descrip;
      end;

      //precio := solanalisisint.setValorAnalisis(xcodos, xcodigo, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));

      profesional.getDatos(medicoanter);
      paciente.getDatos(codigoanter);

      if (salida = 'P') or (salida = 'I') then begin
        List.Linea(0, 0, fecha + '  ' + protocolo, 1, 'Arial, normal, 8', salida, 'N');
        List.Linea(20, list.lineactual, paciente.nombre, 2, 'Arial, normal, 8', salida, 'N');
        List.Linea(65, list.lineactual, profesional.nombres, 3, 'Arial, normal, 8', salida, 'N');
        list.importe(98, list.lineactual, '', precio, 4, 'Arial, normal, 8');
        List.Linea(99, list.lineactual, '', 5, 'Arial, normal, 8', salida, 'S');
      end;

      if (salida = 'X') then begin
        inc(i); c := inttostr(i);
        excel.setString('a' + c, 'a' + c, fecha + '  ' + protocolo, 'Arial, normal, 9');
        excel.setString('b' + c, 'b' + c, paciente.nombre, 'Arial, normal, 9');
        excel.setString('c' + c, 'c' + c, profesional.nombres, 'Arial, normal, 9');
        excel.setReal('d' + c, 'd' + c, cant, 'Arial, normal, 9');
        excel.setReal('e' + c, 'e' + c, precio, 'Arial, normal, 9');
      end;

    end;
    cant := 0;
    precio := 0;
  end;

begin

  obsocial.getDatos(xcodos);
  if (obsocial.Factnbu = 'N') then obsocial.SincronizarArancel(xcodos, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));
  if (obsocial.Factnbu = 'S') then obsocial.SincronizarArancelNBU(xcodos, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));

  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' Solicitudes Ingresadas por Obra Social - Periodo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Fecha / Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(20, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
    List.Titulo(65, list.Lineactual, 'Profesional', 3, 'Arial, cursiva, 8');
    List.Titulo(93, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
    List.Titulo(0, 0, 'Obra Social: ' + obsocial.codos + ' ' + obsocial.Nombre, 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'X') then begin
    excel.setString('a1', 'a1', 'Solicitudes Ingresadas por Obra Social - Per�odo: ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 11');
    excel.setString('a2', 'a2', 'Obra Social: ' + obsocial.codos + '  ' + obsocial.Nombre, 'Arial, negrita, 10');
    excel.setString('a3', 'a3', 'Fecha / Protocolo', 'Arial, negrita, 9');
    excel.setString('b3', 'b3', 'Paciente', 'Arial, negrita, 9');
    excel.setString('c3', 'c3', 'Profesional', 'Arial, negrita, 9');
    excel.setString('d3', 'd3', 'Cant.', 'Arial, negrita, 9');
    excel.setString('e3', 'e3', 'Precio', 'Arial, negrita, 9');
    excel.Alinear('c3', 'c3', 'D');
    excel.Alinear('d3', 'd3', 'D');
    excel.Alinear('e3', 'e3', 'D');
    excel.FijarAnchoColumna('b2', 'b2', 40);
  end;

  r := datosdb.tranSQL('select solicitudint.*, detsolint.codigo from detsolint, solicitudint where solicitudint.protocolo = detsolint.protocolo and solicitudint.fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and solicitudint.fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and solicitudint.codos = ' + '''' + xcodos + '''' + ' order by codpac, codigo');
  r.Open; codigoanter := ''; i := 3;

  while not r.eof do begin
    if (trim(r.FieldByName('codpac').AsString) <> trim(codigoanter)) or (trim(r.FieldByName('idprof').AsString) <> trim(medicoanter) ) then ListarLinea(xcodos, codigoanter, xdesde, salida);
    codigoanter := r.FieldByName('codpac').AsString;
    medicoanter := r.FieldByName('idprof').AsString;
    protocolo := r.FieldByName('protocolo').AsString;
    fecha := utiles.sFormatoFecha(r.FieldByName('fecha').AsString);
    precio := precio + solanalisisint.setValorAnalisis(xcodos, r.FieldByName('codigo').AsString, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));
    inc(cant);
    r.next;
  end;

  ListarLinea(xcodos, codigoanter, xdesde, salida);

  r.close; r.free;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if (salida = 'X') then begin
    excel.setString('d1', 'd1', '', 'Arial, negrita, 11');
    excel.Visulizar;
  end;


{var
  imp, totos, totgral, total: real; totob: integer; Q: TQuery;
  idanter, descrip: string;

  procedure TotalOS(salida: char);
  begin
    obsocial.getDatos(idanter);
    List.Linea(0, 0, '    ', 1, 'Arial, negrita, 5', salida, 'S');
    List.Linea(0, 0, 'Total ' + obsocial.nombre, 1, 'Arial, negrita, 9', salida, 'S');
    List.importe(60, list.lineactual, '#######', total, 2, 'Arial, negrita, 9');
    List.importe(98, list.lineactual, '', totos, 3, 'Arial, negrita, 9');
    List.Linea(0, 0, list.Linealargopagina(salida) , 1, 'Arial, normal, 11', salida, 'S');
    List.Linea(0, 0, '    ', 1, 'Arial, negrita, 4', salida, 'S');
    total := 0; totos := 0;
  end;

begin
  totos := 0; totob := 0; totgral := 0;

  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Solicitudes Ingresadas por Obra Social - Periodo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Fecha / Protocolo', 1, 'Arial, cursiva, 8');
  List.Titulo(20, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(65, list.Lineactual, 'Profesional', 3, 'Arial, cursiva, 8');
  List.Titulo(93, list.Lineactual, 'Monto', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  Q := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + solicitud.TableName + '.protocolo, ' + solicitud.TableName + '.codpac, ' + solicitud.TableName + '.fecha, ' + solicitud.TableName + '.idprof, ' + solicitud.TableName + '.codos FROM ' + solicitud.TableName +
                                               ' WHERE ' + solicitud.TableName + '.fecha >= ' + '"' + utiles.sExprFecha2000(xdesde) + '"' + ' AND ' + solicitud.TableName + '.fecha <= ' + '"' + utiles.sExprFecha2000(xhasta) + '"' + ' AND codos > ' + '"' + '000000' + '"' + ' ORDER BY codos, protocolo');

  Q.Open; Q.First; total := 0; idanter := ''; imp := 0;
  while not Q.EOF do begin
    if (utiles.verificarItemsLista(listOS, Q.FieldByName('codos').AsString)) then begin

      if Q.FieldByName('codos').AsString <> idanter then
        begin
          if Length(Trim(idanter)) > 0 then TotalOS(salida);

          obsocial.getDatos(Q.FieldByName('codos').AsString);

          List.Linea(0, 0, obsocial.nombre, 1, 'Arial, negrita, 9', salida, 'S');
          List.Linea(0, 0, '    ', 1, 'Arial, negrita, 5', salida, 'S');

          if (obsocial.Factnbu = 'N') then obsocial.SincronizarArancel(obsocial.codos, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));
          if (obsocial.Factnbu = 'S') then obsocial.SincronizarArancelNBU(obsocial.codos, Copy(xdesde, 4, 2) + '/' + Copy(utiles.sExprFecha2000(xdesde), 1, 4));
        end;

      paciente.getDatos(Q.FieldByName('codpac').AsString);
      profesional.getDatos(Q.FieldByName('idprof').AsString);


      if (obsocial.Factnbu = 'N') then imp := solanalisisint.setImportePacientePor_ObraSocial(Q.FieldByName('codpac').AsString, Q.FieldByName('codos').AsString, xdesde, xhasta) + solanalisisint.Total9984 else
        imp := solanalisisint.setImportePacientePor_ObraSocial(Q.FieldByName('codpac').AsString, Q.FieldByName('codos').AsString, xdesde, xhasta);
      List.Linea(0, 0, utiles.sFormatoFecha(Q.FieldByName('fecha').AsString) + '  ' + Q.FieldByName('protocolo').AsString, 1, 'Arial, normal, 8', salida, 'N');
      List.Linea(20, list.lineactual, paciente.nombre, 2, 'Arial, normal, 8', salida, 'N');
      List.Linea(65, list.lineactual, profesional.nombres, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(98, list.lineactual, '', imp, 4, 'Arial, normal, 8');
      List.Linea(99, list.lineactual, '', 5, 'Arial, normal, 8', salida, 'S');

      Inc(totob);
      total   := total + 1;
      totos   := totos   + imp;
      totgral := totgral + imp;

      idanter := Q.FieldByName('codos').AsString;
      items   := obsocial.nombre;
      descrip := obsocial.nombre;
    end;
    Q.Next;
  end;

  if Length(Trim(idanter)) > 0 then TotalOS(salida);

  if total <> 0 then Begin
    List.Linea(0, 0, '    ', 1, 'Arial, normal, 8', salida, 'S');
    List.derecha(98, list.Lineactual, '###################', '-------------------', 2, 'Arial, normal, 9');
    List.Linea(0, 0, 'Total de Solicitudes Obra Social:', 1, 'Arial, negrita, 9', salida, 'S');
    List.importe(60, list.lineactual, '#######', total, 2, 'Arial, negrita, 9');
    List.importe(98, list.lineactual, '', totos, 3, 'Arial, negrita, 9');
    List.Linea(0, 0, '    ', 1, 'Arial, negrita, 4', salida, 'S');
  end;

  if totos > 0 then Begin
    List.Linea(0, 0, '    ', 1, 'Arial, normal, 8', salida, 'S');
    List.derecha(98, list.Lineactual, '###################', '-------------------', 2, 'Arial, normal, 9');
    List.Linea(0, 0, 'Total General de Solicitudes:', 1, 'Arial, negrita, 9', salida, 'S');
    List.importe(60, list.lineactual, '#######', totob, 2, 'Arial, negrita, 9');
    List.importe(98, list.lineactual, '', totgral, 3, 'Arial, negrita, 9');
    List.Linea(0, 0, '    ', 1, 'Arial, negrita, 4', salida, 'S');
    List.Linea(0, 0, ' ', 1, 'Courier New, normal, 8', salida, 'S');
  end;

  Q.Close;

  list.FinList;}
end;

//------------------------------------------------------------------------------

function TTSolicitudAnalisisFabrissinInternacion.getCantidadItemsOrden(xnrosolicitud: string): integer;
var
  r: TQuery;
  i: integer;
begin
  r := datosdb.tranSQL(detsol.DatabaseName, 'select codigo from ' + detsol.TableName + ' where protocolo = ' + '''' + xnrosolicitud + '''');
  r.Open; i := 0;
  while not r.eof do begin
    if (length(trim(refinos.getCodigoExporta(r.FieldByName('codigo').AsString))) > 0) then begin
      if (refinos.Separado <> 'S') then inc(i);
    end;
    r.next;
  end;
  r.Close; r.Free;

  result := i;
end;

//------------------------------------------------------------------------------

function TTSolicitudAnalisisFabrissinInternacion.setAnalisis(xnrosolicitud: string): TQuery;
// Objetivo...: devolver un set de registros con los an�lisis de una solicitud dada
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT * FROM ' + detsol.TableName + ' WHERE protocolo = ' + '"' + xnrosolicitud + '"' + ' ORDER BY protocolo, items');
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ExportarOrdenesML(xlista: TStringList; xruta: string);
// Objetivo...: exportar ordenes metrolab
var
  i, j, k, m: integer;
  linea1, linea2, linea3, codigo, prot, nroint: string;
  archivo: TextFile;
  listasep: TStringList;
  r, t, q: TQuery;
begin
  listasep := TStringList.Create;

  refinos.conectar;
  refinosag.conectar;

  protex.conectar;

  AssignFile(archivo, xruta + '\protocolosinternacion.ana');
  rewrite(archivo);
  for i := 1 to xlista.Count do begin

     linea1 := ''; linea2 := ''; linea3 := '';
     listasep.Clear;

     m := pos(';', xlista.Strings[i-1]);
     prot := copy(xlista.Strings[i-1], 1, m-1);
     nroint := trim(copy(xlista.Strings[i-1], m+1, 10));

     if (buscar(prot)) then begin

       getDatos(prot);
       protex.Registrar(prot, nroint, fecha);

       j := solanalisisint.getCantidadItemsOrden(prot);

       if (j > 0) then begin

         paciente.getDatos(solicitud.FieldByName('codpac').AsString);
         linea1 := nroint + ';' + 'N' + ';' + copy(paciente.nombre, 1, 30) + ';' + solicitud.FieldByName('protocolo').AsString + ';' + utiles.sLlenarIzquierda(paciente.Edad, 3, '0') + ';' + paciente.Sexo + ';' + IntToStr(j);

         r := solanalisisint.setAnalisis(prot);
         r.Open;
         while not r.eof do begin
           codigo := refinos.getCodigoExporta(r.FieldByName('codigo').AsString);
           refinos.getDatos(r.FieldByName('codigo').AsString);
           if (length(trim(codigo)) > 0) then begin

             if (refinos.Separado <> 'S') then  // Agrupamos las practicas que van en la misma linea
               linea2 := linea2 + ';' + codigo
             else
               listasep.Add(';' + codigo);
           end;

           // Ahora verificamos los codigos que se repiten en la misma linea y en una separada, el Cleavence, 660193
           q := refinosmixto.getCodigosMismaLinea(r.FieldByName('codigo').AsString);
           q.open;
           while not q.eof do begin
             if (length(trim(r.FieldByName('codigo').AsString )) = 6) then
               linea2 := linea2 + ';' + q.FieldByName('exporta').AsString;
             if (length(trim(r.FieldByName('codigo').AsString )) = 4) then
               linea2 := linea2 + ';' + q.FieldByName('exporta').AsString;
             q.next;
           end;
           q.close; q.Free;

           q := refinosmixto.getCodigosDistintaLinea(r.FieldByName('codigo').AsString);
           q.open;
           while not q.eof do begin
             if (length(trim(r.FieldByName('codigo').AsString )) = 6) then
               listasep.Add(';' + q.FieldByName('exporta').AsString);
             if (length(trim(r.FieldByName('codigo').AsString )) = 4) then
               listasep.Add(';' + q.FieldByName('exporta').AsString);
             q.next;
           end;
           q.close; q.Free;

           r.Next;
         end;

         // Ahora Agregamos las lineas individuales
         for k := 1 to listasep.Count do
           writeln(archivo, linea1 + listasep.Strings[k-1] + ';(CR)(LF)');

         // Tratamiento de los codigos desagregados
         listasep.Clear;
         linea3 := '';
         r.First;
         while not r.eof do begin
           if (refinosag.BuscarRef(r.FieldByName('codigo').AsString))then begin
              t := refinosag.getCodigos(r.FieldByName('codigo').AsString);
              t.open;
              while not t.eof do begin
                codigo := refinos.getCodigoExporta(t.FieldByName('codigo2').AsString);
                refinos.getDatos(t.FieldByName('codigo2').AsString);
                if (length(trim(codigo)) > 0) then begin
                  if (refinos.Separado <> 'S') then  // Agrupamos las practicas que van en la misma linea
                    linea3 := linea3 + ';' + codigo
                  else
                    listasep.Add(';' + codigo);
                end;
                t.next;
              end;
              t.close; t.Free;

           end;

           r.Next;
         end;
         r.close; r.free;

         // Registramos la linea con los codigos concentrados
         if (length(trim(linea3+linea2)) > 0) then
           writeln(archivo, linea1 + linea2 + linea3 + ';(CR)(LF)');

         linea2 := ''; linea3 := '';

       end;

     end;

  end;

  closeFile(archivo);

  refinosag.desconectar;
  refinos.desconectar;
  protex.desconectar;

  listasep.Destroy; listasep := nil;
end;

//------------------------------------------------------------------------------

function  TTSolicitudAnalisisFabrissinInternacion.getNroAnalisis(xprotocolo, xcodigo: string): string;
// Objetivo...: recuperar nro. de analisis
begin
  if (BuscarResultado(xprotocolo, xcodigo, '01')) then begin
    while not detsol.Eof do begin
      if (detsol.FieldByName('protocolo').AsString <> xprotocolo) then break;
      if (detsol.FieldByName('codigo').AsString <> xcodigo) then begin
        result := detsol.FieldByName('items').AsString;
        break;
      end;
      detsol.Next;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarResultadoML(xprotocolo, xsigla, xvalor: string);
// Objetivo...: registrar resultado protocolo

var
  r, t: TQuery;
  cant: integer;
  cod: string;
  ok, eqOK1, eqOK2: boolean;

  procedure CopiarItemsPlantilla(xprotocolo, xcodigo1, xcodigo2: string);
  var
    c: string;
  begin
    c := '';
    if BuscarDetSol(xprotocolo, '001') then
      if (length(trim(detsol.FieldByName('codigo').AsString)) > 4) then c := xcodigo1 else c := xcodigo2;

    if(length(trim(c)) > 0) then begin
      cod := c;

      if (plantanalisis.Buscar(xcodigo1, '01')) then
        r := plantanalisis.setplantanalisis(xcodigo1);
      if (plantanalisis.Buscar(xcodigo2, '01')) then
        r := plantanalisis.setplantanalisis(xcodigo2);

      r.Open;

      cant := r.RecordCount;

      r.First;
      while not r.eof do begin
        GuardarResultado(xprotocolo, c, r.FieldByName('items').AsString, r.FieldByName('resultado').AsString, r.FieldByName('valoresn').AsString, getNroAnalisis(xprotocolo, c), cant);
        r.next;
      end;

      r.close; r.free;

    end;

    detsol.IndexFieldNames := 'protocolo;items';

  end;

  //----------------------------------------------------------------------------

  procedure RegistrarRes(xprotocolo, xcodigo, xitems, xvalor: string);
  var
    __codigo: string;

  begin

    __codigo := xcodigo;  // Si el c�digo no existe ...   03/03/2015
    if (detsol.IndexFieldNames <> 'protocolo;codigo') then detsol.IndexFieldNames := 'protocolo;codigo';
    if not (datosdb.Buscar(detsol, 'protocolo', 'codigo', xprotocolo, xcodigo))  then begin
      t := refinos.getCodigoExportaSQL(xsigla); // ... prorrateamos el c�digo
      t.Open;
      while not t.eof do begin
        if (datosdb.Buscar(detsol, 'protocolo', 'codigo', xprotocolo, t.FieldByName('codnbu').AsString)) then begin
          __codigo := t.FieldByName('codnbu').AsString;
          break;
        end;
        t.next;
      end;
      t.close; t.free;

      // Actualizamos el c�digo en los Resultados - 06/03/2015
      datosdb.tranSQL('delete from ' + resultado.TableName + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and codanalisis = ' + '''' + __codigo + '''');
      datosdb.tranSQL('update ' + resultado.TableName + ' set codanalisis = ' + '''' + __codigo + '''' + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and codanalisis = ' + '''' + xcodigo + '''');
    end;

    if (BuscarResultado(xprotocolo, __codigo, xitems)) then begin
      resultado.Edit;
      resultado.FieldByName('resultado').AsString := utiles.FormatearNumero(xvalor);
      try
        resultado.Post
       except
        resultado.Cancel
      end;

      datosdb.closeDB(resultado); resultado.Open;

    end;

  end;

begin

  // Buscamos la equivalencia
  eqOK1 := false; eqOK2 := false;

  if (eqml.Buscar(xsigla)) then eqOK1 := true else
    if (eqml.BuscarAbreviatura(trim(xsigla))) then eqOK2 := true;

  if (eqOK1) or (eqOK2) then begin

    if (eqOK1) then eqml.getDatos(xsigla);
    if (eqOK2) then eqml.getDatosAbreviatura(trim(xsigla));

    ok := false;

    if (plantanalisis.Buscar(eqml.Codigo1, '01')) then ok := true;
    if (plantanalisis.Buscar(eqml.Codigo2, '01')) then ok := true;

    if (ok) then begin

      CopiarItemsPlantilla(xprotocolo, eqml.Codigo1, eqml.Codigo2);

      RegistrarRes(xprotocolo, cod, eqml.Items, xvalor);

    end;

  end;

end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.EstadisticaPracticasRealizadas(xcodos, xdesde, xhasta: string; salida: char);
var
  r: TQuery;
  descrip, codigoanter, c, cod: string;
  cant, i, m, id: integer;

  procedure ListarLinea(xcodos, xcodigo, xdesde: string; salida: char);
  var
    precio: real;
    rt: TQuery;
  begin
    if (cant >= 0) then begin
      if (length(trim(xcodigo)) = 6) then begin
        nbu.getDatos(xcodigo);
        descrip := nbu.Descrip;
      end else begin
        nomeclatura.getDatos(xcodigo);
        descrip := nomeclatura.descrip;
      end;

      rt := datosdb.tranSQL('select count(codigo) from estadisticas where codigo = ' + '''' + xcodigo + '''');
      rt.open;
      cant := rt.Fields[0].AsInteger;
      rt.close; rt.free;

      rt := datosdb.tranSQL('select monto from estadisticas where codigo = ' + '''' + xcodigo + '''');
      rt.open;
      precio := rt.Fields[0].AsFloat;
      rt.close; rt.free;

      if (salida = 'P') or (salida = 'I') then begin
        list.Linea(0, 0, xcodigo, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(10, list.lineactual, descrip, 2, 'Arial, normal, 8', salida, 'N');
        list.importe(65, list.Lineactual, '######', cant, 3, 'Arial, normal, 8');
        list.importe(77, list.Lineactual, '', precio, 4, 'Arial, normal, 8');
        list.importe(95, list.Lineactual, '', precio * cant, 5, 'Arial, normal, 8');
        list.Linea(95, list.lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
      end;

      if (salida = 'X') then begin
        inc(i); c := inttostr(i);
        excel.setString('a' + c, 'a' + c, xcodigo, 'Arial, normal, 9');
        excel.setString('b' + c, 'b' + c, descrip, 'Arial, normal, 9');
        excel.setReal('c' + c, 'c' + c, cant, 'Arial, normal, 9');
        excel.setReal('d' + c, 'd' + c, precio, 'Arial, normal, 9');
        excel.setReal('e' + c, 'e' + c, precio * cant, 'Arial, normal, 9');
      end;

    end;

  end;


begin
  ListarSolicitudesValorizadasPorObraSocial('001', xcodos, xdesde, xhasta, 'N');
  list.altopag := 0;
  i := 3;

  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, titulo, 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Practicas Realizadas en el Per�odo: ' + xdesde + ' - ' + xhasta, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'C�digo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Determinaci�n', 2, 'Arial, cursiva, 8');
    List.Titulo(62, List.lineactual, 'Cant.', 3, 'Arial, cursiva, 8');
    List.Titulo(72, List.lineactual, 'Costo', 4, 'Arial, cursiva, 8');
    List.Titulo(91, List.lineactual, 'Total', 5, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

    List.Titulo(0, 0, 'Obra Social: ' + obsocial.codos + ' ' + obsocial.Nombre, 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'X') then begin
    excel.setString('a1', 'a1', 'Practicas Realizadas en el Per�odo: ' + xdesde + ' - ' + xhasta, 'Arial, negrita, 11');
    excel.setString('a2', 'a2', 'Obra Social: ' + obsocial.codos + '  ' + obsocial.Nombre, 'Arial, negrita, 10');
    excel.setString('a3', 'a3', 'C�digo', 'Arial, negrita, 9');
    excel.setString('b3', 'b3', 'Determinaci�n', 'Arial, negrita, 9');
    excel.setString('c3', 'c3', 'Cant.', 'Arial, negrita, 9');
    excel.setString('d3', 'd3', 'Costo', 'Arial, negrita, 9');
    excel.setString('e3', 'e3', 'Total', 'Arial, negrita, 9');
    excel.Alinear('c3', 'c3', 'D');
    excel.Alinear('d3', 'd3', 'D');
    excel.Alinear('e3', 'e3', 'D');
    excel.FijarAnchoColumna('b3', 'b3', 40);
  end;

  r := datosdb.tranSQL('select distinct(codigo) from estadisticas');
  r.open;
  while not r.eof do begin
    ListarLinea(xcodos, r.Fields[0].asstring, xdesde, salida);
    r.next;
  end;
  r.close; r.free;

  if (salida = 'P') or (salida = 'I') then list.FinList;
  if (salida = 'X') then begin
    excel.setString('d1', 'd1', '', 'Arial, negrita, 11');
    excel.Visulizar;
  end;
end;

//------------------------------------------------------------------------------

function TTSolicitudAnalisisFabrissinInternacion.getProtocolosItems(xprotocolo: string): TQuery;
begin
  result := datosdb.tranSQL('select protocolo, items, codigo from detsolint where protocolo = ' + '''' + xprotocolo + '''' + ' order by items');
end;

function  TTSolicitudAnalisisFabrissinInternacion.getProtocolos(xdesde, xhasta: string): TQuery;
begin
  result := datosdb.tranSQL('select protocolo, fecha, codpac, idprof, codos, codsan, habitacion, muestra from solicitudint where fecha between ' +
              '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' order by protocolo desc');
end;

function TTSolicitudAnalisisFabrissinInternacion.getProtocolosItemsResultado(xprotocolo, xcodanalisis, xitems: string): TQuery;
begin
  result := datosdb.tranSQL('select protocolo, items, codanalisis, resultado, valoresn, nroanalisis from resultadoint where protocolo = ' + ''''
         + xprotocolo + '''' + ' and codanalisis =  ' + '''' + xcodanalisis + '''' + ' and nroanalisis = ' + '''' + xitems + '''' + ' order by items');
end;

function TTSolicitudAnalisisFabrissinInternacion.getProtocolosItemsResultadoObservaciones(xprotocolo, xcodanalisis, xitems: string): TQuery;
begin
  result := datosdb.tranSQL('select observacion from obsitemsint where protocolo = ' + ''''
         + xprotocolo + '''' + ' and codanalisis =  ' + '''' + xcodanalisis + '''' + ' and items = ' + '''' + xitems + '''');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarResultadoCM(xprotocolo, xitems, xvalor: string; copiarTemplate: boolean);
var
  r: TQuery;
  s, __cod, __valor: string;

  procedure CopiarItemsPlantilla(xprotocolo, xcodigo1, xcodigo2: string);
  var
    c, cod: string;
    r: TQuery;
    cant: integer;
  begin

    c := '';
    detsol.IndexFieldNames := 'protocolo;codigo';

    if (datosdb.Buscar(detsol, 'protocolo', 'codigo', trim(xprotocolo), xcodigo1)) then c := xcodigo1 else
      if (datosdb.Buscar(detsol, 'protocolo', 'codigo', trim(xprotocolo), xcodigo2)) then c := xcodigo2;

    if(length(trim(c)) > 0) then begin

      if (plantanalisis.Buscar(xcodigo1, '01')) then
        r := plantanalisis.setplantanalisis(xcodigo1);
      if (plantanalisis.Buscar(xcodigo2, '01')) then
        r := plantanalisis.setplantanalisis(xcodigo2);
      utiles.msgerror('3');
      r.Open;

      cant := r.RecordCount;

      r.First;
      while not r.eof do begin
        GuardarResultado(trim(xprotocolo), c, r.FieldByName('items').AsString, r.FieldByName('resultado').AsString, r.FieldByName('valoresn').AsString, getNroAnalisis(xprotocolo, c), cant);
        r.next;
      end;

      r.close; r.free;

    end;

    detsol.IndexFieldNames := 'protocolo;items';

  end;

begin

  r := plantanalisis.getPlantanalisisBySigla(xitems);
  r.Open;
  if (r.RecordCount > 0) then begin

    __cod := nbu.setCodigoNBU(r.fieldbyname('codigo').asstring);

    // Verificamos si existe la plantilla     10/07/2022
    if (copiarTemplate) then begin
      if not (BuscarResultado(trim(xprotocolo), trim(__cod), '01')) then begin
        CopiarItemsPlantilla(xprotocolo, __cod, r.fieldbyname('codigo').asstring);
      end;
    end;

    // Transferimos ...
    if (r.fieldbyname('ceros').asstring = '') then __valor := xvalor else begin


      if (copy(r.fieldbyname('ceros').asstring, 1, 1) = 'x') then begin
        __valor := trim(utiles.StringRemplazarCaracteres(xvalor, '.', ','));
        __valor := FloatTostr(StrToFloat(__valor) *  StrToFloat(trim(copy(r.fieldbyname('ceros').asstring, 2, 10))));
        __valor := utiles.getNumberMask(__valor);
        __valor := StringReplace(__valor, ',00', '', [rfReplaceAll, rfIgnoreCase]);
      end else begin
        __valor := trim(utiles.StringRemplazarCaracteres(xvalor, '.', ''));
        __valor := utiles.sLlenarDerecha(__valor, r.fieldbyname('ceros').asinteger, '0');
        __valor := utiles.getNumberMask(__valor);
        __valor := StringReplace(__valor, ',00', '', [rfReplaceAll, rfIgnoreCase]);
      end;

    end;

    s := 'update resultadoint set resultado = ' + '''' + __valor  + '''' + ' where protocolo = ' + '''' + xprotocolo + '''' +
         ' and codanalisis = ' + '''' + __cod + '''' + ' and items = ' + '''' + r.fieldbyname('items').asstring + '''';

    datosdb.tranSQL(s);
  end;

  r.Close; r.free;

end;

procedure TTSolicitudAnalisisFabrissinInternacion.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not solicitud.Active then solicitud.Open;
    if not detsol.Active then detsol.Open;
    if not admisiones.Active then admisiones.Open;
    if not obsitems.Active then obsitems.Open;
    if not obsfinal.Active then obsfinal.Open;
    if not confinf.Active then confinf.Open;
  end;
  Inc(conexiones);
  obsocial.conectar;
  paciente.conectar;
  profesional.conectar;
  sanatorio.conectar;
  nomeclatura.conectar;
  plantanalisis.conectar;
  profesional.conectar;
  nbu.conectar;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(solicitud);
    datosdb.closeDB(detsol);
    datosdb.closeDB(admisiones);
    datosdb.closeDB(obsitems);
    datosdb.closeDB(obsfinal);
    datosdb.closeDB(confinf);
  end;
  obsocial.desconectar;
  paciente.desconectar;
  profesional.desconectar;
  sanatorio.desconectar;
  nomeclatura.desconectar;
  plantanalisis.desconectar;
  profesional.desconectar;
  nbu.desconectar;
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
