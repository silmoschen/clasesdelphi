unit CContactos;

interface

uses CPersona, CCodpost, SysUtils, DB, DBTables, CUtiles, CListar, CIDBFM;

type

TTContactos = class(TTPersona) // Clase TSocio Heredada de Persona
  telefono1, telefono2, email: string;
  tabla2: TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono1, xtelefono2, xemail: string);
  destructor  Destroy; override;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono1, xtelefono2, xemail: string);
  procedure   Borrar(cod: string);
  function    Buscar(cod: string): boolean;

  procedure   getDatos(cod: string);

  function    getTelefono1: string;
  function    getTelefono2: string;
  function    getEmail: string;
  function    setContactos: TQuery; overload;
  function    setContactos(xnombre: string): TQuery; overload;
  function    NuevoContacto(xemail: string): string;

  procedure   conectar;
  procedure   desconectar;
 private
  { Declaraciones Privadas }
  conexiones: shortint;
end;

function contact: TTContactos;

implementation

var
  xcontact: TTContactos = nil;

constructor TTContactos.Create(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono1, xtelefono2, xemail: string);
// Vendedor - Heredada de Persona
begin
  inherited Create(xcodigo, xnombre, xdomicilio, xcp, xorden);
  telefono1 := xtelefono1;
  telefono2 := xtelefono2;
  email     := xemail;

  tperso    := datosdb.openDB('contactos', 'Id');
  tabla2    := datosdb.openDB('contactoh', 'Id');
end;

destructor TTContactos.Destroy;
begin
  inherited Destroy;
end;

function TTContactos.getTelefono1: string;
begin
  Result := telefono1;
end;

function TTContactos.getTelefono2: string;
begin
  Result := telefono2;
end;

function TTContactos.getEmail: string;
begin
  Result := email;
end;

procedure TTContactos.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono1, xtelefono2, xemail: string);
// Objetivo...: Grabar Atributos de Vendedores
var
  idc: string;
begin
  // Verificamos que el contacto No Exista
  idc := NuevoContacto(xemail);
  if Buscar(idc) then tabla2.Edit else tabla2.Append;
  tabla2.FieldByName('id').AsString        := idc;
  tabla2.FieldByName('telefono1').AsString := xtelefono1;
  tabla2.FieldByName('telefono2').AsString := xtelefono2;
  tabla2.FieldByName('email').AsString     := xemail;
  tabla2.Post;
  // Actualizamos los Atributos de la Clase Persona
  inherited Grabar(idc, xnombre, xdomicilio, xcp, xorden);  //* Metodo de la Superclase
end;

procedure  TTContactos.getDatos(cod: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  tabla2.Refresh;
  inherited getDatos(cod);  // Heredamos de la Superclase
  if Buscar(cod) then
    begin
      telefono1 := tabla2.FieldByName('telefono1').AsString;
      telefono2 := tabla2.FieldByName('telefono2').AsString;
      email     := tabla2.FieldByName('email').AsString;
    end
  else
    begin
      telefono1 := ''; telefono2 := ''; email := '';
    end;
end;

procedure TTContactos.Borrar(cod: string);
// Objetivo...: Eliminar un Instancia de Vendedor
var
  i: integer; xiact: string;
  r: TQuery;
begin
  i := 0;
  if Buscar(cod) then
    begin
      inherited Borrar(cod);  // Metodo de la Superclase Persona
      tabla2.Delete;
    end;
  // Ahora, renumeramos el id de los contactos restantes
  r := setContactos;
  r.Open; r.First;
  while not r.EOF do
    begin
      Inc(i); xiact := utiles.sLlenarIzquierda(IntToStr(i), 4, '0');
      if tperso.FindKey([r.FieldByName('id').AsString]) then
        begin
          tperso.Edit;
          tperso.FieldByName('id').AsString := xiact;
          try
            tperso.Post;
          except
            tperso.Cancel;
          end;
        end;
      if tabla2.FindKey([r.FieldByName('id').AsString]) then
        begin
          tabla2.Edit;
          tabla2.FieldByName('id').AsString := xiact;
          try
            tabla2.Post;
          except
            tabla2.Cancel;
          end;
        end;

      r.Next;
    end;
  r.Close;
end;

function TTContactos.Buscar(cod: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
 inherited Buscar(cod);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
 if tabla2.FindKey([cod]) then Result := True else Result := False;
end;

function TTContactos.setContactos: TQuery;
// Objetivo...: retornar un set de registros con los datos de los contactos
begin
  Result := datosdb.tranSQL('SELECT id, nombre, domicilio, cp, orden, telefono1, telefono2, email FROM ' + tperso.TableName + ', contactoh WHERE ' + tperso.TableName + '.id = contactoh.id ORDER BY nombre');
end;

function TTContactos.setContactos(xnombre: string): TQuery;
// Objetivo...: retornar un set de registros con los datos de los contactos que cumplan con los caracteres ingresados para el nombre
begin
  if xnombre = '*' then Result := setContactos else   // Todos
    Result := datosdb.tranSQL('SELECT id, nombre, domicilio, cp, orden, telefono1, telefono2, email FROM ' + tperso.TableName + ', contactoh WHERE ' + tperso.TableName + '.id = contactoh.id AND nombre LIKE ' + '''' + '%' + xnombre + '%' + '''' + ' ORDER BY nombre');
end;

function TTContactos.NuevoContacto(xemail: string): string;
// Objetivo...: Verificar un contacto, por medio de la direccion de e-mail
var
  nc: string;
begin
  tabla2.IndexName := 'email';
  if tabla2.FindKey([xemail]) then nc := tabla2.FieldByName('id').AsString else nc := Nuevo;
  tabla2.IndexFieldNames := 'id';
  Result := nc;
end;

procedure   TTContactos.conectar;
begin
  if conexiones = 0 then Begin
    if not tperso.Active then tperso.Open;
    if not tabla2.Active then tabla2.Open;
  end;
  Inc(conexiones);
end;

procedure   TTContactos.desconectar;
begin
  Dec(conexiones);
  if conexiones = 0 then Begin
    datosdb.closeDB(tabla2);
    datosdb.closeDB(tperso);
  end;
end;

{===============================================================================}

function contact: TTContactos;
begin
  if xcontact = nil then
    xcontact := TTContactos.Create('', '', '', '', '', '', '', '');
  Result := xcontact;
end;

{===============================================================================}

initialization

finalization
  xcontact.Free;

end.
