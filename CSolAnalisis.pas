unit CSolAnalisis;

interface

uses CPaciente, CProfesional, CNomecla, CPlantanalisis, CObrasSociales, CTitulos, Classes,
     CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM, Ccctelab, CUtilidadesArchivos,
     CCBloqueosLaboratorios, Contnrs;

const
  meses: array[1..12] of string = ('Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre');

type

TTSolicitudAnalisis = class(TObject)
  nrosolicitud, protocolo, fecha, hora, codpac, codprof, codos, resultanalisis, nroanalisis, entorden, obssolicitud, obsitems, obsgeneral, identidad, Codftoma, Periodo, NSanatorio: string;
  Abona, FechaEntrega, RetiraFecha, RetiraHora, Idplantilla, Plantilla, Fuente: string;
  exisolicitud, ModoHistorico: boolean; registrosExportados: Integer;
  PorcentajeDif9984, PorcentajeDifObraSocial, total, Entrega: Real;
  FechaPago, ConceptoPago, ItemsPago: String;
  MontoPago, EntregaPago, SaldoPago: Real;
  fuente_barras: String;
  Codanalisis, Items, Resultados, Valoresn: String;
  codigo_barras: Boolean;
  Lonnombre: Integer;
  solicitud, detsol, resultado, obsresul, obsanalisis, ultnro, movpagos: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    ultimasolicitud: string;
  function    ultimoprotocolo: string;       

  function    Buscar(xnrosolicitud: string): boolean; overload;
  function    Buscar(xnrosolicitud, xcodanalisis: string): boolean; overload;
  function    Buscar(xnrosolicitud, xcodanalisis, xitems: string): boolean; overload;
  function    BuscarResultado(xnrosolicitud, xcodanalisis, xitems: string): boolean;
  procedure   Grabar(xnrosolicitud, xprotocolo, xfecha, xhora, xcodpac, xcodprof, xcodos, xitems, xcodanalisis, xcodosan, xidentidad, xidquederiv: string; xosrie, xosug, xnorie, xnoug: real; xcantidaditems: Integer); overload;
  procedure   Grabar(xnrosolicitud, xobservaciones: string); overload;
  procedure   GrabarEntOrden(xnrosolicitud, xentorden: string);
  procedure   GrabarResultado(xnrosolicitud, xcodanalisis, xitems, xresultado, xvaloresn, xnroanalisis: string; xcantidaditems: Integer);
  procedure   GrabarObservacion(xnrosolicitud, xcodanalisis, xitems, xobservacion: string); overload;
  procedure   GrabarObservacion(xnrosolicitud, xcodanalisis, xobservacion: string); overload;
  procedure   ReordenarDeterminacion(xnrosolicitud, xcodanalisis, xnroanalisis: String);
  procedure   Borrar(xnrosolicitud: string); overload;
  procedure   Borrar(xnrosolicitud, xcodanalisis: string); overload;
  procedure   getDatos(xnrosolicitud: string); overload;
  procedure   getDatos(xnrosolicitud, xcodanalisis, xitems: string); overload;
  function    setAnalisis: TQuery; overload;
  function    setAnalisis(xnrosolicitud: string): TQuery; overload;
  function    setAnalisisPaciente(xcodpac: string): TQuery;
  function    setAnalisisPacienteDESC(xcodpac: string): TQuery;
  function    setAnalisisFecha(xfecha: string): TQuery;
  function    setResultados(xnrosolicitud: string): TQuery;
  function    setListaResultados(xnrosolicitud: string): TObjectList;
  function    setSolicitudes(xdfecha, xhfecha: String): TQuery;
  function    NuevaSolicitud: string;
  function    NuevoProtocolo: string;
  procedure   Listar(xdf, xhf: string; salida: char);
  procedure   ListarResultado(xdnrosol, xhnrosol: string; detSel: Array of String; salida: char);
  procedure   ListarResultadoF(xdfecha, xhfecha: string; detSel: Array of String; salida: char);
  procedure   ListarResultadoP(xdesdeprot, xhastaprot: string; salida: char);
  function    setEstadisticaSolicitudes(xdf, xhf: string): TQuery;
  function    setEstadisticaSolicitudesPacientes(xdf, xhf: string): TQuery;
  function    setEstadisticaObrasSociales(xdf, xhf: string): TQuery;
  function    setEstadisticaAnalisisEnviados(xdf, xhf: string): TQuery;
  function    setAuditoriaSolicitudes(xfecha: string): TQuery;
  function    setOrdenesAnalisis(xdfecha, xhfecha: string): TQuery;
  function    setObrasSociales_Pacientes(xdfecha, xhfecha: string): TQuery;
  function    setDeterminacionesAnalisis(xdfecha, xhfecha: string): TStringList;
  function    setProtocolosDeterminacion(xdfecha, xhfecha, xcodanalisis: string): TObjectList;
  function    setCodigosAnalisisHojaDeTrabajo(xdfecha, xhfecha: string): TQuery;
  function    getEntOrden: string;
  function    CalcularValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): Real; virtual;
  function    setValorAnalisis(xcodos, xcodanalisis, xperiodo: string): Real;
  function    Precio9984: Real;
  function    Total9984: Real;
  procedure   ExportarDatosPorObraSocial(xdfecha, xhfecha: string);
  procedure   CopiarDatosExportados(xdrive: string);
  function    setDatosExportadosPorObraSocial: TQuery;
  function    setImportePacientePor_ObraSocial(xcodpac, xcodob, xdfecha, xhfecha: string): real; overload;
  function    setImportePacientePor_ObraSocial(xcodpac, xdfecha, xhfecha: string): TQuery; overload;
  function    verificarSiElItemsTieneMovimientos(xnrosolicitud, xcodanalisis: string): boolean;
  procedure   BorrarItemsEnMovimiento(xnrosolicitud, xcodanalisis: string);

  procedure   ListHojaDeTrabajo(xnrosolicitud: string; salida: char);

  procedure   GuardarOrdenenesSolicitudAnalisis(xprotocolo, xitems, xentregaOrden: string); overload;
  procedure   GuardarOrdenenesSolicitudAnalisis(xprotocolo, xitems, xentregaOrden, xcodos: string); overload;

  procedure   ListarSolicitudesRegistradas(xdfecha, xhfecha: String; salida: char);

  procedure   Depurar(xfecha: string);
  function    verificarPaciente(xcodpac: string): boolean;
  function    verificarProfesional(xcodprof: string): boolean;
  function    verificarEntidadDerivacion(xidentidad: string): boolean;
  function    verificarObraSocial(xcodos: string): boolean;
  function    verificarEntidadQueDeriva(xentidad: string): boolean;
  function    verificarResultadoSolicitud(xnrosolicitud: string): boolean;
  procedure   RegistrarUltimaSolicitud(xnrosolicitud, xprotocolo: string);
  procedure   ImprimirSobre(xnombre: string; xlineas, xmargeniz: Integer; salida: char); virtual;

  function    BuscarMovPagos(xprotocolo, xitems: String): Boolean;
  procedure   RegistrarMovPagos(xprotocolo, xitems, xfecha, xcodpac, xconcepto: String; xtipomov: Integer; xmonto, xentrega: Real; xcantitems: Integer; xmodifica: Boolean);
  procedure   BorrarMovPagos(xprotocolo: String);
  procedure   BorrarPagosProtocolo(xprotocolo: String);
  procedure   BorrarEntrega(xprotocolo: String);
  procedure   DeterminarEstado(xprotocolo, xestado: String);
  function    setPagosAdeudados(xdesde, xhasta: String): TObjectList;
  function    setPagosRegistrados(xdesde, xhasta: String): TObjectList;
  function    setProtocolosSaldados(xdesde, xhasta: String): TObjectList;
  procedure   RecalcularSaldo(xprotocolo: String);
  procedure   ListarMovPagos(xdesde, xhasta: String; salida: char);
  procedure   ListarSaldosACobrar(xdesde, xhasta: String; salida: char);
  procedure   ListarSaldosCobrados(xdesde, xhasta: String; salida: char);

  {procedure   ConsultarHistorico;
  procedure   DesconectarHistorico;}

  function    Bloquear: Boolean;
  procedure   QuitarBloqueo;
  function    BloquearResultado: Boolean;
  procedure   QuitarBloqueoResultado;
  function    BloquearCobro: Boolean;
  procedure   QuitarBloqueoCobro;

  procedure   AjustarFechaSolicitudes(xdesdeprot, xhastaprot, xnuevafecha: String);

  procedure   VerificarIntegridadPacientes;
  function    BuscarPaciente(xcodpac: String): Boolean;

  procedure   conectar;
  procedure   desconectar;
 protected
  { Declaraciones Protegidas }
  v9984, T9984: Real;
  dir, drvhistorico: String; fuenteObservac: String;
  procedure   ListHDeTrabajo(xnrosolicitud: string; salida: char); virtual;
  procedure   TituloSol(salida: char); virtual;
  procedure   ListSol(xcodpac, xidprof: string; salida: char); virtual;
  procedure   ListDetSol(xnrosolicitud: string; detSel: Array of String; salida: char); virtual;
  function    verificarItemsEnLista(listArray: Array of String; xitems: String): Boolean;
  procedure   ListarResultadoAC(xdesde, xhasta: string; detSel: Array of String; salida, filtro: char);
  function    setDeterminaciones(xnrosolicitud: String): TStringList;
 private
  { Declaraciones Privadas }
  cantsol: integer; r: TQuery; controlSQL: boolean;
  conexiones: integer;
  totales: array[1..5] of Real;
  procedure   BorrarItems(xnrosolicitud: string);
  procedure   Grabar(xnrosolicitud, xprotocolo, xfecha, xhora, xcodpac, xcodprof, xcodos, xidquederiv: string); overload;
  procedure   ListLinea(salida: char);
end;

function solicitudanalisisclinicos: TTSolicitudAnalisis;

implementation

var
  xsolicitudanalisisclinicos: TTSolicitudAnalisis = nil;

constructor TTSolicitudAnalisis.Create;
var
  archivo: TextFile;
  conn: string;
begin
  if dbs.BaseClientServ = 'N' then Begin
    ultnro := datosdb.openDB('ultnro', 'nrosolicitud');
  end;

  if dbs.BaseClientServ = 'S' then Begin
    if not (FileExists(dbs.DirSistema + '\driverconn.txt')) then begin
      if Length(Trim(dbs.baseDat_N)) = 0 then dbs.NuevaBaseDeDatos('laboratorio', dbs.usuario, dbs.password);   // Creamos la Base de datos C/S
    end else begin
      AssignFile(archivo, dbs.DirSistema + '\driverconn.txt');
      reset(archivo);
      readln(archivo, conn);
      closeFile(archivo);
      if Length(Trim(dbs.baseDat_N)) = 0 then dbs.NuevaBaseDeDatos(conn, dbs.usuario, dbs.password);   // Creamos la Base de datos C/S
    end;

    ultnro := datosdb.openDB('ultnro', 'nrosolicitud', '', dbs.baseDat_N);
  end;

  fuenteObservac := 'Arial, cursiva, 9';
