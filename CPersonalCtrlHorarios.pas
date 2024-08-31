unit CPersonalCtrlHorarios;

interface

uses CPersona, CBDT, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTPersonalCtrlHorarios = class(TTPersona)
  Telefono, Clave: String; salario: Real;
  tpersonal: TTable;
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;

  function    Buscar(xnrodoc: string): Boolean;
  procedure   Grabar(xnrodoc, xnombre, xdireccion, xtelefono, xclave: String; xsalario: Real);
  procedure   Borrar(xnrodoc: String);
  procedure   getDatos(xnrodoc: string);

  procedure   BuscarPorNroDocumento(xexpr: string);
  procedure   BuscarPorNombre(xexpr: string);
  function    verificarClavePersonal(xclave: String): Boolean;

  function    setPersonalAlf: TQuery;

  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  
  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
  procedure   List_Tit(salida: char);
end;

function personal: TTPersonalCtrlHorarios;

implementation

var
  xpersonal: TTPersonalCtrlHorarios = nil;

constructor TTPersonalCtrlHorarios.Create;
begin
  tperso    := datosdb.openDB('personal', '');
  tpersonal := datosdb.openDB('personalh', '');
end;

destructor TTPersonalCtrlHorarios.Destroy;
begin
  inherited Destroy;
end;

function  TTPersonalCtrlHorarios.Buscar(xnrodoc: string): Boolean;
// Objetivo...: Buscar una instancia
begin
  if tpersonal.IndexFieldNames <> 'Nrodoc' then tpersonal.IndexFieldNames := 'Nrodoc';
  if tperso.IndexFieldNames <> 'Nrodoc' then tperso.IndexFieldNames := 'Nrodoc';
  inherited Buscar(xnrodoc);
  Result := tpersonal.FindKey([xnrodoc]);
end;

procedure TTPersonalCtrlHorarios.Grabar(xnrodoc, xnombre, xdireccion, xtelefono, xclave: String; xsalario: Real);
// Objetivo...: Almacenar una instacia de la clase
begin
  if Buscar(xnrodoc) then tpersonal.Edit else tpersonal.Append;
  tpersonal.FieldByName('nrodoc').AsString    := xnrodoc;
  tpersonal.FieldByName('telefono').AsString  := xtelefono;
  tpersonal.FieldByName('clave').AsString     := xclave;
  tpersonal.FieldByName('salario').AsFloat    := xsalario;
  try
    tpersonal.Post
  except
    tpersonal.Cancel
  end;
  inherited Grabar(xnrodoc, xnombre, xdireccion, '', '');
end;

procedure TTPersonalCtrlHorarios.Borrar(xnrodoc: String);
// Objetivo...: Eliminar una instancia
begin
  if Buscar(xnrodoc) then Begin
    inherited Borrar(xnrodoc);
    tpersonal.Delete;
    getDatos(tpersonal.FieldByName('nrodoc').AsString);
  end;
end;

procedure TTPersonalCtrlHorarios.getDatos(xnrodoc: string);
// Objetivo...: Cargar/iniciar los atributos para una instancia
begin
  if Buscar(xnrodoc) then Begin
    telefono  := tpersonal.FieldByName('telefono').AsString;
    salario   := tpersonal.FieldByName('salario').AsFloat;
    clave     := tpersonal.FieldByName('clave').AsString;
  end else Begin
    telefono := ''; salario := 0; clave := '';
  end;
  inherited getDatos(xnrodoc);
end;

