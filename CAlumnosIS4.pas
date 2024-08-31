unit CAlumnosIS4;

interface

uses CPersona, CBDT, SysUtils, DBTables, CUtiles, CListar, CIDBFM;

type

TTAlumno = class(TTPersona)
  Apellido, Nacionalidad, FechaNac, Estcivil, Lugarnac, Altura, Telefono, Barrio,
  Residencia, Titulo, Expendido, Adeudaasig, Cuantas, Trabaja, Domtrab, Cptrab,
  Ordentrab, Teltrab, Oficio, Horarios, Abona: String;
  tabla: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnrodoc: String): Boolean;
  procedure   Registrar(xnrodoc, xapellido, xnombre, xdireccion, xcp, xorden,
              xnacionalidad, xfechaNac, xEstcivil, xLugarnac, xAltura, xTelefono, xBarrio, xResidencia,
              xTitulo, xExpendido, xAdeudaasig, xCuantas, xTrabaja, xDomicilio, xCptrab, xOrdentrab,
              xTeltrab, xOficio, xHorarios: String);
  procedure   getDatos(xnrodoc: String);
  procedure   Borrar(xnrodoc: String);

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function alumno: TTAlumno;

implementation

var
  xalumno: TTAlumno = nil;

constructor TTAlumno.Create;
begin
  tperso := datosdb.openDB('alumnos', '');
  tabla  := datosdb.openDB('alumnosh', '');
end;

destructor TTAlumno.Destroy;
begin
  inherited Destroy;
end;

function  TTAlumno.Buscar(xnrodoc: String): Boolean;
// Objetivo...: Buscar instancia del objeto
begin
  if tabla.IndexFieldNames <> 'nrodoc' then tabla.IndexFieldNames := 'nrodoc';
  Result := tabla.FindKey([xnrodoc]);
  inherited Buscar(xnrodoc);
end;

procedure TTAlumno.Registrar(xnrodoc, xapellido, xnombre, xdireccion, xcp, xorden,
            xnacionalidad, xfechaNac, xEstcivil, xLugarnac, xAltura, xTelefono, xBarrio, xResidencia,
            xTitulo, xExpendido, xAdeudaasig, xCuantas, xTrabaja, xDomicilio, xCptrab, xOrdentrab,
            xTeltrab, xOficio, xHorarios: String);
// Objetivo...: Registrar instancia del objeto
begin
  inherited GrabarApNombre(xnrodoc, xapellido, xnombre, xdireccion, xcp, xorden);
  if Buscar(xnrodoc) then tabla.Edit else tabla.Append;
  tabla.FieldByName('nrodoc').AsString       := xnrodoc;
  tabla.FieldByName('nacionalidad').AsString := xnacionalidad;
  tabla.FieldByName('fechanac').AsString     := utiles.sExprFecha2000(xfechanac);
  tabla.FieldByName('estcivil').AsString     := xestcivil;
  tabla.FieldByName('lugarnac').AsString     := xlugarnac;
  tabla.FieldByName('altura').AsString       := xaltura;
  tabla.FieldByName('telefono').AsString     := xtelefono;
  tabla.FieldByName('barrio').AsString       := xbarrio;
  tabla.FieldByName('residencia').AsString   := xresidencia;
  tabla.FieldByName('titulo').AsString       := xtitulo;
  tabla.FieldByName('expendido').AsString    := xexpendido;
  tabla.FieldByName('adeudaasig').AsString   := xadeudaasig;
  tabla.FieldByName('cuantas').AsString      := xcuantas;
  tabla.FieldByName('trabaja').AsString      := xtrabaja;
  tabla.FieldByName('domicilio').AsString    := xdomicilio;
  tabla.FieldByName('cptrab').AsString       := xcptrab;
  tabla.FieldByName('ordentrab').AsString    := xordentrab;
  tabla.FieldByName('teltrab').AsString      := xteltrab;
  tabla.FieldByName('oficio').AsString       := xoficio;
  tabla.FieldByName('horarios').AsString     := xhorarios;
  try
    tabla.Post
   except
    tabla.Cancel
  end;
  datosdb.closedb(tabla); tabla.Open;
end;

procedure TTAlumno.getDatos(xnrodoc: String);
// Objetivo...: Recuperar instancia del objeto
begin
  inherited getDatosApNombre(xnrodoc);
  if Buscar(xnrodoc) then Begin
    apellido     := tperso.FieldByName('apellido').AsString;
    nacionalidad := tabla.FieldByName('nacionalidad').AsString;
    fechanac     := utiles.sFormatoFecha(tabla.FieldByName('fechanac').AsString);
    estcivil     := tabla.FieldByName('estcivil').AsString;
    lugarnac     := tabla.FieldByName('lugarnac').AsString;
    altura       := tabla.FieldByName('altura').AsString;
    telefono     := tabla.FieldByName('telefono').AsString;
    barrio       := tabla.FieldByName('barrio').AsString;
    residencia   := tabla.FieldByName('residencia').AsString;
    titulo       := tabla.FieldByName('titulo').AsString;
    expendido    := tabla.FieldByName('expendido').AsString;
    adeudaasig   := tabla.FieldByName('adeudaasig').AsString;
    cuantas      := tabla.FieldByName('cuantas').AsString;
    trabaja      := tabla.FieldByName('trabaja').AsString;
    domtrab      := tabla.FieldByName('domicilio').AsString;
    cptrab       := tabla.FieldByName('cptrab').AsString;
    ordentrab    := tabla.FieldByName('ordentrab').AsString;
    teltrab      := tabla.FieldByName('teltrab').AsString;
    oficio       := tabla.FieldByName('oficio').AsString;
    horarios     := tabla.FieldByName('horarios').AsString;
  end else Begin
    apellido := ''; nacionalidad := ''; fechanac := ''; estcivil := ''; lugarnac := ''; altura := '';
    barrio := ''; residencia := ''; titulo := ''; expendido := ''; adeudaasig := '';
    cuantas := ''; trabaja := ''; domicilio := ''; cptrab := ''; ordentrab := ''; teltrab := '';
    oficio := ''; horarios := ''; telefono := '';
  end;
end;

procedure TTAlumno.Borrar(xnrodoc: String);
// Objetivo...: Borrar instancia del objeto
begin
  {if Buscar(xnrodoc) then Begin
    tabla.Delete;
    inherited Borrar(xnrodoc);
    datosdb.refrescar(tperso);
    datosdb.refrescar(tabla);
  end;}
end;

procedure TTAlumno.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla.Active then tabla.Open;
  end;
  Inc(conexiones);
end;

procedure TTAlumno.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso); 
    datosdb.closeDB(tabla);
  end;
end;

{===============================================================================}

function alumno: TTAlumno;
begin
  if xalumno = nil then
    xalumno := TTAlumno.Create;
  Result := xalumno;
end;

{===============================================================================}

initialization

finalization
  xalumno.Free;

end.