end;

destructor TTSolicitudAnalisis.Destroy;
begin
  inherited Destroy;
end;

function TTSolicitudAnalisis.ultimasolicitud: string;
begin
  Result := ultnro.FieldByName('nrosolicitud').AsString;
end;

function TTSolicitudAnalisis.ultimoprotocolo: string;
begin
  Result := ultnro.FieldByName('protocolo').AsString;
end;

function TTSolicitudAnalisis.getEntOrden: string;
// Objetivo...: retornar si la solicitud tiene o no orden
begin
  if Buscar(nrosolicitud) then Result := solicitud.FieldByName('entorden').AsString;
end;

function  TTSolicitudAnalisis.Buscar(xnrosolicitud: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if not solicitud.Active then solicitud.Open;
  if solicitud.FindKey([xnrosolicitud]) then Result := True else Result := False;
end;

function  TTSolicitudAnalisis.Buscar(xnrosolicitud, xcodanalisis: string): boolean;
// Objetivo...: Buscar una instancia
begin
  if datosdb.Buscar(obsanalisis, 'nrosolicitud', 'codanalisis', xnrosolicitud, xcodanalisis) then Result := True else Result := False;
end;

function  TTSolicitudAnalisis.Buscar(xnrosolicitud, xcodanalisis, xitems: string): boolean;
// Objetivo...: Buscar una instancia para el resultado de un análisis
begin
  if datosdb.Buscar(resultado, 'nrosolicitud', 'codanalisis', 'items', xnrosolicitud, xcodanalisis, xitems) then Result := True else Result := False;
end;

function  TTSolicitudAnalisis.BuscarResultado(xnrosolicitud, xcodanalisis, xitems: string): boolean;
// Objetivo...: Buscar una instancia para el resultado de un análisis
begin
  if datosdb.Buscar(obsresul, 'nrosolicitud', 'codanalisis', 'items', xnrosolicitud, xcodanalisis, xitems) then Result := True else Result := False;
end;

procedure TTSolicitudAnalisis.Grabar(xnrosolicitud, xprotocolo, xfecha, xhora, xcodpac, xcodprof, xcodos, xitems, xcodanalisis, xcodosan, xidentidad, xidquederiv: string; xosrie, xosug, xnorie, xnoug: real; xcantidaditems: Integer);
// Objetivo...: Almacenar una instacia de la clase - Atributos de una solicitud de análisis
var
  codrecep: string;
begin
  if xitems = '01' then Grabar(xnrosolicitud, xprotocolo, xfecha, xhora, xcodpac, xcodprof, xcodos, xidquederiv);   // Soliticitud
  if datosdb.Buscar(detsol, 'nrosolicitud', 'items', xnrosolicitud, xitems) then detsol.Edit else detsol.Append;
  detsol.FieldByName('nrosolicitud').AsString := xnrosolicitud;
  detsol.FieldByName('items').AsString        := xitems;
  detsol.FieldByName('codanalisis').AsString  := xcodanalisis;
  detsol.FieldByName('codos').AsString        := xcodosan;
  detsol.FieldByName('identidad').AsString    := xidentidad;
  detsol.FieldByName('osub').AsFloat          := xosrie;
  detsol.FieldByName('osug').AsFloat          := xosug;
  detsol.FieldByName('noub').AsFloat          := xnorie;
  detsol.FieldByName('noug').AsFloat          := xnoug;
  // Obtenemos los datos del codigo del nomeclador de toma y recepción
  nomeclatura.getDatos(xcodanalisis);
  codrecep := nomeclatura.cftoma;
  nomeclatura.getDatos(codrecep);
  detsol.FieldByName('cfub').AsFloat          := nomeclatura.ub;
  detsol.FieldByName('cfug').AsFloat          := nomeclatura.gastos;
  try
    detsol.Post
   except
    detsol.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantidaditems), 2, '0') then Begin
    datosdb.tranSQL(solicitud.DatabaseName, 'delete from ' + detsol.TableName + ' where nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantidaditems), 2, '0') + '"');
    datosdb.refrescar(detsol);
  end;
end;

procedure TTSolicitudAnalisis.Grabar(xnrosolicitud, xobservaciones: string);
// Objetivo...: Almacenar una instacia de la clase - Atributos de una solicitud de análisis - Observaciones
begin
  if Buscar(xnrosolicitud) then Begin
    solicitud.Edit;
    solicitud.FieldByName('observaciones').Value := xobservaciones;
    try
      solicitud.Post
    except
      solicitud.Cancel
    end;
  end;
  datosdb.refrescar(solicitud);
end;

procedure TTSolicitudAnalisis.GrabarResultado(xnrosolicitud, xcodanalisis, xitems, xresultado, xvaloresn, xnroanalisis: string; xcantidaditems: Integer);
// Objetivo...: Almacenar las instancias pertenecientes a los resultados de un análisis
begin
  if (xcantidaditems = -1) and (xitems = '01') then Begin  // 25/10/2019 borramos todos los items al inicio
    datosdb.refrescar(resultado);
    datosdb.tranSQL(solicitud.DatabaseName, 'delete from ' + resultado.TableName + ' where nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' and codanalisis = ' + '"' + xcodanalisis + '"');
    datosdb.refrescar(resultado);
  end;

  if Buscar(xnrosolicitud, xcodanalisis, xitems) then resultado.Edit else resultado.Append;
  resultado.FieldByName('nrosolicitud').AsString := xnrosolicitud;
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
    datosdb.tranSQL(solicitud.DatabaseName, 'delete from ' + resultado.TableName + ' where nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' and codanalisis = ' + '"' + xcodanalisis + '"' + ' and items > ' + '"' + utiles.sLlenarIzquierda(IntToStr(xcantidaditems), 2, '0') + '"');
    datosdb.refrescar(resultado);
  end;
end;

procedure TTSolicitudAnalisis.GrabarObservacion(xnrosolicitud, xcodanalisis, xitems, xobservacion: string);
// Objetivo...: Almacenar las observaciones de un items perteneciente a los resultados de análisis
begin
  if BuscarResultado(xnrosolicitud, xcodanalisis, xitems) then obsresul.Edit else obsresul.Append;
  obsresul.FieldByName('nrosolicitud').AsString  := xnrosolicitud;
  obsresul.FieldByName('codanalisis').AsString   := xcodanalisis;
  obsresul.FieldByName('items').AsString         := xitems;
  obsresul.FieldByName('observaciones').AsString := xobservacion;
  try
    obsresul.Post
  except
    obsresul.Cancel
  end;
  datosdb.refrescar(obsresul);
end;

procedure TTSolicitudAnalisis.GrabarObservacion(xnrosolicitud, xcodanalisis, xobservacion: string);
// Objetivo...: Almacenar las instancias generales de un analisis concreto
begin
  if Buscar(xnrosolicitud, xcodanalisis) then obsanalisis.Edit else obsanalisis.Append;
  obsanalisis.FieldByName('nrosolicitud').AsString := xnrosolicitud;
  obsanalisis.FieldByName('codanalisis').AsString  := xcodanalisis;
  obsanalisis.FieldByName('observaciones').Value   := xobservacion;
  try
    obsanalisis.Post
  except
    obsanalisis.Cancel
  end;
  datosdb.refrescar(obsanalisis);
end;

procedure TTSolicitudAnalisis.Grabar(xnrosolicitud, xprotocolo, xfecha, xhora, xcodpac, xcodprof, xcodos, xidquederiv: string);
// Objetivo...: Almacenar una instacia de la clase - Pedido de solicitud de análisis
begin
  if Buscar(xnrosolicitud) then solicitud.Edit else solicitud.Append;
  solicitud.FieldByName('nrosolicitud').AsString := xnrosolicitud;
  solicitud.FieldByName('protocolo').AsString    := xprotocolo;
  solicitud.FieldByName('fecha').AsString        := utiles.sExprFecha2000(xfecha);
  solicitud.FieldByName('hora').AsString         := xhora;
  solicitud.FieldByName('codpac').AsString       := xcodpac;
  solicitud.FieldByName('codprof').AsString      := xcodprof;
  solicitud.FieldByName('codos').AsString        := xcodos;
  solicitud.FieldByName('entidadderiv').AsString := xidquederiv;
  try
    solicitud.Post
  except
    solicitud.Cancel
  end;
  if not exisolicitud then  // Si la solicitud es Nueva actualizamos el ultimo nro de protocolo para la correlatividad
    if utiles.sLlenarIzquierda(Nuevasolicitud, 5, '0') <= utiles.sLlenarIzquierda(xnrosolicitud, 5, '0') then RegistrarUltimaSolicitud(xnrosolicitud, xprotocolo);
  datosdb.refrescar(solicitud);
end;

procedure TTSolicitudAnalisis.RegistrarUltimaSolicitud(xnrosolicitud, xprotocolo: string);
// Objetivo...: Almacenar el último de la ultima solicitud válida
begin
  if not (ultnro.Active) then ultnro.Open;  
  if ultnro.RecordCount = 0 then ultnro.Append else ultnro.Edit;  // Guardamos el último nro. de solicitud
  ultnro.FieldByName('nrosolicitud').AsString := xnrosolicitud;
  ultnro.FieldByName('protocolo').AsString    := xprotocolo;
  try
    ultnro.Post
  except
    ultnro.Cancel
  end;
  datosdb.refrescar(ultnro);
end;

procedure TTSolicitudAnalisis.ReordenarDeterminacion(xnrosolicitud, xcodanalisis, xnroanalisis: String);
// Objetivo...: Renumerar Determinaciones analisis - aquellas que se han insertado
Begin
  datosdb.tranSQL(solicitud.DatabaseName, 'update ' + resultado.TableName + ' set nroanalisis = ' + '"' + xnroanalisis + '"' + ' where nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' and codanalisis = ' + '"' + xcodanalisis + '"');
end;

procedure TTSolicitudAnalisis.Borrar(xnrosolicitud: string);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xnrosolicitud) then Begin
    solicitud.Delete;
    BorrarItems(xnrosolicitud);
    datosdb.tranSQL(solicitud.DatabaseName, 'DELETE FROM ' + resultado.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"');
    datosdb.tranSQL(solicitud.DatabaseName, 'DELETE FROM ' + obsresul.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"');
    datosdb.tranSQL(solicitud.DatabaseName, 'DELETE FROM ' + obsanalisis.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"');
    getDatos(solicitud.FieldByName('nrosolicitud').AsString);
  end;
end;

procedure TTSolicitudAnalisis.Borrar(xnrosolicitud, xcodanalisis: string);
// Objetivo...: Anular los items de un resultado de análisis determinado
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'DELETE FROM ' + resultado.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' AND codanalisis = ' + '"' + xcodanalisis + '"');
end;

procedure TTSolicitudAnalisis.BorrarItems(xnrosolicitud: string);
// Objetivo...: Anular los items de un análisis determinado
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'DELETE FROM ' + detsol.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"');
end;

procedure TTSolicitudAnalisis.getDatos(xnrosolicitud: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xnrosolicitud) then Begin
    nrosolicitud := solicitud.FieldByName('nrosolicitud').AsString;
    protocolo    := solicitud.FieldByName('protocolo').AsString;
    fecha        := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
    hora         := solicitud.FieldByName('hora').AsString;
    codpac       := solicitud.FieldByName('codpac').AsString;
    codprof      := solicitud.FieldByName('codprof').AsString;
    codos        := solicitud.FieldByName('codos').AsString;
    entorden     := solicitud.FieldByName('entorden').AsString;
    obssolicitud := solicitud.FieldByName('observaciones').AsString;
    exisolicitud := true;
  end else Begin
    nrosolicitud := ''; protocolo := ''; fecha := utiles.sFormatoFecha(utiles.sExprFecha2000(DateToStr(Now()))); codpac := ''; codprof := ''; codos := ''; entorden := ''; obssolicitud := ''; hora := ''; codftoma := '';
    exisolicitud := false;
  end;
end;

procedure TTSolicitudAnalisis.GrabarEntOrden(xnrosolicitud, xentorden: string);
// Objetivo...: Actualizar el atributo de entrega de ordenes
begin
  if Buscar(xnrosolicitud) then Begin
    solicitud.Edit;
    solicitud.FieldByName('entorden').AsString := xentorden;
    try
      solicitud.Post
    except
      solicitud.Cancel
    end;
    datosdb.refrescar(solicitud);
  end;
end;

procedure TTSolicitudAnalisis.getDatos(xnrosolicitud, xcodanalisis, xitems: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia de los resultados de los análisis
begin
  if Buscar(xnrosolicitud, xcodanalisis, xitems) then
    resultanalisis := resultado.FieldByName('resultado').AsString
  else
    resultanalisis := '';
  // Cargamos las observaciones de los items
  if BuscarResultado(xnrosolicitud, xcodanalisis, xitems) then obsitems := obsresul.FieldByName('observaciones').Value else obsitems := '';
  // Observacion Final de la solicitud
  if Buscar(xnrosolicitud, xcodanalisis) then obsgeneral := obsanalisis.FieldByName('observaciones').Value else obsgeneral := '';
end;

function TTSolicitudAnalisis.setAnalisis(xnrosolicitud: string): TQuery;
// Objetivo...: devolver un set de registros con los análisis de una solicitud dada
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT nrosolicitud, items, codanalisis, codos, identidad, entorden, osub, osug, noub, noug FROM ' + detsol.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' ORDER BY nrosolicitud, items');
end;

function TTSolicitudAnalisis.setAnalisis: TQuery;
// Objetivo...: devolver un set de registros con los análisis registrados
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT * FROM ' + detsol.TableName + ' ORDER BY nrosolicitud, items');
end;

function TTSolicitudAnalisis.setAnalisisPaciente(xcodpac: string): TQuery;
// Objetivo...: devolver un set de registros con los análisis de un paciente determinado
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT nrosolicitud, protocolo, fecha, codpac, codprof, codos FROM ' + solicitud.TableName + ' WHERE codpac = ' + '"' + xcodpac + '"' + ' ORDER BY fecha');
end;

function TTSolicitudAnalisis.setAnalisisPacienteDESC(xcodpac: string): TQuery;
// Objetivo...: devolver un set de registros con los análisis de un paciente determinado
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT nrosolicitud, protocolo, fecha, codpac, codprof, codos FROM ' + solicitud.TableName + ' WHERE codpac = ' + '"' + xcodpac + '"' + ' ORDER BY fecha DESC');
end;

function TTSolicitudAnalisis.setResultados(xnrosolicitud: string): TQuery;
// Objetivo...: devolver un set de registros con los resultados de análisis de una solicitud
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT nrosolicitud, codanalisis, items, resultado, valoresn, nroanalisis FROM ' + resultado.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' order by nroanalisis, items');
end;

function TTSolicitudAnalisis.setListaResultados(xnrosolicitud: string): TObjectList;
// Objetivo...: devolver una coleccion con los resultados de análisis de una solicitud
var
  l: TObjectList;
  objeto: TTSolicitudAnalisis;
begin
  l := TObjectList.Create;
  resultado.IndexFieldNames := 'nrosolicitud;nroanalisis;items';

  // Rastreamos la primer determinación, si no existe, verificamos si existen otras
  if not datosdb.Buscar(resultado, 'nrosolicitud', 'nroanalisis', 'items', xnrosolicitud, '01', '01') then Begin
    datosdb.Filtrar(resultado, 'nrosolicitud = ' + '''' +  xnrosolicitud + '''');
    resultado.First;
  end;
  while not resultado.Eof do Begin
    if resultado.FieldByName('nrosolicitud').AsString <> xnrosolicitud then Break;
    objeto := TTSolicitudAnalisis.Create;
    objeto.nrosolicitud := resultado.FieldByName('nrosolicitud').AsString;
    objeto.Codanalisis  := resultado.FieldByName('codanalisis').AsString;
    objeto.Items        := resultado.FieldByName('items').AsString;
    objeto.Resultados   := resultado.FieldByName('resultado').AsString;
    objeto.Valoresn     := resultado.FieldByName('valoresn').AsString;
    objeto.nroanalisis  := resultado.FieldByName('nroanalisis').AsString;
    resultado.Next;
    l.Add(objeto);
  end;

  if resultado.Filtered then datosdb.QuitarFiltro(resultado);
  resultado.IndexFieldNames := 'nrosolicitud;codanalisis;items';

  Result := l;
end;

function TTSolicitudAnalisis.setSolicitudes(xdfecha, xhfecha: String): TQuery;
// Objetivo...: devolver un set de registros con las solicitudes entre dos fechas
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT protocolo, codpac, codos, fecha FROM ' + solicitud.TableName + ' WHERE fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' and fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' order by fecha, protocolo');
end;

function TTSolicitudAnalisis.setAnalisisFecha(xfecha: string): TQuery;
// Objetivo...: devolver un set con las solicitudes de análisis de una fecha determinada
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + solicitud.TableName + '.nrosolicitud, ' + solicitud.TableName + '.fecha, ' + solicitud.TableName + '.hora, ' + solicitud.TableName + '.Codpac, paciente.nombre FROM ' + solicitud.TableName + ', paciente WHERE ' + solicitud.TableName + '.codpac = paciente.codpac AND fecha = ' + '"' + utiles.sExprFecha2000(xfecha) + '"' + ' ORDER BY nrosolicitud');
end;

function TTSolicitudAnalisis.setEstadisticaSolicitudes(xdf, xhf: string): TQuery;
// Objetivo...: devolver un set de registros ...
begin
  if LowerCase(solicitud.TableName) = 'solicitud' then Begin
    Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + detsol.TableName + '.nrosolicitud, ' + detsol.TableName + '.codanalisis, ' + solicitud.TableName + '.fecha, ' + solicitud.TableName + '.codpac, ' + solicitud.TableName + '.codprof, ' + solicitud.TableName + '.protocolo FROM ' + detsol.TableName + ', ' + solicitud.TableName + ' WHERE ' + detsol.TableName + '.nrosolicitud = ' + solicitud.TableName + '.nrosolicitud AND ' + solicitud.TableName + '.fecha >= ' + '"' + xdf + '"' + ' AND ' + solicitud.TableName + '.fecha <= ' + '"' + xhf + '"' + ' ORDER BY codanalisis, nrosolicitud, fecha');
  end;
  if LowerCase(solicitud.TableName) = 'solicitudint' then Begin
    Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + detsol.TableName + '.nrosolicitud, ' + detsol.TableName + '.codanalisis, ' + solicitud.TableName + '.fecha, ' + solicitud.TableName + '.codpac, ' + solicitud.TableName + '.codprof, ' + solicitud.TableName + '.entidadderiv, ' + solicitud.TableName + '.protocolo FROM ' + detsol.TableName + ', ' + solicitud.TableName + ' WHERE ' + detsol.TableName + '.nrosolicitud = ' + solicitud.TableName + '.nrosolicitud AND ' + solicitud.TableName + '.fecha >= ' + '"' + xdf + '"' + ' AND ' + solicitud.TableName + '.fecha <= ' + '"' + xhf + '"' + ' ORDER BY codanalisis, nrosolicitud, fecha');
  end;   
end;

function TTSolicitudAnalisis.setEstadisticaSolicitudesPacientes(xdf, xhf: string): TQuery;
// Objetivo...: devolver un set de registros ...
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + solicitud.TableName + '.nrosolicitud, ' + solicitud.TableName + '.codpac, ' + solicitud.TableName + '.fecha, ' + solicitud.TableName + '.codprof, ' +
  solicitud.TableName + '.protocolo FROM ' + solicitud.TableName + ' WHERE ' + solicitud.TableName + '.fecha >= ' + '"' + xdf + '"' + ' AND ' + solicitud.TableName + '.fecha <= ' + '"' + xhf + '"' + ' ORDER BY fecha, nrosolicitud');
end;

function TTSolicitudAnalisis.setEstadisticaObrasSociales(xdf, xhf: string): TQuery;
// Objetivo...: devolver un set de registros ...
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + solicitud.TableName + '.nrosolicitud, ' + solicitud.TableName + '.codpac, ' + solicitud.TableName + '.fecha, ' + solicitud.TableName + '.codprof, ' + solicitud.TableName + '.protocolo, ' + solicitud.TableName + '.codos FROM ' + solicitud.TableName +
  ' WHERE ' + solicitud.TableName + '.fecha >= ' + '"' + xdf + '"' + ' AND ' + solicitud.TableName + '.fecha <= ' + '"' + xhf + '"' + ' AND codos > ' + '"' + '000000' + '"' + ' ORDER BY codos, nrosolicitud');
end;

function TTSolicitudAnalisis.setEstadisticaAnalisisEnviados(xdf, xhf: string): TQuery;
// Objetivo...: devolver un set de registros ...
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT entidades.Identidad, ' + detsol.TableName + '.Nrosolicitud, ' + detsol.TableName + '.Codanalisis, ' + detsol.TableName + '.Codos, ' + solicitud.TableName + '.Fecha, ' + solicitud.TableName + '.Codpac, ' + solicitud.TableName + '.Protocolo, ' +
            solicitud.TableName + '.Codprof FROM entidades '+ ', ' + detsol.TableName + ', ' + solicitud.TableName + ' WHERE entidades.Identidad = ' + detsol.TableName + '.Identidad AND ' + solicitud.TableName + '.Nrosolicitud = ' + detsol.TableName + '.Nrosolicitud AND ' + solicitud.TableName +
            '.fecha >= ' + '"' + xdf + '"' + ' AND ' + solicitud.TableName + '.fecha <= ' + '"' + xhf + '"' + ' ORDER BY Identidad, Codpac');
end;

function TTSolicitudAnalisis.setAuditoriaSolicitudes(xfecha: string): TQuery;
// Objetivo...: devolver un set de registros ...
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT nrosolicitud, protocolo, fecha, codpac, codprof, codos FROM ' + solicitud.TableName + ' WHERE fecha = ' + '"' + xfecha + '"' + ' ORDER BY nrosolicitud');
end;

function TTSolicitudAnalisis.setOrdenesAnalisis(xdfecha, xhfecha: string): TQuery;
// Objetivo...: devolver un set de ordenes
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + detsol.TableName + '.nrosolicitud, ' + detsol.TableName + '.Items, ' + detsol.TableName + '.Codanalisis, ' + detsol.TableName + '.Entorden, ' + detsol.TableName + '.codos, ' + solicitud.TableName + '.codpac FROM ' + detsol.TableName + ', ' + solicitud.TableName +
            ' WHERE ' + detsol.TableName + '.Nrosolicitud = ' + solicitud.TableName + '.Nrosolicitud AND ' + solicitud.TableName + '.fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND ' + solicitud.TableName + '.fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' ORDER BY Codpac, Codos');
end;

function TTSolicitudAnalisis.setObrasSociales_Pacientes(xdfecha, xhfecha: string): TQuery;
// Objetivo...: devolver un set de ordenes
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + detsol.TableName + '.Codos, ' + detsol.TableName + '.Items, ' + solicitud.TableName + '.Nrosolicitud, ' + solicitud.TableName + '.Protocolo, ' + solicitud.TableName + '.Codpac, ' + detsol.TableName + '.Codanalisis, ' + detsol.TableName + '.Entorden ' +
            ' FROM ' + solicitud.TableName + ' ,' + detsol.TableName + ' WHERE ' + solicitud.TableName + '.Nrosolicitud = ' + detsol.TableName + '.Nrosolicitud AND ' + solicitud.TableName + '.fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' +
            ' AND ' + detsol.TableName + '.Entorden = ' + '"' + 'S' + '"' + ' ORDER BY Codos, protocolo, Codpac');
