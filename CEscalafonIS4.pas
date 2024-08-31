unit CEscalafonIS4;

interface

uses CTablaEscalafonIS4, CMateriasIS4, CCarrerasIS4, CDocentesIS4, CBDT, SysUtils,
     DBTables, CUtiles, CListar, CIDBFM, Contnrs, CServers2000_Excel, Classes,
     StdCtrls, CUtilidadesArchivos, Forms;

type

TTEscalafonamiento = class
  PeriodoIns, NrodocIns, IdcarreraIns, IdmateriaIns: String;
  PeriodoPG, NrodocPG, ItemsPG, SubitemsPG: String;
  PeriodoPM, NrodocPM, IdcarreraPM, IdmateriaPM, ItemsPM, SubitemsPM: String;
  NrodocIt, ItemsgIt, ItemsIt, SubitemsIt, DescripIt, FechaIt, Eval: String;
  PuntosPG, PuntosPM, PuntosTot, PuntosIt, HsCatedra, HsReloj, Cantidad, CantidadPM: Real;
  NrodocItMat, IdmateriaMat, ItemsgItMat, ItemsItMat, SubitemsItMat, DescripItMat, FechaItMat, EvalMat: String;
  Motivo, PeriodoTope, FechaTope: String;
  PuntosPGMat, PuntosPMMat, PuntosItMat, HsCatedraMat, HsRelojMat, CantidadMat: Real;
  ant_nrodoc, ant_idcarrera, ant_idmateria, ant_desde, ant_hasta: String;
  DatosInstitucion: TStringList;
  inscripcion, tabla1, tabla2, puntaje, puntositems, desestimaciones, topesescalafon, tabla3, tabla4, tabla5, bloqueo: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    BuscarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria: String): Boolean;
  procedure   RegistrarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria, xestado: String);
  procedure   BorrarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria: String);
  procedure   getDatosInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria: String);
  function    setMateriasInscripcion(xperiodo, xnrodoc, xidcarrera: String): TObjectList; overload;
  function    setMateriasInscripcion(xperiodo, xidcarrera: String): TObjectList; overload;
  function    setMateriasInscripcionEsc(xperiodo, xnrodoc: String): TObjectList;
  function    setMateriasInscripcionCicloAnterior(xperiodo, xnrodoc, xidcarrera: String): TObjectList;
  procedure   ListarInscripcion(xperiodo, xnrodoc: String; salida: char);
  procedure   ListarInscriptos(xperiodo, xidcarrera: String; salida: char);

  function    BuscarPG(xperiodo, xnrodoc, xitems, xsubitems: String): Boolean;
  procedure   RegistrarPG(xperiodo, xnrodoc, xitems, xsubitems: String; xpuntos: Real);
  procedure   BorrarPG(xperiodo, xnrodoc, xitems, xsubitems: String);
  procedure   getDatosPG(xperiodo, xnrodoc, xitems, xsubitems: String);
  function    setSumaPG(xperiodo, xnrodoc, xitems: String): Real;

  function    BuscarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String): Boolean;
  procedure   RegistrarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String; xpuntos, xcantidad: Real);
  procedure   BorrarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String);
  procedure   getDatosPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String);
  function    setItemsMateria(xperiodo, xnrodoc: String): TObjectList;
  function    setSumaPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems: String): Real;

  procedure   RealizarRecuento(xperiodo, xidcarrera: String; xmaterias: TStringList);
  function    setEscalafon(xperiodo, xidcarrera, xidmateria, xtipo_escalafon: String): TObjectList;

  function    BuscarItems(xnrodoc, xitemsg, xitems, xsubitems: String): Boolean;
  procedure   RegistrarItems(xnrodoc, xitemsg, xitems, xsubitems, xdescrip, xfecha, xeval: String; xpuntos, xhscatedra, xhsreloj, xcantidad: Real; xcantitems: Integer);
  function    setItems(xnrodoc, xitemsg, xitems: String): TObjectList;
  procedure   BorrarItems(xnrodoc, xitemsg, xitems: String);

  function    BuscarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria: String): Boolean;
  procedure   registrarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria, xmotivo: String);
  procedure   BorrarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria: String);
  procedure   getDatosDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria: String);

  procedure   ListarExpediente(xperiodo: String; xlista: TStringList; salida: char);

  procedure   RegistrarDatosInst(xdatos: TMemo);
  procedure   getDatosInst;

  function    BuscarTope(xperiodo: String): Boolean;
  procedure   RegistrarTope(xperiodo, xfecha: String);
  procedure   BorrarTope(xperiodo: String);
  procedure   getDatosTope(xperiodo: String);

  procedure   Exportar(xperiodo, xidcarrera: String);
  function    Importar(xperiodo, xdrive: String; xlista: TStringList): TStringList;
  function    setListaDocentesImportar(xperiodo, xdrive: String): TStringList;
  procedure   ImportarAntecedentesDocente(xlista: TStringList; xperiodo, xdrive: String; ximportar_datos_docentes: Boolean);

  function    BuscarEscalafonAlternativo(xperiodo, xnrodoc, xidcarrera: String): Boolean;

  function    BuscarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde: String): Boolean;
  procedure   RegistrarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde, xhasta: String);
  procedure   BorrarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde: String);
  function    setListaAntiguedad(xnrodoc, xidcarrera, xidmateria: String): TObjectList;
  function    verificarSiTieneAntiguedad(xnrodoc, xidcarrera, xidmateria: String): Boolean;

  function    BuscarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex: String): Boolean;
  procedure   RegistrarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex: String);
  procedure   BorrarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex: String);
  function    VerificarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera: String): Boolean;
  function    setCarrerasExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera: String): String;

  procedure   CopiarEscalafon(xdeperiodo, xaperiodo, xidcarrera: String; xinscripciones, xantecedentesmateria, xdesestimaciones, xexclusiones: Boolean);
  procedure   AnularCopiarEscalafon(xperiodo, xidcarrera: String);

  function    BuscarBloqueo(xnrodoc, xtipo: String): Boolean;
  procedure   Bloquear(xnrodoc, xtipo, xusuario, xtarea: String);
  procedure   QuitarBloqueo(xnrodoc, xtipo: String);
  function    verificarBloqueo(xnrodoc, xtipo: String): String;
  procedure   BorrarBloqueosUsuario(xusuario: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  c1: Integer;
  l1: String;
  archivo: TextFile;
  procedure   ListarTitulo(salida: char);
  procedure   RegistrarIns(xperiodo, xnrodoc, xidcarrera, xidmateria, xestado: String);
end;

function escalafon: TTEscalafonamiento;

implementation

var
  xescalafon: TTEscalafonamiento = nil;

constructor TTEscalafonamiento.Create;
begin
  inscripcion      := datosdb.openDB('inscripciondocente', '');
  tabla1           := datosdb.openDB('puntosgenerales', '');
  tabla2           := datosdb.openDB('puntosmateria', '');
  puntaje          := datosdb.openDB('puntosescalafon', '');
  puntositems      := datosdb.openDB('puntositems', '');
  desestimaciones  := datosdb.openDB('desestimaciones', '');
  topesescalafon   := datosdb.openDB('topesescalafon', '');
  tabla3           := datosdb.openDB('escalafonalter', '');
  tabla4           := datosdb.openDB('antiguedad_doc', '');
  tabla5           := datosdb.openDB('excluiresc', '');
  bloqueo          := datosdb.openDB('bloqueos_es', '');
  DatosInstitucion := TStringList.Create;
  getDatosInst;
end;

destructor TTEscalafonamiento.Destroy;
begin
  inherited Destroy;
end;

function  TTEscalafonamiento.BuscarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria: String): Boolean;
// Objetivo...: Buscar una Instancia
begin
  Result := datosdb.Buscar(inscripcion, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', xperiodo, xnrodoc, xidcarrera, xidmateria);
end;

procedure TTEscalafonamiento.RegistrarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria, xestado: String);
// Objetivo...: Buscar una Instancia
begin
  if xestado = 'S' then Begin
    if BuscarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria) then inscripcion.Edit else inscripcion.Append;
    inscripcion.FieldByName('periodo').AsString   := xperiodo;
    inscripcion.FieldByName('nrodoc').AsString    := Trim(xnrodoc);
    inscripcion.FieldByName('idcarrera').AsString := xidcarrera;
    inscripcion.FieldByName('idmateria').AsString := xidmateria;
    inscripcion.FieldByName('estado').AsString    := 'I';
    try
      inscripcion.Post
     except
      inscripcion.Cancel
    end;
    datosdb.closeDB(inscripcion); inscripcion.Open;
  end else
    BorrarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria);
end;

procedure TTEscalafonamiento.RegistrarIns(xperiodo, xnrodoc, xidcarrera, xidmateria, xestado: String);
// Objetivo...: Buscar una Instancia
begin
  if BuscarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria) then inscripcion.Edit else inscripcion.Append;
  inscripcion.FieldByName('periodo').AsString   := xperiodo;
  inscripcion.FieldByName('nrodoc').AsString    := Trim(xnrodoc);
  inscripcion.FieldByName('idcarrera').AsString := xidcarrera;
  inscripcion.FieldByName('idmateria').AsString := xidmateria;
  inscripcion.FieldByName('estado').AsString    := 'S';
  try
    inscripcion.Post
   except
    inscripcion.Cancel
  end;
  datosdb.closeDB(inscripcion); inscripcion.Open;
end;

procedure TTEscalafonamiento.BorrarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria: String);
// Objetivo...: Borrar una Instancia
begin
  if BuscarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria) then Begin
    inscripcion.Delete;
    datosdb.closeDB(inscripcion); inscripcion.Open;
  end;
end;

procedure TTEscalafonamiento.getDatosInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria: String);
// Objetivo...: Cargar una Instancia
begin
  if BuscarInscripcion(xperiodo, xnrodoc, xidcarrera, xidmateria) then Begin
    PeriodoIns   := inscripcion.FieldByName('periodo').AsString;
    NrodocIns    := inscripcion.FieldByName('periodo').AsString;
    IdcarreraIns := inscripcion.FieldByName('idcarrera').AsString;
    IdmateriaIns := inscripcion.FieldByName('idmateria').AsString;
  end else Begin
    PeriodoIns := ''; NrodocIns := ''; IdcarreraIns := ''; IdmateriaIns := '';
  end;
end;

function  TTEscalafonamiento.setMateriasInscripcion(xperiodo, xnrodoc, xidcarrera: String): TObjectList;
// Objetivo...: Set de Materias en las que se inscribio
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and estado <> ' + '''' + 'S' + '''');
  inscripcion.First;
  while not inscripcion.Eof do Begin
    objeto := TTEscalafonamiento.Create;
    objeto.PeriodoIns   := inscripcion.FieldByName('periodo').AsString;
    objeto.NrodocIns    := Trim(inscripcion.FieldByName('nrodoc').AsString);
    objeto.IdcarreraIns := inscripcion.FieldByName('idcarrera').AsString;
    objeto.IdmateriaIns := inscripcion.FieldByName('idmateria').AsString;
    l.Add(objeto);
    inscripcion.Next;
  end;
  datosdb.QuitarFiltro(inscripcion);

  Result := l;
end;

function  TTEscalafonamiento.setMateriasInscripcion(xperiodo, xidcarrera: String): TObjectList;
// Objetivo...: Set de Materias en las que se inscribio
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and estado <> ' + '''' + 'S' + '''');
  inscripcion.First;
  while not inscripcion.Eof do Begin
    objeto := TTEscalafonamiento.Create;
    objeto.PeriodoIns   := inscripcion.FieldByName('periodo').AsString;
    objeto.NrodocIns    := Trim(inscripcion.FieldByName('nrodoc').AsString);
    objeto.IdcarreraIns := inscripcion.FieldByName('idcarrera').AsString;
    objeto.IdmateriaIns := inscripcion.FieldByName('idmateria').AsString;
    l.Add(objeto);
    inscripcion.Next;
  end;
  datosdb.QuitarFiltro(inscripcion);

  Result := l;
end;

function  TTEscalafonamiento.setMateriasInscripcionEsc(xperiodo, xnrodoc: String): TObjectList;
// Objetivo...: Set de Materias en las que se inscribio
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and estado <> ' + '''' + 'S' + '''');
  inscripcion.First;
  while not inscripcion.Eof do Begin
    objeto := TTEscalafonamiento.Create;
    objeto.PeriodoIns   := inscripcion.FieldByName('periodo').AsString;
    objeto.NrodocIns    := Trim(inscripcion.FieldByName('nrodoc').AsString);
    objeto.IdcarreraIns := inscripcion.FieldByName('idcarrera').AsString;
    objeto.IdmateriaIns := inscripcion.FieldByName('idmateria').AsString;
    l.Add(objeto);
    inscripcion.Next;
  end;
  datosdb.QuitarFiltro(inscripcion);

  Result := l;
end;

function TTEscalafonamiento.setMateriasInscripcionCicloAnterior(xperiodo, xnrodoc, xidcarrera: String): TObjectList;
// Objetivo...: Set de Materias en las que se inscribio el ciclo anterior
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  inscripcion.First;
  while not inscripcion.Eof do Begin
    objeto := TTEscalafonamiento.Create;
    objeto.PeriodoIns   := inscripcion.FieldByName('periodo').AsString;
    objeto.NrodocIns    := Trim(inscripcion.FieldByName('nrodoc').AsString);
    objeto.IdcarreraIns := inscripcion.FieldByName('idcarrera').AsString;
    objeto.IdmateriaIns := inscripcion.FieldByName('idmateria').AsString;
    l.Add(objeto);
    inscripcion.Next;
  end;
  datosdb.QuitarFiltro(inscripcion);

  Result := l;
