unit CVendedor;

interface

uses CPersona, SysUtils, DB, DBTables, tablas;

type

TTVendedor = class(TTPersona)          // Clase TVendedor Heredada de Persona
  telefono, categoria: string;
  tabla1, tabla2     : TTable;         // Tablas para la Persistencia de Objetos
 public
  { Declaraciones Públicas }
  constructor Crear(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcategoria: string);
  function    Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcategoria: string): boolean;
  function    Borrar(cod: string): string;
  function    Buscar(cod: string): boolean;

  procedure   getDatos(cod: string);
  function    Nuevo: string;

  function    getTelefono: string;
  function    getCategoria: string;
  procedure   cerrar;
 private
  { Declaraciones Privadas }
  conexiones: integer;            // Control de conexiones Abiertas
end;

implementation

constructor TTVendedor.Crear(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcategoria: string);
// Vendedor - Heredada de Persona
begin
  inherited Crear(xcodigo, xnombre, xdomicilio, xcp, xorden);  // Constructor de la Superclase
  telefono  := xtelefono;
  categoria := xcategoria;

  tabla1    := MD.vendedor;  // Atributos estáticos
  tabla2    := MD.vendedh;
  if conexiones = 0 then
    begin
      tabla1.Open;  // Tablas de Persistencia
      tabla2.Open;
    end;
  Inc(conexiones);  // Control de Conexiones Activas
end;

procedure TTVendedor.cerrar;
begin
  Dec(conexiones);        // Disminuímos el Número de Conexiones Abiertas
  if conexiones = 0 then  // No hay nadie conectado a las tablas
    begin
      tabla1.Close;
      tabla2.Close;
      Destroy;
    end;
end;

//------------------------------------------------------------------------------

function TTVendedor.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xtelefono, xcategoria: string): boolean;
// Objetivo...: Grabar Atributos de Vendedores
begin
  try
    if Buscar(codigo) then tabla2.Edit else tabla2.Append;
    tabla2.FieldByName('codvend').Value   := xcodigo;
    tabla2.FieldByName('telefono').Value  := xtelefono;
    tabla2.FieldByName('categoria').Value := xcategoria;
    tabla2.Post;
    // Actualizamos los Atributos de la Clase Persona
    inherited Grabar(tabla1, xcodigo, xnombre, xdomicilio, xcp, xorden);  //* Metodo de la Superclase
    Result := True;
  finally
    Result := False;
  end;
end;

procedure  TTVendedor.getDatos(cod: string);
// Objetivo...: Obtener/Inicializar los Atributos para un objeto Vendedor
begin
  inherited getDatos(tabla1, cod);  // Heredamos de la Superclase}
  if Buscar(cod) then
    begin
      telefono  := tabla2.FieldByName('telefono').Value;
      categoria := tabla2.FieldByName('categoria').Value;
    end
  else
    begin
      telefono := ''; categoria := '';
    end;
end;

function TTVendedor.Borrar(cod: string): string;
// Objetivo...: Eliminar un Instancia de Vendedor
begin
  try
    if Buscar(cod) then
      begin
        inherited Borrar(tabla1, cod);  // Metodo de la Superclase Persona
        tabla2.Delete;
        getDatos(tabla2.FieldByName('codvend').Value);  // Fijamos los Atributos Siguientes al Objeto Borrado
      end;
  except
  end;
end;

function TTVendedor.Buscar(cod: string): boolean;
// Objetivo...: Verificar si Existe el Vendedor
begin
  if tabla2.FindKey([cod]) then
    begin
      inherited Buscar(tabla1, cod);  // Método de la Superclase (Sincroniza los Valores de las Tablas)
      Result := True;
    end
  else
    Result := False;
end;

function TTVendedor.Nuevo: string;
begin
  Result := inherited Nuevo(tabla1);
end;

function TTVendedor.getTelefono: string;
begin
  Result := telefono;
end;

function TTVendedor.getCategoria: string;
begin
  Result := categoria;
end;

end.