end;

function TTSolicitudAnalisis.setCodigosAnalisisHojaDeTrabajo(xdfecha, xhfecha: string): TQuery;
// Objetivo...: devolver los codigos de analisis registrados entre ambas fechas
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT codanalisis, protocolo FROM ' + detsol.TableName + ' ,' +  solicitud.TableName + ' WHERE ' + detsol.TableName + '.nrosolicitud = ' + solicitud.TableName + '.nrosolicitud AND fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"' + ' ORDER BY protocolo, codanalisis');
end;

procedure TTSolicitudAnalisis.ExportarDatosPorObraSocial(xdfecha, xhfecha: string);
// Objetivo...: devolver un set de ordenes
var
  exportar: TTable;
  orden, protanter: String; i: Integer;
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'DELETE FROM exportobs'); // Vaciamos la tabla

  exportar := datosdb.openDB('exportobs', 'Codos;Codpac;Items');
  exportar.Open;
  r := setObrasSociales_Pacientes(xdfecha, xhfecha);
  r.Open; i := 0; registrosExportados := 0;

  paciente.conectar;
  while not r.EOF do Begin
   if r.FieldByName('codos').AsString <> '000000' then Begin
    if r.FieldByName('protocolo').AsString <> protanter then Begin
      Inc(i);
      orden := utiles.sLlenarIzquierda(IntToStr(i), 4, '0');
    end;
    if datosdb.Buscar(exportar, 'Codos', 'Codpac', 'Items', r.FieldByName('codos').AsString, r.FieldByName('codpac').AsString, utiles.sLlenarIzquierda(r.FieldByName('items').AsString, 3, '0')) then exportar.Edit else exportar.Append;
    exportar.FieldByName('codos').AsString       := r.FieldByName('codos').AsString;
    exportar.FieldByName('codpac').AsString      := r.FieldByName('codpac').AsString;
    exportar.FieldByName('items').AsString       := utiles.sLlenarIzquierda(r.FieldByName('items').AsString, 3, '0');
    exportar.FieldByName('orden').AsString       := orden;
    exportar.FieldByName('codanalisis').AsString := r.FieldByName('codanalisis').AsString;
    exportar.FieldByName('importe').AsFloat      := setValorAnalisis(r.FieldByName('codos').AsString, r.FieldByName('codanalisis').AsString, Copy(xdfecha, 4, 2) + Copy(utiles.sExprFecha2000(xdfecha), 1, 4));
    exportar.FieldByName('protocolo').AsString   := r.FieldByName('protocolo').AsString;
    paciente.getDatos(r.FieldByName('codpac').AsString);
    exportar.FieldByName('nombre').AsString      := paciente.nombre;
    try
      exportar.Post
    except
      exportar.Cancel
    end;
    datosdb.refrescar(exportar);
    protanter := r.FieldByName('protocolo').AsString;
    Inc(registrosExportados);
   end;
   r.Next;
  end;

  r.Close; r.Free;
  exportar.Close;
  paciente.desconectar;