end;

procedure TTEscalafonamiento.ListarInscripcion(xperiodo, xnrodoc: String; salida: char);
// Objetivo...: Listar Inscripcion

procedure ListarDocente(salida: char);
Begin
  docente.getDatos(Trim(inscripcion.FieldByName('nrodoc').AsString));
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Docente: ' + docente.codigo + ' - ' + docente.Apellido + ', ' + docente.nombre, 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
end;

procedure ListarCarrera(salida: char);
Begin
  carrera.getDatos(inscripcion.FieldByName('idcarrera').AsString);
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  list.Linea(0, 0, 'Carrera: ' + carrera.Idcarrera + ' - ' + carrera.Carrera, 1, 'Arial, negrita, 9', salida, 'S');
  list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
end;

var
  idanter1, idanter2, ldat, idanter3: String;
  cant, i: Integer;
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  ListarTitulo(salida);
  List.Titulo(0, 0, ' Listado de Inscripciones del Docente', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, '  Cód.' + utiles.espacios(3) +  'Materia', 1, 'Arial, normal, 8');
  List.Titulo(78, list.Lineactual, 'Curso', 2, 'Arial, normal, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' +  'and nrodoc = ' + '''' + xnrodoc + '''' + ' and estado <> ' + '''' + 'S' + '''');
  ldat := ''; cant := 0;
  for i := 1 to 5 do Begin
    inscripcion.First;
    while not inscripcion.Eof do Begin
      materia.getDatos(inscripcion.FieldByName('idcarrera').AsString, inscripcion.FieldByName('idmateria').AsString);
      if materia.Curso = IntToStr(i) then Begin
        if Trim(inscripcion.FieldByName('nrodoc').AsString) <> idanter1 then Begin
          ListarDocente(salida);
          ListarCarrera(salida);
          idanter1 := Trim(inscripcion.FieldByName('nrodoc').AsString);
          idanter2 := inscripcion.FieldByName('idcarrera').AsString;
        end;
        if inscripcion.FieldByName('idcarrera').AsString <> idanter2 then Begin
          ListarCarrera(salida);
          idanter2 := inscripcion.FieldByName('idcarrera').AsString;
        end;

        if i > 1 then Begin
          if materia.Curso <> idanter3 then list.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
          idanter3 := materia.Curso;
        end;

        list.Linea(0, 0, '  ' + materia.Idmateria + '   ' + materia.Materia, 1, 'Arial, normal, 8', salida, 'N');
        list.Linea(80, list.Lineactual, materia.Curso, 2, 'Arial, normal, 8', salida, 'S');
        Inc(cant);
        ldat := 'S';
      end;
      inscripcion.Next;
    end;
  end;
  datosdb.QuitarFiltro(inscripcion);

  if cant > 0 then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Cantidad de Materias en las que se Inscribió:     ' + IntToStr(cant), 1, 'Arial, negrita, 9', salida, 'S');
  end;

  if ldat <> 'S' then list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');

  list.FinList;
end;

procedure TTEscalafonamiento.ListarInscriptos(xperiodo, xidcarrera: String; salida: char);
// Objetivo...: Listar Inscripciones
var
  idanter1, idanter2, ldat: String;
  cant: Integer;

procedure ListarCarrera(salida: char);
Begin
  carrera.getDatos(inscripcion.FieldByName('idcarrera').AsString);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Carrera: ' + carrera.Idcarrera + ' - ' + carrera.Carrera, 1, 'Arial, negrita, 10', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Carrera: ' + carrera.Idcarrera + ' - ' + carrera.Carrera, 'Arial, negrita, 10');
  end;
end;

procedure ListarMateria(salida: char);
Begin
  materia.getDatos(inscripcion.FieldByName('idcarrera').AsString, inscripcion.FieldByName('idmateria').AsString);
  if (salida = 'P') or (salida = 'I') then Begin
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Materia: ' + materia.Idmateria + ' - ' + materia.Materia, 1, 'Arial, negrita, 9', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Materia: ' + materia.Idmateria + ' - ' + materia.Materia, 'Arial, negrita, 9');
  end;
  Inc(cant);
end;

Begin
  if (salida = 'P') or (salida = 'I') then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    ListarTitulo(salida);
    List.Titulo(0, 0, 'Listado de Inscriptos a Interinatos y Suplencias', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, '  Nro. Doc.', 1, 'Arial, cursiva, 9');
    List.Titulo(15, list.Lineactual, 'Apellido y Nombres', 2, 'Arial, cursiva, 9');
    List.Titulo(55, list.Lineactual, 'Teléfono', 3, 'Arial, cursiva, 9');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Listado de Inscriptos a Interinatos y Suplencias', 'Arial, negrita, 12');
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Nro. Doc', 'Arial, cursiva, 10');
    excel.setString('b' + l1, 'b' + l1, 'Apellido y Nombres', 'Arial, cursiva, 10');
    excel.setString('c' + l1, 'c' + l1, 'Teléfono', 'Arial, cursiva, 10');
    excel.FijarAnchoColumna('b' + l1, 'b' + l1, 40);
    excel.FijarAnchoColumna('c' + l1, 'c' + l1, 30);
  end;

  inscripcion.IndexFieldNames := 'Periodo;Idcarrera;Idmateria';
  datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' +  'and idcarrera = ' + '''' + xidcarrera + '''' + ' and estado <> ' + '''' + 'S' + '''');
  inscripcion.First; ldat := '';
  while not inscripcion.Eof do Begin
    if inscripcion.FieldByName('idcarrera').AsString <> idanter1 then Begin
      ListarCarrera(salida);
      idanter1 := inscripcion.FieldByName('idcarrera').AsString;
      idanter2 := '';
    end;
    if inscripcion.FieldByName('idmateria').AsString <> idanter2 then Begin
      ListarMateria(salida);
      idanter2 := inscripcion.FieldByName('idmateria').AsString;
    end;

    docente.getDatos(Trim(inscripcion.FieldByName('nrodoc').AsString));
    if (salida = 'P') or (salida = 'I') then Begin
      list.Linea(0, 0, '  ' + docente.codigo, 1, 'Arial, normal, 9', salida, 'N');
      list.Linea(15, list.Lineactual, docente.Apellido + ', ' + docente.nombre, 2, 'Arial, normal, 9', salida, 'N');
      list.Linea(55, list.Lineactual, docente.Telefono, 3, 'Arial, normal, 9', salida, 'S');
      ldat := 'S';
    end;
    if (salida = 'X') then Begin
      Inc(c1); l1 := Trim(IntToStr(c1));
      excel.setString('a' + l1, 'a' + l1, docente.codigo, 'Arial, normal, 9');
      excel.setString('b' + l1, 'b' + l1, docente.apellido + ', ' + docente.nombre, 'Arial, normal, 9');
      excel.setString('c' + l1, 'c' + l1, docente.Telefono, 'Arial, normal, 9');
    end;

    inscripcion.Next;
  end;

  datosdb.QuitarFiltro(inscripcion);
  inscripcion.IndexFieldNames := 'Periodo;Nrodoc;Idcarrera;Idmateria';

  if (salida = 'P') or (salida = 'I') then Begin
    if cant > 0 then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0, 'Cantidad de Materias en las que se Inscribe: ' + IntToStr(cant), 1, 'Arial, normal, 10', salida, 'S');
    end;
    if ldat <> 'S' then list.Linea(0, 0, 'No hay Datos para Listar ...!', 1, 'Arial, normal, 11', salida, 'S');
  end;
  if (salida = 'X') then Begin
    Inc(c1); l1 := Trim(IntToStr(c1));
    excel.setString('a' + l1, 'a' + l1, 'Cantidad de Materias en las que se Inscribe: ' + IntToStr(cant), 'Arial, normal, 10');
    excel.setString('c1', 'c1', '', 'Arial, cursiva, 10');
    excel.Visulizar;
  end;

  list.FinList;
end;

function  TTEscalafonamiento.BuscarPG(xperiodo, xnrodoc, xitems, xsubitems: String): Boolean;
// Objetivo...: recuperar instancia
begin
  Result := datosdb.Buscar(tabla1, 'periodo', 'nrodoc', 'items', 'subitems', xperiodo, xnrodoc, xitems, xsubitems);
end;

procedure TTEscalafonamiento.RegistrarPG(xperiodo, xnrodoc, xitems, xsubitems: String; xpuntos: Real);
// Objetivo...: registrar instancia
begin
  if BuscarPG(xperiodo, xnrodoc, xitems, xsubitems) then tabla1.Edit else tabla1.Append;
  tabla1.FieldByName('periodo').AsString  := xperiodo;
  tabla1.FieldByName('nrodoc').AsString   := Trim(xnrodoc);
  tabla1.FieldByName('items').AsString    := xitems;
  tabla1.FieldByName('subitems').AsString := xsubitems;
  tabla1.FieldByName('puntos').AsFloat    := xpuntos;
  try
    tabla1.Post
   except
    tabla1.Cancel
  end;
  datosdb.closeDB(tabla1); tabla1.Open;
end;

procedure TTEscalafonamiento.BorrarPG(xperiodo, xnrodoc, xitems, xsubitems: String);
// Objetivo...: borrar instancia
begin
  if BuscarPG(xperiodo, xnrodoc, xitems, xsubitems) then Begin
    tabla1.Delete;
    datosdb.closeDB(tabla1); tabla1.Open;
  end;
end;

procedure TTEscalafonamiento.getDatosPG(xperiodo, xnrodoc, xitems, xsubitems: String);
// Objetivo...: cargar una instancia
begin
  if BuscarPG(xperiodo, xnrodoc, xitems, xsubitems) then Begin
    PeriodoPG  := tabla1.FieldByName('periodo').AsString;
    NrodocPG   := Trim(tabla1.FieldByName('nrodoc').AsString);
    ItemsPG    := tabla1.FieldByName('items').AsString;
    SubitemsPG := tabla1.FieldByName('subitems').AsString;
    PuntosPG   := tabla1.FieldByName('puntos').AsFloat;
  end else Begin
    PeriodoPG := ''; NrodocPG := ''; ItemsPG := ''; subitemsPG := ''; PuntosPG := 0;
  end;
end;

function  TTEscalafonamiento.setSumaPG(xperiodo, xnrodoc, xitems: String): Real;
// Objetivo...: Devolver toda la suma de un items
var
  s: Real;
begin
  datosdb.Filtrar(tabla1, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and items = ' + '''' + xitems + '''');
  tabla1.First; s := 0;
  while not tabla1.Eof do Begin
    s := s + tabla1.FieldByName('puntos').AsFloat;
    tabla1.Next;
  end;
  datosdb.QuitarFiltro(tabla1);

  Result := s;
end;

function  TTEscalafonamiento.BuscarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String): Boolean;
// Objetivo...: recuperar instancia
begin
  Result := datosdb.Buscar(tabla2, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', 'items', 'subitems', xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems);
end;

procedure TTEscalafonamiento.RegistrarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String; xpuntos, xcantidad: Real);
// Objetivo...: registrar instancia
begin
  if BuscarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('periodo').AsString   := xperiodo;
  tabla2.FieldByName('nrodoc').AsString    := Trim(xnrodoc);
  tabla2.FieldByName('idcarrera').AsString := xidcarrera;
  tabla2.FieldByName('idmateria').AsString := xidmateria;
  tabla2.FieldByName('items').AsString     := xitems;
  tabla2.FieldByName('subitems').AsString  := xsubitems;
  tabla2.FieldByName('puntos').AsFloat     := xpuntos;
  tabla2.FieldByName('cantidad').AsFloat   := xcantidad;
  try
    tabla2.Post
   except
    tabla2.Cancel
  end;
  datosdb.closeDB(tabla2); tabla2.Open;
end;

procedure TTEscalafonamiento.BorrarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String);
// Objetivo...: borrar instancia
begin
  if BuscarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems) then Begin
    tabla2.Delete;
    datosdb.closeDB(tabla2); tabla2.Open;
  end;
end;

procedure TTEscalafonamiento.getDatosPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems: String);
// Objetivo...: cargar una instancia
begin
  if BuscarPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems, xsubitems) then Begin
    PeriodoPM   := tabla2.FieldByName('periodo').AsString;
    NrodocPM    := Trim(tabla2.FieldByName('nrodoc').AsString);
    IdcarreraPM := tabla2.FieldByName('idcarrera').AsString;
    IdmateriaPM := tabla2.FieldByName('idmateria').AsString;
    ItemsPM     := tabla2.FieldByName('items').AsString;
    SubitemsPM  := tabla2.FieldByName('subitems').AsString;
    PuntosPM    := tabla2.FieldByName('puntos').AsFloat;
    CantidadPM  := tabla2.FieldByName('cantidad').AsFloat;
  end else Begin
    PeriodoPM := ''; NrodocPM := ''; ItemsPM := ''; subitemsPM := ''; PuntosPM := 0; CantidadPM := 0;
  end;
end;

function TTEscalafonamiento.setSumaPM(xperiodo, xnrodoc, xidcarrera, xidmateria, xitems: String): Real;
// objetivo...: Subtotalizar Puntos Agrupados por Materia
var
  s: Real;