procedure TTPersonalCtrlHorarios.List_Tit(salida: char);
// Objetivo...: Listar una Línea
begin
  list.Setear(salida);
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Nómina de Personal', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Nº Doc.', 1, 'Arial, cursiva, 8');
  List.Titulo(10, list.Lineactual, 'Nombre', 2, 'Arial, cursiva, 8');
  List.Titulo(40, list.Lineactual, 'Dirección', 3, 'Arial, cursiva, 8');
  List.Titulo(67, list.Lineactual, 'Teléfono', 4, 'Arial, cursiva, 8');
  List.Titulo(92, list.Lineactual, 'Salario', 5, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTPersonalCtrlHorarios.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  tpersonal.FindKey([tperso.FieldByName('nrodoc').AsString]);
  List.Linea(0, 0, tpersonal.FieldByName('nrodoc').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(10, list.Lineactual, tperso.FieldByName('nombre').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, list.Lineactual, tperso.FieldByName('direccion').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(67, list.Lineactual, tpersonal.FieldByName('telefono').AsString, 4, 'Arial, normal, 8', salida, 'N');
  List.importe(97, list.Lineactual, '', tpersonal.FieldByName('salario').AsFloat, 5, 'Arial, normal, 8');
  List.Linea(98, list.Lineactual, ' ', 6, 'Arial, normal, 8', salida, 'S');
end;

procedure TTPersonalCtrlHorarios.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexFieldNames := 'Nombre';
  list_Tit(salida);

  tperso.First;
  while not tperso.EOF do Begin
    // Ordenado por Código
    if (ent_excl = 'E') and (orden = 'C') then
      if (tperso.FieldByName('nrodoc').AsString >= iniciar) and (tperso.FieldByName('nrodoc').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'C') then
      if (tperso.FieldByName('nrodoc').AsString < iniciar) or (tperso.FieldByName('nrodoc').AsString > finalizar) then List_linea(salida);
    // Ordenado Alfabéticamente
    if (ent_excl = 'E') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
    if (ent_excl = 'X') and (orden = 'A') then
      if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

    tperso.Next;
  end;
  List.FinList;

  tperso.IndexFieldNames := 'Nrodoc';
  tperso.First;
end;

procedure TTPersonalCtrlHorarios.BuscarPorNroDocumento(xexpr: string);
// Objetivo...: buscar por código
begin
  tperso.IndexFieldNames := 'Nrodoc';
  tperso.FindNearest([xexpr]);
end;

procedure TTPersonalCtrlHorarios.BuscarPorNombre(xexpr: string);
// Objetivo...: buscar por nombre
begin
  tperso.IndexFieldNames := 'Nombre';
  tperso.FindNearest([xexpr]);
end;

function  TTPersonalCtrlHorarios.verificarClavePersonal(xclave: String): Boolean;
// Objetivo...: verificar contraseña de usuario
Begin
  tpersonal.IndexFieldNames := 'Clave';
  if tpersonal.FindKey([xclave]) then Begin
     getDatos(tpersonal.FieldByName('nrodoc').AsString);
     Result := True;
  end else Result := False;
end;

function  TTPersonalCtrlHorarios.setPersonalAlf: TQuery;
// Objetivo...: Devolver la Nómina de Personal Ordenada Alfabeticamente
Begin
  Result := datosdb.tranSQL('SELECT nrodoc, nombre FROM personal ORDER BY Nombre'); 
end;

procedure TTPersonalCtrlHorarios.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tpersonal.Active then tpersonal.Open;
    tperso.FieldByName('cp').Visible := False; tperso.FieldByName('orden').Visible := False;
    tperso.FieldByName('nrodoc').DisplayLabel := 'Nro.Doc.'; tperso.FieldByName('nombre').DisplayLabel := 'Nombre'; tperso.FieldByName('direccion').DisplayLabel := 'Dirección';
  end;
  Inc(conexiones);
end;

procedure TTPersonalCtrlHorarios.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tpersonal);
    datosdb.closeDB(tperso);
  end;
end;

{===============================================================================}

function personal: TTPersonalCtrlHorarios;
begin
  if xpersonal = nil then
    xpersonal := TTPersonalCtrlHorarios.Create;
  Result := xpersonal;
end;

{===============================================================================}

initialization

finalization
  xpersonal.Free;

end.