end;

procedure TTSolicitudAnalisis.CopiarDatosExportados(xdrive: string);
// Objetivo...: Copiar los datos exportados
begin
  utilesarchivos.CopiarArchivos(dbs.baseDat, 'exportobs.*', xdrive);
end;

function TTSolicitudAnalisis.setDatosExportadosPorObraSocial: TQuery;
// Objetivo...: devolver un set de datos exportados
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT * FROM exportobs');
end;

function TTSolicitudAnalisis.NuevaSolicitud: string;
// Objetivo...: Obtener el siguiente nro. de solicitud
begin
  if not ultnro.Active then ultnro.Open;
  ultnro.First;
  if ultnro.RecordCount = 0 then Result := '1' else Result := IntToStr(ultnro.FieldByName('nrosolicitud').AsInteger + 1);
  if (dbs.Trial) and (ultnro.FieldByName('nrosolicitud').AsInteger > 50) then Result := '-1';
end;

function TTSolicitudAnalisis.NuevoProtocolo: string;
// Objetivo...: obtener el siguinte nro. de protocolo
begin
  ultnro.First;
  if ultnro.RecordCount = 0 then Result := '1' else Result := IntToStr(ultnro.FieldByName('protocolo').AsInteger + 1);
  if (dbs.Trial) and (ultnro.FieldByName('protocolo').AsInteger > 50) then Result := '-1';
end;

procedure   TTSolicitudAnalisis.Listar(xdf, xhf: string; salida: char);
// Objetivo...: listar solicitudes de análisis
begin
  r := TQuery.Create(nil);
  r := solicitudanalisisclinicos.setAnalisis;
  r.Open;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Solicitudes de Análisis', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '       Código  Análisis', 1, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  solicitud.First; cantsol := 0;
  while not solicitud.EOF do Begin
    if (solicitud.FieldByName('fecha').AsString >= utiles.sExprFecha2000(xdf)) and (solicitud.FieldByName('fecha').AsString <= utiles.sExprFecha2000(xhf)) then ListLinea(salida);
    solicitud.Next;
  end;

  if cantsol > 0 then Begin
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    List.Linea(0, 0, 'Cantidad de solicitudes :   ' + IntToStr(cantsol), 1, 'Arial, cursiva, 8', salida, 'S');
  end else Begin
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    List.Linea(0, 0, 'No Existen datos para Listar', 1, 'Arial, normal, 11', salida, 'S');
  end;

  r.Close; r.Free;
  list.FinList;
end;

procedure TTSolicitudAnalisis.ListLinea(salida: char);
// Objetivo...: Listar Linea
begin
  paciente.getDatos(solicitud.FieldByName('codpac').AsString);
  profesional.getDatos(solicitud.FieldByName('codprof').AsString);
  if cantsol > 0 then List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Solicitud: ' + solicitud.FieldByName('nrosolicitud').AsString + '  ' + solicitud.FieldByName('protocolo').AsString + '  ' + paciente.Nombre , 1, 'Arial, negrita, 8', salida, 'N');
  List.Linea(65, List.lineactual, 'Fecha: ' + utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString) + '  Prof.: ' + profesional.nombres, 2, 'Arial, negrita, 8', salida, 'S');

  r.First;
  while not r.EOF do Begin
    if r.FieldByName('nrosolicitud').AsString = solicitud.FieldByName('nrosolicitud').AsString then Begin
      nomeclatura.getDatos(r.FieldByName('codanalisis').AsString);
      List.Linea(0, 0, '       ' + r.FieldByName('codanalisis').AsString + '   ' + nomeclatura.descrip, 1, 'Arial, normal, 8', salida, 'S');
    end;
    r.Next;
  end;
  Inc(cantsol);
end;

function  TTSolicitudAnalisis.setDeterminaciones(xnrosolicitud: String): TStringList;
var
  l: TStringList;
Begin
  l := TStringList.Create;
  if datosdb.Buscar(detsol, 'nrosolicitud', 'items', xnrosolicitud, '01') then Begin
    while not detsol.Eof do Begin
      if detsol.FieldByName('nrosolicitud').AsString <> xnrosolicitud then Break;
      l.Add(detsol.FieldByName('codanalisis').AsString);
      detsol.Next;
    end;
  end;
  Result := l;
end;

procedure TTSolicitudAnalisis.ListarResultado(xdnrosol, xhnrosol: string; detSel: array of String; salida: char);
// Objetivo...: Emitir Ficha con los resultados de los análisis - Filtro por Nro. solicitud
begin
  ListarResultadoAC(xdnrosol, xhnrosol, detSel, salida, 'S');
end;

procedure TTSolicitudAnalisis.ListarResultadoF(xdfecha, xhfecha: string; detSel: Array of String; salida: char);
// Objetivo...: Emitir Ficha con los resultados de los análisis - Filtro por fecha
begin
  ListarResultadoAC(xdfecha, xhfecha, detSel, salida, 'F');
end;

procedure TTSolicitudAnalisis.ListarResultadoP(xdesdeprot, xhastaprot: string; salida: char);
// Objetivo...: Emitir Ficha con los resultados de los análisis - Filtro por Solicitud
var
  l: array[1..1] of String;
begin
  ListarResultadoAC(xdesdeprot, xhastaprot, l, salida, 'S');
end;

procedure TTSolicitudAnalisis.ListarResultadoAC(xdesde, xhasta: string; detSel: Array of String; salida, filtro: char);
// Objetivo...: Emitir Ficha con los resultados de los análisis
var
  saltopag, listar, tit, datosOK: boolean;
