unit CPersonaDBExpress;

interface

uses CCodpostDBExpress, SysUtils, DBClient, CdbExpressBase, CUtiles;

type

//******************************************************************************
TTPersona = class(TObject)            // Superclase
  codigo, nombre, domicilio, codpost, orden, apellido: string;
  localidad, codprovin, provincia: string;
  tperso: TClientDataSet;
 public
  { Declaraciones Públicas }
  constructor Create(xcodigo, xnombre, xdomicilio, xcp, xorden: string);
  destructor  Destroy; override;

  function    getNombre(xid: string): string; overload;
  function    getCodprovin: string;
  function    getProvincia: string;

  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden: string); overload;
  procedure   Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xclave: string); overload;
  procedure   GrabarApNombre(xcodigo, xapellido, xnombre, xdomicilio, xcp, xorden: string); overload;
  procedure   Borrar(cod: string);
  function    Buscar(cod: string): boolean;
  function    Nuevo: string;
  procedure   getDatos(cod: string);
  procedure   getDatosApNombre(cod: string);
  function    VerificarCodpost(xcp, xorden: string): boolean;
 private
  { Declaraciones Privadas }
end;

function persona: TTPersona;

implementation

var
  xpersona: TTPersona = nil;

constructor TTPersona.Create(xcodigo, xnombre, xdomicilio, xcp, xorden: string);
// Persona - Superclase
begin
  inherited Create;
  codigo    := xcodigo;
  nombre    := xnombre;
  domicilio := xdomicilio;
  codpost   := xcp;
  orden     := xorden;

  localidad := '';
  codprovin := '';
  provincia := '';
end;

destructor TTPersona.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------

function TTPersona.getNombre(xid: string): string;
// Objetivo...: Retornar Nombre
begin
  if Buscar(xid) then Result := tperso.FieldByName('nombre').AsString else Result := '';
end;

function TTPersona.getCodprovin: string;
// Objetivo...: Retornar Código de Provincia
begin
  Result := codprovin;
end;

function TTPersona.getProvincia: string;
// Objetivo...: Retornar Provincia
begin
  Result := provincia;
end;

procedure TTPersona.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden: string);
// Objetivo...: Grabar Atributos Persona
begin
  if Buscar(xcodigo) then tperso.Edit else tperso.Append;
  tperso.Fields[0].AsString := xcodigo;
  tperso.Fields[1].AsString := TrimLeft(xnombre);
  tperso.Fields[2].AsString := TrimLeft(xdomicilio);
  if Length(Trim(xcp)) > 0 then Begin
    tperso.Fields[3].AsString := xcp;
    tperso.Fields[4].AsString := xorden;
  end;
  try
    tperso.Post;
  except
    tperso.Cancel
  end;
  tperso.ApplyUpdates(-1);
end;

procedure TTPersona.Grabar(xcodigo, xnombre, xdomicilio, xcp, xorden, xclave: string);
// Objetivo...: Grabar Atributos Persona - Confidenciales
begin
  if Buscar(xcodigo) then tperso.Edit else tperso.Append;
  tperso.Fields[0].AsString := xcodigo;
  tperso.Fields[1].AsString := xnombre;
  tperso.Fields[2].AsString := xdomicilio;
  if Length(Trim(xcp)) > 0 then Begin
    tperso.Fields[3].AsString := xcp;
    tperso.Fields[4].AsString := xorden;
  end;
  tperso.Fields[5].AsString := xclave;
  try
    tperso.Post; tperso.Refresh;
  except
    tperso.Cancel;
  end;
  tperso.ApplyUpdates(-1);
end;

procedure TTPersona.GrabarApNombre(xcodigo, xapellido, xnombre, xdomicilio, xcp, xorden: string);
// Objetivo...: Grabar Atributos Persona - Confidenciales
begin
  if Buscar(xcodigo) then tperso.Edit else tperso.Append;
  tperso.Fields[0].AsString := xcodigo;
  tperso.Fields[1].AsString := xapellido;
  tperso.Fields[2].AsString := xnombre;
  tperso.Fields[3].AsString := xdomicilio;
  if Length(Trim(xcp)) > 0 then Begin
    tperso.Fields[4].AsString := xcp;
    tperso.Fields[5].AsString := xorden;
  end;
  try
    tperso.Post;
  except
    tperso.Cancel;
  end;
  tperso.ApplyUpdates(-1);
