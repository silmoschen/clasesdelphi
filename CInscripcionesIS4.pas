unit CInscripcionesIS4;

interface

uses CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM,
     CCarrerasIS4, CAlumnosIS4, Classes, CServers2000_Excel;

type

TTInscripciones = class
  subt1, subt2, subt3, Electro, RxTorax, RxColumna: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xperiodo, xidcarrera, xitems: String): Boolean;
  procedure   Registrar(xperiodo, xidcarrera, xitems, xnrodoc, xabona: String; xcantitems: Integer);
  procedure   Borrar(xperiodo, xidcarrera: String);
  procedure   RegistrarRequisitosEdFisica(xperiodo, xidcarrera, xitems, xelectro, xrxtorax, xrxcolumna: String);
  procedure   getRequisitosEdFisica(xperiodo, xidcarrera, xitems: String);

  function    setInscriptos(xperiodo, xidcarrera: String): TStringList;
  function    setInscriptosAlf(xperiodo, xidcarrera: String): TStringList;

  procedure   Listar(xperiodo, xidcarrera: String; salida: char);

  procedure   RegistrarPago(xperiodo, xidcarrera, xitems, xabona: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  fila: Integer; ffila: String;
  conexiones: shortint;
end;

function inscripcion: TTInscripciones;

implementation

var
  xinscripcion: TTInscripciones = nil;

constructor TTInscripciones.Create;
begin
  tabla := datosdb.openDB('inscriptos', '');
end;

destructor TTInscripciones.Destroy;
begin
  inherited Destroy;
end;

function  TTInscripciones.Buscar(xperiodo, xidcarrera, xitems: String): Boolean;
// Objetivo...: Recuperar una instancia
begin
  if tabla.IndexFieldNames <> 'periodo;idcarrera;items' then tabla.IndexFieldNames := 'periodo;idcarrera;items';
  Result := datosdb.Buscar(tabla, 'periodo', 'idcarrera', 'items', xperiodo, xidcarrera, xitems);
end;

procedure TTInscripciones.Registrar(xperiodo, xidcarrera, xitems, xnrodoc, xabona: String; xcantitems: Integer);
// Objetivo...: Registrar una instancia
begin
  if Buscar(xperiodo, xidcarrera, xitems) then tabla.Edit else tabla.Append;
  tabla.FieldByName('periodo').AsString   := xperiodo;
  tabla.FieldByName('idcarrera').AsString := xidcarrera;
  tabla.FieldByName('items').AsString     := xitems;
  tabla.FieldByName('nrodoc').AsString    := xnrodoc;
  tabla.FieldByName('abona').AsString     := xabona;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  if xitems = utiles.sLlenarIzquierda(IntToStr(xcantitems), 3, '0') then Begin
    datosdb.tranSQL('delete from inscriptos where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''' + ' and items > ' + '''' + xitems + '''');
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTInscripciones.Borrar(xperiodo, xidcarrera: String);
// Objetivo...: Borrar Items Carreras
Begin
  datosdb.tranSQL('delete from ' + tabla.TableName + ' where periodo = ' + '''' + xperiodo + '''' + ' and idcarrera = ' + '''' + xidcarrera + '''');
  datosdb.closeDB(tabla); tabla.Open;
end;

procedure TTInscripciones.RegistrarRequisitosEdFisica(xperiodo, xidcarrera, xitems, xelectro, xrxtorax, xrxcolumna: String);
// Objetivo...: Registrar Requisitos Educación Fisica
Begin
  if Buscar(xperiodo, xidcarrera, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('electro').AsString   := xelectro;
    tabla.FieldByName('rxtorax').AsString   := xrxtorax;
    tabla.FieldByName('rxcolumna').AsString := xrxcolumna;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.closeDB(tabla); tabla.Open;
  end;
end;

procedure TTInscripciones.getRequisitosEdFisica(xperiodo, xidcarrera, xitems: String);
// Objetivo...: Devolver Requisitos educación Fisica
begin
  if Buscar(xperiodo, xidcarrera, xitems) then Begin
    Electro   := tabla.FieldByName('electro').AsString;
    Rxtorax   := tabla.FieldByName('rxtorax').AsString;
    Rxcolumna := tabla.FieldByName('rxcolumna').AsString;
  end else Begin
    Electro := ''; rxtorax := ''; rxcolumna := '';
  end;
end;

function  TTInscripciones.setInscriptos(xperiodo, xidcarrera: String): TStringList;
// Objetivo...: Devolver un set
var
  l: TStringList;
begin
  l := TStringList.Create;
  if Buscar(xperiodo, xidcarrera, '001') then Begin
    while not tabla.Eof do Begin
      if (tabla.FieldByName('periodo').AsString <> xperiodo) or (tabla.FieldByName('idcarrera').AsString <> xidcarrera) then Break;
      l.Add(tabla.FieldByName('items').AsString + tabla.FieldByName('nrodoc').AsString + ';1' + tabla.FieldByName('abona').AsString);
      tabla.Next;
    end;
  end;
  Result := l;
end;

function  TTInscripciones.setInscriptosAlf(xperiodo, xidcarrera: String): TStringList;
// Objetivo...: Devolver un set
var
  l1, l2: TStringList;
  i, p: Integer;
begin
  l1 := TStringList.Create;
  l2 := TStringList.Create;
  if Buscar(xperiodo, xidcarrera, '001') then Begin
    while not tabla.Eof do Begin
      if (tabla.FieldByName('periodo').AsString <> xperiodo) or (tabla.FieldByName('idcarrera').AsString <> xidcarrera) then Break;
      alumno.getDatos(tabla.FieldByName('nrodoc').AsString);
      l1.Add(alumno.Apellido + ' ' + alumno.nombre + ';1' + tabla.FieldByName('items').AsString + tabla.FieldByName('nrodoc').AsString);
      tabla.Next;
    end;
  end;

  l1.Sort;
  For i := 1 to l1.Count do Begin
    p := Pos(';1', l1.Strings[i-1]);
    l2.Add(Copy(l1.Strings[i-1], p+2, 3) + Trim(Copy(l1.Strings[i-1], p+5, 10)) + ';1' + Copy(l1.Strings[i-1], 1, p-1));
  end;

  Result := l2;
end;

procedure TTInscripciones.Listar(xperiodo, xidcarrera: String; salida: char);
var
  l: TStringList;
  i, p: Integer;
Begin
  fila := 0;
  if salida <> 'X' then Begin
    list.Setear(salida);
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
    if Length(Trim(subt1)) > 0 then List.Titulo(0, 0, subt1, 1, 'Arial, negrita, 12');
    if Length(Trim(subt2)) > 0 then List.Titulo(0, 0, subt2, 1, 'Arial, negrita, 12');
    if Length(Trim(subt3)) > 0 then List.Titulo(0, 0, subt3, 1, 'Arial, negrita, 12');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, ' Listado Inscripciones a Carreras', 1, 'Arial, negrita, 14');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
    List.Titulo(0, 0, 'Nro.', 1, 'Arial, cursiva, 8');
    List.Titulo(5, list.Lineactual, 'Nro. Doc.', 2, 'Arial, cursiva, 8');
    List.Titulo(14, list.Lineactual, 'Apellido y Nombres', 3, 'Arial, cursiva, 8');
    List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
    List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
  end else Begin
    excel.setString('A1', 'A1', subt1, 'Arial, negrita, 10');
    excel.setString('A2', 'A2', subt2, 'Arial, negrita, 10');
    excel.setString('A3', 'A3', subt3, 'Arial, negrita, 10');
    excel.setString('B4', 'B4', 'Listado Inscripciones a Carreras', 'Arial, negrita, 12');
    excel.setString('D4', 'D4', 'Año Lectivo: ' + xperiodo, 'Arial, negrita, 12');
    excel.setString('A6', 'A6', 'Nro.', 'Arial, negrita, 10');
    excel.setString('B6', 'B6', 'Nro. Doc.', 'Arial, negrita, 9');
    excel.setString('C6', 'C6', 'Apellido y Nombres', 'Arial, negrita, 9');
    excel.setString('D6', 'D6', 'Nacionalidad', 'Arial, negrita, 9');
    excel.setString('E6', 'E6', 'F.Nac.', 'Arial, negrita, 9');
    excel.setString('F6', 'F6', 'E.Civil', 'Arial, negrita, 9');
    excel.setString('G6', 'G6', 'Lugar Nacimiento', 'Arial, negrita, 9');
    excel.setString('H6', 'H6', 'Altura', 'Arial, negrita, 9');
    excel.setString('I6', 'I6', 'Teléfono', 'Arial, negrita, 9');
    excel.setString('J6', 'J6', 'Barrio', 'Arial, negrita, 9');
    excel.setString('K6', 'K6', 'Residencia', 'Arial, negrita, 9');
    excel.setString('L6', 'L6', 'Título', 'Arial, negrita, 9');
    excel.setString('M6', 'M6', 'Expendido por', 'Arial, negrita, 9');
    excel.setString('N6', 'N6', 'Adeuda Mat?', 'Arial, negrita, 9');
    excel.setString('O6', 'O6', 'Trabaja?', 'Arial, negrita, 9');
    excel.setString('P6', 'P6', 'Dom. de Trabajo', 'Arial, negrita, 9');
    excel.setString('Q6', 'Q6', 'Tel.Trab.', 'Arial, negrita, 9');
    excel.setString('R6', 'R6', 'Oficio', 'Arial, negrita, 9');
    excel.setString('S6', 'S6', 'Horarios', 'Arial, negrita, 9');

    fila := 7;
    excel.FijarAnchoColumna('A1', 'A1', 5);
    excel.FijarAnchoColumna('B1', 'B1', 10);
    excel.FijarAnchoColumna('C1', 'C1', 32);
    excel.FijarAnchoColumna('D1', 'D1', 20);
    excel.FijarAnchoColumna('E1', 'E1', 10);
    excel.FijarAnchoColumna('G1', 'G1', 20);
    excel.FijarAnchoColumna('H1', 'H1', 20);
    excel.FijarAnchoColumna('J1', 'J1', 30);
    excel.FijarAnchoColumna('K1', 'K1', 30);
    excel.FijarAnchoColumna('L1', 'L1', 30);
    excel.FijarAnchoColumna('M1', 'M1', 30);
    excel.FijarAnchoColumna('O1', 'O1', 10);
    excel.FijarAnchoColumna('P1', 'P1', 30);
    excel.FijarAnchoColumna('Q1', 'Q1', 20);
    excel.FijarAnchoColumna('R1', 'R1', 20);
    excel.FijarAnchoColumna('S1', 'S1', 20);
  end;

  carrera.getDatos(xidcarrera);
  if salida <> 'X' then Begin
    list.Linea(0, 0, 'Carrera: ' + carrera.Carrera, 1, 'Arial, negrita, 12', salida, 'N');
    list.Linea(80, list.Lineactual, 'Año Lectivo: ' + xperiodo, 3, 'Arial, negrita, 12', salida, 'S');
    list.Linea(0, 0, '', 1, 'Arial, normal, 5', salida, 'S');
  end else Begin
    Inc(fila); ffila := IntToStr(fila);
    excel.setString('A' + ffila, 'A' + ffila, 'Carrera: ' + carrera.Carrera, 'Arial, negrita, 10');
    Inc(fila);
  end;

  l := setInscriptosAlf(xperiodo, xidcarrera);
  For i := 1 to l.Count do Begin
    p := Pos(';1', l.Strings[i-1]);
    if salida <> 'X' then Begin
      list.Linea(0, 0, utiles.sLlenarIzquierda(IntToStr(i), 3, '0'), 1, 'Arial, normal, 8', salida, 'N');
      list.Linea(5, list.Lineactual, Copy(l.Strings[i-1], 4, p-4), 2, 'Arial, normal, 8', salida, 'N');
      list.Linea(14, list.Lineactual, Copy(l.Strings[i-1], p+2, 50), 3, 'Arial, normal, 8', salida, 'S');
    end else Begin
      Inc(fila); ffila := IntToStr(fila);
      alumno.getDatos(Copy(l.Strings[i-1], 4, p-4));
      excel.setString('A' + ffila, 'A' + ffila, utiles.sLlenarIzquierda(IntToStr(i), 3, '0'), 'Arial, normal, 8');
      excel.setString('B' + ffila, 'B' + ffila, '''' + Copy(l.Strings[i-1], 4, p-4), 'Arial, normal, 8');
      excel.setString('C' + ffila, 'C' + ffila, Copy(l.Strings[i-1], p+2, 50), 'Arial, normal, 8');
      excel.setString('D' + ffila, 'D' + ffila, alumno.Nacionalidad, 'Arial, normal, 8');
      excel.setString('E' + ffila, 'E' + ffila, '''' + alumno.FechaNac, 'Arial, normal, 8');
      excel.setString('F' + ffila, 'F' + ffila, alumno.Estcivil, 'Arial, normal, 8');
      excel.setString('G' + ffila, 'G' + ffila, alumno.Lugarnac, 'Arial, normal, 8');
      excel.setString('H' + ffila, 'H' + ffila, alumno.Altura, 'Arial, normal, 8');
      excel.setString('I' + ffila, 'I' + ffila, alumno.Telefono, 'Arial, normal, 8');
      excel.setString('J' + ffila, 'J' + ffila, alumno.Barrio, 'Arial, normal, 8');
      excel.setString('K' + ffila, 'K' + ffila, alumno.Residencia, 'Arial, normal, 8');
      excel.setString('L' + ffila, 'L' + ffila, alumno.Titulo, 'Arial, normal, 8');
      excel.setString('M' + ffila, 'M' + ffila, alumno.Expendido, 'Arial, normal, 8');
      excel.setString('N' + ffila, 'N' + ffila, alumno.Adeudaasig, 'Arial, normal, 8');
      excel.setString('O' + ffila, 'O' + ffila, alumno.Trabaja, 'Arial, normal, 8');
      excel.setString('P' + ffila, 'P' + ffila, alumno.Domtrab, 'Arial, normal, 8');
      excel.setString('Q' + ffila, 'Q' + ffila, alumno.Teltrab, 'Arial, normal, 8');
      excel.setString('R' + ffila, 'R' + ffila, alumno.Oficio, 'Arial, normal, 8');
      excel.setString('S' + ffila, 'S' + ffila, alumno.Horarios, 'Arial, normal, 8');
    end;
  end;

  if salida <> 'X' then list.FinList else Begin
    excel.setString('A9', 'A9', '', 'Arial, normal, 8');
    excel.Visulizar;
  end;
end;

procedure TTInscripciones.RegistrarPago(xperiodo, xidcarrera, xitems, xabona: String);
// Objetivo...: registrar si abona
Begin
  if Buscar(xperiodo, xidcarrera, xitems) then Begin
    tabla.Edit;
    tabla.FieldByName('abona').AsString := xabona;
    try
      tabla.Post
     except
      tabla.Cancel
    end;
    datosdb.refrescar(tabla);
  end;
end;

procedure TTInscripciones.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla);
  end;
  Inc(conexiones);
  carrera.conectar;
  alumno.conectar;
end;

procedure TTInscripciones.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    if not tabla.Active then tabla.Open;
  end;
  carrera.desconectar;
  alumno.desconectar;
end;

{===============================================================================}

function inscripcion: TTInscripciones;
begin
  if xinscripcion = nil then
    xinscripcion := TTInscripciones.Create;
  Result := xinscripcion;
end;

{===============================================================================}

initialization

finalization
  xinscripcion.Free;

end.