Begin
  datosdb.Filtrar(tabla2, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and idmateria = ' + '''' + xidmateria + '''' + ' and items = ' + '''' + xitems + '''');
  tabla2.First; s := 0;
  while not tabla2.Eof do Begin
    s := s + tabla2.FieldByName('puntos').AsFloat;
    tabla2.Next;
  end;
  datosdb.QuitarFiltro(tabla2);

  Result := s;
end;

function TTEscalafonamiento.setItemsMateria(xperiodo, xnrodoc: String): TObjectList;
// Objetivo...: Devolver un set de Objetos con los Puntos por Materia
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla2, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''');
  tabla2.First;
  while not tabla2.Eof do Begin
    objeto      := TTEscalafonamiento.Create;
    objeto.PeriodoPM   := tabla2.FieldByName('periodo').AsString;
    objeto.NrodocPM    := Trim(tabla2.FieldByName('nrodoc').AsString);
    objeto.IdcarreraPM := tabla2.FieldByName('idcarrera').AsString;
    objeto.IdmateriaPM := tabla2.FieldByName('idmateria').AsString;
    objeto.ItemsPM     := tabla2.FieldByName('items').AsString;
    objeto.SubitemsPM  := tabla2.FieldByName('subitems').AsString;
    objeto.PuntosPM    := tabla2.FieldByName('puntos').AsFloat;
    objeto.CantidadPM  := tabla2.FieldByName('cantidad').AsFloat;
    l.Add(objeto);
    tabla2.Next;
  end;
  datosdb.QuitarFiltro(tabla2);

  Result := l;
end;

procedure TTEscalafonamiento.RealizarRecuento(xperiodo, xidcarrera: String; xmaterias: TStringList);
// Objetivo...: Armar el Escalafon
var
  puntos1, puntos2, puntos3: Real;
  l: TStringList;

  procedure RegistrarEscalafonAlternativo(xperiodo, xnrodoc, xidcarrera: String);
  // Objetivo...: registrar instancia
  begin
    if BuscarEscalafonAlternativo(xperiodo, xnrodoc, xidcarrera) then tabla3.Edit else tabla3.Append;
    tabla3.FieldByName('periodo').AsString   := xperiodo;
    tabla3.FieldByName('nrodoc').AsString    := Trim(xnrodoc);
    tabla3.FieldByName('idcarrera').AsString := xidcarrera;
    try
      tabla3.Post
     except
      tabla3.Cancel
    end;
    datosdb.closeDB(tabla3); tabla3.Open;
  end;

  procedure BorrarEscalafonAlternativo(xperiodo, xnrodoc, xidcarrera: String);
  // Objetivo...: borrar instancia
  begin
    if BuscarEscalafonAlternativo(xperiodo, xnrodoc, xidcarrera) then Begin
      tabla3.Delete;
      datosdb.closeDB(tabla3); tabla3.Open;
    end;
  end;

Begin
  // Preparamos las estructuras de trabajo
  datosdb.tranSQL('delete from ' + puntaje.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  datosdb.tranSQL('delete from ' + tabla3.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  datosdb.closeDB(puntaje); puntaje.Open;
  datosdb.closeDB(tabla3); tabla3.Open;

  puntaje.IndexFieldNames := 'periodo;nrodoc;idcarrera;idmateria';

  l := tablaes.setItemsRequeridosEscalafonPrincipal;   // Para determinar quienes van al escalafón principal

  // Lo realizamos por carrera y por Materia
  datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and estado <> ' + '''' + 'S' + '''');
  inscripcion.First;
  while not inscripcion.Eof do Begin
    if utiles.verificarItemsLista(xmaterias, inscripcion.FieldByName('idmateria').AsString) then Begin
      puntos1 := 0; puntos2 := 0; puntos3 := 0;
      // Recolectamos los puntos Generales
      datosdb.Filtrar(tabla1, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + Trim(inscripcion.FieldByName('nrodoc').AsString) + '''');
      tabla1.First;
      while not tabla1.Eof do Begin
        puntos1 := puntos1 + tabla1.FieldByName('puntos').AsFloat;
        if utiles.verificarItemsLista(l, tabla1.FieldByName('items').AsString) then
          puntos3 := puntos3 + tabla1.FieldByName('puntos').AsFloat;
        tabla1.Next;
      end;
      datosdb.QuitarFiltro(tabla1);

      // Verificamos si va al escalafon principal o alternativo
      if puntos3 = 0 then RegistrarEscalafonAlternativo(xperiodo, Trim(inscripcion.FieldByName('nrodoc').AsString), xidcarrera) else
        BorrarEscalafonAlternativo(xperiodo, Trim(inscripcion.FieldByName('nrodoc').AsString), xidcarrera);

      // Recolectamos los puntos para la Materia
      datosdb.Filtrar(tabla2, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + Trim(inscripcion.FieldByName('nrodoc').AsString) + '''' + ' and idcarrera = ' + '''' + inscripcion.FieldByName('idcarrera').AsString + '''' + ' and idmateria = ' + '''' + inscripcion.FieldByName('idmateria').AsString + '''');
      tabla2.First;
      while not tabla2.Eof do Begin
        puntos2 := puntos2 + tabla2.FieldByName('puntos').AsFloat;
        tabla2.Next;
      end;
      datosdb.QuitarFiltro(tabla2);

      // Actualizamos el registro
      if datosdb.Buscar(puntaje, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', xperiodo, Trim(inscripcion.FieldByName('nrodoc').AsString), inscripcion.FieldByName('idcarrera').AsString, inscripcion.FieldByName('idmateria').AsString) then puntaje.Edit else puntaje.Append;
      puntaje.FieldByName('periodo').AsString   := xperiodo;
      puntaje.FieldByName('nrodoc').AsString    := Trim(inscripcion.FieldByName('nrodoc').AsString);
      puntaje.FieldByName('idcarrera').AsString := inscripcion.FieldByName('idcarrera').AsString;
      puntaje.FieldByName('idmateria').AsString := inscripcion.FieldByName('idmateria').AsString;

      puntaje.FieldByName('puntosg').AsFloat    := puntos1;
      puntaje.FieldByName('puntosp').AsFloat    := puntos2;
      puntaje.FieldByName('puntostot').AsFloat  := puntos1 + puntos2;
      try
        puntaje.Post
       except
        puntaje.Cancel
      end;
      datosdb.closeDB(puntaje); puntaje.Open;
    end;

    inscripcion.Next;
  end;
  datosdb.QuitarFiltro(inscripcion);
end;

function  TTEscalafonamiento.setEscalafon(xperiodo, xidcarrera, xidmateria, xtipo_escalafon: String): TObjectList;
// Objetivo...: devolver escalafon por materia
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
  incluye: Boolean;
begin
  puntaje.IndexName := 'puntosescalafon_suma';
  l := TObjectList.Create;
  datosdb.Filtrar(puntaje, 'periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and idmateria = ' + '''' + xidmateria + '''');

  // Recuperamos los Docentes Desestimados
  puntaje.First;
  while not puntaje.Eof do Begin
    incluye := False;

    // Determinamos si se incluye o no de acuerdo al tipo de escalafón
    if xtipo_escalafon = '1' then incluye := True;
    if xtipo_escalafon = '2' then
      if not BuscarEscalafonAlternativo(xperiodo, Trim(puntaje.FieldByName('nrodoc').AsString), xidcarrera) then incluye := True;
    if xtipo_escalafon = '3' then
      if BuscarEscalafonAlternativo(xperiodo, Trim(puntaje.FieldByName('nrodoc').AsString), xidcarrera) then incluye := True;

    // Determinamos si se incluye o no en cuanto a si fue desestimado
    if BuscarDesestimaciones(xperiodo, Trim(puntaje.FieldByName('nrodoc').AsString), xidcarrera, puntaje.FieldByName('idmateria').AsString) then incluye := True else incluye := False;

    if incluye then Begin
      objeto := TTEscalafonamiento.Create;
      objeto.PeriodoPG    := puntaje.FieldByName('periodo').AsString;
      objeto.NrodocPG     := Trim(puntaje.FieldByName('nrodoc').AsString);
      objeto.IdcarreraPM  := puntaje.FieldByName('idcarrera').AsString;
      objeto.IdmateriaPM  := puntaje.FieldByName('idmateria').AsString;
      objeto.PuntosPG     := puntaje.FieldByName('puntosg').AsFloat;
      objeto.PuntosPM     := puntaje.FieldByName('puntosp').AsFloat;
      objeto.Motivo       := desestimaciones.FieldByName('motivo').AsString;
      l.Add(objeto);
    end;
    puntaje.Next;
  end;

  // Recuperamos los Docentes en Escalafón
  puntaje.First;
  while not puntaje.Eof do Begin
    incluye := False;

    // Determinamos si se incluye o no de acuerdo al tipo de escalafón
    if xtipo_escalafon = '1' then incluye := True;
    if xtipo_escalafon = '2' then
      if not BuscarEscalafonAlternativo(xperiodo, Trim(puntaje.FieldByName('nrodoc').AsString), xidcarrera) then incluye := True;
    if xtipo_escalafon = '3' then
      if BuscarEscalafonAlternativo(xperiodo, Trim(puntaje.FieldByName('nrodoc').AsString), xidcarrera) then incluye := True;

    // Determinamos si se incluye o no en cuanto a si fue desestimado
    if BuscarDesestimaciones(xperiodo, Trim(puntaje.FieldByName('nrodoc').AsString), xidcarrera, puntaje.FieldByName('idmateria').AsString) then incluye := False;

    if incluye then Begin
      objeto := TTEscalafonamiento.Create;
      objeto.PeriodoPG    := puntaje.FieldByName('periodo').AsString;
      objeto.NrodocPG     := Trim(puntaje.FieldByName('nrodoc').AsString);
      objeto.IdcarreraPM  := puntaje.FieldByName('idcarrera').AsString;
      objeto.IdmateriaPM  := puntaje.FieldByName('idmateria').AsString;
      objeto.PuntosPG     := puntaje.FieldByName('puntosg').AsFloat;
      objeto.PuntosPM     := puntaje.FieldByName('puntosp').AsFloat;
      objeto.PuntosTot    := puntaje.FieldByName('puntostot').AsFloat;
      //utiles.msgError(puntaje.FieldByName('puntostot').AsString);
      l.Add(objeto);
    end;
    puntaje.Next;
  end;

  datosdb.QuitarFiltro(puntaje);

  Result := l;
end;

function  TTEscalafonamiento.BuscarItems(xnrodoc, xitemsg, xitems, xsubitems: String): Boolean;
// Objetivo...: Recuperar Instancia
begin
  Result := datosdb.Buscar(puntositems, 'nrodoc', 'itemsg', 'items', 'subitems', xnrodoc, xitemsg, xitems, xsubitems);
end;

procedure TTEscalafonamiento.RegistrarItems(xnrodoc, xitemsg, xitems, xsubitems, xdescrip, xfecha, xeval: String; xpuntos, xhscatedra, xhsreloj, xcantidad: Real; xcantitems: Integer);
// Objetivo...: Registrar Instancia
begin
  if BuscarItems(xnrodoc, xitemsg, xitems, xsubitems) then puntositems.Edit else puntositems.Append;
  puntositems.FieldByName('nrodoc').AsString   := Trim(xnrodoc);
  puntositems.FieldByName('itemsg').AsString   := xitemsg;
  puntositems.FieldByName('items').AsString    := xitems;
  puntositems.FieldByName('subitems').AsString := xsubitems;
  puntositems.FieldByName('descrip').AsString  := xdescrip;
  puntositems.FieldByName('fecha').AsString    := utiles.sExprFecha2000(xfecha);
  puntositems.FieldByName('eval').AsString     := xeval;
  puntositems.FieldByName('puntos').AsFloat    := xpuntos;
  puntositems.FieldByName('hscatedra').AsFloat := xhscatedra;
  puntositems.FieldByName('hsreloj').AsFloat   := xhsreloj;
  puntositems.FieldByName('cantidad').AsFloat  := xcantidad;
  try
    puntositems.Post
   except
    puntositems.Cancel
  end;
  if xsubitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then datosdb.tranSQL('delete from puntositems where nrodoc = ' + '''' + xnrodoc + '''' + ' and itemsg = ' + '''' + xitemsg + '''' + ' and items = ' + '''' + xitems + '''' + ' and subitems > ' + '''' + xsubitems + '''');
  datosdb.closeDB(puntositems); puntositems.Open;
end;

function  TTEscalafonamiento.setItems(xnrodoc, xitemsg, xitems: String): TObjectList;
// Objetivo...: Recuperar Items
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(puntositems, 'nrodoc = ' + '''' + xnrodoc + '''' + ' and itemsg = ' + '''' + xitemsg + '''' + ' and items = ' + '''' + xitems + '''');
  puntositems.First;
  while not puntositems.Eof do Begin
    objeto := TTEscalafonamiento.Create;
    objeto.NrodocIt     := Trim(puntositems.FieldByName('nrodoc').AsString);
    objeto.ItemsgIt     := puntositems.FieldByName('itemsg').AsString;
    objeto.ItemsIt      := puntositems.FieldByName('items').AsString;
    objeto.SubitemsIt   := puntositems.FieldByName('subitems').AsString;
    objeto.DescripIt    := puntositems.FieldByName('descrip').AsString;
    objeto.Eval         := puntositems.FieldByName('eval').AsString;
    objeto.FechaIt      := utiles.sFormatoFecha(puntositems.FieldByName('fecha').AsString);
    objeto.PuntosIt     := puntositems.FieldByName('puntos').AsFloat;
    objeto.HsCatedra    := puntositems.FieldByName('hscatedra').AsFloat;
    objeto.HsReloj      := puntositems.FieldByName('hsreloj').AsFloat;
    objeto.Cantidad     := puntositems.FieldByName('cantidad').AsFloat;
    l.Add(objeto);
    puntositems.Next;
  end;
  datosdb.QuitarFiltro(puntositems);

  Result := l;
end;

procedure TTEscalafonamiento.BorrarItems(xnrodoc, xitemsg, xitems: String);
// Objetivo...: borrar items
begin
  datosdb.tranSQL('delete from puntositems where nrodoc = ' + '''' + xnrodoc + '''' + ' and itemsg = ' + '''' + xitemsg + '''' + ' and items = ' + '''' + xitems + '''');
  datosdb.closeDB(puntositems); puntositems.Open;
end;

function  TTEscalafonamiento.BuscarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria: String): Boolean;
// Objetivo...: Recuperar Desestimaciones
begin
  Result := datosdb.Buscar(desestimaciones, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', xperiodo, xnrodoc, xidcarrera, xidmateria);
end;

procedure TTEscalafonamiento.RegistrarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria, xmotivo: String);
// Objetivo...: Registrar Desestimaciones
begin
  if BuscarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria) then desestimaciones.Edit else desestimaciones.Append;
  desestimaciones.FieldByName('periodo').AsString   := xperiodo;
  desestimaciones.FieldByName('nrodoc').AsString    := Trim(xnrodoc);
  desestimaciones.FieldByName('idcarrera').AsString := xidcarrera;
  desestimaciones.FieldByName('idmateria').AsString := xidmateria;
  desestimaciones.FieldByName('motivo').AsString    := xmotivo;
  try
    desestimaciones.Post
   except
    desestimaciones.Cancel
  end;
  datosdb.closeDB(desestimaciones); desestimaciones.Open;
end;

procedure TTEscalafonamiento.BorrarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria: String);
// Objetivo...: Borrar Desestimaciones
begin
  if BuscarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria) then Begin
    desestimaciones.Delete;
    datosdb.closeDB(desestimaciones); desestimaciones.Open;
  end;
end;

procedure TTEscalafonamiento.getDatosDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria: String);
// Objetivo...: Recuperar Datos Desestimaciones
begin
  if BuscarDesestimaciones(xperiodo, xnrodoc, xidcarrera, xidmateria) then Begin
    Motivo := desestimaciones.FieldByName('motivo').AsString;
  end else Begin
    Motivo := '';
  end;
end;

procedure TTEscalafonamiento.ListarExpediente(xperiodo: String; xlista: TStringList; salida: char);
// Objetivo...: Listar Expediente
var
  ldat, idanter1, idanter2, idanter3: String;
  i, j, k: Integer;
  l: TObjectList;
  objeto: TTEscalafon;
  obj: TTEscalafonamiento;
  totales: array[1..10] of real;
  ld: Boolean;

  procedure ListarDocente(salida: char);
  Begin
    list.Linea(0, 0,'*** Materias en las que se Inscribe ***', 1, 'Arial, negrita, 11', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');

    docente.getDatos(Trim(inscripcion.FieldByName('nrodoc').AsString));
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Docente: ' + docente.codigo + ' - ' + docente.Apellido + ', ' + docente.nombre, 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    ld := True;
  end;

  procedure ListarCarrera(salida: char);
  Begin
    carrera.getDatos(inscripcion.FieldByName('idcarrera').AsString);
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    list.Linea(0, 0, 'Carrera: ' + carrera.Idcarrera + ' - ' + carrera.Carrera, 1, 'Arial, negrita, 8', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end;

  procedure ListarSubitems(xnrodoc, xitemsg, xsubitems: String; salida: char);
  var
    l: Boolean;
  Begin
    datosdb.Filtrar(puntositems, 'nrodoc = ' + '''' + xnrodoc + '''' + ' and itemsg = ' + '''' + xitemsg + '''' + ' and items = ' + '''' + xsubitems + '''');
    l := False;
    while not puntositems.Eof do Begin
      l := True;
      list.Linea(0, 0, '       * ' + puntositems.FieldByName('descrip').AsString, 1, 'Arial, cursiva, 8', salida, 'N');
      list.Linea(55, list.Lineactual, utiles.sFormatoFecha(puntositems.FieldByName('fecha').AsString), 2, 'Arial, cursiva, 8', salida, 'N');
      list.importe(65, list.Lineactual, '###.##', puntositems.FieldByName('hscatedra').AsFloat, 3, 'Arial, cursiva, 8');
      if puntositems.FieldByName('hscatedra').AsFloat > 0 then list.Linea(66, list.Lineactual, 'Hs.Cat.', 4, 'Arial, cursiva, 8', salida, 'N') else
        list.Linea(66, list.Lineactual, '', 4, 'Arial, cursiva, 8', salida, 'N');
      list.importe(77, list.Lineactual, '###.##', puntositems.FieldByName('hsreloj').AsFloat, 5, 'Arial, cursiva, 8');
      if puntositems.FieldByName('hsreloj').AsFloat > 0 then list.Linea(78, list.Lineactual, 'Hs.Rel.', 6, 'Arial, cursiva, 8', salida, 'N') else
        list.Linea(78, list.Lineactual, '', 6, 'Arial, cursiva, 8', salida, 'N');
      list.importe(92, list.Lineactual, '', puntositems.FieldByName('puntos').AsFloat, 7, 'Arial, cursiva, 8');
      list.Linea(93, list.Lineactual, 'E.: ' + puntositems.FieldByName('eval').AsString, 8, 'Arial, normal, 5', salida, 'S');
      puntositems.Next;
    end;
    datosdb.QuitarFiltro(puntositems);
    if l then list.Linea(0, 0, '', 1, 'Arial, cursiva, 8', salida, 'S');
  end;

  procedure ListarAntiguedad(xnrodoc, xidcarrera, xidmateria: String; salida: char);
  var
    cd: String;
    ca, ca1: Integer;
  Begin
    datosdb.Filtrar(tabla4, 'nrodoc = ' + '''' + xnrodoc + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and idmateria = ' + '''' + xidmateria + '''');
    tabla4.First; ca := 0;
    while not tabla4.Eof do Begin
      cd := utiles.RestarFechas(utiles.sFormatoFecha(tabla4.FieldByName('hasta').AsString), utiles.sFormatoFecha(tabla4.FieldByName('desde').AsString));
      ca := ca + StrToInt(cd);
      list.Linea(0, 0, '', 1, 'Arial, cursiva, 8', salida, 'N');
      list.Linea(8, list.Lineactual, 'De: ' + utiles.sFormatoFecha(tabla4.FieldByName('desde').AsString), 2, 'Arial, cursiva, 8', salida, 'N');
      list.Linea(23, list.Lineactual,'Al: ' +utiles.sFormatoFecha(tabla4.FieldByName('hasta').AsString), 3, 'Arial, cursiva, 8', salida, 'N');
      list.Linea(38, list.Lineactual, ' Días:   ' + cd, 4, 'Arial, cursiva, 8', salida, 'N');
      ca1 := ca div 360;
      if ca1 < 1 then ca1 := 0;
      list.Linea(58, list.Lineactual, 'Años:   ' + IntToStr(ca1), 5, 'Arial, cursiva, 8', salida, 'S');
      tabla4.Next;
    end;
    datosdb.QuitarFiltro(tabla4);
    if ca > 0 then list.Linea(0, 0, '', 1, 'Arial, cursiva, 5', salida, 'S');
  end;

begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  ListarTitulo(salida);
  List.Titulo(0, 0, 'Antecedentes Personales Escalafón', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  for i := 1 to 10 do totales[i] := 0;

  for i := 1 to xlista.Count do Begin

    if (i > 1) and (ld) then Begin
      list.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 8', salida, 'S');
    end;

    ld := False; ldat := '';
    datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' +  'and nrodoc = ' + '''' + xlista.Strings[i-1] + '''' + ' and estado <> ' + '''' + 'S' + '''');
    for k := 1 to 5 do Begin
      inscripcion.First;
      while not inscripcion.Eof do Begin
        materia.getDatos(inscripcion.FieldByName('idcarrera').AsString, inscripcion.FieldByName('idmateria').AsString);
        if IntToStr(k) = materia.Curso then Begin
          if Trim(inscripcion.FieldByName('nrodoc').AsString) <> idanter1 then Begin
            ListarDocente(salida);
            ListarCarrera(salida);
            idanter1 := Trim(inscripcion.FieldByName('nrodoc').AsString);
            idanter2 := inscripcion.FieldByName('idcarrera').AsString;
          end;
          if inscripcion.FieldByName('idcarrera').AsString <> idanter2 then Begin
            ListarCarrera(salida);
            idanter2 := inscripcion.FieldByName('idcarrera').AsString;
          end;

          if k > 1 then
            if materia.Curso <> idanter3 then Begin
              list.Linea(0, 0, ' ', 1, 'Arial, normal, 5', salida, 'S');
              idanter3 := materia.Curso;
            end;

          list.Linea(0, 0, '  ' + materia.Idmateria + '   ' + materia.Materia, 1, 'Arial, normal, 8', salida, 'N');
          list.Linea(60, list.Lineactual, materia.Curso, 2, 'Arial, normal, 8', salida, 'S');
          ldat := 'S';
        end;
        inscripcion.Next;
      end;
    end;
    datosdb.QuitarFiltro(inscripcion);

    if ld then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0,'*** Antecedentes Generales ***', 1, 'Arial, negrita, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;

    l := tablaes.setConceptos('');
    for j := 1 to l.Count do Begin
      objeto := TTEscalafon(l.Items[j-1]);
      if objeto.Global = 'S' then Begin
        tablaes.getDatosConcepto(objeto.Items, objeto.Subitems);
        // Recuperamos el puntaje Existente
        escalafon.getDatosPG(xperiodo, xlista.Strings[i-1], objeto.Items, objeto.Subitems);
        if escalafon.PuntosPG > 0 then Begin
          list.Linea(0, 0, '    ' + tablaes.Concepto, 1, 'Arial, normal, 8', salida, 'N');
          list.Importe(60, list.Lineactual, '', escalafon.PuntosPG, 2, 'Arial, normal, 8');
          tablaes.getDatosItems(objeto.Items);
          list.Linea(70, list.Lineactual, tablaes.Descrip, 3, 'Arial, normal, 8', salida, 'S');
          totales[1] := totales[1] + escalafon.PuntosPG;
          ListarSubitems(xlista.Strings[i-1], tablaes.Items, tablaes.Subitems, salida);
        end;
      end;
    end;
    l.Free; l := Nil;

    if ld then Begin
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
      list.Linea(0, 0,'*** Antecedentes por Materia ***', 1, 'Arial, negrita, 11', salida, 'S');
      list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
    end;

    l := setItemsMateria(xperiodo, xlista.Strings[i-1]);
    for j := 1 to l.Count do Begin
      obj := TTEscalafonamiento(l.Items[j-1]);
      carrera.getDatos(obj.IdcarreraPM);
      materia.getDatos(obj.IdcarreraPM, obj.IdmateriaPM);
      tablaes.getDatosConcepto(obj.ItemsPM, obj.SubitemsPM);
      list.Linea(0, 0, '    ' + Copy(materia.Materia, 1, 35), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(35, list.Lineactual, Copy(carrera.Carrera, 1, 30), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(65, list.Lineactual, tablaes.Concepto, 3, 'Arial, normal, 8', salida, 'N');
      list.importe(95, list.Lineactual, '', obj.PuntosPM, 4, 'Arial, normal, 8');
      list.Linea(95, list.Lineactual, '', 5, 'Arial, normal, 8', salida, 's');
      if tablaes.DisAntiguedad = 'S' then ListarAntiguedad(xlista.Strings[i-1], obj.IdcarreraPM, obj.IdmateriaPM, salida);
    end;
    l.Free; l := Nil;
  end;

  list.FinList;
end;

procedure TTEscalafonamiento.RegistrarDatosInst(xdatos: TMemo);
// Objetivo...: Registrar Datos Institucion
begin
  xdatos.Lines.SaveToFile(dbs.DirSistema + '\def_inst.ini');
end;

procedure TTEscalafonamiento.getDatosInst;
// Objetivo...: Recuperar Datos Institucion
begin
  if FileExists(dbs.DirSistema + '\def_inst.ini') then Begin
    DatosInstitucion.LoadFromFile(dbs.DirSistema + '\def_inst.ini');
  end;
end;

procedure TTEscalafonamiento.ListarTitulo(salida: char);
// Objetivo...: Listar Titulos
var
  i: Integer;
begin
  for i := 1 to DatosInstitucion.Count do Begin
    if (salida = 'I') or (salida = 'P') then Begin
      list.Titulo(0, 0, DatosInstitucion.Strings[i-1], 1, 'Arial, normal, 8');
    end;
  end;

  if (salida = 'I') or (salida = 'P') then
    list.Titulo(0, 0, '', 1, 'Arial, normal, 5');
end;

function TTEscalafonamiento.BuscarTope(xperiodo: String): Boolean;
// Objetivo...: Recuperar Instancia
begin
  Result := topesescalafon.FindKey([xperiodo]);
end;

procedure TTEscalafonamiento.RegistrarTope(xperiodo, xfecha: String);
// Objetivo...: Registrar Instancia
begin
  if BuscarTope(xperiodo) then topesescalafon.Edit else topesescalafon.Append;
  topesescalafon.FieldByName('periodo').AsString := xperiodo;
  topesescalafon.FieldByName('fecha').AsString   := utiles.sExprFecha2000(xfecha);
  try
    topesescalafon.Post
   except
    topesescalafon.Cancel
  end;
  datosdb.closeDB(topesescalafon); topesescalafon.Open;
end;

procedure TTEscalafonamiento.BorrarTope(xperiodo: String);
// Objetivo...: Borrar Instancia
begin
  if BuscarTope(xperiodo) then Begin
    topesescalafon.Delete;
    datosdb.closeDB(topesescalafon); topesescalafon.Open;
  end;
end;

procedure TTEscalafonamiento.getDatosTope(xperiodo: String);
// Objetivo...: Recuperar Instancia
begin
  if BuscarTope(xperiodo) then Begin
    PeriodoTope := topesescalafon.FieldByName('periodo').AsString;
    FechaTope   := utiles.sFormatoFecha(topesescalafon.FieldByName('fecha').AsString);
  end else Begin
    PeriodoTope := ''; FechaTope := '';
  end;
end;

procedure  TTEscalafonamiento.Exportar(xperiodo, xidcarrera: String);
// Objetivo...: Exportar Escalafon
var
  expt_inscripcion, expt_tabla1, expt_tabla2, expt_puntaje, expt_puntositems, expt_desestimaciones, expt_antiguedaddoc: TTable;
  lista: TStringList;

  //----------------------------------------------------------------------------
  procedure CopiarEstructuras;
  // Objetivo...: Copiar Estructuras de Datos
  Begin
    utilesarchivos.CopiarArchivos(dbs.DirSistema + '\exportar\escalafon\estructu', '*.*', dbs.DirSistema + '\exportar\escalafon\work');
    // Instanciamos las tablas
    expt_inscripcion      := datosdb.openDB('inscripciondocente', '', '', dbs.DirSistema + '\exportar\escalafon\work');
    expt_tabla1           := datosdb.openDB('puntosgenerales', '', '', dbs.DirSistema + '\exportar\escalafon\work');
    expt_tabla2           := datosdb.openDB('puntosmateria', '', '', dbs.DirSistema + '\exportar\escalafon\work');
    expt_puntaje          := datosdb.openDB('puntosescalafon', '', '', dbs.DirSistema + '\exportar\escalafon\work');
    expt_puntositems      := datosdb.openDB('puntositems', '', '', dbs.DirSistema + '\exportar\escalafon\work');
    expt_desestimaciones  := datosdb.openDB('desestimaciones', '', '', dbs.DirSistema + '\exportar\escalafon\work');
    expt_antiguedaddoc    := datosdb.openDB('antiguedad_doc', '', '', dbs.DirSistema + '\exportar\escalafon\work');
  end;

  procedure ExportarInscripcion(xperiodo, xidcarrera: String);
  // Objetivo...: Exportar Inscripciones
  Begin
    lista := TStringList.Create;
    expt_inscripcion.Open;
    datosdb.Filtrar(inscripcion, 'periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and estado <> ' + '''' + 'S' + '''');
    inscripcion.First;
    while not inscripcion.Eof do Begin
      if datosdb.Buscar(expt_inscripcion, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', inscripcion.FieldByName('periodo').AsString, Trim(inscripcion.FieldByName('nrodoc').AsString), inscripcion.FieldByName('idcarrera').AsString, inscripcion.FieldByName('idmateria').AsString) then expt_inscripcion.Edit else expt_inscripcion.Append;
      expt_inscripcion.FieldByName('periodo').AsString   := inscripcion.FieldByName('periodo').AsString;
      expt_inscripcion.FieldByName('nrodoc').AsString    := Trim(inscripcion.FieldByName('nrodoc').AsString);
      expt_inscripcion.FieldByName('idcarrera').AsString := inscripcion.FieldByName('idcarrera').AsString;
      expt_inscripcion.FieldByName('idmateria').AsString := inscripcion.FieldByName('idmateria').AsString;
      try
        expt_inscripcion.Post
       except
        expt_inscripcion.Cancel
      end;
      lista.Add(Trim(inscripcion.FieldByName('nrodoc').AsString)); // Arma la Lista de Docentes para Exportar
      inscripcion.Next;
    end;
    datosdb.QuitarFiltro(inscripcion);
    datosdb.closeDB(expt_inscripcion);
  end;

  procedure ExportarPuntosGenerales(xperiodo: String);
  // Objetivo...: Exportar Puntaje General
  Begin
    expt_tabla1.Open;
    datosdb.Filtrar(tabla1, 'periodo = ' + '''' + xperiodo + '''');
    tabla1.First;
    while not tabla1.Eof do Begin
      if datosdb.Buscar(expt_tabla1, 'periodo', 'nrodoc', 'items', 'subitems', tabla1.FieldByName('periodo').AsString, Trim(tabla1.FieldByName('nrodoc').AsString), tabla1.FieldByName('items').AsString, tabla1.FieldByName('subitems').AsString) then expt_tabla1.Edit else expt_tabla1.Append;
      expt_tabla1.FieldByName('periodo').AsString   := tabla1.FieldByName('periodo').AsString;
      expt_tabla1.FieldByName('nrodoc').AsString    := Trim(tabla1.FieldByName('nrodoc').AsString);
      expt_tabla1.FieldByName('items').AsString     := tabla1.FieldByName('items').AsString;
      expt_tabla1.FieldByName('subitems').AsString  := tabla1.FieldByName('subitems').AsString;
      expt_tabla1.FieldByName('puntos').AsFloat     := tabla1.FieldByName('puntos').AsFloat;
      try
        expt_tabla1.Post
       except
        expt_tabla1.Cancel
      end;
      tabla1.Next;
    end;
    datosdb.QuitarFiltro(tabla1);
    datosdb.closeDB(expt_tabla1);
  end;

  procedure ExportarPuntosMateria(xperiodo, xidcarrera: String);
  // Objetivo...: Exportar Puntaje por Materia
  Begin
    expt_tabla2.Open;
    datosdb.Filtrar(tabla2, 'periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
    tabla2.First;
    while not tabla2.Eof do Begin
      if datosdb.Buscar(expt_tabla2, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', 'items', 'subitems', tabla2.FieldByName('periodo').AsString, tabla2.FieldByName('nrodoc').AsString, tabla2.FieldByName('idcarrera').AsString, tabla2.FieldByName('idmateria').AsString, tabla2.FieldByName('items').AsString, tabla2.FieldByName('subitems').AsString) then expt_tabla2.Edit else expt_tabla2.Append;
      expt_tabla2.FieldByName('periodo').AsString   := tabla2.FieldByName('periodo').AsString;
      expt_tabla2.FieldByName('nrodoc').AsString    := Trim(tabla2.FieldByName('nrodoc').AsString);
      expt_tabla2.FieldByName('idcarrera').AsString := tabla2.FieldByName('idcarrera').AsString;
      expt_tabla2.FieldByName('idmateria').AsString := tabla2.FieldByName('idmateria').AsString;
      expt_tabla2.FieldByName('items').AsString     := tabla2.FieldByName('items').AsString;
      expt_tabla2.FieldByName('subitems').AsString  := tabla2.FieldByName('subitems').AsString;
      expt_tabla2.FieldByName('puntos').AsFloat     := tabla2.FieldByName('puntos').AsFloat;
      expt_tabla2.FieldByName('cantidad').AsFloat   := tabla2.FieldByName('cantidad').AsFloat;
      try
        expt_tabla2.Post
       except
        expt_tabla2.Cancel
      end;
      tabla2.Next;
    end;
    datosdb.QuitarFiltro(tabla2);
    datosdb.closeDB(expt_tabla2);
  end;

  procedure ExportarPuntajeFinal(xperiodo, xidcarrera: String);
  // Objetivo...: Exportar Puntos Escalafon
  Begin
    expt_puntaje.Open;
    datosdb.Filtrar(puntaje, 'periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
    puntaje.First;
    while not puntaje.Eof do Begin
      if datosdb.Buscar(expt_puntaje, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', puntaje.FieldByName('periodo').AsString, Trim(puntaje.FieldByName('nrodoc').AsString), puntaje.FieldByName('idcarrera').AsString, puntaje.FieldByName('idmateria').AsString) then expt_puntaje.Edit else expt_puntaje.Append;
      expt_puntaje.FieldByName('periodo').AsString   := puntaje.FieldByName('periodo').AsString;
      expt_puntaje.FieldByName('nrodoc').AsString    := Trim(puntaje.FieldByName('nrodoc').AsString);
      expt_puntaje.FieldByName('idcarrera').AsString := puntaje.FieldByName('idcarrera').AsString;
      expt_puntaje.FieldByName('idmateria').AsString := puntaje.FieldByName('idmateria').AsString;
      expt_puntaje.FieldByName('puntosg').AsFloat    := puntaje.FieldByName('puntosg').AsFloat;
      expt_puntaje.FieldByName('puntosp').AsFloat    := puntaje.FieldByName('puntosp').AsFloat;
      expt_puntaje.FieldByName('puntostot').AsFloat  := puntaje.FieldByName('puntostot').AsFloat;
      try
        expt_puntaje.Post
       except
        expt_puntaje.Cancel
      end;
      puntaje.Next;
    end;
    datosdb.QuitarFiltro(puntaje);
    datosdb.closeDB(expt_puntaje);
  end;

  procedure ExportarItemsPuntosGenerales;
  // Objetivo...: Exportar Detalle Items Puntos Generales
  Begin
    expt_puntositems.Open;
    puntositems.First;
    while not puntositems.Eof do Begin
      if datosdb.Buscar(expt_puntositems, 'nrodoc', 'itemsg', 'items', 'subitems', Trim(puntositems.FieldByName('nrodoc').AsString), puntositems.FieldByName('itemsg').AsString, puntositems.FieldByName('items').AsString, puntositems.FieldByName('subitems').AsString) then expt_puntositems.Edit else expt_puntositems.Append;
      expt_puntositems.FieldByName('nrodoc').AsString   := Trim(puntositems.FieldByName('nrodoc').AsString);
      expt_puntositems.FieldByName('itemsg').AsString   := puntositems.FieldByName('itemsg').AsString;
      expt_puntositems.FieldByName('items').AsString    := puntositems.FieldByName('items').AsString;
      expt_puntositems.FieldByName('subitems').AsString := puntositems.FieldByName('subitems').AsString;
      expt_puntositems.FieldByName('descrip').AsString  := puntositems.FieldByName('descrip').AsString;
      expt_puntositems.FieldByName('fecha').AsString    := puntositems.FieldByName('fecha').AsString;
      expt_puntositems.FieldByName('puntos').AsFloat    := puntositems.FieldByName('puntos').AsFloat;
      expt_puntositems.FieldByName('hscatedra').AsFloat := puntositems.FieldByName('hscatedra').AsFloat;
      expt_puntositems.FieldByName('hsreloj').AsFloat   := puntositems.FieldByName('hsreloj').AsFloat;
      expt_puntositems.FieldByName('cantidad').AsFloat  := puntositems.FieldByName('cantidad').AsFloat;
      expt_puntositems.FieldByName('eval').AsString     := puntositems.FieldByName('eval').AsString;
      try
        expt_puntositems.Post
       except
        expt_puntositems.Cancel
      end;
      puntositems.Next;
    end;
    datosdb.QuitarFiltro(puntositems);
    datosdb.closeDB(expt_puntositems);
  end;

  procedure ExportarDesestimaciones(xperiodo, xidcarrera: String);
  // Objetivo...: Exportar Inscripciones
  Begin
    expt_desestimaciones.Open;
    datosdb.Filtrar(desestimaciones, 'periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
    desestimaciones.First;
    while not desestimaciones.Eof do Begin
      if datosdb.Buscar(expt_desestimaciones, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', desestimaciones.FieldByName('periodo').AsString, Trim(desestimaciones.FieldByName('nrodoc').AsString), desestimaciones.FieldByName('idcarrera').AsString, desestimaciones.FieldByName('idmateria').AsString) then expt_desestimaciones.Edit else expt_desestimaciones.Append;
      expt_desestimaciones.FieldByName('periodo').AsString   := desestimaciones.FieldByName('periodo').AsString;
      expt_desestimaciones.FieldByName('nrodoc').AsString    := Trim(desestimaciones.FieldByName('nrodoc').AsString);
      expt_desestimaciones.FieldByName('idcarrera').AsString := desestimaciones.FieldByName('idcarrera').AsString;
      expt_desestimaciones.FieldByName('idmateria').AsString := desestimaciones.FieldByName('idmateria').AsString;
      expt_desestimaciones.FieldByName('motivo').AsString    := desestimaciones.FieldByName('motivo').AsString;
      try
        expt_desestimaciones.Post
       except
        expt_desestimaciones.Cancel
      end;
      desestimaciones.Next;
    end;
    datosdb.QuitarFiltro(desestimaciones);
    datosdb.closeDB(expt_desestimaciones);
  end;

  procedure ExportarAntiguedadDocente(xperiodo: String);
  // Objetivo...: Exportar Puntaje General
  Begin
    expt_antiguedaddoc.Open;
    tabla4.First;
    while not tabla4.Eof do Begin
      if datosdb.Buscar(expt_antiguedaddoc, 'nrodoc', 'idcarrera', 'idmateria', 'desde', Trim(tabla4.FieldByName('nrodoc').AsString), Trim(tabla4.FieldByName('idcarrera').AsString), tabla4.FieldByName('idmateria').AsString, tabla4.FieldByName('desde').AsString) then expt_antiguedaddoc.Edit else expt_antiguedaddoc.Append;
      expt_antiguedaddoc.FieldByName('nrodoc').AsString    := Trim(tabla4.FieldByName('nrodoc').AsString);
      expt_antiguedaddoc.FieldByName('idcarrera').AsString := Trim(tabla4.FieldByName('idcarrera').AsString);
      expt_antiguedaddoc.FieldByName('idmateria').AsString := tabla4.FieldByName('idmateria').AsString;
      expt_antiguedaddoc.FieldByName('desde').AsString     := tabla4.FieldByName('desde').AsString;
      expt_antiguedaddoc.FieldByName('hasta').AsString     := tabla4.FieldByName('hasta').AsString;
      try
        expt_antiguedaddoc.Post
       except
        expt_antiguedaddoc.Cancel
      end;
      tabla4.Next;
    end;
    datosdb.closeDB(expt_antiguedaddoc);
  end;

  //----------------------------------------------------------------------------

Begin
  conectar;
  CopiarEstructuras;
  // Transferimos los Datos
  ExportarInscripcion(xperiodo, xidcarrera);
  ExportarPuntosGenerales(xperiodo);
  ExportarPuntosMateria(xperiodo, xidcarrera);
  ExportarPuntajeFinal(xperiodo, xidcarrera);
  ExportarItemsPuntosGenerales;
  ExportarDesestimaciones(xperiodo, xidcarrera);
  ExportarAntiguedadDocente(xperiodo);
  materia.Exportar(xidcarrera);
  docente.Exportar(lista);
  // Compactamos
  utilesarchivos.CompactarArchivos(dbs.DirSistema + '\exportar\escalafon\work\*.*', dbs.DirSistema + '\exportar\escalafon\esc_export.bck');
  desconectar;
end;

function  TTEscalafonamiento.Importar(xperiodo, xdrive: String; xlista: TStringList): TStringList;
// Objetivo...: Exportar Escalafon
var
  imp_inscripcion, imp_tabla1, imp_tabla2, imp_puntaje, imp_puntositems, imp_desestimaciones, imp_antiguedaddoc: TTable;
  id_carrera: TStringList;

  //----------------------------------------------------------------------------
  procedure CopiarEstructuras(xdrive: String);
  // Objetivo...: Copiar Estructuras de Datos
  Begin
    utilesarchivos.CopiarArchivos(xdrive + '\', 'esc_export.bck', dbs.DirSistema + '\Importar\Escalafon');
    // Descompactamos los datos
    if FileExists(dbs.DirSistema + '\Importar\escalafon\esc_export.bck') then Begin
      utilesarchivos.DescompactarArchivos(dbs.DirSistema + '\Importar\escalafon\esc_export.bck', dbs.DirSistema + '\Importar\Escalafon\work');
      // Instanciamos las tablas
      imp_inscripcion      := datosdb.openDB('inscripciondocente', '', '', dbs.DirSistema + '\importar\escalafon\work');
      imp_tabla1           := datosdb.openDB('puntosgenerales', '', '', dbs.DirSistema + '\importar\escalafon\work');
      imp_tabla2           := datosdb.openDB('puntosmateria', '', '', dbs.DirSistema + '\importar\escalafon\work');
      imp_puntaje          := datosdb.openDB('puntosescalafon', '', '', dbs.DirSistema + '\importar\escalafon\work');
      imp_puntositems      := datosdb.openDB('puntositems', '', '', dbs.DirSistema + '\importar\escalafon\work');
      imp_desestimaciones  := datosdb.openDB('desestimaciones', '', '', dbs.DirSistema + '\importar\escalafon\work');
      imp_antiguedaddoc    := datosdb.openDB('antiguedad_doc', '', '', dbs.DirSistema + '\importar\escalafon\work');
    end;
  end;

  procedure ImportarInscripcion(xlista: TStringList; xperiodo: String);
  // Objetivo...: Importar Inscripciones
  Begin
    imp_inscripcion.Open;
    imp_inscripcion.First;
    inscripcion.IndexFieldNames := 'periodo;nrodoc;idcarrera;idmateria';
    while not imp_inscripcion.Eof do Begin
      if utiles.verificarItemsLista(xlista, imp_inscripcion.FieldByName('nrodoc').AsString) then Begin
        if datosdb.Buscar(inscripcion, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', imp_inscripcion.FieldByName('periodo').AsString, Trim(imp_inscripcion.FieldByName('nrodoc').AsString), imp_inscripcion.FieldByName('idcarrera').AsString, imp_inscripcion.FieldByName('idmateria').AsString) then inscripcion.Edit else inscripcion.Append;
        inscripcion.FieldByName('periodo').AsString   := imp_inscripcion.FieldByName('periodo').AsString;
        inscripcion.FieldByName('nrodoc').AsString    := Trim(imp_inscripcion.FieldByName('nrodoc').AsString);
        inscripcion.FieldByName('idcarrera').AsString := imp_inscripcion.FieldByName('idcarrera').AsString;
        inscripcion.FieldByName('idmateria').AsString := imp_inscripcion.FieldByName('idmateria').AsString;
        if id_carrera.Count = 0 then id_carrera.Add(inscripcion.FieldByName('idcarrera').AsString) else
          if not utiles.verificarItemsLista(id_carrera, inscripcion.FieldByName('idcarrera').AsString) then id_carrera.Add(inscripcion.FieldByName('idcarrera').AsString);
        try
          inscripcion.Post
         except
          inscripcion.Cancel
        end;
      end;
      imp_inscripcion.Next;
    end;
    datosdb.closeDB(imp_inscripcion);
    datosdb.closeDB(inscripcion); inscripcion.Open;
  end;

  procedure ImportarPuntosGenerales(xlista: TStringList; xperiodo: String);
  // Objetivo...: Importar Puntaje General
  Begin
    imp_tabla1.Open;
    imp_tabla1.First;
    tabla1.IndexFieldNames := 'periodo;nrodoc;items;subitems';
    while not imp_tabla1.Eof do Begin
      if utiles.verificarItemsLista(xlista, imp_tabla1.FieldByName('nrodoc').AsString) then Begin
        if datosdb.Buscar(tabla1, 'periodo', 'nrodoc', 'items', 'subitems', imp_tabla1.FieldByName('periodo').AsString, imp_tabla1.FieldByName('nrodoc').AsString, imp_tabla1.FieldByName('items').AsString, imp_tabla1.FieldByName('subitems').AsString) then tabla1.Edit else tabla1.Append;
        tabla1.FieldByName('periodo').AsString   := imp_tabla1.FieldByName('periodo').AsString;
        tabla1.FieldByName('nrodoc').AsString    := Trim(imp_tabla1.FieldByName('nrodoc').AsString);
        tabla1.FieldByName('items').AsString     := imp_tabla1.FieldByName('items').AsString;
        tabla1.FieldByName('subitems').AsString  := imp_tabla1.FieldByName('subitems').AsString;
        tabla1.FieldByName('puntos').AsFloat     := imp_tabla1.FieldByName('puntos').AsFloat;
        try
          tabla1.Post
         except
          tabla1.Cancel
        end;
      end;
      imp_tabla1.Next;
    end;
    datosdb.closeDB(imp_tabla1);
  end;

  procedure ImportarPuntosMateria(xlista: TStringList; xperiodo: String);
  // Objetivo...: Importar Puntaje por Materia
  Begin
    imp_tabla2.Open;
    imp_tabla2.First;
    tabla2.IndexFieldNames := 'periodo;nrodoc;idcarrera;idmateria;items;subitems';
    while not imp_tabla2.Eof do Begin
      if utiles.verificarItemsLista(xlista, imp_tabla2.FieldByName('nrodoc').AsString) then Begin
        if datosdb.Buscar(tabla2, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', 'items', 'subitems', imp_tabla2.FieldByName('periodo').AsString, imp_tabla2.FieldByName('nrodoc').AsString, imp_tabla2.FieldByName('idcarrera').AsString, imp_tabla2.FieldByName('idmateria').AsString, imp_tabla2.FieldByName('items').AsString, imp_tabla2.FieldByName('subitems').AsString) then tabla2.Edit else tabla2.Append;
        tabla2.FieldByName('periodo').AsString   := imp_tabla2.FieldByName('periodo').AsString;
        tabla2.FieldByName('nrodoc').AsString    := Trim(imp_tabla2.FieldByName('nrodoc').AsString);
        tabla2.FieldByName('idcarrera').AsString := imp_tabla2.FieldByName('idcarrera').AsString;
        tabla2.FieldByName('idmateria').AsString := imp_tabla2.FieldByName('idmateria').AsString;
        tabla2.FieldByName('items').AsString     := imp_tabla2.FieldByName('items').AsString;
        tabla2.FieldByName('subitems').AsString  := imp_tabla2.FieldByName('subitems').AsString;
        tabla2.FieldByName('puntos').AsFloat     := imp_tabla2.FieldByName('puntos').AsFloat;
        tabla2.FieldByName('cantidad').AsFloat   := imp_tabla2.FieldByName('cantidad').AsFloat;
        try
          tabla2.Post
         except
          tabla2.Cancel
        end;
      end;
      imp_tabla2.Next;
    end;
    datosdb.closeDB(imp_tabla2);
  end;

  procedure ImportarPuntajeFinal(xlista: TStringList; xperiodo: String);
  // Objetivo...: Exportar Puntos Escalafon
  Begin
    imp_puntaje.Open;
    imp_puntaje.First;
    puntaje.IndexFieldNames := 'periodo;nrodoc;idcarrera;idmateria';
    while not imp_puntaje.Eof do Begin
      if utiles.verificarItemsLista(xlista, imp_puntaje.FieldByName('nrodoc').AsString) then Begin
        if datosdb.Buscar(puntaje, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', imp_puntaje.FieldByName('periodo').AsString, Trim(imp_puntaje.FieldByName('nrodoc').AsString), imp_puntaje.FieldByName('idcarrera').AsString, imp_puntaje.FieldByName('idmateria').AsString) then puntaje.Edit else puntaje.Append;
        puntaje.FieldByName('periodo').AsString   := imp_puntaje.FieldByName('periodo').AsString;
        puntaje.FieldByName('nrodoc').AsString    := Trim(imp_puntaje.FieldByName('nrodoc').AsString);
        puntaje.FieldByName('idcarrera').AsString := imp_puntaje.FieldByName('idcarrera').AsString;
        puntaje.FieldByName('idmateria').AsString := imp_puntaje.FieldByName('idmateria').AsString;
        puntaje.FieldByName('puntosg').AsFloat    := imp_puntaje.FieldByName('puntosg').AsFloat;
        puntaje.FieldByName('puntosp').AsFloat    := imp_puntaje.FieldByName('puntosp').AsFloat;
        puntaje.FieldByName('puntostot').AsFloat  := imp_puntaje.FieldByName('puntostot').AsFloat;
        try
          puntaje.Post
         except
          puntaje.Cancel
        end;
      end;
      imp_puntaje.Next;
    end;
    datosdb.closeDB(imp_puntaje);
  end;

  procedure ImportarItemsPuntosGenerales(xlista: TStringList);
  // Objetivo...: Exportar Detalle Items Puntos Generales
  Begin
    imp_puntositems.Open;
    imp_puntositems.First;
    puntositems.IndexFieldNames := 'nrodoc;itemsg;items;subitems';
    while not imp_puntositems.Eof do Begin
      if utiles.verificarItemsLista(xlista, Trim(imp_puntositems.FieldByName('nrodoc').AsString)) then Begin
        if datosdb.Buscar(puntositems, 'nrodoc', 'itemsg', 'items', 'subitems', Trim(imp_puntositems.FieldByName('nrodoc').AsString), imp_puntositems.FieldByName('itemsg').AsString, imp_puntositems.FieldByName('items').AsString, imp_puntositems.FieldByName('subitems').AsString) then puntositems.Edit else puntositems.Append;
        puntositems.FieldByName('nrodoc').AsString   := Trim(imp_puntositems.FieldByName('nrodoc').AsString);
        puntositems.FieldByName('itemsg').AsString   := imp_puntositems.FieldByName('itemsg').AsString;
        puntositems.FieldByName('items').AsString    := imp_puntositems.FieldByName('items').AsString;
        puntositems.FieldByName('subitems').AsString := imp_puntositems.FieldByName('subitems').AsString;
        puntositems.FieldByName('descrip').AsString  := imp_puntositems.FieldByName('descrip').AsString;
        puntositems.FieldByName('fecha').AsString    := imp_puntositems.FieldByName('fecha').AsString;
        puntositems.FieldByName('puntos').AsFloat    := imp_puntositems.FieldByName('puntos').AsFloat;
        puntositems.FieldByName('hscatedra').AsFloat := imp_puntositems.FieldByName('hscatedra').AsFloat;
        puntositems.FieldByName('hsreloj').AsFloat   := imp_puntositems.FieldByName('hsreloj').AsFloat;
        puntositems.FieldByName('cantidad').AsFloat  := imp_puntositems.FieldByName('cantidad').AsFloat;
        puntositems.FieldByName('eval').AsString     := imp_puntositems.FieldByName('eval').AsString;
        try
          puntositems.Post
         except
          puntositems.Cancel
        end;
      end;
      imp_puntositems.Next;
    end;
    datosdb.closeDB(imp_puntositems);
  end;

  procedure ImportarDesestimaciones(xlista: TStringList; xperiodo: String);
  // Objetivo...: Importar Inscripciones
  Begin
    imp_desestimaciones.Open;
    imp_desestimaciones.First;
    desestimaciones.IndexFieldNames := 'periodo;nrodoc;idcarrera;idmateria';
    while not imp_desestimaciones.Eof do Begin
      if utiles.verificarItemsLista(xlista, imp_desestimaciones.FieldByName('nrodoc').AsString) then Begin
        if datosdb.Buscar(desestimaciones, 'periodo', 'nrodoc', 'idcarrera', 'idmateria', imp_desestimaciones.FieldByName('periodo').AsString, Trim(imp_desestimaciones.FieldByName('nrodoc').AsString), imp_desestimaciones.FieldByName('idcarrera').AsString, imp_desestimaciones.FieldByName('idmateria').AsString) then desestimaciones.Edit else desestimaciones.Append;
        desestimaciones.FieldByName('periodo').AsString   := imp_desestimaciones.FieldByName('periodo').AsString;
        desestimaciones.FieldByName('nrodoc').AsString    := Trim(imp_desestimaciones.FieldByName('nrodoc').AsString);
        desestimaciones.FieldByName('idcarrera').AsString := imp_desestimaciones.FieldByName('idcarrera').AsString;
        desestimaciones.FieldByName('idmateria').AsString := imp_desestimaciones.FieldByName('idmateria').AsString;
        desestimaciones.FieldByName('motivo').AsString    := imp_desestimaciones.FieldByName('motivo').AsString;
        try
          desestimaciones.Post
         except
          desestimaciones.Cancel
        end;
      end;
      imp_desestimaciones.Next;
    end;
    datosdb.closeDB(imp_desestimaciones);
  end;

  procedure ImportarAntiguedaddoc;
  // Objetivo...: Importar Antiguedad docente
  Begin
    imp_antiguedaddoc.Open;
    imp_antiguedaddoc.First;
    tabla4.IndexFieldNames := 'nrodoc;idcarrera;idmateria;desde';
    while not imp_antiguedaddoc.Eof do Begin
      if utiles.verificarItemsLista(xlista, imp_antiguedaddoc.FieldByName('nrodoc').AsString) then Begin
        if datosdb.Buscar(tabla4, 'nrodoc', 'idcarrera', 'idmateria', 'desde', imp_antiguedaddoc.FieldByName('nrodoc').AsString, imp_antiguedaddoc.FieldByName('idcarrera').AsString, imp_antiguedaddoc.FieldByName('idmateria').AsString, imp_antiguedaddoc.FieldByName('desde').AsString) then tabla4.Edit else tabla4.Append;
        tabla4.FieldByName('nrodoc').AsString    := Trim(imp_antiguedaddoc.FieldByName('nrodoc').AsString);
        tabla4.FieldByName('idcarrera').AsString := Trim(imp_antiguedaddoc.FieldByName('idcarrera').AsString);
        tabla4.FieldByName('idmateria').AsString := imp_antiguedaddoc.FieldByName('idmateria').AsString;
        tabla4.FieldByName('desde').AsString     := imp_antiguedaddoc.FieldByName('desde').AsString;
        tabla4.FieldByName('hasta').AsString     := imp_antiguedaddoc.FieldByName('hasta').AsString;
        try
          tabla4.Post
         except
          tabla4.Cancel
        end;
      end;
      imp_antiguedaddoc.Next;
    end;
    datosdb.closeDB(imp_antiguedaddoc);
  end;

  //----------------------------------------------------------------------------

Begin
  id_carrera := TStringList.Create;
  conectar;
  CopiarEstructuras(xdrive);
  if FileExists(dbs.DirSistema + '\Importar\escalafon\esc_export.bck') then Begin
    // Transferimos los Datos
    ImportarInscripcion(xlista, xperiodo);
    ImportarPuntosGenerales(xlista, xperiodo);
    ImportarPuntosMateria(xlista, xperiodo);
    ImportarPuntajeFinal(xlista, xperiodo);
    ImportarItemsPuntosGenerales(xlista);
    ImportarDesestimaciones(xlista, xperiodo);
    ImportarAntiguedaddoc;
    materia.Importar;
    docente.Importar;
    Result := id_carrera;
  end else
    Result := nil;
  desconectar;
end;

function TTEscalafonamiento.setListaDocentesImportar(xperiodo, xdrive: String): TStringList;
// Objetivo...: Devolver una Lista de los Docentes Importados
var
  imp_inscripcion: TTable;
  r: TQuery;
  lista: TStringList;
  objdocente: TTDocente;   // Instancia para trabajar la Nómina de Docentes Importados

  //----------------------------------------------------------------------------
  procedure CopiarEstructuras(xdrive: String);
  // Objetivo...: Copiar Estructuras de Datos
  Begin
    utilesarchivos.CopiarArchivos(xdrive, '*.bck', dbs.DirSistema + '\Importar\Escalafon');
    // Descompactamos los datos
    if FileExists(dbs.DirSistema + '\Importar\escalafon\esc_export.bck') then Begin
      utilesarchivos.DescompactarArchivos(dbs.DirSistema + '\Importar\escalafon\esc_export.bck', dbs.DirSistema + '\Importar\Escalafon\work');
      // Instanciamos las tablas
      imp_inscripcion := datosdb.openDB('inscripciondocente', '', '', dbs.DirSistema + '\importar\escalafon\work');
    end;
  end;

begin
  lista      := TStringList.Create;
  conectar;
  CopiarEstructuras(xdrive);
  if FileExists(dbs.DirSistema + '\Importar\escalafon\esc_export.bck') then Begin
    objdocente := TTDocente.Create;
    objdocente.Instaciar(imp_inscripcion.DatabaseName);
    r := datosdb.tranSQL(imp_inscripcion.DatabaseName, 'select distinct nrodoc from ' + imp_inscripcion.TableName);
    r.Open;
    while not r.Eof do Begin
      objdocente.getDatos(r.FieldByName('nrodoc').AsString);
      lista.Add(objdocente.Apellido + ', ' + objdocente.nombre + ';1' + r.FieldByName('nrodoc').AsString);
      r.Next;
    end;
    lista.Sort;
    r.Close; r.Free;
    objdocente.desconectar;
    objdocente.Destroy; objdocente := Nil;
  end;
  Result := lista;
end;

procedure TTEscalafonamiento.ImportarAntecedentesDocente(xlista: TStringList; xperiodo, xdrive: String; ximportar_datos_docentes: Boolean);
// Objetivo...: Exportar Escalafon
var
  imp_tabla1, imp_puntositems: TTable;

  //----------------------------------------------------------------------------
  procedure CopiarEstructuras(xdrive: String);
  // Objetivo...: Copiar Estructuras de Datos
  Begin
    utilesarchivos.CopiarArchivos(xdrive, 'esc_export.bck', dbs.DirSistema + '\Importar\Escalafon');
    // Descompactamos los datos
    if FileExists(dbs.DirSistema + '\Importar\escalafon\esc_export.bck') then Begin
      utilesarchivos.DescompactarArchivos(dbs.DirSistema + '\Importar\escalafon\esc_export.bck', dbs.DirSistema + '\Importar\Escalafon\work');
      // Instanciamos las tablas
      imp_tabla1           := datosdb.openDB('puntosgenerales', '', '', dbs.DirSistema + '\importar\escalafon\work');
      imp_puntositems      := datosdb.openDB('puntositems', '', '', dbs.DirSistema + '\importar\escalafon\work');
    end;
  end;

  procedure ImportarPuntosGenerales(xperiodo: String);
  // Objetivo...: Importar Puntaje General
  Begin
    imp_tabla1.Open;
    imp_tabla1.First;
    while not imp_tabla1.Eof do Begin
      if (utiles.verificarItemsLista(xlista, Trim(imp_tabla1.FieldByName('nrodoc').AsString))) then Begin
        if datosdb.Buscar(tabla1, 'periodo', 'nrodoc', 'items', 'subitems', imp_tabla1.FieldByName('periodo').AsString, imp_tabla1.FieldByName('nrodoc').AsString, imp_tabla1.FieldByName('items').AsString, imp_tabla1.FieldByName('subitems').AsString) then tabla1.Edit else tabla1.Append;
        tabla1.FieldByName('periodo').AsString   := imp_tabla1.FieldByName('periodo').AsString;
        tabla1.FieldByName('nrodoc').AsString    := Trim(imp_tabla1.FieldByName('nrodoc').AsString);
        tabla1.FieldByName('items').AsString     := imp_tabla1.FieldByName('items').AsString;
        tabla1.FieldByName('subitems').AsString  := imp_tabla1.FieldByName('subitems').AsString;
        tabla1.FieldByName('puntos').AsFloat     := imp_tabla1.FieldByName('puntos').AsFloat;
        try
          tabla1.Post
         except
          tabla1.Cancel
        end;
      end;
      imp_tabla1.Next;
    end;
    datosdb.closeDB(imp_tabla1);
  end;

  procedure ImportarItemsPuntosGenerales;
  // Objetivo...: Importar Detalle Items Puntos Generales
  Begin
    imp_puntositems.Open;
    imp_puntositems.First;
    while not imp_puntositems.Eof do Begin
      if (utiles.verificarItemsLista(xlista, Trim(imp_puntositems.FieldByName('nrodoc').AsString))) then Begin
        if datosdb.Buscar(puntositems, 'nrodoc', 'itemsg', 'items', 'subitems', Trim(imp_puntositems.FieldByName('nrodoc').AsString), imp_puntositems.FieldByName('itemsg').AsString, imp_puntositems.FieldByName('items').AsString, imp_puntositems.FieldByName('subitems').AsString) then puntositems.Edit else puntositems.Append;
        puntositems.FieldByName('nrodoc').AsString   := Trim(imp_puntositems.FieldByName('nrodoc').AsString);
        puntositems.FieldByName('itemsg').AsString   := imp_puntositems.FieldByName('itemsg').AsString;
        puntositems.FieldByName('items').AsString    := imp_puntositems.FieldByName('items').AsString;
        puntositems.FieldByName('subitems').AsString := imp_puntositems.FieldByName('subitems').AsString;
        puntositems.FieldByName('descrip').AsString  := imp_puntositems.FieldByName('descrip').AsString;
        puntositems.FieldByName('fecha').AsString    := imp_puntositems.FieldByName('fecha').AsString;
        puntositems.FieldByName('puntos').AsFloat    := imp_puntositems.FieldByName('puntos').AsFloat;
        puntositems.FieldByName('hscatedra').AsFloat := imp_puntositems.FieldByName('hscatedra').AsFloat;
        puntositems.FieldByName('hsreloj').AsFloat   := imp_puntositems.FieldByName('hsreloj').AsFloat;
        puntositems.FieldByName('cantidad').AsFloat  := imp_puntositems.FieldByName('cantidad').AsFloat;
        puntositems.FieldByName('eval').AsString     := imp_puntositems.FieldByName('eval').AsString;
        try
          puntositems.Post
         except
          puntositems.Cancel
        end;
      end;
      imp_puntositems.Next;
    end;
    datosdb.closeDB(imp_puntositems);
  end;

  procedure ImportarDocentes;
  // Objetivo...: Importar Datos Docentes
  var
    i: Integer;
    objdocente: TTDocente;

  Begin
    objdocente := TTDocente.Create;
    objdocente.Instaciar(dbs.DirSistema + '\importar\escalafon\work');
    for i := 1 to xlista.Count do Begin
      if objdocente.Buscar(xlista.Strings[i-1]) then Begin
        objdocente.getDatos(xlista.Strings[i-1]);
        docente.Registrar(xlista.Strings[i-1], objdocente.Apellido, objdocente.nombre, objdocente.domicilio, objdocente.codpost, objdocente.orden,
                          objdocente.Telefono, objdocente.FechaNac, objdocente.Estcivil, objdocente.Email, objdocente.Carpetam, objdocente.Estante, objdocente.Titulo);
      end;
    end;

    objdocente.desconectar;
    objdocente.Destroy; objdocente := Nil;
  end;

  //----------------------------------------------------------------------------

Begin
  conectar;
  CopiarEstructuras(xdrive);
  if FileExists(dbs.DirSistema + '\Importar\escalafon\esc_export.bck') then Begin
    // Transferimos los Datos
    ImportarPuntosGenerales(xperiodo);
    ImportarItemsPuntosGenerales;
    docente.Importar;
  end;
  desconectar;
end;

function TTEscalafonamiento.BuscarEscalafonAlternativo(xperiodo, xnrodoc, xidcarrera: String): Boolean;
// Objetivo...: recuperar instancia
begin
  Result := datosdb.Buscar(tabla3, 'periodo', 'nrodoc', 'idcarrera', xperiodo, xnrodoc, xidcarrera);
end;

function  TTEscalafonamiento.BuscarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde: String): Boolean;
// Objetivo...: Recuperar Instancia
Begin
  Result := datosdb.Buscar(tabla4, 'nrodoc', 'idcarrera', 'idmateria', 'desde', xnrodoc, xidcarrera, xidmateria, utiles.sExprFecha2000(xdesde));
end;

procedure TTEscalafonamiento.RegistrarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde, xhasta: String);
// Objetivo...: Registrar Instancia
Begin
  if BuscarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde) then tabla4.Edit else tabla4.Append;
  tabla4.FieldByName('nrodoc').AsString    := xnrodoc;
  tabla4.FieldByName('idcarrera').AsString := xidcarrera;
  tabla4.FieldByName('idmateria').AsString := xidmateria;
  tabla4.FieldByName('desde').AsString     := utiles.sExprFecha2000(xdesde);
  tabla4.FieldByName('hasta').AsString     := utiles.sExprFecha2000(xhasta);
  try
    tabla4.Post
   except
    tabla4.Cancel
  end;
  datosdb.closeDB(tabla4); tabla4.Open;
end;

procedure TTEscalafonamiento.BorrarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde: String);
// Objetivo...: Borrar Instancia
Begin
  if BuscarAntiguedad(xnrodoc, xidcarrera, xidmateria, xdesde) then Begin
    tabla4.Delete;
    datosdb.closeDB(tabla4); tabla4.Open;
  end;
end;

function  TTEscalafonamiento.setListaAntiguedad(xnrodoc, xidcarrera, xidmateria: String): TObjectList;
// Objetivo...: Recuperar lista de Instancias
var
  l: TObjectList;
  objeto: TTEscalafonamiento;
begin
  l := TObjectList.Create;
  datosdb.Filtrar(tabla4, 'nrodoc = ' + '''' + xnrodoc + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and idmateria = ' + '''' + xidmateria + '''');
  tabla4.First;
  while not tabla4.Eof do Begin
    objeto                  := TTEscalafonamiento.Create;
    objeto.ant_nrodoc       := tabla4.FieldByName('nrodoc').AsString;
    objeto.ant_idcarrera    := tabla4.FieldByName('idcarrera').AsString;
    objeto.ant_idmateria    := tabla4.FieldByName('idmateria').AsString;
    objeto.ant_desde        := utiles.sFormatoFecha(tabla4.FieldByName('desde').AsString);
    objeto.ant_hasta        := utiles.sFormatoFecha(tabla4.FieldByName('hasta').AsString);
    l.Add(objeto);
    tabla4.Next;
  end;
  datosdb.QuitarFiltro(tabla3);

  Result := l;
end;

function TTEscalafonamiento.verificarSiTieneAntiguedad(xnrodoc, xidcarrera, xidmateria: String): Boolean;
// Objetivo...: cerrar tablas de persistencia
begin
  tabla4.IndexFieldNames := 'nrodoc;idcarrera;idmateria';
  Result := datosdb.Buscar(tabla4, 'nrodoc', 'idcarrera', 'idmateria', xnrodoc, xidcarrera, xidmateria);
  tabla4.IndexFieldNames := 'nrodoc;idcarrera;idmateria;desde';
end;

function TTEscalafonamiento.BuscarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex: String): Boolean;
// Objetivo...: buscar una instancia
begin
  tabla5.IndexFieldNames := 'periodo;nrodoc;idmateria;idcarrera;idcarreraex';
  Result := datosdb.Buscar(tabla5, 'periodo', 'nrodoc', 'idmateria', 'idcarrera', 'idcarreraex', xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex);
end;

procedure TTEscalafonamiento.RegistrarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex: String);
// Objetivo...: registrar una instancia
begin
  if BuscarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex) then tabla5.Edit else tabla5.Append;
  tabla5.FieldByName('periodo').AsString     := xperiodo;
  tabla5.FieldByName('nrodoc').AsString      := xnrodoc;
  tabla5.FieldByName('idmateria').AsString   := xidmateria;
  tabla5.FieldByName('idcarrera').AsString   := xidcarrera;
  tabla5.FieldByName('idcarreraex').AsString := xidcarreraex;
  try
    tabla5.Post
   except
    tabla5.Cancel
  end;
  datosdb.closeDB(tabla5); tabla5.Open;
end;

procedure TTEscalafonamiento.BorrarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex: String);
// Objetivo...: borrar una instancia
begin
  if BuscarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera, xidcarreraex) then Begin
    tabla5.Delete;
    datosdb.closeDB(tabla5); tabla5.Open;
  end;
end;

function TTEscalafonamiento.VerificarExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera: String): Boolean;
// Objetivo...: buscar una instancia
begin
  //tabla5.IndexFieldNames := 'periodo;nrodoc;idmateria;idcarrera';
  //Result := datosdb.Buscar(tabla5, 'periodo', 'nrodoc', 'idmateria', 'idcarrera', xperiodo, xnrodoc, xidmateria, xidcarrera);
  datosdb.Filtrar(tabla5, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and idmateria = ' + '''' + xidmateria + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  if tabla5.RecordCount > 0 then result := true else result := false;
  datosdb.QuitarFiltro(tabla5);
end;

function  TTEscalafonamiento.setCarrerasExclusion(xperiodo, xnrodoc, xidmateria, xidcarrera: String): String;
// Objetivo...: devolver las carreras en las que no se inscribe
var
  l: String;
begin
  datosdb.Filtrar(tabla5, 'periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + xnrodoc + '''' + ' and idmateria = ' + '''' + xidmateria + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  tabla5.First;
  while not tabla5.Eof do Begin
    carrera.getDatos(tabla5.FieldByName('idcarreraex').AsString);
    l := l + Copy(carrera.Carrera, 1, 20) + ' - ';
    tabla5.Next;
  end;
  datosdb.QuitarFiltro(tabla5);
  Result := Copy(l, 1, Length(l) - 3);
end;

procedure TTEscalafonamiento.CopiarEscalafon(xdeperiodo, xaperiodo, xidcarrera: String; xinscripciones, xantecedentesmateria, xdesestimaciones, xexclusiones: Boolean);
// Objetivo...: copiar datos de un período a otro
var
  r: TQuery;

  procedure CopiarInscripcion(xdeperiodo, xaperiodo, xidcarrera: String);
  // Objetivo...: Copiar Inscripción
  var
    s: TQuery;
  Begin
    r := datosdb.tranSQL('select * from inscripciondocente where periodo = ' + '''' + xdeperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
    r.Open;
    while not r.Eof do Begin
      if not BuscarInscripcion(xaperiodo, r.FieldByName('nrodoc').AsString, r.FieldByName('idcarrera').AsString, r.FieldByName('idmateria').AsString) then RegistrarIns(xaperiodo, r.FieldByName('nrodoc').AsString, r.FieldByName('idcarrera').AsString, r.FieldByName('idmateria').AsString, 'S');
      // Objetivo...: Copiar Puntos Generales
      s := datosdb.tranSQL('select * from puntosgenerales where periodo = ' + '''' + xdeperiodo + '''' + ' and nrodoc = ' + '''' + r.FieldByName('nrodoc').AsString + '''');
      s.Open;
      while not s.Eof do Begin
        RegistrarPG(xaperiodo, s.FieldByName('nrodoc').AsString, s.FieldByName('items').AsString, s.FieldByName('subitems').AsString, s.FieldByName('puntos').AsFloat);
        s.Next;
      end;
      s.Close; s.Free;

      r.Next;
    end;
    r.Close; r.Free;
  end;

  procedure CopiarPuntosMateria(xdeperiodo, xaperiodo, xidcarrera: String);
  // Objetivo...: Copiar Puntos por Materia
  Begin
    r := datosdb.tranSQL('select * from puntosmateria where periodo = ' + '''' + xdeperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
    r.Open;
    while not r.Eof do Begin
      RegistrarPM(xaperiodo, r.FieldByName('nrodoc').AsString, r.FieldByName('idcarrera').AsString, r.FieldByName('idmateria').AsString, r.FieldByName('items').AsString,
                  r.FieldByName('subitems').AsString, r.FieldByName('puntos').AsFloat, r.FieldByName('cantidad').AsFloat);
      r.Next;
    end;
    r.Close; r.Free;
  end;

  procedure CopiarDesestimaciones(xdeperiodo, xaperiodo, xidcarrera: String);
  // Objetivo...: Copiar Desestimaciones
  Begin
    r := datosdb.tranSQL('select * from desestimaciones where periodo = ' + '''' + xdeperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
    r.Open;
    while not r.Eof do Begin
      RegistrarDesestimaciones(xaperiodo, r.FieldByName('nrodoc').AsString, r.FieldByName('idcarrera').AsString, r.FieldByName('idmateria').AsString, r.FieldByName('motivo').AsString);
      r.Next;
    end;
    r.Close; r.Free;
  end;

  procedure CopiarExclusiones(xdeperiodo, xaperiodo, xidcarrera: String);
  // Objetivo...: Copiar Exclusiones
  Begin
    r := datosdb.tranSQL('select * from excluiresc where periodo = ' + '''' + xdeperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
    r.Open;
    while not r.Eof do Begin
      RegistrarExclusion(xaperiodo, r.FieldByName('nrodoc').AsString, r.FieldByName('idmateria').AsString, r.FieldByName('idcarrera').AsString, r.FieldByName('idcarreraex').AsString);
      r.Next;
    end;
    r.Close; r.Free;
  end;

begin
  if xinscripciones then CopiarInscripcion(xdeperiodo, xaperiodo, xidcarrera);
  if xantecedentesmateria then CopiarPuntosMateria(xdeperiodo, xaperiodo, xidcarrera);
  if xdesestimaciones then CopiarDesestimaciones(xdeperiodo, xaperiodo, xidcarrera);
  if xexclusiones then CopiarExclusiones(xdeperiodo, xaperiodo, xidcarrera);
end;

procedure TTEscalafonamiento.AnularCopiarEscalafon(xperiodo, xidcarrera: String);
// Objetivo...: Anular Copia
var
  r: TQuery;
begin
  // Primero Borramos solo los docentes afectados
  r := datosdb.tranSQL('select distinct nrodoc from inscripciondocente where periodo = ' + '''' + xperiodo + '''');
  r.Open;
  while not r.Eof do Begin
    datosdb.tranSQL('delete from puntosgenerales where periodo = ' + '''' + xperiodo + '''' + ' and nrodoc = ' + '''' + r.FieldByName('nrodoc').AsString + '''');
    datosdb.refrescar(tabla1);
    r.Next;
  end;
  r.Close; r.Free;
  datosdb.tranSQL('delete from inscripciondocente where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  datosdb.tranSQL('delete from puntosmateria where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  datosdb.tranSQL('delete from desestimaciones where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  datosdb.tranSQL('delete from excluiresc where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  datosdb.refrescar(inscripcion);
  datosdb.refrescar(tabla2);
  datosdb.refrescar(desestimaciones);
  datosdb.refrescar(tabla5);
end;

function  TTEscalafonamiento.BuscarBloqueo(xnrodoc, xtipo: String): Boolean;
// Objetivo...: Buscar Instancia
begin
  datosdb.refrescar(bloqueo);
  datosdb.closeDB(bloqueo); bloqueo.Open;
  Result := datosdb.Buscar(bloqueo, 'nrodoc', 'tipo', xnrodoc, xtipo);
end;

procedure TTEscalafonamiento.Bloquear(xnrodoc, xtipo, xusuario, xtarea: String);
// Objetivo...: bloquear Proceso
begin
  if BuscarBloqueo(xnrodoc, xtipo) then bloqueo.Edit else bloqueo.Append;
  bloqueo.FieldByName('nrodoc').AsString  := xnrodoc;
  bloqueo.FieldByName('tipo').AsString    := xtipo;
  bloqueo.FieldByName('usuario').AsString := xusuario;
  bloqueo.FieldByName('tarea').AsString   := xtarea;
  try
    bloqueo.Post
   except
    bloqueo.Cancel
  end;
  datosdb.closeDB(bloqueo); bloqueo.Open;
end;

procedure TTEscalafonamiento.QuitarBloqueo(xnrodoc, xtipo: String);
// Objetivo...: Quitar Bloqueo
begin
  if BuscarBloqueo(xnrodoc, xtipo) then Begin
    bloqueo.Delete;
    datosdb.closeDB(bloqueo); bloqueo.Open;
  end;
end;

function  TTEscalafonamiento.verificarBloqueo(xnrodoc, xtipo: String): String;
// Objetivo...: Verificar Estado del Bloqueo
begin
  if BuscarBloqueo(xnrodoc, xtipo) then Result := bloqueo.FieldByName('usuario').AsString else Result := '';
end;

procedure TTEscalafonamiento.BorrarBloqueosUsuario(xusuario: String);
// Objetivo...: Verificar Estado del Bloqueo
begin
  datosdb.tranSQL('delete from bloqueos_es where usuario = ' + '''' + xusuario + '''');
  datosdb.closeDB(bloqueo); bloqueo.Open;
end;

procedure TTEscalafonamiento.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  materia.conectar;
  tablaes.conectar;
  docente.conectar;
  if conexiones = 0 then Begin
    if not inscripcion.Active then inscripcion.Open;
    if not tabla1.Active then tabla1.Open;
    if not tabla2.Active then tabla2.Open;
    if not puntaje.Active then puntaje.Open;
    if not puntositems.Active then puntositems.Open;
    if not desestimaciones.Active then desestimaciones.Open;
    if not topesescalafon.Active then topesescalafon.Open;
    if not tabla4.Active then tabla4.Open;
    if not tabla5.Active then tabla5.Open;
    if not bloqueo.Active then bloqueo.Open;
  end;
  Inc(conexiones);
end;

procedure TTEscalafonamiento.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  materia.desconectar;
  tablaes.desconectar;
  docente.desconectar;
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(inscripcion);
    datosdb.closeDB(tabla1);
    datosdb.closeDB(tabla2);
    datosdb.closeDB(puntaje);
    datosdb.closeDB(puntositems);
    datosdb.closeDB(desestimaciones);
    datosdb.closeDB(topesescalafon);
    datosdb.closeDB(tabla4);
    datosdb.closeDB(tabla5);
    datosdb.closeDB(bloqueo);
  end;
end;

{===============================================================================}

function escalafon: TTEscalafonamiento;
begin
  if xescalafon = nil then
    xescalafon := TTEscalafonamiento.Create;
  Result := xescalafon;
end;

{===============================================================================}

initialization

finalization
  xescalafon.Free;

end.
