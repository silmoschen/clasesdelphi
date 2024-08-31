unit CSolAnalisisisInternacion_Dohrman;

interface

uses CPacienteInternacion_Fabrissin, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     Classes, CObrasSocialesCCBInt, CSanatoriosLaboratorios, CNomeclaCCB, CPlantAnalisis_Int,
     CProfesionalFabrissinInternado, CNBU, Contnrs, CCBloqueosLaboratorios, CUtilidadesArchivos;

const
  elementos = 10;
  esp = ' ';

type

TTSolicitudAnalisisFabrissinInternacion = class
  Protocolo, Fecha, Hora, Codpac, Codos, idprof, Codsan, Habitacion, Admision, Fealta, Febaja,
  Resultado_Analisis, Observacionitems, ObservacionFinal, Retiva, Muestra, Fechafact, FuenteTitulo, FuenteSubtitulo: String;
  LineasPag, lineas_blanco, CS, CI: Integer;
  Titulo: String; Subtitulo: TStringList;
  FechaPago, ConceptoPago, ItemsPago: String;
  MontoPago, EntregaPago, SaldoPago: Real;
  listdatossan, tiene_cobros: Boolean;
  solicitud, detsol, admisiones, resultado, obsitems, obsfinal, confinf, movpagos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xprotocolo: String): Boolean;
  procedure   Registrar(xprotocolo, xfecha, xhora, xcodpac, xcodos, xidprof, xcodsan, xhabitacion, xadmision, xmuestra, xitems, xcodigo: String; xcantitems: Integer);
  procedure   getDatos(xprotocolo: String);
  procedure   Borrar(xprotocolo: String);
  function    setItems(xprotocolo: String): TStringList;
  function    NuevoProtocolo: String;
  function    setProtocolosPaciente(xcodpac: String): TStringList;
  function    setProtocolosPacientePorNro(xcodpac: String): TStringList;
  function    setProtocolosFecha(xfecha: String): TStringList; overload;
  function    setProtocolosFecha(xdesde, xhasta: String): TStringList; overload;
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

  procedure   ListHojaDeTrabajo(xnrosolicitud: string; salida: char);

  procedure   ListarSolicitudes(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarEgresosPacientes(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesPorAdmision(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
  procedure   ListarSolicitudesValorizadas(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesPorAdmisionValorizadas(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
  procedure   ListarSolicitudesCodigosPorAdmision(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
  procedure   ListarSolicitudesValorizadasPorObraSocial(xcodsan, xcodos, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesValorizadasPorFechaFacturacion(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarSolicitudesValorizadasPorFechaFacturacionResumidas(xcodsan, xdesde, xhasta: String; salida: char);
  procedure   ListarCodigosSolicitudes(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);

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

  procedure   ListarResultados(xcodsan, xdfecha, xhfecha: String; xprotocolos: TStringList; salida: char);
  procedure   ListarProtocolo(xprotocolo: String; xdeterminaciones: TStringList; salida: char);
  procedure   ListarResultadoPorAdmision(xcodsan, xcodpac: String; xadmisiones: TStringList; salida: char);

  function    CalcularValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): Real;
  function    setValorAnalisis(xcodos, xcodanalisis, xperiodo: string): Real;
  function    Precio9984: Real;
  function    Total9984: Real;

  // -- Parámetros de Informes
  function    BuscarParametroInf(xid: String): Boolean;
  procedure   RegistrarParametroInf(xid: String; xalto, xsep: Integer);
  procedure   getDatosParametrosInf(xid: String);

  function    setProtocolosAdmision(xnroadmision: String): TStringList;

  // -- Cobros
  function    BuscarMovPagos(xprotocolo, xitems: String): Boolean;
  procedure   RegistrarMovPagos(xprotocolo, xitems, xfecha, xcodpac, xconcepto: String; xtipomov: Integer; xmonto, xentrega: Real; xcantitems: Integer; xmodifica: Boolean);
  procedure   getMovPagos(xprotocolo: String);
  procedure   BorrarMovPagos(xprotocolo: String);
  procedure   BorrarPagosProtocolo(xprotocolo: String);
  procedure   BorrarEntrega(xprotocolo: String);
  procedure   DeterminarEstado(xprotocolo, xestado: String);
  procedure   RecalcularSaldo(xprotocolo: String);
  procedure   ListarMovPagos(xdesde, xhasta: String; salida: char);
  function    setPagosAdeudados(xdesde, xhasta: String): TObjectList;
  function    setProtocolosSaldados(xdesde, xhasta: String): TObjectList;
  function    setPagosRegistrados(xprotocolo: String): TObjectList;

  function    Exportar(xdesde, xhasta: String): TStringList;
  function    setProtocolosImportados: TStringList;
  procedure   Importar(lista: TStringList);
  procedure   ImportarResultados(lista: TStringList);

  function    BloquearCobro: Boolean;
  procedure   QuitarBloqueoCobro;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  pag, lineas, sm: Integer;
  CHR18, CHR15, Caracter, Lin: String;
  listdat: Boolean;
  lcodsan, ldfecha, lhfecha, Periodo, codftoma: String;
  v9984, PorcentajeDifObraSocial, PorcentajeDif9984, t9984: Real;
  totales: array[1..elementos] of Real;
  function    BuscarDetSol(xprotocolo, xitems: String): Boolean;
  function    ControlarSalto: boolean;
  procedure   RealizarSalto;
  procedure   titulo1(xdesde, xhasta: String);
  procedure   ListDetSol(xnrosolicitud: string; detSel: TStringList; salida: char);
  function    setResultados(xnrosolicitud: string): TStringList;
  procedure   TituloResultado(xcodsan, xdfecha, xhfecha: String; salida: char);
  procedure   ListTituloResultado(xcodsan, xdfecha, xhfecha: String; salida: char);
  procedure   TituloResultado1(xcodsan, xdfecha, xhfecha: String; salida: char);
  procedure   ListDatosPaciente(salida: char);
  procedure   ListMemo(xcampo: String; xtabla: TTable; salida: char);
  procedure   titulo2;
  procedure   IniciarArreglos;
  procedure   titulo3(xcodos: String);
  procedure   ListHDeTrabajo(xnrosolicitud: string; salida: char);
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
  movpagos   := datosdb.openDB('movpagos', '');
  LineasPag  := 65;
  chr18      := chr(18);
  chr15      := chr(15);
  Caracter   := '-';
  Subtitulo  := TStringList.Create;
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

procedure TTSolicitudAnalisisFabrissinInternacion.Registrar(xprotocolo, xfecha, xhora, xcodpac, xcodos, xidprof, xcodsan, xhabitacion, xadmision, xmuestra, xitems, xcodigo: String; xcantitems: Integer);
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
  end;

  if BuscarDetSol(xprotocolo, xitems) then detsol.Edit else detsol.Append;
  detsol.FieldByName('protocolo').AsString := xprotocolo;
  detsol.FieldByName('items').AsString     := xitems;
  detsol.FieldByName('codigo').AsString    := xcodigo;
  try
    detsol.Post
   except
    detsol.Cancel
  end;

  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from ' + detsol.TableName + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(solicitud); datosdb.closeDB(detsol);
    solicitud.Open; detsol.Close;
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.getDatos(xprotocolo: String);
// Objetivo...: recuperar una instancia
begin
  if Buscar(xprotocolo) then Begin
    protocolo  := solicitud.FieldByName('protocolo').AsString;
    fecha      := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
    hora       := solicitud.FieldByName('hora').AsString;
    codpac     := solicitud.FieldByName('codpac').AsString;
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
  if BuscarMovPagos(xprotocolo, '001') then tiene_cobros := False else tiene_cobros := True;
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
    if ca = 1 then BorrarAdmision(cp, ad);  // Significa que solo tiene un protocolo en la admisión, lo borramos

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

function  TTSolicitudAnalisisFabrissinInternacion.setItems(xprotocolo: String): TStringList;
// Objetivo...: recuperar items
var
  l: TStringList;
begin
  l := TStringList.Create;
  if BuscarDetSol(xprotocolo, '001') then Begin
    while not detsol.Eof do Begin
      if detsol.FieldByName('protocolo').AsString <> xprotocolo then Break;
      l.Add(detsol.FieldByName('items').AsString + detsol.FieldByName('codigo').AsString);
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

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosPaciente(xcodpac: String): TStringList;
// Objetivo...: devolver los protocolos
var
  l: TStringList;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TStringList.Create;
  solicitud.IndexFieldNames := 'Codpac;Admision';
  datosdb.Filtrar(solicitud, 'codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if solicitud.FieldByName('codpac').AsString <> xcodpac then Break;
    l.Add(solicitud.FieldByName('protocolo').AsString + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + solicitud.FieldByName('codos').AsString + solicitud.FieldByName('idprof').AsString + solicitud.FieldByName('admision').AsString + ';1' + solicitud.FieldByName('retiva').AsString + ';2' + solicitud.FieldByName('muestra').AsString);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  Buscar(protocolo);
  Result := l;
end;

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosPacientePorNro(xcodpac: String): TStringList;
// Objetivo...: devolver los protocolos
var
  l: TStringList;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TStringList.Create;
  solicitud.IndexFieldNames := 'Protocolo';
  datosdb.Filtrar(solicitud, 'codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if solicitud.FieldByName('codpac').AsString <> xcodpac then Break;
    l.Add(solicitud.FieldByName('protocolo').AsString + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + solicitud.FieldByName('codos').AsString + solicitud.FieldByName('idprof').AsString + solicitud.FieldByName('admision').AsString + ';1' + solicitud.FieldByName('retiva').AsString + ';2' + solicitud.FieldByName('muestra').AsString + ';3' +  solicitud.FieldByName('codsan').AsString);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  Buscar(protocolo);
  Result := l;
end;

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosFecha(xfecha: String): TStringList;
// Objetivo...: devolver los protocolos
var
  l: TStringList;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TStringList.Create;
  solicitud.IndexFieldNames := 'Fecha;Muestra';
  datosdb.Filtrar(solicitud, 'fecha = ' + '''' + utiles.sExprFecha2000(xfecha) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    l.Add(solicitud.FieldByName('protocolo').AsString + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + solicitud.FieldByName('codos').AsString + solicitud.FieldByName('idprof').AsString + solicitud.FieldByName('admision').AsString + ';1' + solicitud.FieldByName('retiva').AsString + ';2' + solicitud.FieldByName('muestra').AsString + ';3' + solicitud.FieldByName('codpac').AsString + solicitud.FieldByName('habitacion').AsString);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  Buscar(protocolo);
  Result := l;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarAdmisionProtocolo(xprotocolo: String);
// Objetivo...: borrar admisión desde protocolo
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

    // Verificamos a ver si queda algun protocolo con esa admisión
    solicitud.IndexFieldNames := 'admision';
    if not solicitud.FindKey([nroadmision]) then Begin  // Significa que ya no queda ningun protocolo con ese nro. de admisión
      datosdb.tranSQL('delete from ' + admisiones.TableName + ' where admision = ' + '''' + nroadmision + '''');
      datosdb.refrescar(admisiones);
    end;
    solicitud.IndexFieldNames := 'protocolo';
  end;
end;

function  TTSolicitudAnalisisFabrissinInternacion.setProtocolosFecha(xdesde, xhasta: String): TStringList;
// Objetivo...: devolver los protocolos
var
  l: TStringList;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TStringList.Create;
  solicitud.IndexFieldNames := 'Fecha;Muestra';
  datosdb.Filtrar(solicitud, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    l.Add(solicitud.FieldByName('protocolo').AsString + solicitud.FieldByName('codpac').AsString);
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

  // Registramos el nro. de admisión en el protocolo
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
// Objetivo...: imprimir lineas en blanco hasta realizar salto de página
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
  det: TStringList;
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
    List.Titulo(35, List.lineactual, 'Médico', 4, 'Arial, cursiva, 8');
    List.Titulo(55, List.lineactual, 'Obra Social', 5, 'Arial, cursiva, 8');
    List.Titulo(72, List.lineactual, 'Nro.Adm.', 6, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 7, 'Arial, cursiva, 8');
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
          list.Linea(17, list.Lineactual, Copy(paciente.nombre, 1, 20), 3, 'Arial, normal, 8', salida, 'N');
          list.Linea(35, list.Lineactual, Copy(profesional.nombres, 1, 20), 4, 'Arial, normal, 8', salida, 'N');
          list.Linea(55, list.Lineactual, Copy(obsocial.nombre, 1, 22), 5, 'Arial, normal, 8', salida, 'N');
          list.Linea(72, list.Lineactual, admisiones.FieldByName('admision').AsString, 6, 'Arial, normal, 8', salida, 'N');
          k := 6; j := 7; t := 0;
          For i := 1 to det.Count do Begin
            j := j + 4;
            Inc(k);
            Inc(t);
            if t < 4 then list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'N') else Begin
              list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'S');
              if i < det.Count then Begin
                list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
                j := 7; k := 1;
              end;
              t := 0;
            end;
          end;

          if k <> 1 then list.Linea(97, list.Lineactual, '', k+1, 'Arial, normal, 8', salida, 'S');

        end;

        if (salida = 'T') then Begin
          list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
          list.LineaTxt(Copy(paciente.nombre, 1, 20) + utiles.espacios(22 - (Length(Trim(copy(paciente.nombre, 1, 20))))), False);
          list.LineaTxt(Copy(profesional.nombres, 1, 20) + utiles.espacios(22 - (Length(Trim(Copy(profesional.nombres, 1, 20))))), False);
          list.LineaTxt(Copy(obsocial.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(obsocial.nombre, 1, 25))))), False);
          list.LineaTxt(admisiones.FieldByName('admision').AsString + utiles.espacios(18 - (Length(Trim(admisiones.FieldByName('admision').AsString)))), False);
          k := 5; j := 7; t := 0;
          For i := 1 to det.Count do Begin
            j := j + 4;
            Inc(k);
            Inc(t);
            if t < 4 then list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', False) else Begin
              list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', True);
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

procedure TTSolicitudAnalisisFabrissinInternacion.ListHojaDeTrabajo(xnrosolicitud: string; salida: char);
// Objetivo...: Listar hoja de trabajo
begin
  ListHDeTrabajo(xnrosolicitud, salida);
  list.CompletarPagina;
  list.FinList;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListHDeTrabajo(xnrosolicitud: string; salida: char);
// Objetivo...: Listar Observaciones de Solicitud
const
  c: string = ' ';
var
  os, ls, x, s, edadpac: string; lineas, i, j: integer;
  l: TStringList;
begin
  getDatos(xnrosolicitud);  // Cargamos la solicitud pedida

  list.Setear(salida);
  list.NoImprimirPieDePagina;

  //titulos.base_datos := dbs.baseDat_N;
  //titulos.conectar;
  List.Linea(0, 0, '  ', 1, 'Arial, negrita, 13', salida, 'N'); List.Linea(54, list.lineactual, '  ' + TrimLeft(titulo), 2, 'Arial, negrita, 13', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  For i := 1 to subtitulo.Count do Begin
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 9', salida, 'N');
    List.Linea(54, list.Lineactual, '  ' + subtitulo.Strings[i-1], 2, 'Arial, cursiva, 8', salida, 'S');
  end;
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 9', salida, 'S');

  //list.ListMemoRecortandoEspaciosVericales('Direccion', 'Arial, normal, 8', 55, salida, titulos.tabla, 0);
  //List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  //list.ListMemoRecortandoEspaciosVericales('Actividad', 'Arial, cursiva, 7', 55, salida, titulos.tabla, 0);
  //List.Linea(0, 0, NSanatorio, 1, 'Arial, negrita, 10', salida, 'S');
  //if Length(Trim(NSanatorio)) > 0 then List.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  //titulos.desconectar;

  profesional.getDatos(idprof);

  // 1º Línea
  List.Linea(0, 0, 'Nombre ', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + paciente.nombre, 2, 'Arial, normal, 9', salida, 'N');
  List.Linea(55, list.Lineactual, 'Nombre ', 3, 'Arial, normal, 9', salida, 'N'); List.Linea(66, list.Lineactual, ':  ' + paciente.nombre, 4, 'Arial, normal, 9', salida, 'S');
  // 2º Línea
  if Copy(paciente.fenac, 7, 2) > '05' then s := '19' else s := '20';
  x := Copy(paciente.Fenac, 1, 6) + s + Copy(paciente.Fenac, 7, 2);
  if Length(Trim(paciente.fenac)) > 0 then edadpac := IntToStr(utiles.Edad(x)) else edadpac := '';
  List.Linea(0, 0, 'Edad ', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + edadpac, 2, 'Arial, normal, 9', salida, 'N');
  List.Linea(55, list.Lineactual, 'Edad ', 3, 'Arial, normal, 9', salida, 'N'); List.Linea(66, list.Lineactual, ':  ' + edadpac, 4, 'Arial, normal, 9', salida, 'S');
  // 3º Línea
  List.Linea(0, 0, 'Nº Protocolo', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + protocolo, 2, 'Arial, normal, 10', salida, 'N');
  List.Linea(55, list.Lineactual, 'Nº Protocolo', 3, 'Arial, normal, 9', salida, 'N'); List.Linea(66, list.Lineactual, ':  ' + protocolo, 4, 'Arial, normal, 9', salida, 'S');
  // 4º Línea
  List.Linea(0, 0, 'Fecha ', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + fecha, 2, 'Arial, normal, 9', salida, 'N');
  List.Linea(55, list.Lineactual, 'Fecha ', 3, 'Arial, normal, 9', salida, 'N'); List.Linea(66, list.Lineactual, ':  ' + fecha, 4, 'Arial, normal, 9', salida, 'S');
  // 5º Línea
  List.Linea(0, 0, 'Profesional', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(11, list.Lineactual, ':  ' + profesional.nombres, 2, 'Arial, normal, 9', salida, 'N');
  List.Linea(55, list.Lineactual, 'Profesional', 3, 'Arial, normal, 9', salida, 'N'); List.Linea(66, list.Lineactual, ':  ' + profesional.nombres, 4, 'Arial, normal, 9', salida, 'S');
  // 6º Línea
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 4', salida, 'S');
  // 7º Línea
  List.Linea(0, 0, 'Abona', 1, 'Arial, cursiva, 8', salida, 'N'); List.Linea(6, list.Lineactual, ':', 2, 'Arial, cursiva, 8', salida, 'N'); List.importe(15, list.Lineactual, '', MontoPago, 3, 'Arial, cursiva, 8');
  List.Linea(16, list.Lineactual, 'Entrega', 4, 'Arial, normal, 8', salida, 'N'); List.Linea(22, list.Lineactual, ':', 5, 'Arial, normal, 8', salida, 'N'); List.importe(31, list.Lineactual, '', EntregaPago, 6, 'Arial, normal, 8');
  List.Linea(34, list.Lineactual, 'Saldo', 7, 'Arial, normal, 8', salida, 'N'); List.Linea(39, list.Lineactual, ':', 8, 'Arial, normal, 8', salida, 'N'); List.importe(49, list.Lineactual, '', MontoPago - EntregaPago, 9, 'Arial, normal, 8');

  // 8º Línea
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Solicitud:', 1, 'Arial, cursiva, 9', salida, 'N');
  List.Linea(55, list.lineactual, 'Solicitud:', 2, 'Arial, cursiva, 9', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');

  // Obtenemos la lista de análisis
  l := solanalisisint.setItems(protocolo);
  for i := 1 to l.Count do Begin
    nomeclatura.getDatos(Copy(l.Strings[i-1], 4, 4));
    //obsocial.getDatos(r.FieldByName('codos').AsString);
    //if r.FieldByName('entorden').AsString = 'S' then ls := '[S]' else ls := '[N]';
    //if r.FieldByName('codos').AsString <> '0000' then os := ls + ' ' + obsocial.nombre else os := ' ';
    List.Linea(0, 0, '   ' + Copy(l.Strings[i-1], 4, 4) + ' ' + Copy(nomeclatura.descrip, 1, 36), 1, 'Arial, normal, 9', salida, 'N');
    List.Linea(38, list.Lineactual, ''{Copy(os, 1, 15)}, 2, 'Arial, normal, 9', salida, 'N');
    List.Linea(56, list.Lineactual, Copy(l.Strings[i-1], 4, 4) + ' ' + nomeclatura.descrip, 3, 'Arial, normal, 9', salida, 'S');
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  end;
  l.Free; l := Nil;

  //list.ListMemo('observaciones', 'Arial, cursiva, 8', 0, salida, solicitud, 0);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudes(xcodsan, xdesde, xhasta: String; salida: char);
// Objetivo...: cerrar tablas de persistencia
var
  det: TStringList;
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
    List.Titulo(0, 0, ' Planilla de Ingresos Lapso: ' + xdesde + ' - ' + xhasta + ' Ent. Der.: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo  N.Mu.', 1, 'Arial, cursiva, 8');
    List.Titulo(14, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(21, List.lineactual, 'Paciente', 3, 'Arial, cursiva, 8');
    List.Titulo(37, List.lineactual, 'Médico', 4, 'Arial, cursiva, 8');
    List.Titulo(57, List.lineactual, 'Obra Social', 5, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, '', 6, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 7, 'Arial, cursiva, 8');
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

    det := setItems(solicitud.FieldByName('protocolo').AsString);
    paciente.getDatos(solicitud.FieldByName('codpac').AsString);
    profesional.getDatos(solicitud.FieldByName('idprof').AsString);
    obsocial.getDatos(solicitud.FieldByName('codos').AsString);
    listdat := True;

    Inc(c);

    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, solicitud.FieldByName('protocolo').AsString + ' ' + solicitud.FieldByName('muestra').AsString, 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(14, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(21, list.Lineactual, Copy(paciente.nombre, 1, 20), 3, 'Arial, normal, 8', salida, 'N');
      list.Linea(37, list.Lineactual, Copy(profesional.nombres, 1, 20), 4, 'Arial, normal, 8', salida, 'N');
      list.Linea(57, list.Lineactual, Copy(obsocial.nombre, 1, 25), 5, 'Arial, normal, 8', salida, 'N');
      list.Linea(77, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'N');
      k := 6; j := 7; t := 0;
      For i := 1 to det.Count do Begin
        j := j + 4;
        Inc(k);
        Inc(t);
        if t < 4 then list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'N') else Begin
          list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'S');
          if i < det.Count then Begin
            list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
            j := 7; k := 1;
          end;
          t := 0;
        end;
      end;

      if k <> 1 then list.Linea(97, list.Lineactual, '', k+1, 'Arial, normal, 8', salida, 'S');

    end;

    if (salida = 'T') then Begin
      list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + ' ' + solicitud.FieldByName('muestra').AsString + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
      list.LineaTxt(Copy(paciente.nombre, 1, 20) + utiles.espacios(22 - (Length(Trim(copy(paciente.nombre, 1, 20))))), False);
      list.LineaTxt(Copy(profesional.nombres, 1, 20) + utiles.espacios(22 - (Length(Trim(Copy(profesional.nombres, 1, 20))))), False);
      list.LineaTxt(Copy(obsocial.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(obsocial.nombre, 1, 25))))), False);
      list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), False);
      k := 5; j := 7; t := 0;
      For i := 1 to det.Count do Begin
        j := j + 4;
        Inc(k);
        Inc(t);
        if t < 4 then list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', False) else Begin
          list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', True);
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

  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Pacientes Listados: ' + IntToStr(c), 1, 'Arial, negrita, 9', salida, 'S');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt('', True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
    list.LineaTxt('Cantidad de Pacientes Listados: ' + IntToStr(c), True); Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
  end;


  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarSolicitudesPorAdmision(xcodsan, xcodpac: String; xlistadmisiones: TStringList; salida: char);
// Objetivo...: Listar Solicitudes por Admisión
var
  det: TStringList;
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
    List.Titulo(0, 0, ' Planilla de Ingresos por Admisión - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'Médico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitación', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 6, 'Arial, cursiva, 8');
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
          list.Linea(0, 0, 'Admisión Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
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
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, normal, 8', salida, 'N');
        k := 5; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'N') else Begin
            list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'S');
            if i < det.Count then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

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
          if t < 4 then list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', False) else Begin
            list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', True);
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
  det: TStringList;
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
    List.Titulo(0, 0, ' Detalle de Ingresos Lapso: ' + xdesde + ' - ' + xhasta + ' Ent. Deriv.: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(17, List.lineactual, 'Paciente', 3, 'Arial, cursiva, 8');
    List.Titulo(37, List.lineactual, 'Médico', 4, 'Arial, cursiva, 8');
    List.Titulo(57, List.lineactual, 'Obra Social', 5, 'Arial, cursiva, 8');
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
      list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
      list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
      list.Linea(17, list.Lineactual, Copy(paciente.nombre, 1, 20), 3, 'Arial, negrita, 8', salida, 'N');
      list.Linea(37, list.Lineactual, Copy(profesional.nombres, 1, 20), 4, 'Arial, negrita, 8', salida, 'N');
      list.Linea(57, list.Lineactual, Copy(obsocial.nombre, 1, 25), 5, 'Arial, negrita, 8', salida, 'N');
      list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 6, 'Arial, negrita, 8', salida, 'S');

      k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
      For i := 1 to det.Count do Begin
        list.Linea(k, t, Copy(det.Strings[i-1], 4, 4), c, 'Arial, cursiva, 8', salida, 'N');
        t := list.Lineactual;
        monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
        totales[1] := totales[1] + monto;
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
      list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + ' ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
      list.LineaTxt(Copy(paciente.nombre, 1, 20) + utiles.espacios(22 - (Length(Trim(copy(paciente.nombre, 1, 20))))), False);
      list.LineaTxt(Copy(profesional.nombres, 1, 20) + utiles.espacios(22 - (Length(Trim(Copy(profesional.nombres, 1, 20))))), False);
      list.LineaTxt(Copy(obsocial.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(obsocial.nombre, 1, 25))))), False);
      list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), True);
      Inc(lineas); if controlarSalto then titulo1(xdesde, xhasta);
      k := 0; j := 0; t := 0; c := 1;
      For i := 1 to det.Count do Begin
        list.LineaTxt(Copy(det.Strings[i-1], 4, 4), False);

        monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
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
      list.derecha(60, list.Lineactual, '', 'Retención I.V.A.:', 2, 'Arial, normal, 10');
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
      list.LineaTxt(utiles.espacios(26) + 'Retención I.V.A.        :             ', False);
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
// Objetivo...: Listar Solicitudes por Admisión Valorizadas
var
  det: TStringList;
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
    List.Titulo(0, 0, ' Planilla de Ingresos por Admisión - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'Médico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitación', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 6, 'Arial, cursiva, 8');
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
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('admision').AsString) then Begin
      if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Admisión Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
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
      totales[6] := 0;

      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'S');

        k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
        For i := 1 to det.Count do Begin
          list.Linea(k, t, Copy(det.Strings[i-1], 4, 4), c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
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
          list.Linea(k, t, codftoma, c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := totales[2];
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

        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;

      if (salida = 'T') then Begin
        list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 1, 5) + '      ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
        list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
        list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
        list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), True);

        k := 0; j := 0; t := 0; c := 1;
        For i := 1 to det.Count do Begin
          list.LineaTxt(Copy(det.Strings[i-1], 4, 4), False);

          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
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
      list.derecha(60, list.Lineactual, '', 'Retención I.V.A.:', 2, 'Arial, normal, 10');
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
      list.LineaTxt(utiles.espacios(26) + 'Retención I.V.A.        :             ', False);
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
// Objetivo...: Listar Solicitudes por Admisión Valorizadas
var
  det: TStringList;
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
    List.Titulo(0, 0, ' Planilla de Códigos por Admisión - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'Médico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitación', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 6, 'Arial, cursiva, 8');
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
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and codpac = ' + '''' + xcodpac + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if utiles.verificarItemsLista(xlistadmisiones, solicitud.FieldByName('admision').AsString) then Begin
      if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
        paciente.getDatos(solicitud.FieldByName('codpac').AsString);
        if (salida = 'P') or (salida = 'I') then Begin
          list.Linea(0, 0, 'Admisión Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
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
        list.Linea(0, 0, Copy(solicitud.FieldByName('protocolo').AsString, 6, 5), 1, 'Arial, negrita, 8', salida, 'N');
        list.Linea(10, list.Lineactual, utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Arial, negrita, 8', salida, 'N');
        list.Linea(25, list.Lineactual, Copy(profesional.nombres, 1, 25), 3, 'Arial, negrita, 8', salida, 'N');
        list.Linea(50, list.Lineactual, Copy(obsocial.nombre, 1, 30), 4, 'Arial, negrita, 8', salida, 'N');
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, negrita, 8', salida, 'S');

        k := 0; j := 0; t := 0; c := 1; totales[2] := 0; totales[5] := 0;
        For i := 1 to det.Count do Begin
          list.Linea(k, t, Copy(det.Strings[i-1], 4, 4), c, 'Arial, cursiva, 8', salida, 'N');
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
          list.LineaTxt(Copy(det.Strings[i-1], 4, 4), False);

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
// Objetivo...: Listar Solicitudes por Admisión Valorizadas
var
  det: TStringList;
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
    List.Titulo(0, 0, ' Planilla de Ingresos por Obra Social - Ent. Deriv.: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    obsocial.getDatos(xcodos);
    List.Titulo(0, 0, 'Obra Social: ' + obsocial.nombre, 1, 'Arial, normal, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'Médico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;

  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
    titulo3(xcodos);
  end;

  protocolo := solicitud.FieldByName('codpac').AsString;
  IniciarArreglos;
  solicitud.IndexFieldNames := 'codpac;admision';
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and codos = ' + '''' + xcodos + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if (solicitud.FieldByName('codpac').AsString <> codpacanter) or (solicitud.FieldByName('admision').AsString <> admisionanter) then Begin
      paciente.getDatos(solicitud.FieldByName('codpac').AsString);
      if (salida = 'P') or (salida = 'I') then Begin
        list.Linea(0, 0, 'Admisión Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
        list.Linea(40, list.Lineactual, 'Paciente: ' + paciente.nombre, 2, 'Arial, negrita, 9, clNavy', salida, 'S');
        list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      end;
      if (salida = 'T') then Begin
        if listdat then Begin
          list.LineaTxt(' ', True);
          Inc(lineas); if controlarSalto then titulo3(xcodos);
        end;
        list.LineaTxt(CHR18 + 'Admision Nro.: ' +  solicitud.FieldByName('admision').AsString + utiles.espacios(12 - (Length(Trim(solicitud.FieldByName('admision').AsString)))), False);
        list.LineaTxt('Paciente: ' + paciente.nombre + CHR15, True);
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
        list.Linea(k, t, Copy(det.Strings[i-1], 4, 4), c, 'Arial, cursiva, 8', salida, 'N');
        t := list.Lineactual;
        monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
        totales[1] := totales[1] + monto;
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
      list.LineaTxt(Copy(solicitud.FieldByName('protocolo').AsString, 6, 5) + '      ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' ', False);
      list.LineaTxt(Copy(profesional.nombres, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(profesional.nombres, 1, 25))))), False);
      list.LineaTxt(Copy(obsocial.nombre, 1, 30) + utiles.espacios(32 - (Length(Trim(Copy(obsocial.nombre, 1, 30))))), False);
      list.LineaTxt(Copy(solicitud.FieldByName('habitacion').AsString, 1, 15) + utiles.espacios(16 - (Length(Trim(solicitud.FieldByName('habitacion').AsString)))), True);

      k := 0; j := 0; t := 0; c := 1;
      For i := 1 to det.Count do Begin
        list.LineaTxt(Copy(det.Strings[i-1], 4, 4), False);

        monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
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
          Inc(lineas); if controlarSalto then titulo3(xcodos);
          k := 0; j := 0; t := 0; c := 1;
        end;
      end;

      list.LineaTxt('', True);
      Inc(lineas); if controlarSalto then titulo3(xcodos);
    end;

    if (obsocial.Retencioniva > 0) and (solicitud.FieldByName('retiva').AsString = 'S') then Begin
      totales[4] := ((totales[5] + totales[2]) * (obsocial.Retencioniva * 0.01));
      totales[3] := totales[3] + totales[4];
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
      list.derecha(60, list.Lineactual, '', 'Retención I.V.A.:', 2, 'Arial, normal, 10');
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
      list.LineaTxt(utiles.espacios(26) + 'Retención I.V.A.        :             ', False);
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
// Objetivo...: Listar Solicitudes por Admisión Valorizadas
var
  det: TStringList;
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
    List.Titulo(25, List.lineactual, 'Médico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitación', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 6, 'Arial, cursiva, 8');
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
          list.Linea(20, list.Lineactual, Copy(paciente.nombre, 1, 25), 2, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(60, list.Lineactual, 'In./Eg./Fact.: ' + utiles.sFormatoFecha(admisiones.FieldByName('fealta').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('febaja').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('fechafact').AsString), 3, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
          end;
          list.LineaTxt(CHR18 + 'Adm.: ' +  solicitud.FieldByName('admision').AsString + ' ' + Copy(paciente.nombre, 1, 20) + utiles.espacios(32 - (Length(Trim(solicitud.FieldByName('admision').AsString + Copy(paciente.nombre, 1, 20))))), False);
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
          list.Linea(k, t, Copy(det.Strings[i-1], 4, 4), c, 'Arial, cursiva, 8', salida, 'N');
          t := list.Lineactual;
          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
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
          list.LineaTxt(Copy(det.Strings[i-1], 4, 4), False);

          monto := setValorAnalisis(solicitud.FieldByName('codos').AsString, Copy(det.Strings[i-1], 4, 4), Copy(solicitud.FieldByName('fecha').AsString, 5, 2) + '/' + Copy(solicitud.FieldByName('fecha').AsString, 1, 4));
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
      list.derecha(60, list.Lineactual, '', 'Retención I.V.A.:', 2, 'Arial, normal, 10');
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
      list.LineaTxt(utiles.espacios(26) + 'Retención I.V.A.        :             ', False);
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
// Objetivo...: Listar Solicitudes por Admisión Valorizadas
var
  det: TStringList;
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
    List.Titulo(25, List.lineactual, 'Médico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitación', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 6, 'Arial, cursiva, 8');
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
          list.Linea(20, list.Lineactual, Copy(paciente.nombre, 1, 25), 2, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(60, list.Lineactual, 'In./Eg./Fact.: ' + utiles.sFormatoFecha(admisiones.FieldByName('fealta').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('febaja').AsString) + '  ' + utiles.sFormatoFecha(admisiones.FieldByName('fechafact').AsString), 3, 'Arial, negrita, 8, clNavy', salida, 'S');
          list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if listdat then Begin
            list.LineaTxt(' ', True);
            Inc(lineas); if controlarSalto then titulo3('Planilla de Admisiones - Sanatorio: ' + sanatorio.Descrip);
          end;
          list.LineaTxt(CHR18 + 'Adm.: ' +  solicitud.FieldByName('admision').AsString + ' ' + Copy(paciente.nombre, 1, 20) + utiles.espacios(32 - (Length(Trim(solicitud.FieldByName('admision').AsString + Copy(paciente.nombre, 1, 20))))), False);
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
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'N') else Begin
            list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'S');
            if i < det.Count then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

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
          if t < 4 then list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', False) else Begin
            list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', True);
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
// Objetivo...: Listar Solicitudes por Admisión
var
  det: TStringList;
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
    List.Titulo(0, 0, ' Planilla de Ingresos por Admisión - Sanatorio: ' + sanatorio.Descrip, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Protocolo', 1, 'Arial, cursiva, 8');
    List.Titulo(10, List.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
    List.Titulo(25, List.lineactual, 'Médico', 3, 'Arial, cursiva, 8');
    List.Titulo(50, List.lineactual, 'Obra Social', 4, 'Arial, cursiva, 8');
    List.Titulo(77, List.lineactual, 'Habitación', 5, 'Arial, cursiva, 8');
    List.Titulo(87, List.lineactual, 'Códigos', 6, 'Arial, cursiva, 8');
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
          list.Linea(0, 0, 'Admisión Nro.: ' + solicitud.FieldByName('admision').AsString, 1, 'Arial, negrita, 9, clNavy', salida, 'N');
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
        list.Linea(77, list.Lineactual, Copy(solicitud.FieldByName('habitacion').AsString, 1, 10), 5, 'Arial, normal, 8', salida, 'N');
        k := 5; j := 7; t := 0;
        For i := 1 to det.Count do Begin
          j := j + 4;
          Inc(k);
          Inc(t);
          if t < 4 then list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'N') else Begin
            list.Linea(75 + j, list.Lineactual, Copy(det.Strings[i-1], 4, 4), k, 'Arial, normal, 8', salida, 'S');
            if i < det.Count then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
              j := 7; k := 1;
            end;
            t := 0;
          end;
        end;

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
          if t < 4 then list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', False) else Begin
            list.LineaTxt(Copy(det.Strings[i-1], 4, 4) + ' ', True);
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
// Objetivo...: Buscar una instancia perteneciente a resultados de un análisis
begin
  if resultado.IndexFieldNames <> 'protocolo;codanalisis;items' then resultado.IndexFieldNames := 'protocolo;codanalisis;items';
  Result := datosdb.Buscar(resultado, 'protocolo', 'codanalisis', 'items', xprotocolo, xcodanalisis, xitems);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.GuardarResultado(xprotocolo, xcodanalisis, xitems, xresultado, xvaloresn, xnroanalisis: string; xcantidaditems: Integer);
// Objetivo...: Almacenar las instancias pertenecientes a los resultados de un análisis
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
    datosdb.closedb(resultado); resultado.Open;
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarResultado(xprotocolo: string);
// Objetivo...: Borrar las instancias pertenecientes a los resultados de un análisis
begin
  datosdb.tranSQL('delete from ' + resultado.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.tranSQL('delete from ' + obsitems.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.tranSQL('delete from ' + obsfinal.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.refrescar(resultado);
  datosdb.refrescar(obsitems);
  datosdb.refrescar(obsfinal);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.BorrarResultadoDeterminacion(xprotocolo, xcodanalisis: string);
// Objetivo...: Borrar las instancias pertenecientes a los resultados de un análisis
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

function TTSolicitudAnalisisFabrissinInternacion.setResultados(xnrosolicitud: string): TStringList;
// Objetivo...: devolver un set de registros con los resultados de análisis de una solicitud
var
  l: TStringList;
begin
  l := TStringList.Create;
  //if not resultado.Active then resultado.Open;
  resultado.IndexFieldNames := 'protocolo;nroanalisis;items';
  datosdb.Filtrar(resultado, 'protocolo = ' + '''' + xnrosolicitud + '''');
  resultado.First;
  while not resultado.Eof do Begin
    if resultado.FieldByName('protocolo').AsString <> xnrosolicitud then Break;
    l.Add(resultado.FieldByName('protocolo').AsString + resultado.FieldByName('codanalisis').AsString + resultado.FieldByName('items').AsString + resultado.FieldByName('resultado').AsString + ';1' + resultado.FieldByName('valoresn').AsString);
    resultado.Next;
  end;
  datosdb.QuitarFiltro(resultado);
  resultado.IndexFieldNames := 'protocolo;codanalisis;items';
  Result := l;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListarResultados(xcodsan, xdfecha, xhfecha: String; xprotocolos: TStringList; salida: char);
// Objetivo...: Listar Resultados por fecha y sanatorio
var
  registros, j: Integer;
Begin
  if salida = 'T' then Begin
    list.IniciarImpresionModoTexto(LineasPag);
  end else
  lcodsan := xcodsan; ldfecha := xdfecha; lhfecha := xhfecha;
  ldfecha := ''; lhfecha := '';
  listdat := False;
  if salida = 'P' then Begin
    list.Setear(salida);
    TituloResultado(codsan, '', '', salida);
  end;
  if salida = 'T' then TituloResultado(codsan, '', '', salida);
  list.NoImprimirPieDePagina;
  datosdb.Filtrar(solicitud, 'codsan = ' + '''' + xcodsan + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  registros := solicitud.RecordCount;
  solicitud.First; j := 0;
  while not solicitud.Eof do Begin
    Inc(j);
    if salida = 'I' then Begin
      list.Setear(salida);
      TituloResultado(codsan, '', '', salida);
    end;

    if utiles.verificarItemsLista(xprotocolos, solicitud.FieldByName('protocolo').AsString) then ListDetSol(solicitud.FieldByName('protocolo').AsString, Nil, salida);
    if salida = 'T' then Begin
      RealizarSalto;
      if j < registros then TituloResultado(codsan, '', '', salida);
    end;
    if (salida = 'P') then Begin
      ListTituloResultado(codsan, '', '', salida);
      list.CompletarPagina;
    end;
    if salida = 'I' then list.FinList;

    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  if (salida = 'P') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then list.FinalizarImpresionModoTexto(1);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarProtocolo(xprotocolo: String; xdeterminaciones: TStringList; salida: char);
// Objetivo...: Listar Protocolo Individual
var
  ts: char;
Begin
  list.NoImprimirPieDePagina;
  listdat := False;
  ts := salida;
  if salida = 'N' then salida := 'T';
  if salida = 'T' then list.IniciarImpresionModoTexto(LineasPag) else list.Setear(salida);
  list.altopag := 0; list.m := 0;
  getDatos(xprotocolo);
  lcodsan := codsan; ldfecha := utiles.setFechaActual; lhfecha := utiles.setFechaActual;
  sanatorio.getDatos(lcodsan);
  TituloResultado(codsan, '', '', salida);
  ListDetSol(xprotocolo, xdeterminaciones, salida);
  if (salida = 'P') or (salida = 'I') then Begin
    if not listdat then list.Linea(0, 0, 'No Existen Datos para Listar ...!', 1, 'Arial, normal, 9', salida, 'S');
    list.FinList;
  end;
  if salida = 'T' then Begin
    RealizarSalto;
    if ts = 'T' then list.FinalizarImpresionModoTextoSinSaltarPagina(1) else
      list.FinalizarExportacion;
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarResultadoPorAdmision(xcodsan, xcodpac: String; xadmisiones: TStringList; salida: char);
// Objetivo...: Listar Resultados por Admisión
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
  f1, f2: String;
Begin
  if Length(Trim(fuentetitulo)) = 0 then f1 := 'Arial, negrita, 20' else f1 := fuentetitulo;
  if Length(Trim(fuentesubtitulo)) = 0 then f2 := 'Arial, normal, 10' else f2 := fuentesubtitulo;

  j := 0;
  if (salida = 'P') or (salida = 'I') then Begin
    list.Titulo(0, 0, '', 1, 'Arial, normal, 18');
    if Length(Trim(xdfecha)) = 8 then list.Titulo(0, 0, 'Informe de Resultados Lapso: ' + xdfecha + '-' + xhfecha, 1, 'Arial, negrita, 14') else Begin
      List.Titulo(0, 0, titulo, 1, f1);
      For i := 1 to subtitulo.Count do
        List.Titulo(0, 0, '  ' + subtitulo.Strings[i-1], 1, f2);
    end;
    if listdatossan then Begin
      list.Titulo(0, 0, '*** Sanatorio: ' + xcodsan + ' - ' + sanatorio.Descrip + ' ***', 1, 'Arial, normal, 12');
      list.Titulo(70, list.Lineactual, 'Teléfono: ' + sanatorio.Telefono, 2, 'Arial, normal, 12');
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
      list.Linea(70, list.Lineactual, 'Teléfono: ' + sanatorio.Telefono, 2, 'Arial, normal, 12', salida, 'S');
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
      list.Titulo(70, list.Lineactual, 'Teléfono: ' + sanatorio.Telefono, 2, 'Arial, normal, 12');
    end;
    list.Titulo(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11');
    list.Titulo(0, 0, '', 1, 'Arial, normal, 8');
  end;
  if (salida = 'T') then Begin
    list.LineaTxt(CHR18 + esp + ' ', True);
    Lineas := 2;
    list.LineaTxt(esp + list.ancho_doble_seleccionar + Titulo + list.ancho_doble_cancelar, True);
    Inc(lineas);
    list.LineaTxt(CHR18 + esp + list.modo_resaltado_seleccionar + 'Paciente: ' + solicitud.FieldByName('codpac').AsString + ' ' + Copy(paciente.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(paciente.nombre, 1, 25))))) + ' Fecha: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' Muestra: ' + solicitud.FieldByName('muestra').AsString, True);
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
var
  i: Integer;
Begin
  if (salida = 'P') or (salida = 'I') then Begin
    for i := 1 to CS do list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    paciente.getDatos(solicitud.FieldByName('codpac').AsString);
    obsocial.getDatos(solicitud.FieldByName('codos').AsString);
    profesional.getDatos(solicitud.FieldByName('idprof').AsString);
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Paciente: ' + paciente.nombre, 1, 'Times New Roman, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Indicación del Dr/a.: ' + profesional.nombres, 1, 'Times New Roman, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Protocolo Nro.: ' + solicitud.FieldByName('protocolo').AsString, 1, 'Times New Roman, normal, 11', salida, 'N');
    list.Linea(50, list.Lineactual, 'Fecha: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString), 2, 'Times New Roman, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    for i := 1 to CI do list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
  end;
  if (salida = 'T') then Begin
    for i := 1 to CS do Begin
      list.LineaTxt('', True);
      Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    end;
    paciente.getDatos(solicitud.FieldByName('codpac').AsString);
    obsocial.getDatos(solicitud.FieldByName('codos').AsString);
    profesional.getDatos(solicitud.FieldByName('idprof').AsString);
    list.LineaTxt(CHR18 + esp + list.modo_resaltado_seleccionar + 'Paciente: ' + Copy(paciente.nombre, 1, 25) + utiles.espacios(27 - (Length(Trim(Copy(paciente.nombre, 1, 25))))), True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(esp + 'Indicacion del Dr/a.: ' + Copy(profesional.nombres, 1, 35), True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(esp +  'Protocolo Nro. ' + solicitud.FieldByName('protocolo').AsString + '   Fecha: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + ' Nro. Muestra: ' + solicitud.FieldByName('muestra').AsString + '             Dr.: ' + profesional.nombres + list.modo_resaltado_cancelar + CHR(18), True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(utiles.sLlenarIzquierda(lin, 80, Caracter), True); Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    list.LineaTxt(CHR15, True);
    Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    for i := 1 to CI do Begin
      list.LineaTxt('', True);
      Inc(lineas); if controlarSalto then TituloResultado(lcodsan, ldfecha, lhfecha, salida);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ListDetSol(xnrosolicitud: string; detSel: TStringList; salida: char);
// Objetivo...: Listar detalle de la solicitud
var
  r, t: TStringList; xcodanalisisanter, xnrosolanter, fuente, codanter, itobs: string; distancia, i, j, p1, k: integer; f, imp, itp, l_dat, seg_it, l_items: boolean;
begin
  fuente := 'Arial, normal, 10';
  r := setResultados(xnrosolicitud); t := r; l_dat := False;
  xcodanalisisanter := ''; protocolo := xnrosolicitud;
  For i := 1 to r.Count do Begin
    if utiles.verificarItemsLista(detSel, Copy(r.Strings[i-1], 11, 4)) then Begin

      if not (l_dat) then Begin  // Datos del Paciente
        ListDatosPaciente(salida);
        l_dat := True;
      end;

      listdat := True;
      l_items := True;

      if Copy(r.Strings[i-1], 11, 4) <> xcodanalisisanter then Begin


        if Length(Trim(xcodanalisisanter)) > 0 then Begin // Observaciones de análisis
          if (salida = 'I') or (salida = 'P') then Begin
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
          end;
          if (salida = 'I') or (salida = 'P') then Begin
            if not List.EfectuoSaltoPagina then List.Linea(0, 0, '  ', 1, fuente, salida, 'S') else Begin // En la misma página
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 24', salida, 'S');
            end;
          end;
        end;
        nomeclatura.getDatos(Copy(r.Strings[i-1], 11, 4));

        if (salida = 'I') or (salida = 'P') then
          List.Linea(0, 0, ' ' + UpperCase(nomeclatura.descrip), 1, 'Arial, negrita, 9', salida, 'S')
        else Begin
          if Copy(r.Strings[i-1], 11, 4) <> codanter then Begin
            list.LineaTxt('', True);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
            codanter := Copy(r.Strings[i-1], 11, 4);
          end;
          list.LineaTxt(CHR18 + list.modo_resaltado_seleccionar + Copy(UpperCase(nomeclatura.descrip), 1, 35) + utiles.espacios(37 - (Length(Trim(Copy(UpperCase(nomeclatura.descrip), 1, 35))))) + list.modo_resaltado_cancelar, False);
        end;

        f := False; // Impresión de Items paralelos - a la descripción del análisis
        For j := 1 to t.Count do Begin
          p1 := Pos(';1', t.Strings[j-1]);
          plantanalisis.getDatos(Copy(t.Strings[j-1], 11, 4), Copy(r.Strings[j-1], 15, 3));
          if (plantanalisis.itemsParalelo = '00') and (Copy(t.Strings[j-1], 11, 4) = Copy(r.Strings[i-1], 11, 4)) then Begin  // Items paralelo a la descripción del análisis
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
            if (salida = 'I') or (salida = 'P') then Begin
              if Copy(t.Strings[j-1], 17, p1-17) <> ';1' then List.Linea(distancia, list.lineactual, plantanalisis.elemento + ':  ' + Copy(t.Strings[j-1], 17, p1-17), 2, 'Arial, cursiva, 9', salida, 'N') else
                List.Linea(distancia, list.lineactual, '', 2, 'Arial, cursiva, 9', salida, 'N');
            end;
            if (salida = 'T') then Begin
              if Copy(t.Strings[j-1], 17, p1-17) <> ';1' then List.LineaTxt(plantanalisis.elemento + ':  ' + Copy(Copy(t.Strings[j-1], 17, p1-17), 1, 21) + '  ', True) else
                List.LineaTxt('', True);
              Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
            end;

            f := True;
          end;
         end;

        if (salida = 'I') or (salida = 'P') then Begin
          if not f then List.Linea(80, list.Lineactual, ' ', 3, 'Arial, negrita, 11', salida, 'S');
          // Fin Impresión de Items paralelos
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 6', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if not f then Begin
            List.LineaTxt(' ', true);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
          end;
          // Fin Impresión de Items paralelos
        end;
      end;

      plantanalisis.getDatos(Copy(r.Strings[i-1], 11, 4), Copy(r.Strings[i-1], 15, 3));
      if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
      // Impresión de Items independientes
      if plantanalisis.imputable = 'N' then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
          List.Linea(0, 0, '  ' + plantanalisis.elemento, 1, 'Arial, negrita, 9', salida, 'N');
        end;
        if salida = 'T' then Begin
          List.LineaTxt(esp + esp + plantanalisis.elemento, True);
          Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
        end;
      end else Begin
        p1 := Pos(';1', r.Strings[i-1]);
        if Length(Trim(plantanalisis.itemsParalelo)) = 0 then Begin  // Si es un items independiente lo imprimimos
          if Copy(plantanalisis.elemento, 1, 4) = uppercase(Copy(plantanalisis.elemento, 1, 4)) then fuente := 'Arial, normal, 9' else fuente := 'Arial, normal, 9';
          if distancia = 0 then Begin
            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(0, 0, '  ' + plantanalisis.elemento, 1, fuente, salida, 'N')
            end;
            if (salida = 'T') then Begin  // Items Columna 1
              List.LineaTxt(CHR18 + ' ' + esp + Copy(TrimLeft(plantanalisis.elemento), 1, 20) + utiles.espacios(21 - (Length(Copy(TrimLeft(plantanalisis.elemento), 1, 20)))), False);
            end;

            if (salida = 'P') or (salida = 'I') then Begin
              if Length(Trim(Copy(r.Strings[i-1], 17, p1-17))) > 0 then Begin
                if Copy(r.Strings[i-1], 17, p1-17) <> ';1' then List.derecha(47, list.lineactual, '##########################', Copy(r.Strings[i-1], 17, p1-17), 2, 'Arial, normal, 9') else
                  List.derecha(47, list.lineactual, '##########################', '', 2, 'Arial, normal, 9');
                List.Linea(48, list.lineactual, ' ', 3, 'Arial, normal, 9', salida, 'S');
              end else
                if Length(Trim(Copy(r.Strings[i-1], p1+2, 50))) > 0 then Begin
                  List.derecha(distancia + 47, list.lineactual, '##########################', Copy(r.Strings[i-1], p1+2, 50), 2, 'Arial, normal, 9');
                  List.Linea(distancia + 48, list.lineactual, ' ', 3, 'Arial, normal, 9', salida, 'S');
                end else
                  itp := True;
            end;

            if (salida = 'T') then Begin
              if Length(Trim(Copy(r.Strings[i-1], 17, p1-17))) > 0 then Begin
                if Copy(r.Strings[i-1], 17, p1-17) <> ';1' then Begin
                  List.LineaTxt(utiles.sLlenarIzquierda(Copy(r.Strings[i-1], 17, p1-17), 12, ' '), False);
                  seg_it := False;
                end else
                  List.LineaTxt('', False);
              end else
                if Length(Trim(Copy(r.Strings[i-1], p1+2, 50))) > 0 then Begin
                  List.LineaTxt(esp + utiles.sLlenarIzquierda(Copy(r.Strings[i-1], p1+2, 50), 15, ' '), False);
                  List.LineaTxt('', False);
                end else Begin
                  List.LineaTxt(utiles.sLlenarIzquierda(' ', 12, ' '), False);
                  itp := True;
                end;
            end;

          end else Begin
            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 9', salida, 'N');
              List.Linea(distancia, list.Lineactual, plantanalisis.elemento, 2, 'Arial, normal, 9', salida, 'N');
              if Length(Trim(plantanalisis.itemsParalelo)) = 0 then List.Linea(distancia + 15, list.lineactual, Copy(r.Strings[i-1], p1+2, 50), 3, 'Arial, normal, 9', salida, 'N') else List.Linea(distancia + 47, list.lineactual, Copy(r.Strings[i-1], p1+2, 50), 3, 'Arial, normal, 9', salida, 'N');
              if Length(Trim(Copy(r.Strings[i-1], p1+2, 50))) > 0 then Begin
                List.derecha(distancia + 47, list.lineactual, '##########################', Copy(r.Strings[i-1], p1+2, 50), 4, 'Arial, normal, 9');
                List.Linea(distancia + 48, list.lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
              end else
                List.Linea(distancia + 15, list.lineactual, Copy(r.Strings[i-1], p1+2, 50), 3, 'Arial, normal, 9', salida, 'S');
              end;
            end;
         end;

        // Impresión de Items paralelos - a los items comunes
        For k := 1 to t.Count do Begin
          p1 := Pos(';1', t.Strings[k-1]);
          plantanalisis.getDatos(Copy(t.Strings[k-1], 11, 4), Copy(t.Strings[k-1], 15, 2));
          if (plantanalisis.itemsParalelo = Copy(r.Strings[i-1], 15, 2)) and (Copy(t.Strings[k-1], 11, 4) = Copy(r.Strings[i-1], 11, 4)) then Begin
            if Length(Trim(plantanalisis.distancia)) = 0 then distancia := 0 else distancia := StrToInt(plantanalisis.distancia);
            itp := False;

            if (salida = 'P') or (salida = 'I') then Begin
              List.Linea(distancia, list.lineactual, plantanalisis.elemento, 4, 'Arial, normal, 9', salida, 'N');
              if Length(Trim(Copy(t.Strings[k-1], 17, p1-17))) > 0 then Begin
                if Copy(t.Strings[k-1], 17, p1-17) <> ';1' then List.Derecha(distancia + 47, list.lineactual, '##########################', Copy(t.Strings[k-1], 17, p1-17), 5, 'Arial, normal, 9') else
                  List.Derecha(distancia + 47, list.lineactual, '##########################', '', 5, 'Arial, normal, 9');
                List.Linea(distancia + 48, list.lineactual, ' ', 6, 'Arial, normal, 9', salida, 'S');
                imp := True;
              end;
              if Length(Trim(Copy(t.Strings[k-1], p1+2, 50))) > 0 then Begin
                List.Derecha(distancia + 47, list.lineactual, '##########################', Copy(t.Strings[k-1], p1+2, 50), 5, 'Arial, normal, 9');
                List.Linea(distancia + 48, list.lineactual, ' ', 6, 'Arial, normal, 9', salida, 'S');
                imp := True;
              end;
              if not imp then List.Linea(distancia + 48, list.lineactual, ' ', 5, 'Arial, normal, 9', salida, 'S');
              imp := False;
            end;

            if (salida = 'T') then Begin
              List.LineaTxt(' ' + Copy(TrimRight(plantanalisis.elemento), 1, 17) + utiles.espacios(18 - (Length(TrimLeft(Copy(plantanalisis.elemento, 1, 17))))), False);
              if Length(Trim(Copy(t.Strings[k-1], 17, p1-17))) > 0 then Begin
                if Copy(t.Strings[k-1], 17, p1-17) <> ';1' then List.LineaTxt(esp + utiles.sLlenarIzquierda(Copy(t.Strings[k-1], 17, p1-17), 12, ' '), False) else
                  List.LineaTxt(' ', False);
                List.LineaTxt(' ', True);    // Salto
                Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
                imp := True;
                seg_it := True;
              end;
              if Length(Trim(Copy(t.Strings[k-1], p1+2, 50))) > 0 then Begin
                List.LineaTxt(Copy(t.Strings[k-1], p1+2, 18), False);
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
          p1 := Pos(';1', r.Strings[i-1]);
          if (Length(Trim(Copy(r.Strings[i-1], p1+2, 50))) > 0) and (Length(Trim(Copy(r.Strings[i-1], 17, p1-17))) > 0) then Begin
            List.LineaTxt(' ', False);
          end else Begin
            List.LineaTxt('', True);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
          end;
          seg_it := True;
        end;

        if itp then
          if (salida = 'P') or (salida = 'I') then List.Linea(48, list.lineactual, ' ', 3, 'Arial, normal, 9', salida, 'S') else Begin
            List.LineaTxt('', True);
            Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
          end;

        // Fin Impresión de Items paralelos - a los items comunes
      end;

      // Valores Normales cuando hay resultados

      p1 := Pos(';1', r.Strings[i-1]);
      if (Length(Trim(Copy(r.Strings[i-1], p1+2, 50))) > 0) and (Length(Trim(Copy(r.Strings[i-1], 17, p1-17))) > 0) then Begin
        if (salida = 'P') or (salida = 'I') then Begin
          if Copy(r.Strings[i-1], 17, p1-17) <> ';1' then List.Linea(52, list.Lineactual, 'V.N.: ' + Copy(r.Strings[i-1], p1+2, 50), 6, 'Arial, normal, 9', salida, 'S') else
            List.Linea(52, list.Lineactual, '', 6, 'Arial, normal, 9', salida, 'S');
        end;
        if (salida = 'T') then Begin
          if Copy(r.Strings[i-1], 17, p1-17) <> ';1' then List.LineaTxt(chr18 + 'V.N.: ' + Copy(r.Strings[i-1], p1+2, 50), True) else
            List.LineaTxt('', True);
          Inc(lineas); if controlarSalto then TituloResultado1(lcodsan, ldfecha, lhfecha, salida);
        end;

      end else Begin
        if (salida = 'P') or (salida = 'I') then List.Linea(50, list.Lineactual, ' ', 6, 'Arial, normal, 9', salida, 'S');
      end;

      xcodanalisisanter := Copy(r.Strings[i-1], 11, 4);
      xnrosolanter      := Copy(r.Strings[i-1], 1, 10);
      itobs             := Copy(r.Strings[i-1], 15, 2);

    end;

    // Observaciones de items
    if l_items then Begin
      if (salida = 'P') or (salida = 'I') then
        if BuscarObservacionItems(xnrosolanter, xcodanalisisanter, itobs) then list.ListMemo('observacion', 'Arial, cursiva, 9', 5, salida, obsitems, 0);
      if (salida = 'T') then
        if BuscarObservacionItems(xnrosolanter, xcodanalisisanter, itobs) then ListMemo('observacion', obsitems, salida);
    end;
    l_items := False;

  end;

  if (salida = 'P') or (salida = 'I') then
    if BuscarObservacionFinal(xnrosolanter) then list.ListMemo('observacion', 'Arial, cursiva, 9', 0, salida, obsfinal, 0); // Si existen observaciones  }
  if (salida = 'T') then
    if BuscarObservacionFinal(xnrosolanter) then ListMemo('observacion', obsfinal, salida);

  if r.Count > 0 then Begin
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 10', salida, 'S');
    end;
  end;
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

function TTSolicitudAnalisisFabrissinInternacion.setValorAnalisis(xcodos, xcodanalisis, xperiodo: string): real;
var
  cod: String;
begin
  Periodo := xperiodo;
  obsocial.getDatos(xcodos);
  obsocial.SincronizarArancel(xcodos, xperiodo);
  nomeclatura.getDatos(xcodanalisis);
  if Length(Trim(nomeclatura.codfact)) > 0 then cod := nomeclatura.codfact else cod := xcodanalisis;
  nomeclatura.getDatos(cod);   // Sincronizamos el código de referencia para facturar
  if nomeclatura.RIE <> '*' then Result := CalcularValorAnalisis(xcodos, cod, obsocial.UB, nomeclatura.UB, obsocial.UG, nomeclatura.gastos) else Result := CalcularValorAnalisis(xcodos, cod, obsocial.RIEUB, nomeclatura.UB, obsocial.RIEUG, nomeclatura.gastos);
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
end;

//------------------------------------------------------------------------------

function  TTSolicitudAnalisisFabrissinInternacion.BuscarParametroInf(xid: String): Boolean;
// Objetivo...: Registrar Parámetros
Begin
  Result := confinf.FindKey([xid]);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarParametroInf(xid: String; xalto, xsep: Integer);
// Objetivo...: Registrar Parámetros
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
// Objetivo...: recuperar parámetros de impresión
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

function TTSolicitudAnalisisFabrissinInternacion.setProtocolosAdmision(xnroadmision: String): TStringList;
// Objetivo...: devolver los protocolos
var
  l: TStringList;
begin
  protocolo := solicitud.FieldByName('protocolo').AsString;
  l := TStringList.Create;
  solicitud.IndexFieldNames := 'Protocolo';
  datosdb.Filtrar(solicitud, 'admision = ' + '''' + xnroadmision + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    l.Add(solicitud.FieldByName('protocolo').AsString + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + solicitud.FieldByName('codos').AsString + solicitud.FieldByName('idprof').AsString + solicitud.FieldByName('admision').AsString + ';1' + solicitud.FieldByName('retiva').AsString + ';2' + solicitud.FieldByName('muestra').AsString + ';3' + solicitud.FieldByName('codpac').AsString);
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  Buscar(protocolo);
  Result := l;
end;

function  TTSolicitudAnalisisFabrissinInternacion.BuscarMovPagos(xprotocolo, xitems: String): Boolean;
// Objetivo...: Buscar Movimiento de Pago
begin
  if movpagos.IndexFieldNames <> 'protocolo;items' then movpagos.IndexFieldNames := 'protocolo;items';
  Result := datosdb.Buscar(movpagos, 'protocolo', 'items', xprotocolo, xitems);
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RegistrarMovPagos(xprotocolo, xitems, xfecha, xcodpac, xconcepto: String; xtipomov: Integer; xmonto, xentrega: Real; xcantitems: Integer; xmodifica: Boolean);
// Objetivo...: Registrar Movimiento de Pago
var
  it, items: String;
  devol: Boolean;
begin
  if (xtipomov = 2) or (xtipomov = 3) then Begin  // Obtenemos el Nro. de Movimiento
    if BuscarMovPagos(xprotocolo, xitems) then Begin
      it := '0'; devol := False;
      while not movpagos.Eof do Begin
        if movpagos.FieldByName('protocolo').AsString <> xprotocolo then Break;
        if movpagos.FieldByName('tipomov').AsInteger = 2 then it := movpagos.FieldByName('items').AsString;
        // Si es una devolución, sobreescribimos el registro
        if xtipomov = 3 then Begin
          if movpagos.FieldByName('devolucion').AsString = 'S' then Begin
            it := movpagos.FieldByName('items').AsString;
            devol := True;
            Break;
          end;
        end;
        movpagos.Next;
      end;
    end;
    if not devol then it := utiles.sLlenarIzquierda(IntToStr(StrToInt(it) + 1), 3, '0');
    if xitems <> '000' then it := xitems;
  end;

  if (xtipomov = 1) or (xmodifica) then items := xitems else items := it;

  if BuscarMovPagos(xprotocolo, items) then movpagos.Edit else movpagos.Append;
  movpagos.FieldByName('protocolo').AsString := xprotocolo;
  movpagos.FieldByName('items').AsString     := items;
  movpagos.FieldByName('fecha').AsString     := utiles.sExprFecha2000(xfecha);
  movpagos.FieldByName('codpac').AsString    := xcodpac;
  movpagos.FieldByName('concepto').AsString  := xconcepto;
  if xtipomov = 3 then movpagos.FieldByName('tipomov').AsInteger := 2 else
    movpagos.FieldByName('tipomov').AsInteger := xtipomov;
  movpagos.FieldByName('monto').AsFloat      := xmonto;
  movpagos.FieldByName('entrega').AsFloat    := xentrega;
  if xtipomov = 1 then movpagos.FieldByName('estado').AsString := 'I';
  if xtipomov = 2 then movpagos.FieldByName('estado').AsString := 'R';
  if xtipomov = 3 then Begin
    movpagos.FieldByName('estado').AsString     := 'R';
    movpagos.FieldByName('devolucion').AsString := 'S';
  end else
    movpagos.FieldByName('devolucion').AsString := '';
  try
    movpagos.Post
   except
    movpagos.Cancel
  end;
  if items = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then datosdb.tranSQL('delete from ' + movpagos.TableName + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and items > ' + '''' + items + '''');

  // Verificamos sobrantes en el caso de devoluciones
  if xtipomov = 3 then datosdb.tranSQL(solicitud.DatabaseName, 'delete from ' + movpagos.TableName + ' where protocolo = ' + '''' + xprotocolo + '''' + ' and monto = 0');

  datosdb.closeDB(movpagos); movpagos.Open;

  RecalcularSaldo(xprotocolo);
end;

procedure  TTSolicitudAnalisisFabrissinInternacion.getMovPagos(xprotocolo: String);
// Objetivo...: Recuperar Instancia
Begin
  if BuscarMovPagos(xprotocolo, '000') then Begin
    MontoPago    := movpagos.FieldByName('monto').AsFloat;
    EntregaPago  := movpagos.FieldByName('entrega').AsFloat;
    SaldoPago    := movpagos.FieldByName('saldo').AsFloat;
  end else Begin
    MontoPago    := 0;
    EntregaPago  := 0;
    SaldoPago    := 0;
  end;
end;

procedure  TTSolicitudAnalisisFabrissinInternacion.BorrarMovPagos(xprotocolo: String);
// Objetivo...: Borrar Movimientos de Pagos
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'delete from ' + movpagos.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.closeDB(movpagos); movpagos.Open;
end;

procedure  TTSolicitudAnalisisFabrissinInternacion.BorrarPagosProtocolo(xprotocolo: String);
// Objetivo...: Borrar Movimientos de Pagos
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'delete from movpagos where protocolo = ' + '''' + xprotocolo + '''' + ' and tipomov = 2');
  datosdb.closeDB(movpagos); movpagos.Open;
  RecalcularSaldo(xprotocolo);
end;

procedure  TTSolicitudAnalisisFabrissinInternacion.BorrarEntrega(xprotocolo: String);
// Objetivo...: Borrar Entrega
begin
  if BuscarMovPagos(xprotocolo, '000') then Begin
    movpagos.Delete;
    datosdb.closeDB(movpagos); movpagos.Open;
    // Reactivamos la Deuda
    DeterminarEstado(xprotocolo, 'I');
  end;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.DeterminarEstado(xprotocolo, xestado: String);
// Objetivo...: Modificar Estado
begin
  if BuscarMovPagos(xprotocolo, '000') then Begin
    movpagos.Edit;
    movpagos.FieldByName('protocolo').AsString := xprotocolo;
    movpagos.FieldByName('bloqueo').AsString    := xestado;
    try
      movpagos.Post
     except
      movpagos.Cancel
    end;
    datosdb.closeDB(movpagos); movpagos.Open;
  end;
end;

function TTSolicitudAnalisisFabrissinInternacion.setPagosAdeudados(xdesde, xhasta: String): TObjectList;
// Objetivo...: Devolver Protocolos Adeudados
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(movpagos, 'estado = ' + '''' + 'I' + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  movpagos.First;
  while not movpagos.Eof do Begin
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo    := movpagos.FieldByName('protocolo').AsString;
    objeto.FechaPago    := utiles.sFormatoFecha(movpagos.FieldByName('fecha').AsString);
    objeto.Codpac       := movpagos.FieldByName('codpac').AsString;
    objeto.ConceptoPago := movpagos.FieldByName('concepto').AsString;
    objeto.MontoPago    := movpagos.FieldByName('monto').AsFloat;
    objeto.EntregaPago  := movpagos.FieldByName('entrega').AsFloat;
    objeto.SaldoPago    := movpagos.FieldByName('saldo').AsFloat;
    l.Add(objeto);
    movpagos.Next;
  end;
  datosdb.QuitarFiltro(movpagos);
  Result := l;
end;

function TTSolicitudAnalisisFabrissinInternacion.setProtocolosSaldados(xdesde, xhasta: String): TObjectList;
// Objetivo...: Devolver Protocolos Adeudados
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(movpagos, 'estado = ' + '''' + 'P' + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  movpagos.First;
  while not movpagos.Eof do Begin
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo    := movpagos.FieldByName('protocolo').AsString;
    objeto.FechaPago    := utiles.sFormatoFecha(movpagos.FieldByName('fecha').AsString);
    objeto.Codpac       := movpagos.FieldByName('codpac').AsString;
    objeto.ConceptoPago := movpagos.FieldByName('concepto').AsString;
    objeto.MontoPago    := movpagos.FieldByName('monto').AsFloat;
    objeto.EntregaPago  := movpagos.FieldByName('entrega').AsFloat;
    objeto.SaldoPago    := movpagos.FieldByName('saldo').AsFloat;
    l.Add(objeto);
    movpagos.Next;
  end;
  datosdb.QuitarFiltro(movpagos);
  Result := l;
end;

function TTSolicitudAnalisisFabrissinInternacion.setPagosRegistrados(xprotocolo: String): TObjectList;
// Objetivo...: Devolver Pagos Registrados
var
  l: TObjectList;
  objeto: TTSolicitudAnalisisFabrissinInternacion;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(movpagos, 'estado = ' + '''' + 'R' + '''' + ' and protocolo = ' + '''' + xprotocolo + '''');
  movpagos.First;
  while not movpagos.Eof do Begin
    objeto := TTSolicitudAnalisisFabrissinInternacion.Create;
    objeto.Protocolo    := movpagos.FieldByName('protocolo').AsString;
    objeto.FechaPago    := utiles.sFormatoFecha(movpagos.FieldByName('fecha').AsString);
    objeto.ItemsPago    := movpagos.FieldByName('items').AsString;
    objeto.Codpac       := movpagos.FieldByName('codpac').AsString;
    objeto.ConceptoPago := movpagos.FieldByName('concepto').AsString;
    objeto.MontoPago    := movpagos.FieldByName('monto').AsFloat;
    objeto.EntregaPago  := movpagos.FieldByName('entrega').AsFloat;
    objeto.SaldoPago    := movpagos.FieldByName('saldo').AsFloat;
    l.Add(objeto);
    movpagos.Next;
  end;
  datosdb.QuitarFiltro(movpagos);
  Result := l;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.RecalcularSaldo(xprotocolo: String);
// Objetivo...: Recalcular Saldo
var
  s: Real;
Begin
  s := 0;
  if BuscarMovPagos(xprotocolo, '000') then Begin
    while not movpagos.Eof do Begin
      if movpagos.FieldByName('protocolo').AsString <> xprotocolo then Break;
      if movpagos.FieldByName('items').AsString = '000' then Begin
        s := movpagos.FieldByName('monto').AsFloat - movpagos.FieldByName('entrega').AsFloat;
      end else Begin
        s := s - movpagos.FieldByName('monto').AsFloat;
      end;
      movpagos.Edit;
      movpagos.FieldByName('saldo').AsFloat := s;         // Actualizamos saldos invidividuales
      try
        movpagos.Post
       except
        movpagos.Cancel
      end;

      movpagos.Next;
    end;
  end;

  if BuscarMovPagos(xprotocolo, '000') then Begin   // Ajuste del saldo final
    movpagos.Edit;
    if s = 0 then movpagos.FieldByName('estado').AsString := 'P' else movpagos.FieldByName('estado').AsString := 'I';
    movpagos.FieldByName('saldo').AsFloat := s;
    try
      movpagos.Post
     except
      movpagos.Cancel
    end;
  end;

  datosdb.closeDB(movpagos); movpagos.Open;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.ListarMovPagos(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Detalle de Cobros
var
  l: TStringList;
  idanter: String;
  i: Integer;
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Informe Detallado de Cobros - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Protocolo / Paciente', 1, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Fecha', 2, 'Arial, cursiva, 8');
  List.Titulo(61, list.Lineactual, 'Total', 3, 'Arial, cursiva, 8');
  List.Titulo(72, list.Lineactual, 'Ent./Cobro', 4, 'Arial, cursiva, 8');
  List.Titulo(89, list.Lineactual, 'Saldo', 5, 'Arial, cursiva, 8');
  List.Titulo(95, list.Lineactual, 'Dev.', 6, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  l := TStringList.Create; totales[1] := 0; totales[2] := 0; idanter := '';
  datosdb.Filtrar(movpagos, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  movpagos.First;
  while not movpagos.Eof do Begin   // Recuperamos los protocolos con movimientos
    if movpagos.FieldByName('protocolo').AsString <> idanter then Begin
      l.Add(movpagos.FieldByName('protocolo').AsString);
      idanter := movpagos.FieldByName('protocolo').AsString;
    end;
    movpagos.Next;
  end;
  datosdb.QuitarFiltro(movpagos);

  idanter := '';
  For i := 1 to l.Count do Begin
    if BuscarMovPagos(l.Strings[i-1], '000') then Begin
      while not movpagos.Eof do Begin
        if movpagos.FieldByName('protocolo').AsString <> l.Strings[i-1] then Break;
        if movpagos.FieldByName('protocolo').AsString <> idanter then Begin
          paciente.getDatos(movpagos.FieldByName('codpac').AsString);
          list.Linea(0, 0, movpagos.FieldByName('protocolo').AsString + '  ' + paciente.nombre, 1, 'Arial, normal, 8', salida, 'N');
          idanter := movpagos.FieldByName('protocolo').AsString;
        end else Begin
          list.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'N');
        end;
        list.Linea(40, list.Lineactual, utiles.sFormatoFecha(movpagos.FieldByName('fecha').AsString), 2, 'Arial, normal, 8', salida, 'N');
        if movpagos.FieldByName('tipomov').AsInteger = 1 then Begin
          list.importe(65, list.Lineactual, '', movpagos.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
          list.importe(80, list.Lineactual, '', movpagos.FieldByName('entrega').AsFloat, 4, 'Arial, normal, 8');
          if movpagos.FieldByName('estado').AsString = 'I' then list.importe(94, list.Lineactual, '', movpagos.FieldByName('saldo').AsFloat, 5, 'Arial, normal, 8') else
            list.importe(94, list.Lineactual, '', movpagos.FieldByName('monto').AsFloat - movpagos.FieldByName('entrega').AsFloat, 5, 'Arial, normal, 8');
          list.Linea(94, list.Lineactual, '', 6, 'Arial, normal, 8', salida, 'S');
          totales[1] := totales[1] + movpagos.FieldByName('monto').AsFloat;
          totales[2] := totales[2] + movpagos.FieldByName('entrega').AsFloat;
        end else Begin
          list.importe(80, list.Lineactual, '', movpagos.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
          list.importe(94, list.Lineactual, '', movpagos.FieldByName('saldo').AsFloat, 4, 'Arial, normal, 8');
          list.Linea(95, list.Lineactual, movpagos.FieldByName('devolucion').AsString, 5, 'Arial, normal, 8', salida, 'S');
          totales[2] := totales[2] + movpagos.FieldByName('monto').AsFloat;
        end;
        movpagos.Next;
      end;
    end;
  end;

  if totales[1] + totales[2] > 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Total Deuda - Entrega / Cobros / Saldo:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(65, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.importe(80, list.Lineactual, '', totales[2], 3, 'Arial, negrita, 8');
    list.importe(95, list.Lineactual, '', totales[1] - totales[2], 4, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 5, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

//------------------------------------------------------------------------------

function  TTSolicitudAnalisisFabrissinInternacion.BloquearCobro: Boolean;
// Objetivo...: bloquear proceso
begin
  Result := bloqueo.Bloquear('cobros');
end;

procedure TTSolicitudAnalisisFabrissinInternacion.QuitarBloqueoCobro;
// Objetivo...: Quitar Bloqueo
begin
  bloqueo.QuitarBloqueo('cobros');
end;

//------------------------------------------------------------------------------

function TTSolicitudAnalisisFabrissinInternacion.Exportar(xdesde, xhasta: String): TStringList;
// Objetivo...: Exportar Datos
var
  sol, res, obsres, obsit, mov, det: TTable;
  l: TStringList;

  procedure CopiarEstructuras;
  Begin
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\export\estructu', '*.*', dbs.DirSistema + '\export\work');
    sol    := datosdb.openDB('solicitudint', '', '', dbs.DirSistema + '\export\work');
    res    := datosdb.openDB('resultadoint', '', '', dbs.DirSistema + '\export\work');
    obsres := datosdb.openDB('obsresultadoint', '', '', dbs.DirSistema + '\export\work');
    obsit  := datosdb.openDB('obsitemsint', '', '', dbs.DirSistema + '\export\work');
    mov    := datosdb.openDB('movpagos', '', '', dbs.DirSistema + '\export\work');
    det    := datosdb.openDB('detsolint', '', '', dbs.DirSistema + '\export\work');
  end;

  function CopiarProtocolos: TStringList;
  Begin
    sol.Open;
    detsol.Open;
    datosdb.Filtrar(solicitud, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
    solicitud.First;
    while not solicitud.Eof do Begin
      if sol.FindKey([solicitud.FieldByName('protocolo').AsString]) then sol.Edit else sol.Append;
      sol.FieldByName('protocolo').AsString  := solicitud.FieldByName('protocolo').AsString;
      sol.FieldByName('fecha').AsString      := solicitud.FieldByName('fecha').AsString;
      sol.FieldByName('hora').AsString       := solicitud.FieldByName('hora').AsString;
      sol.FieldByName('codpac').AsString     := solicitud.FieldByName('codpac').AsString;
      sol.FieldByName('codos').AsString      := solicitud.FieldByName('codos').AsString;
      sol.FieldByName('idprof').AsString     := solicitud.FieldByName('idprof').AsString;
      sol.FieldByName('codsan').AsString     := solicitud.FieldByName('codsan').AsString;
      sol.FieldByName('habitacion').AsString := solicitud.FieldByName('habitacion').AsString;
      sol.FieldByName('admision').AsString   := solicitud.FieldByName('admision').AsString;
      sol.FieldByName('retiva').AsString     := solicitud.FieldByName('retiva').AsString;
      sol.FieldByName('muestra').AsString    := solicitud.FieldByName('muestra').AsString;
      try
        sol.Post
       except
        sol.Cancel
      end;

      l.Add(solicitud.FieldByName('protocolo').AsString);

      paciente.Exportar(solicitud.FieldByName('codpac').AsString);
      profesional.Exportar(solicitud.FieldByName('idprof').AsString);

      //------------------------------------------------------------------------

      datosdb.Filtrar(detsol, 'protocolo = ' + '''' + solicitud.FieldByName('protocolo').AsString + '''');
      detsol.First;
      while not detsol.Eof do Begin
        if datosdb.Buscar(det, 'protocolo', 'items', detsol.FieldByName('protocolo').AsString, detsol.FieldByName('items').AsString) then det.Edit else det.Append;
        det.FieldByName('protocolo').AsString  := detsol.FieldByName('protocolo').AsString;
        det.FieldByName('items').AsString      := detsol.FieldByName('items').AsString;
        det.FieldByName('codigo').AsString     := detsol.FieldByName('codigo').AsString;
        try
          det.Post
         except
          det.Cancel
        end;
        detsol.Next;
      end;
      datosdb.QuitarFiltro(detsol);

      //------------------------------------------------------------------------

      datosdb.Filtrar(movpagos, 'protocolo = ' + '''' + solicitud.FieldByName('protocolo').AsString + '''');
      movpagos.First;
      while not movpagos.Eof do Begin
        if datosdb.Buscar(mov, 'protocolo', 'items', movpagos.FieldByName('protocolo').AsString, movpagos.FieldByName('items').AsString) then mov.Edit else mov.Append;
        mov.FieldByName('protocolo').AsString  := movpagos.FieldByName('protocolo').AsString;
        mov.FieldByName('items').AsString      := movpagos.FieldByName('items').AsString;
        mov.FieldByName('fecha').AsString      := movpagos.FieldByName('fecha').AsString;
        mov.FieldByName('codpac').AsString     := movpagos.FieldByName('codpac').AsString;
        mov.FieldByName('concepto').AsString   := movpagos.FieldByName('concepto').AsString;
        mov.FieldByName('tipomov').AsInteger   := movpagos.FieldByName('tipomov').Asinteger;
        mov.FieldByName('monto').AsFloat       := movpagos.FieldByName('monto').AsFloat;
        mov.FieldByName('entrega').AsFloat     := movpagos.FieldByName('entrega').AsFloat;
        mov.FieldByName('saldo').AsFloat       := movpagos.FieldByName('saldo').AsFloat;
        mov.FieldByName('estado').AsString     := movpagos.FieldByName('estado').AsString;
        mov.FieldByName('devolucion').AsString := movpagos.FieldByName('devolucion').AsString;
        mov.FieldByName('bloqueo').AsString    := movpagos.FieldByName('bloqueo').AsString;
        try
          mov.Post
         except
          mov.Cancel
        end;
        movpagos.Next;
      end;
      datosdb.QuitarFiltro(movpagos);

      //------------------------------------------------------------------------

      datosdb.Filtrar(obsitems, 'protocolo = ' + '''' + solicitud.FieldByName('protocolo').AsString + '''');
      obsitems.First;
      while not obsitems.Eof do Begin
        if datosdb.Buscar(obsit, 'protocolo', 'codanalisis', 'items', obsitems.FieldByName('protocolo').AsString, obsitems.FieldByName('codanalisis').AsString, obsitems.FieldByName('items').AsString) then obsit.Edit else obsit.Append;
        obsit.FieldByName('protocolo').AsString   := obsitems.FieldByName('protocolo').AsString;
        obsit.FieldByName('codanalisis').AsString := obsitems.FieldByName('codanalisis').AsString;
        obsit.FieldByName('items').AsString       := obsitems.FieldByName('items').AsString;
        obsit.FieldByName('observacion').AsString := obsitems.FieldByName('observacion').AsString;
        try
          obsit.Post
         except
          obsit.Cancel
        end;
        obsitems.Next;
      end;
      datosdb.QuitarFiltro(obsitems);

      //------------------------------------------------------------------------

      datosdb.Filtrar(obsfinal, 'protocolo = ' + '''' + solicitud.FieldByName('protocolo').AsString + '''');
      obsfinal.First;
      while not obsfinal.Eof do Begin
        if obsres.FindKey([obsitems.FieldByName('protocolo').AsString]) then obsres.Edit else obsres.Append;
        obsres.FieldByName('protocolo').AsString   := obsfinal.FieldByName('protocolo').AsString;
        obsres.FieldByName('observacion').AsString := obsfinal.FieldByName('observacion').AsString;
        try
          obsres.Post
         except
          obsres.Cancel
        end;
        obsfinal.Next;
      end;
      datosdb.QuitarFiltro(obsfinal);

      //------------------------------------------------------------------------

      datosdb.Filtrar(resultado, 'protocolo = ' + '''' + solicitud.FieldByName('protocolo').AsString + '''');
      resultado.First;
      while not resultado.Eof do Begin
        if datosdb.Buscar(res, 'protocolo', 'codanalisis', 'items', resultado.FieldByName('protocolo').AsString, resultado.FieldByName('codanalisis').AsString, resultado.FieldByName('items').AsString) then res.Edit else res.Append;
        res.FieldByName('protocolo').AsString   := resultado.FieldByName('protocolo').AsString;
        res.FieldByName('codanalisis').AsString := resultado.FieldByName('codanalisis').AsString;
        res.FieldByName('items').AsString       := resultado.FieldByName('items').AsString;
        res.FieldByName('resultado').AsString   := resultado.FieldByName('resultado').AsString;
        res.FieldByName('valoresn').AsString    := resultado.FieldByName('valoresn').AsString;
        res.FieldByName('nroanalisis').AsString := resultado.FieldByName('nroanalisis').AsString;
        try
          res.Post
         except
          res.Cancel
        end;
        resultado.Next;
      end;
      datosdb.QuitarFiltro(resultado);

      solicitud.Next;
    end;
    datosdb.QuitarFiltro(solicitud);
    datosdb.closeDB(sol);
    datosdb.closeDB(res);
    datosdb.closeDB(obsres);
    datosdb.closeDB(obsit);
    datosdb.closeDB(mov);
    datosdb.closeDB(det);

    Result := l;
  end;

begin
  l := TStringList.Create;
  CopiarEstructuras;
  Result := CopiarProtocolos;
  utilesarchivos.CompactarArchivos(dbs.DirSistema + '\export\work\*.*', dbs.DirSistema + '\export\barld1989.cpr');
end;

//------------------------------------------------------------------------------

function TTSolicitudAnalisisFabrissinInternacion.setProtocolosImportados: TStringList;
// Objetivo...: Descompactar Archivos
var
  tabla, tpac: TTable;
  l: TStringList;
  n: String;
Begin
  l := TStringList.Create;
  utilesarchivos.DescompactarArchivos(dbs.DirSistema + '\import\barld1989.cpr', dbs.DirSistema + '\import\estructu');
  if FileExists(dbs.DirSistema + '\import\estructu\solicitudint.db') then Begin
    tabla := datosdb.openDB('solicitudint', '', '', dbs.DirSistema + '\import\estructu');
    tpac  := datosdb.openDB('pacienteint', '', '', dbs.DirSistema + '\import\estructu');
    tabla.Open; tpac.Open;
    while not tabla.Eof do Begin
      if tpac.FindKey([tabla.FieldByName('codpac').AsString]) then n := tpac.FieldByName('nombre').AsString else n := '';
      l.Add(tabla.FieldByName('protocolo').AsString + utiles.sFormatoFecha(tabla.FieldByName('fecha').AsString) + n);
      tabla.Next;
    end;
    datosdb.closeDB(tabla);
    datosdb.closeDB(tpac);
  end;
  Result := l;
end;

procedure TTSolicitudAnalisisFabrissinInternacion.Importar(lista: TStringList);
// Objetivo...: Importar Datos
var
  sol, res, obsres, obsit, mov, det: TTable;

  procedure InstanciarEstructuras;
  Begin
    sol    := datosdb.openDB('solicitudint', '', '', dbs.DirSistema + '\import\estructu');
    res    := datosdb.openDB('resultadoint', '', '', dbs.DirSistema + '\import\estructu');
    obsres := datosdb.openDB('obsresultadoint', '', '', dbs.DirSistema + '\import\estructu');
    obsit  := datosdb.openDB('obsitemsint', '', '', dbs.DirSistema + '\import\estructu');
    mov    := datosdb.openDB('movpagos', '', '', dbs.DirSistema + '\import\estructu');
    det    := datosdb.openDB('detsolint', '', '', dbs.DirSistema + '\import\estructu');
  end;

  procedure RegistrarProtocolos(lista: TStringList);
  Begin
    sol.Open; det.Open; mov.Open; obsres.Open; obsit.Open; res.Open;
    sol.First;
    while not sol.Eof do Begin
      if utiles.verificarItemsLista(lista, sol.FieldByName('protocolo').AsString) then Begin
        if solicitud.FindKey([sol.FieldByName('protocolo').AsString]) then solicitud.Edit else solicitud.Append;
        solicitud.FieldByName('protocolo').AsString  := sol.FieldByName('protocolo').AsString;
        solicitud.FieldByName('fecha').AsString      := sol.FieldByName('fecha').AsString;
        solicitud.FieldByName('hora').AsString       := sol.FieldByName('hora').AsString;
        solicitud.FieldByName('codpac').AsString     := sol.FieldByName('codpac').AsString;
        solicitud.FieldByName('codos').AsString      := sol.FieldByName('codos').AsString;
        solicitud.FieldByName('idprof').AsString     := sol.FieldByName('idprof').AsString;
        solicitud.FieldByName('codsan').AsString     := sol.FieldByName('codsan').AsString;
        solicitud.FieldByName('habitacion').AsString := sol.FieldByName('habitacion').AsString;
        solicitud.FieldByName('admision').AsString   := sol.FieldByName('admision').AsString;
        solicitud.FieldByName('retiva').AsString     := sol.FieldByName('retiva').AsString;
        solicitud.FieldByName('muestra').AsString    := sol.FieldByName('muestra').AsString;
        try
          solicitud.Post
         except
          solicitud.Cancel
        end;


        paciente.Importar(solicitud.FieldByName('codpac').AsString);
        profesional.Importar(solicitud.FieldByName('idprof').AsString);

        //------------------------------------------------------------------------

        datosdb.Filtrar(det, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        det.First;
        while not det.Eof do Begin
          if datosdb.Buscar(detsol, 'protocolo', 'items', det.FieldByName('protocolo').AsString, det.FieldByName('items').AsString) then detsol.Edit else detsol.Append;
          detsol.FieldByName('protocolo').AsString  := det.FieldByName('protocolo').AsString;
          detsol.FieldByName('items').AsString      := det.FieldByName('items').AsString;
          detsol.FieldByName('codigo').AsString     := det.FieldByName('codigo').AsString;
          try
            detsol.Post
           except
            detsol.Cancel
          end;
          det.Next;
        end;
        datosdb.QuitarFiltro(det);

        //------------------------------------------------------------------------

        datosdb.Filtrar(mov, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        mov.First;
        while not mov.Eof do Begin
          if datosdb.Buscar(movpagos, 'protocolo', 'items', mov.FieldByName('protocolo').AsString, mov.FieldByName('items').AsString) then movpagos.Edit else movpagos.Append;
          movpagos.FieldByName('protocolo').AsString  := mov.FieldByName('protocolo').AsString;
          movpagos.FieldByName('items').AsString      := mov.FieldByName('items').AsString;
          movpagos.FieldByName('fecha').AsString      := mov.FieldByName('fecha').AsString;
          movpagos.FieldByName('codpac').AsString     := mov.FieldByName('codpac').AsString;
          movpagos.FieldByName('concepto').AsString   := mov.FieldByName('concepto').AsString;
          movpagos.FieldByName('tipomov').AsInteger   := mov.FieldByName('tipomov').Asinteger;
          movpagos.FieldByName('monto').AsFloat       := mov.FieldByName('monto').AsFloat;
          movpagos.FieldByName('entrega').AsFloat     := mov.FieldByName('entrega').AsFloat;
          movpagos.FieldByName('saldo').AsFloat       := mov.FieldByName('saldo').AsFloat;
          movpagos.FieldByName('estado').AsString     := mov.FieldByName('estado').AsString;
          movpagos.FieldByName('devolucion').AsString := mov.FieldByName('devolucion').AsString;
          movpagos.FieldByName('bloqueo').AsString    := mov.FieldByName('bloqueo').AsString;
          try
            movpagos.Post
           except
            movpagos.Cancel
          end;
          mov.Next;
        end;
        datosdb.QuitarFiltro(mov);

        //------------------------------------------------------------------------

        datosdb.Filtrar(obsit, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        obsit.First;
        while not obsit.Eof do Begin
          if datosdb.Buscar(obsitems, 'protocolo', 'codanalisis', 'items', obsit.FieldByName('protocolo').AsString, obsit.FieldByName('codanalisis').AsString, obsit.FieldByName('items').AsString) then obsitems.Edit else obsitems.Append;
          obsitems.FieldByName('protocolo').AsString   := obsit.FieldByName('protocolo').AsString;
          obsitems.FieldByName('codanalisis').AsString := obsit.FieldByName('codanalisis').AsString;
          obsitems.FieldByName('items').AsString       := obsit.FieldByName('items').AsString;
          obsitems.FieldByName('observacion').AsString := obsit.FieldByName('observacion').AsString;
          try
            obsitems.Post
           except
            obsitems.Cancel
          end;
          obsit.Next;
        end;
        datosdb.QuitarFiltro(obsit);

        //------------------------------------------------------------------------

        datosdb.Filtrar(obsres, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        obsres.First;
        while not obsres.Eof do Begin
          if obsfinal.FindKey([obsres.FieldByName('protocolo').AsString]) then obsfinal.Edit else obsfinal.Append;
          obsfinal.FieldByName('protocolo').AsString   := obsres.FieldByName('protocolo').AsString;
          obsfinal.FieldByName('observacion').AsString := obsres.FieldByName('observacion').AsString;
          try
            obsfinal.Post
           except
            obsfinal.Cancel
          end;
          obsres.Next;
        end;
        datosdb.QuitarFiltro(obsres);

        //------------------------------------------------------------------------

        datosdb.Filtrar(res, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        res.First;
        while not res.Eof do Begin
          if datosdb.Buscar(resultado, 'protocolo', 'codanalisis', 'items', res.FieldByName('protocolo').AsString, res.FieldByName('codanalisis').AsString, res.FieldByName('items').AsString) then resultado.Edit else resultado.Append;
          resultado.FieldByName('protocolo').AsString   := res.FieldByName('protocolo').AsString;
          resultado.FieldByName('codanalisis').AsString := res.FieldByName('codanalisis').AsString;
          resultado.FieldByName('items').AsString       := res.FieldByName('items').AsString;
          resultado.FieldByName('resultado').AsString   := res.FieldByName('resultado').AsString;
          resultado.FieldByName('valoresn').AsString    := res.FieldByName('valoresn').AsString;
          resultado.FieldByName('nroanalisis').AsString := res.FieldByName('nroanalisis').AsString;
          try
            resultado.Post
           except
            resultado.Cancel
          end;
          res.Next;
        end;
        datosdb.QuitarFiltro(res);
      end;

      sol.Next;
    end;
    datosdb.QuitarFiltro(sol);
    datosdb.closeDB(sol);
    datosdb.closeDB(res);
    datosdb.closeDB(obsres);
    datosdb.closeDB(obsit);
    datosdb.closeDB(mov);
    datosdb.closeDB(det);

  end;

begin
  InstanciarEstructuras;
  RegistrarProtocolos(lista);
end;

//------------------------------------------------------------------------------

procedure TTSolicitudAnalisisFabrissinInternacion.ImportarResultados(lista: TStringList);
// Objetivo...: Importar Datos
var
  sol, res, obsres, obsit, mov, det: TTable;

  procedure InstanciarEstructuras;
  Begin
    sol    := datosdb.openDB('solicitudint', '', '', dbs.DirSistema + '\import\estructu');
    res    := datosdb.openDB('resultadoint', '', '', dbs.DirSistema + '\import\estructu');
    obsres := datosdb.openDB('obsresultadoint', '', '', dbs.DirSistema + '\import\estructu');
    obsit  := datosdb.openDB('obsitemsint', '', '', dbs.DirSistema + '\import\estructu');
    mov    := datosdb.openDB('movpagos', '', '', dbs.DirSistema + '\import\estructu');
    det    := datosdb.openDB('detsolint', '', '', dbs.DirSistema + '\import\estructu');
  end;

  procedure RegistrarProtocolos(lista: TStringList);
  Begin
    sol.Open; det.Open; mov.Open; obsres.Open; obsit.Open; res.Open;
    sol.First;
    while not sol.Eof do Begin
      if utiles.verificarItemsLista(lista, sol.FieldByName('protocolo').AsString) then Begin

        //------------------------------------------------------------------------

        datosdb.Filtrar(obsit, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        obsit.First;
        while not obsit.Eof do Begin
          if datosdb.Buscar(obsitems, 'protocolo', 'codanalisis', 'items', obsit.FieldByName('protocolo').AsString, obsit.FieldByName('codanalisis').AsString, obsit.FieldByName('items').AsString) then obsitems.Edit else obsitems.Append;
          obsitems.FieldByName('protocolo').AsString   := obsit.FieldByName('protocolo').AsString;
          obsitems.FieldByName('codanalisis').AsString := obsit.FieldByName('codanalisis').AsString;
          obsitems.FieldByName('items').AsString       := obsit.FieldByName('items').AsString;
          obsitems.FieldByName('observacion').AsString := obsit.FieldByName('observacion').AsString;
          try
            obsitems.Post
           except
            obsitems.Cancel
          end;
          obsit.Next;
        end;
        datosdb.QuitarFiltro(obsit);

        //------------------------------------------------------------------------

        datosdb.Filtrar(obsres, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        obsres.First;
        while not obsres.Eof do Begin
          if obsfinal.FindKey([obsres.FieldByName('protocolo').AsString]) then obsfinal.Edit else obsfinal.Append;
          obsfinal.FieldByName('protocolo').AsString   := obsres.FieldByName('protocolo').AsString;
          obsfinal.FieldByName('observacion').AsString := obsres.FieldByName('observacion').AsString;
          try
            obsfinal.Post
           except
            obsfinal.Cancel
          end;
          obsres.Next;
        end;
        datosdb.QuitarFiltro(obsres);

        //------------------------------------------------------------------------

        datosdb.Filtrar(res, 'protocolo = ' + '''' + sol.FieldByName('protocolo').AsString + '''');
        res.First;
        while not res.Eof do Begin
          if datosdb.Buscar(resultado, 'protocolo', 'codanalisis', 'items', res.FieldByName('protocolo').AsString, res.FieldByName('codanalisis').AsString, res.FieldByName('items').AsString) then resultado.Edit else resultado.Append;
          resultado.FieldByName('protocolo').AsString   := res.FieldByName('protocolo').AsString;
          resultado.FieldByName('codanalisis').AsString := res.FieldByName('codanalisis').AsString;
          resultado.FieldByName('items').AsString       := res.FieldByName('items').AsString;
          resultado.FieldByName('resultado').AsString   := res.FieldByName('resultado').AsString;
          resultado.FieldByName('valoresn').AsString    := res.FieldByName('valoresn').AsString;
          resultado.FieldByName('nroanalisis').AsString := res.FieldByName('nroanalisis').AsString;
          try
            resultado.Post
           except
            resultado.Cancel
          end;
          res.Next;
        end;
        datosdb.QuitarFiltro(res);
      end;

      sol.Next;
    end;
    datosdb.QuitarFiltro(sol);
    datosdb.closeDB(sol);
    datosdb.closeDB(res);
    datosdb.closeDB(obsres);
    datosdb.closeDB(obsit);
    datosdb.closeDB(mov);
    datosdb.closeDB(det);
  end;

begin
  InstanciarEstructuras;
  RegistrarProtocolos(lista);
end;

//------------------------------------------------------------------------------

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
    if not movpagos.Active then movpagos.Open;
    if not resultado.Active then resultado.Open;
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
    datosdb.closeDB(movpagos);
    datosdb.closeDB(resultado);
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
