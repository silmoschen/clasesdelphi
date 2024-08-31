unit CBuscar;

interface

uses SysUtils, DB, DBTables, tablas;

type

//******************************************************************************
TTPersona = class(TObject)            // Superclase
  codigo, nombre, domicilio, codpost, orden: string;
 public
  { Declaraciones Públicas }
  constructor Crear(xcodigo, xnombre, xdomicilio, xcp, xorden: string);
  function    getCodigo: string;
  function    getNombre: string;
  function    getDomicilio: string;
  function    getCodpost: string;
  function    getOrden: string;

  function    Grabar(tabla: TTable; xcodigo, xnombre, xdomicilio, xcp, xorden: string): boolean;
  function    Borrar(tabla: TTable; cod: string): boolean;
  function    Buscar(tabla: TTable; cod: string): boolean;
  function    Nuevo(tabla: TTable): string;
  procedure   getDatos(tabla: TTable; cod: string);
 private
  { Declaraciones Privadas }
end;

implementation

constructor TTPersona.Crear(xcodigo, xnombre, xdomicilio, xcp, xorden: string);
// Persona - Superclase
begin
  codigo    := xcodigo;
  nombre    := xnombre;
  domicilio := xdomicilio;
  codpost   := xcp;
  orden     := xorden;
end;

//------------------------------------------------------------------------------

function TTPersona.getCodigo: string;
begin
  Result := codigo;
end;

function TTPersona.getNombre: string;
begin
  Result := nombre;
end;

function TTPersona.getDomicilio: string;
begin
  Result := domicilio;
end;

function TTPersona.getCodpost: string;
begin
  Result := codpost;
end;

function TTPersona.getOrden: string;
begin
  Result := orden;
end;

function TTPersona.Grabar(tabla: TTable; xcodigo, xnombre, xdomicilio, xcp, xorden: string): boolean;
// Objetivo...: Grabar Atributos Persona
begin
  try
    if Buscar(tabla, codigo) then tabla.Edit else tabla.Append;
    tabla.Fields[0].Value := codigo;
    tabla.Fields[1].Value := nombre;
    tabla.Fields[2].Value := domicilio;
    tabla.Fields[3].Value := codpost;
    tabla.Fields[4].Value := orden;
    tabla.Post;
    Result := True;
  except
    Result := False;
  end;
end;

function TTPersona.Borrar(tabla: TTable; cod: string): boolean;
//Objetivo...: Eliminar un Objeto de la Superclase Persona
begin
  try
    if Buscar(tabla, cod) then
      begin
        tabla.Delete;
        Result := True;
      end
    except
      Result := False;
    end;
end;

function TTPersona.Buscar(tabla: TTable; cod: string): boolean;
//Objetivo...: Buscar el Objeto solicitado
begin
  if tabla.FindKey([cod]) then Result := True else Result := False;
end;

procedure  TTPersona.getDatos(tabla: TTable; cod: string);
// Objetivo...: Cargar/Inicializar los Atributos de la Superclase
begin
  if Buscar(tabla, cod) then
    begin
      codigo    := tabla.Fields[0].Value;
      nombre    := tabla.Fields[1].Value;
      domicilio := tabla.Fields[2].Value;
      codpost   := tabla.Fields[3].Value;
      orden     := tabla.Fields[4].Value;
    end
   else
    begin
      codigo := ''; nombre := ''; domicilio := ''; codpost := ''; orden := '';
    end;
end;

function TTPersona.Nuevo(tabla: TTable): string;
begin
  tabla.Last;
  Result := IntToStr(tabla.Fields[0].AsInteger + 1);
end;

end.