end;

procedure TTPersona.Borrar(cod: string);
//Objetivo...: Eliminar un Objeto de la Superclase Persona
begin
  if Buscar(cod) then Begin
    tperso.Delete;
    tperso.ApplyUpdates(-1);
  end;
end;

function TTPersona.Buscar(cod: string): boolean;
//Objetivo...: Buscar el Objeto solicitado
begin
  tperso.IndexFieldNames := tperso.Fields[0].FieldName;
  if not tperso.Active then tperso.Open;
  tperso.Refresh;
  if tperso.FindKey([cod]) then Result := True else Result := False;
end;

procedure  TTPersona.getDatos(cod: string);
// Objetivo...: Cargar/Inicializar los Atributos de la Superclase
begin
  if Buscar(cod) then
    begin
      codigo    := tperso.Fields[0].AsString;
      nombre    := tperso.Fields[1].AsString;
      domicilio := tperso.Fields[2].AsString;
      codpost   := tperso.Fields[3].AsString;
      orden     := tperso.Fields[4].AsString;

      if Length(Trim(codpost)) > 0 then
        begin
          cpost.getDatos(codpost, orden);  // Instaciamos los Objetos de la Clase Códigos Postales
          localidad := cpost.Localidad;
          codprovin := cpost.Codprovin;
          provincia := cpost.Desprovin;
        end;
    end
   else
    begin
      codigo := ''; nombre := ''; domicilio := ''; codpost := ''; orden := '';   localidad := ''; codprovin := ''; provincia := '';
    end;
end;

procedure  TTPersona.getDatosApnombre(cod: string);
// Objetivo...: Cargar/Inicializar los Atributos de la Superclase
begin
  if Buscar(cod) then
    begin
      codigo    := tperso.Fields[0].AsString;
      apellido  := tperso.Fields[1].AsString;
      nombre    := tperso.Fields[2].AsString;
      domicilio := tperso.Fields[3].AsString;
      codpost   := tperso.Fields[4].AsString;
      orden     := tperso.Fields[5].AsString;

      if Length(Trim(codpost)) > 0 then
        begin
          cpost.getDatos(codpost, orden);  // Instaciamos los Objetos de la Clase Códigos Postales
          localidad := cpost.Localidad;
          codprovin := cpost.Codprovin;
          provincia := cpost.Desprovin;
        end;
    end
   else
    begin
      codigo := ''; apellido := ''; nombre := ''; domicilio := ''; codpost := ''; orden := '';   localidad := ''; codprovin := ''; provincia := ''; apellido := '';
    end;
end;

function TTPersona.Nuevo: string;
// Objetivo...: Determinar el Código Siguiente
var
  i: string;
begin
  if tperso.IndexFieldNames <> tperso.Fields[0].FieldName then Begin
    i := tperso.IndexName;
    tperso.IndexFieldNames := tperso.Fields[0].FieldName;
  end;
  tperso.Last;
  if Length(Trim(tperso.Fields[0].AsString)) > 0 then  Result := IntToStr(StrToInt(Trim(tperso.Fields[0].AsString)) + 1) else Result := '1';
  if Length(Trim(i)) > 0 then tperso.IndexName := i;
end;

function TTPersona.VerificarCodpost(xcp, xorden: string): boolean;
// Objetivo...: Verificar una Clave Postal dada
begin
  if cpost.Buscar(xcp, xorden) then
    begin
      cpost.getDatos(xcp, xorden);  // Instaciamos los Objetos de la Clase Códigos Postales
      localidad := cpost.Localidad;
      codprovin := cpost.Codprovin;
      provincia := cpost.Desprovin;
      Result := True;
    end
  else
    Result := False;
end;

{===============================================================================}

function persona: TTPersona;
begin
  if xpersona = nil then
    xpersona := TTPersona.Create('', '', '', '', '');
  Result := xpersona;
end;

{===============================================================================}

initialization

finalization
  xpersona.Free;

end.
