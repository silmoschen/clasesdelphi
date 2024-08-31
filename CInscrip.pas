unit CInscrip;

interface

uses CCInscr, CAlumno, CDefCurs, SysUtils, DB, DBTables, CBDT, CIDBFM, CListar;

type

TTInscrip = class(TObject)            // Superclase
  idalumno, codcurso: string;
  tinscrip: TTable;
 public
  { Declaraciones Públicas }
  constructor Create(xidalumno, xcodcurso: string);
  destructor  Destroy; override;

  function    getidalumno: string;
  function    getcodcurso: string;
  function    getCurso: string;
  function    getFeinicio: string;
  function    getFefinal: string;
  function    getObservac: string;
  function    getProfesor: string;
  function    getAlumno: string;

  function    Grabar(xidalumno, xcodcurso: string): boolean;
  procedure   Borrar(xidalumno, xcodcurso: string);
  function    Buscar(xidalumno, xcodcurso: string): boolean;
  procedure   getDatos(xidalumno, xcodcurso: string);
  function    setInscriptos(idcurso: string): TQuery;
  function    setCursos(idalumno: string): TQuery;

  procedure   Depurar;
  function    getCantInscriptos(idcurso: string): integer;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char); overload;
  procedure   Listar(orden, iniciar, finalizar, ent_excl, xfecha: string; salida: char; t: byte); overload;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  cantins   : integer;
  idanterior: string;
  saldo     : real;
  procedure   List_linea(salida: char); overload;
  procedure   List_linea(xfecha: string; salida: char); overload;
  procedure   Listcantinscr(salida: char);
end;

function inscrip: TTInscrip;

implementation

var
  xinscrip: TTInscrip = nil;

constructor TTInscrip.Create(xidalumno, xcodcurso: string);
begin
  inherited Create;
  idalumno := xidalumno;
  codcurso := xcodcurso;

  tinscrip := datosdb.openDB('inscrip.DB', 'Codcurso;Idalumno');
end;

destructor TTInscrip.Destroy;
begin
  inherited Destroy;
end;

function TTInscrip.getidalumno: string;
// Objetivo....: Retornar Cod. marca
begin
  Result := idalumno;
end;

function TTInscrip.getcodcurso: string;
// Objetivo...: Retornar codcursoción
begin
  Result := codcurso;
end;

function TTInscrip.getFeinicio: string;
begin
  Result := defcurso.getFeinicio;
end;

function TTInscrip.getFefinal: string;
begin
  Result := defcurso.getFefinal;
end;

function TTInscrip.getObservac: string;
begin
  Result := defcurso.getObservac;
end;

function TTInscrip.getProfesor: string;
begin
  Result := defcurso.getProfesor;
end;

function TTInscrip.getCurso: string;
begin
  Result := defcurso.getCurso;
end;

function TTInscrip.getAlumno: string;
begin
  Result := alumno.getNombre;
end;

function TTInscrip.Grabar(xidalumno, xcodcurso: string): boolean;
// Objetivo...: Grabar Atributos del Objeto
begin
  try
    if Buscar(xidalumno, xcodcurso) then tinscrip.Edit else tinscrip.Append;
    tinscrip.FieldByName('idalumno').Value := xidalumno;
    tinscrip.FieldByName('codcurso').Value  := xcodcurso;
    tinscrip.Post;
    Result := True;
  finally
    Result := False;
  end;
end;

