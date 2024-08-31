unit CPersonasPreveer_Sepelios;

interface

uses CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM, CCodPost;

type

TTPersonasSepelio = class
  Nrodoc, Nrodoctit, Nombre, Direccion, Telefono, FechaNac, Email, Estudiante, Certificado, Cp, Orden, Localidad, Incapacitado: String;
  tperso: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xNrodoc, xNrodoctit: string): boolean;
  procedure   Grabar(xNrodoc, xNrodoctit, xnombre, xdomicilio, xcp, xorden, xfechanac, xtelefono, xemail, xestudiante, xcertificado, xincapacitado: String);
  procedure   Borrar(xNrodoc, xNrodoctit: string); overload;
  procedure   Borrar(xnrodoc: String); overload;
  procedure   getDatos(xNrodoc, xNrodoctit: string);

  function    setPersonasACargo(NroDocTitular: String): TQuery;

  procedure   Filtrar(NroDocTitular: String);
  procedure   QuitarFiltro;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function tercerossep: TTPersonasSepelio;

implementation

var
  xtersep: TTPersonasSepelio = nil;

constructor TTPersonasSepelio.Create;
begin
  tperso := datosdb.openDB('hijos', 'Nrodoc', '', dbs.DirSistema + '\sepelio');
end;

destructor TTPersonasSepelio.Destroy;
begin
  inherited Destroy;
end;

function  TTPersonasSepelio.Buscar(xNrodoc, xNrodoctit: string): boolean;
// Objetivo...: Buscar una instancia
var
  Filtro: String;
begin
  Filtro := tperso.Filter;
  datosdb.QuitarFiltro(tperso);
  if tperso.IndexFieldNames <> 'Nrodoc;Nrodoctit' then tperso.IndexFieldNames := 'Nrodoc;Nrodoctit';
  Result := datosdb.Buscar(tperso, 'Nrodoc', 'Nrodoctit', xNrodoc, xNrodoctit);
  if Length(Trim(Filtro)) > 0 then datosdb.Filtrar(tperso, Filtro);
end;

procedure TTPersonasSepelio.Grabar(xNrodoc, xNrodoctit, xnombre, xdomicilio, xcp, xorden, xfechanac, xtelefono, xemail, xestudiante, xcertificado, xincapacitado: String);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xNrodoc, xNrodoctit) then tperso.Edit else tperso.Append;
  tperso.FieldByName('Nrodoc').AsString       := xNrodoc;
  tperso.FieldByName('Nrodoctit').AsString    := xNrodoctit;
  tperso.FieldByName('Nombre').AsString       := xNombre;
  tperso.FieldByName('Direccion').AsString    := xDomicilio;
  tperso.FieldByName('cp').AsString           := xcp;
  tperso.FieldByName('Orden').AsString        := xorden;
  tperso.FieldByName('fechanac').AsString     := utiles.sExprFecha(xfechanac);
  tperso.FieldByName('telefono').AsString     := xtelefono;
  tperso.FieldByName('email').AsString        := xemail;
  tperso.FieldByName('estudiante').AsString   := xestudiante;
  tperso.FieldByName('certificado').AsString  := xcertificado;
  tperso.FieldByName('incapacitado').AsString := xincapacitado;
  try
    tperso.Post
  except
    tperso.Cancel
  end;
  datosdb.refrescar(tperso);
end;

procedure TTPersonasSepelio.Borrar(xNrodoc, xNrodoctit: string);
// Objetivo...: Eliminar una instancia
Begin
  if Buscar(xNrodoc, xNrodoctit) then Begin
    tperso.Delete;
    getDatos(tperso.FieldByName('nrodoc').AsString, tperso.FieldByName('nrodoctit').AsString);
    datosdb.refrescar(tperso);
  end;
end;

procedure TTPersonasSepelio.Borrar(xnrodoc: string);
// Objetivo...: Borrar todos los hijos de un titular
begin
  datosdb.tranSQL(dbs.DirSistema + '\sepelio', 'DELETE FROM ' + tperso.TableName + ' WHERE nrodoctit = ' + '"' + xnrodoc + '"');
  datosdb.refrescar(tperso);
end;

procedure TTPersonasSepelio.getDatos(xNrodoc, xNrodoctit: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xNrodoc, xNrodoctit) then Begin
    Nrodoc       := TrimLeft(tperso.FieldByName('nrodoc').AsString);
    Nrodoctit    := TrimLeft(tperso.FieldByName('nrodoctit').AsString);
    Nombre       := TrimLeft(tperso.FieldByName('nombre').AsString);
    Direccion    := TrimLeft(tperso.FieldByName('direccion').AsString);
    cp           := TrimLeft(tperso.FieldByName('cp').AsString);
    orden        := TrimLeft(tperso.FieldByName('orden').AsString);
    FechaNac     := utiles.sFormatoFecha(tperso.FieldByName('fechanac').AsString);
    Telefono     := TrimLeft(tperso.FieldByName('telefono').AsString);
    Email        := TrimLeft(tperso.FieldByName('email').AsString);
    Estudiante   := TrimLeft(tperso.FieldByName('estudiante').AsString);
    Certificado  := TrimLeft(tperso.FieldByName('certificado').AsString);
    Incapacitado := TrimLeft(tperso.FieldByName('incapacitado').AsString);
    cpost.getDatos(cp, orden);
    Localidad  := cpost.localidad;
  end else Begin
    FechaNac := ''; Telefono := ''; Email := ''; Estudiante := ''; Nombre := ''; Direccion := ''; cp := ''; orden := ''; Localidad := ''; Certificado := ''; Incapacitado := 'N';
  end;
end;

function TTPersonasSepelio.setPersonasACargo(NroDocTitular: String): TQuery;
// Objetivo...: Devolver un set con los titulares
Begin
  Result := datosdb.tranSQL(dbs.DirSistema + '\sepelio', 'SELECT * FROM ' + tperso.TableName + ' WHERE nrodoctit = ' + '"' + nrodoctitular + '"' + ' ORDER BY Nombre');
end;

procedure TTPersonasSepelio.Filtrar(NroDocTitular: String);
// Objetivo...: Filtrar Hijos del Titular
begin
  if Length(Trim(NroDocTitular)) > 0 then datosdb.Filtrar(tperso, 'nrodoctit = ' + NroDocTitular) else datosdb.Filtrar(tperso, 'nrodoctit = ' + '-');
end;

procedure TTPersonasSepelio.QuitarFiltro;
// Objetivo...: Quitar Filtro
begin
  datosdb.QuitarFiltro(tperso);
end;

procedure TTPersonasSepelio.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    tperso.FieldByName('nrodoc').DisplayLabel := 'Nº Doc.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre y Apellido'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False; tperso.FieldByName('nrodoctit').Visible := False; tperso.FieldByName('fechanac').Visible := False;
    if not tperso.Active then tperso.Open;
  end;
  Inc(conexiones);
end;

procedure TTPersonasSepelio.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
  end;
end;

{===============================================================================}

function tercerossep: TTPersonasSepelio;
begin
  if xtersep = nil then
    xtersep := TTPersonasSepelio.Create;
  Result := xtersep;
end;

{===============================================================================}

initialization

finalization
  xtersep.Free;

end.
