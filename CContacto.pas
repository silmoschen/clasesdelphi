unit CContacto;

interface

uses CBDT, CPersona, SysUtils, DB, DBTables, CUtiles, CIDBFM, CListar;

type

TTContacto = class(TTPersona)          // Clase TVendedor Heredada de Persona
  tel1, email, fecha, hora: string;
  tabla2: TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xtel1, xemail: string);
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtel1, xemail: string);
  function    Borrar(cod: string): string;
  function    Buscar(cod: string): boolean;
  procedure   getDatos(cod: string);
  procedure   Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
  function    setContactos: TQuery;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
  procedure   List_linea(salida: char);
  procedure   List_Tit(salida: char);
end;

function Contacto: TTContacto;

implementation

var
  xContacto: TTContacto = nil;

constructor TTContacto.Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xtel1, xemail: string);
// Vendedor - Heredada de Persona
begin
  inherited Create(xcodigo, xnombre, xdomicilio, xcp, xorden);  // Constructor de la Superclase
  tel1   := xtel1;
  email  := xemail;
  tperso := datosdb.openDB('contacto', 'codcont');
  tabla2 := datosdb.openDB('contacth', 'codcont');
end;

destructor TTContacto.Destroy;
begin
  inherited Destroy;
end;

procedure TTContacto.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtel1, xemail: string);
// Objetivo...: Grabar Atributos de Vendedores
begin
  if Buscar(xcodigo) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('codcont').AsString  := xcodigo;
  tabla2.FieldByName('telefono').AsString := xtel1;
  tabla2.FieldByName('email').AsString    := xemail;
  try
    tabla2.Post;
  except
    tabla2.Cancel;
  end;
  // Actualizamos los Atributos de la Clase Persona
  inherited Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden);  //* Metodo de la Superclase
end;

procedure  TTContacto.getDatos(cod: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  tabla2.Refresh;
  inherited getDatos(cod);  // Heredamos de la Superclase
  if Buscar(cod) then
    begin
      tel1   := tabla2.FieldByName('telefono').AsString;
      email  := tabla2.FieldByName('email').AsString;
    end
  else
    begin
      tel1 := ''; email := '';
    end;
end;

function TTContacto.Borrar(cod: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(cod) then
      begin
        inherited Borrar(cod);  // Metodo de la Superclase Persona
        tabla2.Delete;
        getDatos(tabla2.FieldByName('codcont').AsString);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTContacto.Buscar(cod: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if tperso.IndexFieldNames <> 'codcont' then tperso.IndexFieldNames := 'codcont';
  if tabla2.IndexFieldNames <> 'codcont' then tabla2.IndexFieldNames := 'codcont';
  inherited Buscar(cod);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
  if tabla2.FindKey([cod]) then Result := True else Result := False;
end;

procedure TTContacto.List_Tit(salida: char);
// Objetivo...: Listar una Línea
begin
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' Listado de Contactos', 1, 'Arial, negrita, 14');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 5');
  List.Titulo(0, 0, 'Cód.  Apellido y Nombre', 1, 'Arial, cursiva, 8');
  List.Titulo(38, List.lineactual, 'Dirección', 2, 'Arial, cursiva, 8');
  List.Titulo(63, List.lineactual, 'telefono', 3, 'Arial, cursiva, 8');
  List.Titulo(85, List.lineactual, 'E-mail', 4, 'Arial, cursiva, 8');
  List.Titulo(0, 0, List.linealargopagina(salida), 1, 'Arial, normal, 11');
  List.Titulo(0, 0, ' ', 1, 'Arial, negrita, 8');
end;

procedure TTContacto.List_linea(salida: char);
// Objetivo...: Listar una Línea
begin
  tabla2.FindKey([tperso.FieldByName('codcont').AsString]);   // Sincronizamos las tablas
  List.Linea(0, 0, tperso.FieldByName('codcont').AsString + '  ' + tperso.FieldByName('nombre').AsString, 1, 'Arial, normal, 8', salida, 'N');
  List.Linea(38, List.lineactual, tperso.FieldByName('direccion').AsString, 2, 'Arial, normal, 8', salida, 'N');
  List.Linea(63, List.lineactual, tabla2.FieldByName('telefono').AsString, 3, 'Arial, normal, 8', salida, 'N');
  List.Linea(85, List.lineactual, tabla2.FieldByName('email').AsString, 4, 'Arial, normal, 8', salida, 'S');
end;

procedure TTContacto.Listar(orden, iniciar, finalizar, ent_excl: string; salida: char);
// Objetivo...: Listado de la clase
begin
  if orden = 'A' then tperso.IndexName := tperso.IndexDefs.Items[1].Name;
  list_Tit(salida);

  tperso.First;
  while not tperso.EOF do
    begin
      // Ordenado por Código
      if (ent_excl = 'E') and (orden = 'C') then
        if (tperso.FieldByName('codcont').AsString >= iniciar) and (tperso.FieldByName('codcont').AsString <= finalizar) then List_linea(salida);
      if (ent_excl = 'X') and (orden = 'C') then
        if (tperso.FieldByName('codcont').AsString < iniciar) or (tperso.FieldByName('codcont').AsString > finalizar) then List_linea(salida);
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

function  TTContacto.setContactos: TQuery;
// Objetivo...: devolver un set de contactos por fecha
begin
  Result := datosdb.tranSQL('SELECT codcont, nombre, direccion, telefono, email FROM contacto, contacth WHERE contacto.codcont = contacth.codcont ORDER BY nombre');
end;

procedure TTContacto.conectar;
// Objetivo...: cerrar tablas de persistencia
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure TTContacto.desconectar;
// Objetivo...: cerrar tablas de persistencia
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tperso);
    datosdb.closeDB(tabla2);
  end;
end;

{===============================================================================}

function Contacto: TTContacto;
begin
  if xContacto = nil then
    xContacto := TTContacto.Create('', '', '', '', '', '', '');
  Result := xContacto;
end;

{===============================================================================}

initialization

finalization
  xContacto.Free;

end.