begin
  TituloSol(salida);

  if filtro = 'S' then
      datosdb.Filtrar(solicitud, 'nrosolicitud >= ' + '''' + xdesde + '''' + ' and nrosolicitud <= ' + '''' + xhasta + '''');
    if filtro = 'F' then
      datosdb.Filtrar(solicitud, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');

  solicitud.First; saltopag := False; tit := False; datosOK := False;
  while not solicitud.EOF do Begin
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
    ListDetSol(solicitud.FieldByName('nrosolicitud').AsString, detSel, salida);
    saltopag := True;

    solicitud.Next;
  end;

  datosdb.QuitarFiltro(solicitud);

  if datosOK then Begin
    if (salida = 'P') or (salida = 'I') then list.FinList;
  end else
    utiles.msgError('No existen datos para listar ...!');

  if (salida = 'T') then list.FinalizarImpresionModoTexto(1); 
end;

procedure TTSolicitudAnalisis.TituloSol(salida: char);
// Objetivo...: Listar títulos de resultados de análisis
begin
  titulos.base_datos := dbs.baseDat_N;
  titulos.conectar;
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 12');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 17'); List.Titulo(34, list.lineactual, ' ' + titulos.titulo, 2, titulos.fTitulo);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 17'); List.Titulo(66, list.lineactual, titulos.profesional, 2, 'Arial, cursiva, 13, clBlue');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 17'); List.Titulo(81, list.lineactual, titulos.actividad, 2, 'Arial, normal, 9');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 6');
  List.Titulo(0, 0, titulos.direccion, 1, 'Arial, normal, 10');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, negrita, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  titulos.desconectar;
end;