procedure TTInscrip.Borrar(xidalumno, xcodcurso: string);
// Objetivo...: Eliminar un Objeto
begin
  ccins.BorrarDet(xcodcurso, xidalumno); // Anulamos todos los movimientos asociados
  if Buscar(xidalumno, xcodcurso) then
    begin
      tinscrip.Delete;
      getDatos(tinscrip.FieldByName('idalumno').AsString, tinscrip.FieldByName('codcurso').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
    end;
end;

function TTInscrip.Buscar(xidalumno, xcodcurso: string): boolean;
// Objetivo...: Buscar el Objeto solicitado
begin
  if not tinscrip.Active then conectar;
  Result := datosdb.Buscar(tinscrip, 'idalumno', 'codcurso', xidalumno, xcodcurso);
end;

procedure  TTInscrip.getDatos(xidalumno, xcodcurso: string);
// Objetivo...: Retornar/Iniciar Atributos
begin
  if Buscar(xidalumno, xcodcurso) then
    begin
      idalumno  := tinscrip.FieldByName('idalumno').Value;
      codcurso   := tinscrip.FieldByName('codcurso').Value;
      defcurso.getDatos(xcodcurso);   // Actualizamos los atributos de la clase con la información de los cursos
      alumno.getDatos(xidalumno);     // Actualizamos los atributos de la clase con la información de los alumnos
    end
   else
    begin
      idalumno := ''; codcurso := '';
    end;
end;

function TTInscrip.setInscriptos(idcurso: string): TQuery;
// Objetivo...: Devolver un set con los inscrips definidos
begin
  Result := datosdb.tranSQL('SELECT inscrip.idalumno AS Id, alumnos.Nombre FROM inscrip, alumnos WHERE inscrip.idalumno = alumnos.idalumno AND inscrip.codcurso = ' + '''' + idcurso + '''' + ' ORDER BY alumnos.Nombre');
end;

function TTInscrip.setCursos(idalumno: string): TQuery;
// Objetivo...: Devolver un set con los inscrips definidos
begin
  Result := datosdb.tranSQL('SELECT inscrip.codcurso, cursos.descrip, dias.inicio, dias.fin, horario.inicio, horario.fin, profesor.nombre, defcurso.observac FROM inscrip, defcurso, cursos, dias, horario, profesor ' +
                            'WHERE inscrip.idalumno = ' + '''' + idalumno + '''' +
                            ' AND inscrip.codcurso = defcurso.codcurso AND defcurso.idcurso = cursos.idcurso AND defcurso.iddias = dias.iddias AND defcurso.idhorario = horario.idhorario AND defcurso.nrolegajo = profesor.nrolegajo');
end;

procedure TTInscrip.Depurar;
// Objetivo...: coordinar la depuración de Inscriptos de los cursos que fueron cerrados
var
  r: TQuery;
begin
  r := defcurso.setCursosCerrados;
  r.Open; r.First;
  while not r.EOF do
    begin
      if ccins.VerifMovimiento(r.FieldByName('codcurso').AsString) then   // Si el curso no tiene nigun pago pendiente ...
        begin
          defcurso.Borrar(r.FieldByName('codcurso').AsString);  // Elimino el Curso Cerrado
          datosdb.tranSQL('DELETE FROM inscrip WHERE codcurso = ' + '''' + r.FieldByName('codcurso').AsString + '''');  // Elimino los inscriptos para ese curso
        end;
      r.Next;
    end;
end;

function TTInscrip.getCantInscriptos(idcurso: string): integer;
// Objetivo...: devolver la cantidad de inscripciones para un curso dado
begin
  datosdb.tranSQL('SELECT inscrip.idalumno FROM inscrip WHERE inscrip.Codcurso = ' + '''' + idcurso + '''');
  datosdb.setSQL.Open; Result := datosdb.setSQL.RecordCount; datosdb.setSQL.Close;
end;

procedure TTInscrip.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  defcurso.getDatos(tinscrip.FieldByName('codcurso').AsString);
  if tinscrip.FieldByName('codcurso').AsString <> idanterior then
    begin
      if cantins > 0 then Listcantinscr(salida);
      if Length(trim(idanterior)) > 0 then List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, 'Curso :  ' + tinscrip.FieldByName('codcurso').AsString, 1, 'Arial, negrita, 8', salida, 'N');
      List.Linea(15, list.lineactual, defcurso.getIdcurso, 2, 'Arial, negrita, 8', salida, 'N');
      List.Linea(20, list.lineactual, defcurso.getDescrip(defcurso.getIdcurso), 3, 'Arial, negrita, 8', salida, 'N');
      List.Linea(70, list.lineactual, 'Inicio/Final. : ' + defcurso.getFeinicio + ' - ' + defcurso.getFefinal, 4, 'Arial, negrita, 8', salida, 'S');
    end;
  alumno.getDatos(tinscrip.FieldByName('idalumno').AsString);
  List.Linea(0, 0, tinscrip.FieldByName('idalumno').AsString + '  ' + alumno.getNombre, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(50, list.lineactual, alumno.getDomicilio, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, list.lineactual, alumno.getTelefono, 3, 'Arial, normal, 8', salida, 'S');

  Inc(cantins);
  idanterior := tinscrip.FieldByName('codcurso').AsString;
end;

procedure TTInscrip.Listcantinscr(salida: char);
// Objetivo...: Listar cantidad de Inscriptos por Curso
begin
  List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  List.Linea(0, 0, 'Cantidad de Inscriptos:  ' + IntToStr(cantins), 1, 'Arial, cursiva, 8', salida, 'S');
  List.Linea(0, 0, list.Linealargopagina(salida), 1, 'Arial, normal, 11', salida, 'S');
  List.Linea(0, 0, '  ', 1, 'Arial, normal, 5', salida, 'S');
  cantins := 0;
end;

procedure TTInscrip.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Inscripciones
begin

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Inscripciones', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Nombre y Apellido', 1, 'Arial, cursiva, 8');
  List.Titulo(40,  List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(70,  List.lineactual, 'Teléfono', 3, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tinscrip.First; cantins := 0;
  while not tinscrip.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tinscrip.FieldByName('codcurso').AsString >= iniciar) and (tinscrip.FieldByName('codcurso').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tinscrip.FieldByName('codcurso').AsString < iniciar) or (tinscrip.FieldByName('codcurso').AsString > finalizar) then List_linea(salida);

      tinscrip.Next;
    end;
    if cantins > 0 then Listcantinscr(salida);
    List.FinList;

    tinscrip.First;
end;

procedure TTInscrip.List_linea(xfecha: string; salida: char);
// Objetivo...: Listar una Línea
var
  fc: string;
begin
  defcurso.getDatos(tinscrip.FieldByName('codcurso').AsString);
  if tinscrip.FieldByName('codcurso').AsString <> idanterior then
    begin
      if Length(Trim(defcurso.getFecierre)) > 4 then fc := defcurso.getFecierre else fc := 'Activo';
      if cantins > 0 then Listcantinscr(salida);
      if Length(trim(idanterior)) > 0 then List.Linea(0, 0, ' ', 1, 'Arial, negrita, 5', salida, 'S');
      List.Linea(0, 0, 'Curso :  ' + tinscrip.FieldByName('codcurso').AsString, 1, 'Arial, negrita, 8', salida, 'N');
      List.Linea(15, list.lineactual, defcurso.getIdcurso, 2, 'Arial, negrita, 8', salida, 'N');
      List.Linea(20, list.lineactual, defcurso.getDescrip(defcurso.getIdcurso), 3, 'Arial, negrita, 8', salida, 'N');
      List.Linea(60, list.lineactual, 'Inicio/Final. : ' + defcurso.getFeinicio + ' - ' + defcurso.getFefinal, 4, 'Arial, negrita, 8', salida, 'N');
      List.Linea(85, list.lineactual, 'Profesor : ' + defcurso.getProfesor, 5, 'Arial, negrita, 8', salida, 'N');
      List.Linea(120, list.lineactual, 'Fecha de Cierre : ' + fc, 6, 'Arial, negrita, 8', salida, 'S');
    end;
  alumno.getDatos(tinscrip.FieldByName('idalumno').AsString);
  List.Linea(0, 0, tinscrip.FieldByName('idalumno').AsString + '  ' + alumno.getNombre, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, list.lineactual,  alumno.getDomicilio, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(70, list.lineactual,  alumno.getTelefono, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, list.lineactual,  alumno.getNrodoc, 4, 'Arial, normal, 8', salida, 'N');
  List.Linea(92, list.lineactual,  alumno.getOfenroladora, 5, 'Arial, normal, 8', salida, 'N');
  List.Linea(114, list.lineactual, alumno.getFechanac, 6, 'Arial, normal, 8', salida, 'N');
  List.Linea(130, list.lineactual, ccins.getUltimoPago, 7, 'Arial, normal, 8', salida, 'N');
  List.importe(150, list.lineactual, '', saldo, 8, 'Arial, normal, 8');
  List.Linea(155, list.lineactual, '', 5, 'Arial, normal, 9', salida, 'S');

  Inc(cantins);
  idanterior := tinscrip.FieldByName('codcurso').AsString;
end;

procedure TTInscrip.Listar(orden, iniciar, finalizar, ent_excl, xfecha: string; salida: char; t: byte);
// Objetivo...: Listar Datos de Cursos Finalizados
var
  listok: boolean;
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Estado de Cursos y Cuotas', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.  Nombre y Apellido', 1, 'Arial, cursiva, 8');
  List.Titulo(40,  List.lineactual, 'Domicilio', 2, 'Arial, cursiva, 8');
  List.Titulo(70,  List.lineactual, 'Teléfono', 3, 'Arial, cursiva, 8');
  List.Titulo(85,  List.lineactual, 'Nro.Doc.', 4, 'Arial, cursiva, 8');
  List.Titulo(95,  List.lineactual, 'Of. Enroladora', 5, 'Arial, cursiva, 8');
  List.Titulo(114, List.lineactual, 'Fe.Nac.', 6, 'Arial, cursiva, 8');
  List.Titulo(130, List.lineactual, 'Últ.Pago', 7, 'Arial, cursiva, 8');
  List.Titulo(145, List.lineactual, 'Saldo', 8, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tinscrip.First; cantins := 0;
  while not tinscrip.EOF do
    begin
      saldo := ccins.getSaldo(tinscrip.FieldByName('idalumno').AsString, xfecha);

      listok := False;
      if t = 1 then listok := True;
      if (t = 2) and (saldo <> 0) then listok := True;
      if (t = 3) and (saldo = 0)  then listok := True;

      // Ordenado por Código
      if listok then
        begin
          if (ent_excl = 'E') and (orden = 'C') then
            if (tinscrip.FieldByName('codcurso').AsString >= iniciar) and (tinscrip.FieldByName('codcurso').AsString <= finalizar) then List_linea(xfecha, salida);
          if (ent_excl = 'X') and (orden = 'C') then
            if (tinscrip.FieldByName('codcurso').AsString < iniciar) or (tinscrip.FieldByName('codcurso').AsString > finalizar) then List_linea(xfecha, salida);
        end;

      tinscrip.Next;
    end;
    if cantins > 0 then Listcantinscr(salida);
    List.FinList;

    tinscrip.First;
end;

procedure TTInscrip.conectar;
// Objetivo...: Abrir tablas de persistencia
var
  i: integer;
begin
  tinscrip.Open;
  tinscrip.FieldByName('idalumno').DisplayLabel := 'Id. Alumno'; tinscrip.FieldByName('codcurso').DisplayLabel := 'Id. Curso';
  alumno.conectar;
  defcurso.conectar;
end;

procedure TTInscrip.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  datosdb.closeDB(tinscrip);
  alumno.desconectar;
  defcurso.desconectar;
end;

{===============================================================================}

function inscrip: TTInscrip;
begin
  if xinscrip = nil then
    xinscrip := TTInscrip.Create('', '');
  Result := xinscrip;
end;

{===============================================================================}

initialization

finalization
  xinscrip.Free;

end.
