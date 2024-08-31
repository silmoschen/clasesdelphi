unit CCEmpleadosDamevin;

interface

uses CPersona, CListar, CUtiles, SysUtils, DB, DBTables, CBDT, CIDBFM;

type

TTEmpleados = class(TTPersona)          // Clase TVendedor Heredada de Persona
  telefono, email: string;
  templeado     : TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create;
  destructor  Destroy; override;
  procedure   Grabar(xnrolegajo, xnombre, xdomicilio, xtelefono, xemail: string);
  function    Borrar(xnrolegajo: string): string;
  function    Buscar(xnrolegajo: string): boolean;
  procedure   getDatos(xnrolegajo: string);
  function    Nuevo: string;
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setEmpleadoedoresAlf: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
end;

function empleado: TTEmpleados;

implementation

var
  xempleado: TTEmpleados = nil;

constructor TTEmpleados.Create;
// Vendedor - Heredada de Persona
begin
  inherited Create('','', '', '', '');
  tperso := datosdb.openDB('empleados', 'nrolegajo');
  templeado := datosdb.openDB('empleadoh', 'nrolegajo');
end;

destructor TTEmpleados.Destroy;
begin
  inherited Destroy;
end;

procedure TTEmpleados.Grabar(xnrolegajo, xnombre, xdomicilio, xtelefono, xemail: string);
// Objetivo...: Grabar Atributos del empleado
begin
  if Buscar(xnrolegajo) then templeado.Edit else templeado.Append;
  templeado.FieldByName('nrolegajo').AsString := xnrolegajo;
  templeado.FieldByName('telefono').AsString  := xtelefono;
  templeado.FieldByName('email').AsString     := xemail;
  templeado.Post;
  // Actualizamos los Atributos de la Clase Persona
  inherited Grabar(xnrolegajo, xnombre, xdomicilio, '', '');  //* Metodo de la Superclase
end;

procedure  TTEmpleados.getDatos(xnrolegajo: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto empleado
begin
  inherited getDatos(xnrolegajo);  // Heredamos de la Superclase
  if Buscar(xnrolegajo) then
    begin
      telefono := templeado.FieldByName('telefono').AsString;
      email    := templeado.FieldByName('email').AsString;
    end
  else
    begin
      telefono := ''; email := '';
    end;
end;

function TTEmpleados.Borrar(xnrolegajo: string): string;
// Objetivo...: Eliminar un Instancia de empleado
begin
  if Buscar(xnrolegajo) then Begin
    inherited Borrar(xnrolegajo);  // Metodo de la Superclase Persona
    templeado.Delete;
    getDatos(templeado.FieldByName('nrolegajo').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
  end;
end;

function TTEmpleados.Buscar(xnrolegajo: string): boolean;
// Objetivo...: Verificar si Existe el empleado
begin
  inherited Buscar(xnrolegajo);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
  if templeado.FindKey([xnrolegajo]) then Result := True else Result := False;
end;

function TTEmpleados.Nuevo: string;
begin
  Result := inherited Nuevo;
end;

procedure TTEmpleados.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  templeado.FindKey([tperso.FieldByName('nrolegajo').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('nrolegajo').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(40, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(67, List.lineactual, templeado.FieldByName('telefono').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(80, List.lineactual, templeado.FieldByName('email').AsString, 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTEmpleados.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listar Datos de Provincias
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;

  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de empleadoes', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Id.      Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(40, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(67, List.lineactual, 'Teléfono', 3, 'Arial, cursiva, 8');
  List.Titulo(80, List.lineactual, 'E-mail', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('nrolegajo').AsString >= iniciar) and (tperso.FieldByName('nrolegajo').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('nrolegajo').AsString < iniciar) or (tperso.FieldByName('nrolegajo').AsString > finalizar) then List_linea(salida);
      // Ordenado Alfabéticamente
      if (ent_excl = 'E') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString >= iniciar) and (tperso.FieldByName('nombre').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'A') then
        if (tperso.FieldByName('nombre').AsString < iniciar) or (tperso.FieldByName('nombre').AsString > finalizar) then List_linea(salida);

      tperso.Next;
    end;
    List.FinList;

    tperso.IndexFieldNames := tperso.IndexFieldNames;
    tperso.First;
end;

function TTEmpleados.setempleadoedoresAlf: TQuery;
// Objetivo...: Devolver un set de empleadoes ordenados alfabeticamente
begin
  Result := datosdb.tranSQL('SELECT * FROM ' + tperso.TableName + ' ORDER BY nombre');
end;

procedure TTEmpleados.conectar;
// Objetivo...: conectar tablas de persistencia - soporte multiempresa
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not templeado.Active then templeado.Open;
  end;
  Inc(conexiones);
end;

procedure TTEmpleados.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones > 0 then Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(templeado);
  end;
end;

{===============================================================================}

function empleado: TTEmpleados;
begin
  if xempleado = nil then
    xempleado := TTEmpleados.Create;
  Result := xempleado;
end;

{===============================================================================}

initialization

finalization
  xempleado.Free;

end.