procedure TTSolicitudAnalisis.ListSol(xcodpac, xidprof: string; salida: char);
// Objetivo...: Listar datos de la solictud - Paciente y Profesional
begin
  paciente.getDatos(xcodpac);
  profesional.getDatos(xidprof);
  List.Linea(0, 0, '     Paciente:  ' + UpperCase(paciente.Nombre), 1, 'Times New Roman, normal, 10, clTeal', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '     Indicación del Dr/a.:  ', 1, 'Times New Roman, normal, 10', salida, 'N');
  List.Linea(19, list.lineactual, profesional.Nombres, 2, 'Times New Roman, negrita, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '     Protocolo Nº ' + solicitud.FieldByName('protocolo').AsString, 1, 'Times New Roman, normal, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, '     Fecha: ' + Copy(solicitud.FieldByName('fecha').AsString, 7, 2) + ' de ' + meses[StrToInt(Copy(solicitud.FieldByName('fecha').AsString, 5, 2))] + ' ' +  Copy(solicitud.FieldByName('fecha').AsString, 1, 4), 1, 'Times New Roman, normal, 10', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, negrita, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 24', salida, 'S');
end;

procedure TTSolicitudAnalisis.ListDetSol(xnrosolicitud: string; detSel: Array of String; salida: char);
// Objetivo...: Listar detalle de la solicitud
var
  r: TQuery; xcodanalisisanter, xnrosolanter, fuente: string;
begin
  r := setResultados(xnrosolicitud);
  r.Open; r.First; xcodanalisisanter := '';
  while not r.EOF do Begin
     if utiles.verificarItemsEnLista(detSel, r.FieldByName('codanalisis').AsString) then Begin    // Si es una determinacion seleccionada
      if r.FieldByName('codanalisis').AsString <> xcodanalisisanter then Begin
         if Length(Trim(xcodanalisisanter)) > 0 then Begin  // Observaciones de análisis
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
            if Buscar(xnrosolanter, xcodanalisisanter) then list.ListMemo('observaciones', 'Arial, cursiva, 9', 0, salida, obsanalisis, 500); // Si existen observaciones
            List.Linea(0, 0, '  ', 1, 'Arial, normal, 3', salida, 'S');
            if not List.EfectuoSaltoPagina then Begin  // En la misma página
              List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
              List.Linea(0, 0, '  ', 1, 'Arial, normal, 7', salida, 'S');
            end else Begin                                 // En otra página
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 16', salida, 'S');
              List.Linea(0, 0, ' ', 1, 'Arial, normal, 24', salida, 'S');
            end;
          end;
          nomeclatura.getDatos(r.FieldByName('codanalisis').AsString);

          if list.RealizarSaltoPagina(list.altotit) then list.IniciarNuevaPagina;

          List.Linea(0, 0, nomeclatura.descrip, 1, 'Arial, normal, 11', salida, 'S');
          List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        end;

      plantanalisis.getDatos(r.FieldByName('codanalisis').AsString, r.FieldByName('items').AsString);
      if plantanalisis.imputable = 'N' then Begin
        List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
        if plantanalisis.elemento <> '-' then List.Linea(0, 0, plantanalisis.elemento, 1, 'Arial, negrita, 9', salida, 'S') else List.Linea(0, 0, '  ', 1, 'Arial, negrita, 9', salida, 'S');
      end else begin
        if Copy(plantanalisis.elemento, 1, 4) = uppercase(Copy(plantanalisis.elemento, 1, 4)) then fuente := 'Arial, normal, 8' else fuente := 'Arial, normal, 9';
        if plantanalisis.elemento <> '-' then List.Linea(0, 0, plantanalisis.elemento, 1, fuente, salida, 'N') else List.Linea(0, 0, '  ', 1, fuente, salida, 'N');
        List.Linea(30, list.lineactual, r.FieldByName('resultado').AsString, 2, 'Arial, normal, 9', salida, 'S');
      end;
      if Length(Trim(r.FieldByName('valoresn').AsString)) > 0 then List.Linea(0, 0, '                 ' + r.FieldByName('valoresn').AsString, 1, 'Arial, normal, 8', salida, 'S');

      // Observaciones de items
      if BuscarResultado(r.FieldByName('nrosolicitud').AsString, r.FieldByName('codanalisis').AsString, r.FieldByName('items').AsString) then list.ListMemo('observaciones', fuenteObservac, 0, salida, obsresul, 500);
      xcodanalisisanter := r.FieldByName('codanalisis').AsString;
      xnrosolanter      := r.FieldByName('nrosolicitud').AsString;
    end;
    r.Next;
  end;

  List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  if verificarItemsEnLista(detSel, xcodanalisisanter) then
    if Buscar(xnrosolanter, xcodanalisisanter) then list.ListMemo('observaciones', 'Arial, cursiva, 9', 0, salida, obsanalisis, 500); // Si existen observaciones

  r.Close; r.Free;
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
end;

procedure TTSolicitudAnalisis.GuardarOrdenenesSolicitudAnalisis(xprotocolo, xitems, xentregaOrden: string);
// Objetivo...: Guardar las ordenes entregadas en la solicitud de análisis
begin
  if datosdb.Buscar(detsol, 'nrosolicitud', 'items', xprotocolo, xitems) then Begin
    detsol.Edit;
    detsol.FieldByName('entorden').AsString := xentregaOrden;
    try
      detsol.Post
    except
      detsol.Cancel
    end;
    datosdb.refrescar(detsol);
  end;
end;

procedure TTSolicitudAnalisis.ListHDeTrabajo(xnrosolicitud: string; salida: char);
// Objetivo...: Listar Observaciones de Solicitud
const
  c: string = ' ';
var
  r: TQuery; os, ls, x, s, edadpac: string; lineas, i, j: integer;
begin
  getDatos(xnrosolicitud);  // Cargamos la solicitud pedida

  list.Setear(salida);
  list.NoImprimirPieDePagina;

  titulos.base_datos := dbs.baseDat_N;
  titulos.conectar;
  if codigo_barras then Begin
    List.Linea(0, 0, '*' + protocolo + '*', 1, fuente_barras, salida, 'S');
    List.Linea(0, 0, '*' + Copy(utiles.StringRemplazarCaracteres(paciente.nombre, ' ', '_'), 1, lonnombre) + '*', 1, fuente_barras, salida, 'N');
    List.Linea(54, list.lineactual, '  ' + TrimLeft(titulos.titulo), 2, titulos.fTitulo, salida, 'S');
  end else
    List.Linea(0, 0, '  ', 1, 'Arial, negrita, 13', salida, 'S'); List.Linea(54, list.lineactual, '  ' + TrimLeft(titulos.titulo), 2, titulos.fTitulo, salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  list.ListMemoRecortandoEspaciosVericales('Direccion', 'Arial, normal, 8', 55, salida, titulos.tabla, 0);
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
  list.ListMemoRecortandoEspaciosVericales('Actividad', 'Arial, cursiva, 7', 55, salida, titulos.tabla, 0);
  List.Linea(0, 0, NSanatorio, 1, 'Arial, negrita, 10', salida, 'S');
  if Length(Trim(NSanatorio)) > 0 then List.Linea(0, 0, '', 1, 'Arial, negrita, 5', salida, 'S');
  titulos.desconectar;

  profesional.getDatos(codprof);

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
  List.Linea(0, 0, 'Abona', 1, 'Arial, cursiva, 8', salida, 'N'); List.Linea(6, list.Lineactual, ':', 2, 'Arial, cursiva, 8', salida, 'N'); List.importe(15, list.Lineactual, '', total, 3, 'Arial, cursiva, 8');
  List.Linea(16, list.Lineactual, 'Entrega', 4, 'Arial, normal, 8', salida, 'N'); List.Linea(22, list.Lineactual, ':', 5, 'Arial, normal, 8', salida, 'N'); List.importe(31, list.Lineactual, '', entrega, 6, 'Arial, normal, 8');
  List.Linea(34, list.Lineactual, 'Saldo', 7, 'Arial, normal, 8', salida, 'N'); List.Linea(39, list.Lineactual, ':', 8, 'Arial, normal, 8', salida, 'N'); List.importe(49, list.Lineactual, '', total - entrega, 9, 'Arial, normal, 8');

  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Prometido para el:  ' + retiraFecha + '  -  ' + retiraHora + ' Hs.', 1, 'Arial, normal, 9', salida, 'N'); List.Linea(55, list.Lineactual, 'Prometido para el:  ' + retiraFecha + '  -  ' + retiraHora + ' Hs.', 2, 'Arial, normal, 9', salida, 'S');
  // 8º Línea
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, 'Solicitud:', 1, 'Arial, cursiva, 9', salida, 'N');
  List.Linea(55, list.lineactual, 'Solicitud:', 2, 'Arial, cursiva, 9', salida, 'S');
  List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');

  // Obtenemos la lista de análisis
  r := setAnalisis(protocolo);
  r.Open; r.First;
  while not r.EOF do Begin
    nomeclatura.getDatos(r.FieldByName('codanalisis').AsString);
    obsocial.getDatos(r.FieldByName('codos').AsString);
    if r.FieldByName('entorden').AsString = 'S' then ls := '[S]' else ls := '[N]';
    if r.FieldByName('codos').AsString <> '0000' then os := ls + ' ' + obsocial.nombre else os := ' ';
    List.Linea(0, 0, '   ' + r.FieldByName('codanalisis').AsString + ' ' + Copy(nomeclatura.descrip, 1, 36), 1, 'Arial, normal, 9', salida, 'N');
    List.Linea(38, list.Lineactual, Copy(os, 1, 15), 2, 'Arial, normal, 9', salida, 'N');
    List.Linea(56, list.Lineactual, r.FieldByName('codanalisis').AsString + ' ' + nomeclatura.descrip, 3, 'Arial, normal, 9', salida, 'S');
    List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
    r.Next;
  end;
  r.Close; r.Free;

  list.ListMemo('observaciones', 'Arial, cursiva, 8', 0, salida, solicitud, 0);
end;

procedure TTSolicitudAnalisis.ListHojaDeTrabajo(xnrosolicitud: string; salida: char);
// Objetivo...: Listar hoja de trabajo
begin
  ListHDeTrabajo(xnrosolicitud, salida);
  list.CompletarPagina;
  list.FinList;
end;

procedure TTSolicitudAnalisis.ListarSolicitudesRegistradas(xdfecha, xhfecha: String; salida: char);
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
  List.Titulo(0, 0, 'Nº Prot.', 1, 'Arial, cursiva, 8');
  List.Titulo(15, list.Lineactual, 'Paciente', 2, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Obra Social', 3, 'Arial, cursiva, 8');
  List.Titulo(65, list.Lineactual, 'Determinaciones', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');

  l := TStringList.Create;
  r := setSolicitudes(xdfecha, xhfecha);
  r.Open; i := 0;
  while not r.Eof do Begin
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
    list.Linea(15, list.Lineactual, Copy(paciente.Nombre, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
    list.Linea(40, list.Lineactual, Copy(obsocial.nombre, 1, 25), 3, 'Arial, normal, 8', salida, 'N');
    list.Linea(65, list.Lineactual, lista, 4, 'Arial, normal, 8', salida, 'S');
    Inc(i);

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

procedure TTSolicitudAnalisis.GuardarOrdenenesSolicitudAnalisis(xprotocolo, xitems, xentregaOrden, xcodos: string);
// Objetivo...: Guardar las ordenes entregadas en la solicitud de análisis
begin
  if datosdb.Buscar(detsol, 'nrosolicitud', 'items', xprotocolo, xitems) then Begin
    detsol.Edit;
    detsol.FieldByName('entorden').AsString := xentregaOrden;
    detsol.FieldByName('codos').AsString    := xcodos;
    try
      detsol.Post
    except
      detsol.Cancel
    end;
    datosdb.refrescar(detsol);
  end;
end;

procedure TTSolicitudAnalisis.Depurar(xfecha: string);
// Objetivo...: Depurar Información
var
  lista: TStringList;
  cantreg, i: Integer;
  histdetsol, histresultado, histrefanalisis, histobsanalisis, histsolicitud: TTable;
  nsol: String;
begin
  if dbs.BaseClientServ = 'N' then drvhistorico := dbs.DirSistema + '\Historico' else Begin
    drvhistorico := 'Laboratoriohistorico';
    dbs.NuevaBaseDeDatos2(drvhistorico, 'sysdba', 'masterkey');
  end;

  histsolicitud   := datosdb.openDB('solicitud', 'nrosolicitud', '', drvhistorico);
  histdetsol      := datosdb.openDB('detsol', 'nrosolicitud;items', '', drvhistorico);
  histresultado   := datosdb.openDB('resultado', 'nrosolicitud;codanalisis;items', '', drvhistorico);
  histrefanalisis := datosdb.openDB('refanalisis', 'nrosolicitud;codanalisis;items', '', drvhistorico);
  histobsanalisis := datosdb.openDB('obsanalisis', 'nrosolicitud;codanalisis', '', drvhistorico);
  histsolicitud.Open; histdetsol.Open; histresultado.Open; histrefanalisis.Open; histobsanalisis.Open;

  cclab.conectar;

  lista := TStringList.Create;

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
          if datosdb.Buscar(histdetsol, 'Nrosolicitud', 'Items', detsol.FieldByName('nrosolicitud').AsString, detsol.FieldByName('items').AsString) then histdetsol.Edit else histdetsol.Append;
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
          if datosdb.Buscar(histresultado, 'nrosolicitud', 'codanalisis', 'items', resultado.FieldByName('nrosolicitud').AsString, resultado.FieldByName('codanalisis').AsString, resultado.FieldByName('items').AsString) then histresultado.Edit else histresultado.Append;
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
          if datosdb.Buscar(histrefanalisis, 'nrosolicitud', 'codanalisis', 'items', obsresul.FieldByName('nrosolicitud').AsString, obsresul.FieldByName('codanalisis').AsString, obsresul.FieldByName('items').AsString) then histrefanalisis.Edit else histrefanalisis.Append;
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
          if datosdb.Buscar(histobsanalisis, 'nrosolicitud', 'codanalisis', obsanalisis.FieldByName('nrosolicitud').AsString, obsanalisis.FieldByName('codanalisis').AsString) then histobsanalisis.Edit else histobsanalisis.Append;
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
        if histsolicitud.FindKey([solicitud.FieldByName('nrosolicitud').AsString]) then histsolicitud.Edit else histsolicitud.Append;
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
      cclab.BorrarComprobante(solicitud.FieldByName('protocolo').AsString, solicitud.FieldByName('codpac').AsString, 'FAC', 'A', '0000', utiles.sLlenarIzquierda(solicitud.FieldByName('protocolo').AsString, 8, '0'));

      lista.Add(solicitud.FieldByName('nrosolicitud').AsString);
      solicitud.Next;
    end;
  end;


  cclab.desconectar;

  datosdb.closeDB(histdetsol); datosdb.closeDB(histresultado); datosdb.closeDB(histrefanalisis); datosdb.closeDB(histobsanalisis); datosdb.closeDB(histsolicitud);
  desconectar;

  utiles.MsgFinalizarProcesandoDatos;
  dbs.desconectarDB2;
end;

function  TTSolicitudAnalisis.verificarPaciente(xcodpac: string): boolean;
// Objetivo...: Verificar paciente en solicitud
var
  t: boolean;
begin
  t := False;
  if not solicitud.Active then Begin
    solicitud.Open;
    t := True;
  end;

  Result := False;
  solicitud.First;
  while not solicitud.EOF do Begin
    if solicitud.FieldByName('codpac').AsString = xcodpac then Begin
      Result := True;
      Break;
    end;
    solicitud.Next;
  end;

  if t then solicitud.Close;
end;

function  TTSolicitudAnalisis.verificarProfesional(xcodprof: string): boolean;
// Objetivo...: Verificar profesional en solicitud
var
  t: boolean;
begin
  t := False;
  if not solicitud.Active then Begin
    solicitud.Open;
    t := True;
  end;

  Result := False;
  solicitud.First;
  while not solicitud.EOF do Begin
    if solicitud.FieldByName('codprof').AsString = xcodprof then Begin
      Result := True;
      Break;
    end;
    solicitud.Next;
  end;

  if t then solicitud.Close;
end;

function  TTSolicitudAnalisis.verificarEntidadDerivacion(xidentidad: string): boolean;
// Objetivo...: Verificar entidades en las solicitudes
begin
  r := datosdb.tranSQL('select identidad from ' + detsol.TableName + ' where idantidad = ' + '"' + xidentidad + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function TTSolicitudAnalisis.verificarObraSocial(xcodos: string): boolean;
// Objetivo...: Verificar Obra Social
begin
  r := datosdb.tranSQL('select codos from ' + detsol.TableName + ' where codos = ' + '"' + xcodos + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function TTSolicitudAnalisis.verificarEntidadQueDeriva(xentidad: string): boolean;
// Objetivo...: Verificar Entidad que deriva
begin
  r := datosdb.tranSQL('select codos from ' + solicitud.TableName + ' where entidadderiv = ' + '"' + xentidad + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

function  TTSolicitudAnalisis.verificarResultadoSolicitud(xnrosolicitud: string): boolean;
// Objetivo...: Verificar profesional en solicitud
begin
  r := datosdb.tranSQL(resultado.DatabaseName, 'select nrosolicitud from ' + resultado.TableName + ' where nrosolicitud = ' + '"' + xnrosolicitud + '"');
  r.Open;
  if r.RecordCount > 0 then Result := True else Result := False;
  r.Close; r.Free;
end;

procedure TTSolicitudAnalisis.ImprimirSobre(xnombre: string; xlineas, xmargeniz: Integer; salida: char);
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
  titulos.getDatosSobre;
  List.Linea(0, 0, '', 1, 'Arial, negrita, 8', salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, negrita, 17', salida, 'N'); List.Linea(4, list.lineactual, utiles.espacios(xmargeniz) + titulos.titsobre, 2, titulos.ftitsobre, salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, negrita, 17', salida, 'N'); List.Linea(26, list.lineactual, utiles.espacios(xmargeniz) + titulos.subtsobre, 2, titulos.fsubtsobre + ', clBlue', salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, negrita, 17', salida, 'N'); List.Linea(24, list.lineactual, utiles.espacios(xmargeniz) + titulos.actsobre, 2, titulos.factsobre, salida, 'S');
  List.Linea(0, 0, '', 1, 'Arial, negrita, 14', salida, 'N');
  titulos.desconectar;
  if Length(Trim(xnombre)) > 0 then Begin
    List.Linea(0, 0, '', 1, 'Arial, negrita, 14', salida, 'N');
    List.Linea(4, list.lineactual, utiles.espacios(xmargeniz) + utiles.espacios(30) + 'Paciente:  ' + UpperCase(xnombre), 2, 'Times New Roman, normal, 10, clTeal', salida, 'S');
  end;
  List.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.FinList;
  list.ImprimirVetical;
end;

function TTSolicitudAnalisis.CalcularValorAnalisis(xcodos, xcodanalisis: string; xOSUB, xNOUB, xOSUG, xNOUG: real): real;
var
  i, j, v, porcentOS: real; montoFijo: Boolean;
begin
  // Verificamos el porcentaje que paga la Obra Social
  if obsocial.porcentaje > 0 then porcentOS := (obsocial.porcentaje * 0.01) else porcentOS := (100 * 0.01);

  i := 0; j := 0; v9984 := 0; PorcentajeDifObraSocial := 0; PorcentajeDif9984 := 0;

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

  PorcentajeDifObraSocial := i     - (i     * porcentOS);    // Obtiene la Dif. a Pagar, por ejemplo, si cubre el 80% obtiene el 20%, la dif.
  PorcentajeDif9984       := v9984 - (v9984 * porcentOS);

  i := i * porcentOS;
  v9984 := v9984 * porcentOS;
  T9984 := T9984 + v9984;

  Result := i;
end;

function TTSolicitudAnalisis.setValorAnalisis(xcodos, xcodanalisis, xperiodo: string): real;
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

{var
  cod: String;
begin
  Periodo := xperiodo;
  obsocial.SincronizarArancel(xcodos, xperiodo);
  obsocial.getDatos(xcodos);
  nomeclatura.getDatos(xcodanalisis);
  if Length(Trim(nomeclatura.codfact)) > 0 then cod := nomeclatura.codfact else cod := xcodanalisis;
  nomeclatura.getDatos(cod);   // Sincronizamos el código de referencia para facturar
  if nomeclatura.RIE <> '*' then Result := CalcularValorAnalisis(xcodos, cod, obsocial.UB, nomeclatura.UB, obsocial.UG, nomeclatura.gastos) else Result := CalcularValorAnalisis(xcodos, cod, obsocial.RIEUB, nomeclatura.UB, obsocial.RIEUG, nomeclatura.gastos);
  Periodo := '';}
end;

function TTSolicitudAnalisis.Precio9984: Real;
begin
  Result := v9984;
end;

function TTSolicitudAnalisis.Total9984: Real;
begin
  Result := T9984;
  T9984  := 0;
end;

function TTSolicitudAnalisis.setImportePacientePor_ObraSocial(xcodpac, xcodob, xdfecha, xhfecha: string): real;
// Objetivo...: Calcular el importe de analisis de obras sociales para un solicitud dada
var
  t: real;
begin
  t := 0;
  // Aislamos los pacientes por obra social y fecha
  datosdb.Filtrar(solicitud, 'codpac = ' + xcodpac + ' AND fecha >= ' + utiles.sExprFecha2000(xdfecha) + ' AND fecha <= ' + utiles.sExprFecha2000(xhfecha));
  solicitud.First;
  while not solicitud.EOF do Begin
    datosdb.Filtrar(detsol, 'nrosolicitud = ' + solicitud.FieldByName('nrosolicitud').AsString);
    detsol.First;
    while not detsol.EOF do Begin // Extraemos los items de esa solicitud
      t := t + setValorAnalisis(detsol.FieldByName('codos').AsString, detsol.FieldByName('codanalisis').AsString, Copy(xdfecha, 1, 2) + '/' + Copy(utiles.sExprFecha2000(xdfecha), 1, 4));
      detsol.Next;
    end;
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  datosdb.QuitarFiltro(detsol);
  Result := t;
end;

function TTSolicitudAnalisis.setImportePacientePor_ObraSocial(xcodpac, xdfecha, xhfecha: string): TQuery;
// Objetivo...: Calcular el importe de analisis de obras sociales para un solicitud dada
begin
  Result := datosdb.tranSQL(solicitud.DatabaseName, 'SELECT ' + detsol.TableName + '.Nrosolicitud, ' + detsol.TableName + '.Codos, ' + detsol.TableName + '.Items, ' + detsol.TableName + '.Codanalisis, ' +
            solicitud.TableName + '.Codpac, ' + solicitud.TableName + '.Fecha FROM ' + solicitud.TableName + ' ,' + detsol.TableName + ' WHERE ' + solicitud.TableName + '.Nrosolicitud = ' + detsol.TableName + '.Nrosolicitud AND ' +
            solicitud.TableName + '.codpac = ' + '"' + xcodpac + '"' + ' AND fecha >= ' + '"' + utiles.sExprFecha2000(xdfecha) + '"' + ' AND fecha <= ' + '"' + utiles.sExprFecha2000(xhfecha) + '"');
end;

function TTSolicitudAnalisis.verificarSiElItemsTieneMovimientos(xnrosolicitud, xcodanalisis: string): boolean;
// Objetivo...: verificar si el items tiene resultados cargados
begin
  Result := Buscar(xnrosolicitud, xcodanalisis, '01');
end;

procedure TTSolicitudAnalisis.BorrarItemsEnMovimiento(xnrosolicitud, xcodanalisis: string);
// Objetivo...: Borrar un items con sus resultados
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'DELETE FROM ' + resultado.TableName + ' WHERE nrosolicitud = ' + '"' + xnrosolicitud + '"' + ' AND codanalisis = ' + '"' + xcodanalisis + '"');
end;

function TTSolicitudAnalisis.setDeterminacionesAnalisis(xdfecha, xhfecha: string): TStringList;
// Objetivo...: Devolver las determinaciones de analisis de las solicitudes
var
  l: TStringList;
  f: Boolean;
  i: Integer;
begin
  l := TStringList.Create;
  datosdb.Filtrar(solicitud, 'Fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' AND fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if datosdb.Buscar(detsol, 'nrosolicitud', 'items', solicitud.FieldByName('nrosolicitud').AsString, '01') then Begin
      while not detsol.Eof do Begin
        if solicitud.FieldByName('nrosolicitud').AsString <> detsol.FieldByName('nrosolicitud').AsString then Break;
        f := True;
        For i := 1 to l.Count do
          if l.Strings[i-1] = detsol.FieldByName('codanalisis').AsString then Begin
            f := False;
            Break;
          end;
        if f then l.Add(detsol.FieldByName('codanalisis').AsString);
        detsol.Next;
      end;
    end;
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);

  Result := l;
end;

function TTSolicitudAnalisis.setProtocolosDeterminacion(xdfecha, xhfecha, xcodanalisis: string): TObjectList;
// Objetivo...: Devolver los protocolos por determinaciones
var
  l: TObjectList;
  objeto: TTSolicitudAnalisis;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(solicitud, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdfecha) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhfecha) + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    if datosdb.Buscar(detsol, 'nrosolicitud', 'items', solicitud.FieldByName('nrosolicitud').AsString, '01') then Begin
      while not detsol.Eof do Begin
        objeto := TTSolicitudAnalisis.Create;
        if solicitud.FieldByName('nrosolicitud').AsString <> detsol.FieldByName('nrosolicitud').AsString then Break;
        if detsol.FieldByName('codanalisis').AsString = xcodanalisis then Begin
          objeto := TTSolicitudAnalisis.Create;
          objeto.nrosolicitud := solicitud.FieldByName('nrosolicitud').AsString;
          objeto.fecha        := utiles.sFormatoFecha(solicitud.FieldByName('fecha').AsString);
          objeto.codpac       := solicitud.FieldByName('codpac').AsString;
          objeto.Items        := detsol.FieldByName('items').AsString;
          l.Add(objeto);
        end;
        detsol.Next;
      end;
    end;
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);

  Result := l;
end;

function TTSolicitudAnalisis.verificarItemsEnLista(listArray: Array of String; xitems: String): Boolean;
// Objetivo...: Verificar que el codigo exista en el arreglo de Obras Sociales
var
  i: Integer;
begin
  Result := False;
  if Length(Trim(listArray[Low(listArray)])) = 0 then  Result := True else Begin  // Retornamos True si no hay elementos, es decir, se listan todas
    For i := Low(listArray) to High(listArray) do
      if listArray[i] = xitems then Begin
        Result := True;
        Break;
      end;
  end;
end;

function  TTSolicitudAnalisis.BuscarMovPagos(xprotocolo, xitems: String): Boolean;
// Objetivo...: Buscar Movimiento de Pago
begin
  if movpagos.IndexFieldNames <> 'protocolo;items' then movpagos.IndexFieldNames := 'protocolo;items';
  Result := datosdb.Buscar(movpagos, 'protocolo', 'items', xprotocolo, xitems);
end;

procedure TTSolicitudAnalisis.RegistrarMovPagos(xprotocolo, xitems, xfecha, xcodpac, xconcepto: String; xtipomov: Integer; xmonto, xentrega: Real; xcantitems: Integer; xmodifica: Boolean);
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

procedure  TTSolicitudAnalisis.BorrarMovPagos(xprotocolo: String);
// Objetivo...: Borrar Movimientos de Pagos
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'delete from ' + movpagos.TableName + ' where protocolo = ' + '''' + xprotocolo + '''');
  datosdb.closeDB(movpagos); movpagos.Open;
end;

procedure  TTSolicitudAnalisis.BorrarPagosProtocolo(xprotocolo: String);
// Objetivo...: Borrar Movimientos de Pagos
begin
  datosdb.tranSQL(solicitud.DatabaseName, 'delete from movpagos where protocolo = ' + '''' + xprotocolo + '''' + ' and tipomov = 2');
  datosdb.closeDB(movpagos); movpagos.Open;
  RecalcularSaldo(xprotocolo);
end;

procedure  TTSolicitudAnalisis.BorrarEntrega(xprotocolo: String);
// Objetivo...: Borrar Entrega
begin
  if BuscarMovPagos(xprotocolo, '000') then Begin
    movpagos.Delete;
    datosdb.closeDB(movpagos); movpagos.Open;
    // Reactivamos la Deuda
    DeterminarEstado(xprotocolo, 'I');
  end;
end;

procedure TTSolicitudAnalisis.DeterminarEstado(xprotocolo, xestado: String);
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

function TTSolicitudAnalisis.setPagosAdeudados(xdesde, xhasta: String): TObjectList;
// Objetivo...: Devolver Protocolos Adeudados
var
  l: TObjectList;
  objeto: TTSolicitudAnalisis;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(movpagos, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and estado = ' + '''' + 'I' + '''');
  movpagos.First;
  while not movpagos.Eof do Begin
    objeto := TTSolicitudAnalisis.Create;
    objeto.Protocolo    := movpagos.FieldByName('protocolo').AsString;
    objeto.Fecha        := utiles.sFormatoFecha(movpagos.FieldByName('fecha').AsString);
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

function TTSolicitudAnalisis.setPagosRegistrados(xdesde, xhasta: String): TObjectList;
// Objetivo...: Devolver Pagos Registrados
var
  l: TObjectList;
  objeto: TTSolicitudAnalisis;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(movpagos, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + ' estado = ' + '''' + 'R' + '''');
  movpagos.First;
  while not movpagos.Eof do Begin
    objeto := TTSolicitudAnalisis.Create;
    objeto.Protocolo    := movpagos.FieldByName('protocolo').AsString;
    objeto.Fecha        := utiles.sFormatoFecha(movpagos.FieldByName('fecha').AsString);
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

function TTSolicitudAnalisis.setProtocolosSaldados(xdesde, xhasta: String): TObjectList;
// Objetivo...: Devolver Protocolos Adeudados
var
  l: TObjectList;
  objeto: TTSolicitudAnalisis;
Begin
  l := TObjectList.Create;
  datosdb.Filtrar(movpagos, 'estado = ' + '''' + 'P' + '''' + ' and fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''');
  movpagos.First;
  while not movpagos.Eof do Begin
    objeto := TTSolicitudAnalisis.Create;
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

procedure TTSolicitudAnalisis.RecalcularSaldo(xprotocolo: String);
// Objetivo...: Recalcular Saldo
var
  saldo: Real;
Begin
  saldo := 0;
  if BuscarMovPagos(xprotocolo, '000') then Begin
    while not movpagos.Eof do Begin
      if movpagos.FieldByName('protocolo').AsString <> xprotocolo then Break;
      if movpagos.FieldByName('items').AsString = '000' then Begin
        saldo := movpagos.FieldByName('monto').AsFloat - movpagos.FieldByName('entrega').AsFloat;
      end else Begin
        saldo := saldo - movpagos.FieldByName('monto').AsFloat;
        movpagos.Edit;
        movpagos.FieldByName('saldo').AsFloat := saldo;         // Actualizamos saldos invidividuales
        try
          movpagos.Post
         except
          movpagos.Cancel
        end;
      end;

      movpagos.Next;
    end;
  end;

  if BuscarMovPagos(xprotocolo, '000') then Begin   // Ajuste del saldo final
    movpagos.Edit;
    movpagos.FieldByName('saldo').AsFloat := saldo; // Actualizamos saldos invidividuales
    if saldo = 0 then movpagos.FieldByName('estado').AsString := 'P' else movpagos.FieldByName('estado').AsString := 'I';
    try
      movpagos.Post
     except
      movpagos.Cancel
    end;
  end;

  datosdb.closeDB(movpagos); movpagos.Open;
end;

procedure TTSolicitudAnalisis.ListarSaldosACobrar(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Detalle de Cobros
var
  l: TStringList;
  idanter: String;
  i: Integer;
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Saldos a Cobrar - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Protocolo / Paciente', 1, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'F. Oper.', 2, 'Arial, cursiva, 8');
  List.Titulo(89, list.Lineactual, 'Saldo', 3, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  l := TStringList.Create; totales[1] := 0; idanter := '';
  datosdb.Filtrar(movpagos, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and estado = ' + '''' + 'I' + '''');
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
          if movpagos.FieldByName('estado').AsString = 'I' then Begin
            list.importe(94, list.Lineactual, '', movpagos.FieldByName('saldo').AsFloat, 3, 'Arial, normal, 8');
            totales[1] := totales[1] + movpagos.FieldByName('saldo').AsFloat;
          end else Begin
            list.importe(94, list.Lineactual, '', movpagos.FieldByName('monto').AsFloat - movpagos.FieldByName('entrega').AsFloat, 3, 'Arial, normal, 8');
            totales[1] := totales[1] + (movpagos.FieldByName('monto').AsFloat - movpagos.FieldByName('entrega').AsFloat);
          end;
          list.Linea(94, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
        end else Begin
          list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        end;
        movpagos.Next;
      end;
    end;
  end;

  if totales[1] <> 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Saldo Acumulado:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTSolicitudAnalisis.ListarSaldosCobrados(xdesde, xhasta: String; salida: char);
// Objetivo...: Listar Detalle de Cobros
var
  l: TStringList;
  idanter: String;
  i: Integer;
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Cobros Efectuados - Lapso: ' + xdesde + '-' + xhasta, 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Protocolo / Paciente', 1, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'F. Oper.', 2, 'Arial, cursiva, 8');
  List.Titulo(89, list.Lineactual, 'Saldo', 3, 'Arial, cursiva, 8');

  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  l := TStringList.Create; totales[1] := 0; idanter := '';
  datosdb.Filtrar(movpagos, 'fecha >= ' + '''' + utiles.sExprFecha2000(xdesde) + '''' + ' and fecha <= ' + '''' + utiles.sExprFecha2000(xhasta) + '''' + ' and estado = ' + '''' + 'P' + '''');
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
          if movpagos.FieldByName('estado').AsString = 'I' then Begin
            list.importe(94, list.Lineactual, '', movpagos.FieldByName('saldo').AsFloat, 3, 'Arial, normal, 8');
            totales[1] := totales[1] + movpagos.FieldByName('saldo').AsFloat;
          end else Begin
            list.importe(94, list.Lineactual, '', movpagos.FieldByName('monto').AsFloat, 3, 'Arial, normal, 8');
            totales[1] := totales[1] + (movpagos.FieldByName('monto').AsFloat);
          end;
          list.Linea(94, list.Lineactual, '', 4, 'Arial, normal, 8', salida, 'S');
        end else Begin
          list.Linea(95, list.Lineactual, '', 3, 'Arial, normal, 8', salida, 'S');
        end;
        movpagos.Next;
      end;
    end;
  end;

  if totales[1] <> 0 then Begin
    list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Saldo Acumulado:', 1, 'Arial, negrita, 8', salida, 'N');
    list.importe(95, list.Lineactual, '', totales[1], 2, 'Arial, negrita, 8');
    list.Linea(96, list.Lineactual, '', 3, 'Arial, negrita, 8', salida, 'S');
  end;

  list.FinList;
end;

procedure TTSolicitudAnalisis.ListarMovPagos(xdesde, xhasta: String; salida: char);
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

function  TTSolicitudAnalisis.Bloquear: Boolean;
// Objetivo...: bloquear proceso
begin
  result := true;
//  Result := bloqueo.Bloquear('solicitud');
end;

procedure TTSolicitudAnalisis.QuitarBloqueo;
// Objetivo...: Quitar Bloqueo
begin
  //bloqueo.QuitarBloqueo('solicitud');
  //plantanalisis.QuitarBloqueo('plantilla');
end;

function  TTSolicitudAnalisis.BloquearResultado: Boolean;
// Objetivo...: bloquear proceso
begin
  result := true;
  //Result := bloqueo.Bloquear('resultado');
end;

procedure TTSolicitudAnalisis.QuitarBloqueoResultado;
// Objetivo...: Quitar Bloqueo
begin
  //bloqueo.QuitarBloqueo('resultado');
end;

function  TTSolicitudAnalisis.BloquearCobro: Boolean;
// Objetivo...: bloquear proceso
begin
  result := true;
  //Result := bloqueo.Bloquear('cobros');
end;

procedure TTSolicitudAnalisis.QuitarBloqueoCobro;
// Objetivo...: Quitar Bloqueo
begin
  //bloqueo.QuitarBloqueo('cobros');
end;

procedure TTSolicitudAnalisis.AjustarFechaSolicitudes(xdesdeprot, xhastaprot, xnuevafecha: String);
// Objetivo...: Ajustar Fechas Solicitud
Begin
  datosdb.Filtrar(solicitud, 'nrosolicitud >= ' + '''' + xdesdeprot + '''' + ' and nrosolicitud <= ' + '''' + xhastaprot + '''');
  solicitud.First;
  while not solicitud.Eof do Begin
    solicitud.Edit;
    solicitud.FieldByName('fecha').AsString := utiles.sExprFecha2000(xnuevafecha);
    try
      solicitud.Post
     except
      solicitud.Cancel
    end;
    solicitud.Next;
  end;
  datosdb.QuitarFiltro(solicitud);
  datosdb.refrescar(solicitud);
end;

{procedure TTSolicitudAnalisis.ConsultarHistorico;
// Objetivo...: cerrar tablas de persistencia
begin
  if dbs.BaseClientServ = 'N' then drvhistorico := dbs.DirSistema + '\Historico' else Begin
    dbs.desconectarDB;
    drvhistorico := 'Laboratoriohistorico';
    dbs.NuevaBaseDeDatos(drvhistorico, 'sysdba', 'masterkey');
  end;
  //conexiones := 1;
  //desconectar;
  datosdb.closeDB(solicitud); datosdb.closeDB(detsol); datosdb.closeDB(resultado); datosdb.closeDB(obsresul); datosdb.closeDB(obsanalisis);
  solicitud     := datosdb.openDB('solicitud', 'nrosolicitud', '', drvhistorico);
  detsol        := datosdb.openDB('detsol', 'nrosolicitud;items', '', drvhistorico);
  resultado     := datosdb.openDB('resultado', 'nrosolicitud;codanalisis;items', '', drvhistorico);
  obsresul      := datosdb.openDB('refanalisis', 'nrosolicitud;codanalisis;items', '', drvhistorico);
  obsanalisis   := datosdb.openDB('obsanalisis', 'nrosolicitud;codanalisis', '', drvhistorico);
  ModoHistorico := True;
  //conectar;
  dir           := drvhistorico;
  ModoHistorico := True;
end;

procedure TTSolicitudAnalisis.DesconectarHistorico;
// Objetivo...: Consultar Datos Normales
Begin
  conexiones := 1;
  Desconectar;
  //datosdb.closeDB(solicitud); datosdb.closeDB(detsol); datosdb.closeDB(resultado); datosdb.closeDB(obsresul); datosdb.closeDB(obsanalisis);
  //InstanciarTablas;
  Conectar;
  ModoHistorico := False;
end;}

procedure TTSolicitudAnalisis.VerificarIntegridadPacientes;
var
  r: TQuery;
Begin
  solicitud.IndexFieldNames := 'codpac';
  r := paciente.setPacientes;
  r.Open;
  while not r.Eof do Begin
    if not solicitud.FindKey([r.FieldByName('codpac').AsString]) then paciente.Borrar(r.FieldByName('codpac').AsString);
    r.Next;
  end;
  r.Close; r.Free;
  solicitud.IndexFieldNames := 'nrosolicitud';
end;

function  TTSolicitudAnalisis.BuscarPaciente(xcodpac: String): Boolean;
// Objetivo...: Buscar paciente
Begin
  solicitud.IndexFieldNames := 'codpac';
  solicitud.IndexFieldNames := 'nrosolicitud';
end;

procedure TTSolicitudAnalisis.conectar;
// Objetivo...: Abrir tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not solicitud.Active then solicitud.Open;
    if not detsol.Active then detsol.Open;
    if not resultado.Active then resultado.Open;
    if not obsresul.Active then obsresul.Open;
    if not obsanalisis.Active then obsanalisis.Open;
    if not ultnro.Active then ultnro.Open;
    if not movpagos.Active then movpagos.Open;
  end;
  paciente.conectar;
  profesional.conectar;
  nomeclatura.conectar;
  Inc(conexiones);
  if not ModoHistorico then  dir := dbs.baseDat_N else
    if dbs.BaseClientServ = 'N' then dir := dbs.DirSistema + '\Historico' else dir := 'Laboratoriohistorico';
end;

procedure TTSolicitudAnalisis.desconectar;
// Objetivo...: Cerrar tablas de persistencia
begin
  controlSQL := False;
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    if solicitud.Active     then datosdb.closeDB(solicitud);
    if detsol.Active        then datosdb.closeDB(detsol);
    if resultado.Active     then datosdb.closeDB(resultado);
    if obsresul.Active      then datosdb.closeDB(obsresul);
    if obsanalisis.Active   then datosdb.closeDB(obsanalisis);
    if ultnro.Active        then datosdb.closeDB(ultnro);
    if movpagos.Active      then datosdb.closeDB(movpagos);
  end;
  paciente.desconectar;
  profesional.desconectar;
  nomeclatura.desconectar;
end;

{===============================================================================}

function solicitudanalisisclinicos: TTSolicitudAnalisis;
begin
  if xsolicitudanalisisclinicos = nil then
    xsolicitudanalisisclinicos := TTSolicitudAnalisis.Create;
  Result := xsolicitudanalisisclinicos;
end;

{===============================================================================}

initialization

finalization
  xsolicitudanalisisclinicos.Free;

end.
